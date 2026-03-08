#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  bash setup.sh --target <dir> --project-name <name> [options]

Options:
  --target <dir>          Target repository path. Default: current directory
  --project-name <name>   Human-readable project name
  --summary <text>        One-line product summary
  --stack <text>          Tech stack string
  --phase <text>          Current phase
  --deadline <text>       Next deadline
  --surfaces <csv>        Comma-separated surface ids. Default: core
  --main-branch <name>    Main branch name. Default: main
  --force                 Overwrite existing files from the kit
  -h, --help              Show help
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$ROOT_DIR/templates/repo"

TARGET_DIR="$(pwd)"
PROJECT_NAME=""
PROJECT_SUMMARY="Fill this in."
PROJECT_STACK="TypeScript / Python / Shell"
PROJECT_PHASE="initial bootstrap"
PROJECT_DEADLINE="TBD"
PROJECT_SURFACES="core"
MAIN_BRANCH="main"
FORCE=0

while [ "$#" -gt 0 ]; do
	case "$1" in
		--target)
			TARGET_DIR="${2:-}"
			shift 2
			;;
		--project-name)
			PROJECT_NAME="${2:-}"
			shift 2
			;;
		--summary)
			PROJECT_SUMMARY="${2:-}"
			shift 2
			;;
		--stack)
			PROJECT_STACK="${2:-}"
			shift 2
			;;
		--phase)
			PROJECT_PHASE="${2:-}"
			shift 2
			;;
		--deadline)
			PROJECT_DEADLINE="${2:-}"
			shift 2
			;;
		--surfaces)
			PROJECT_SURFACES="${2:-}"
			shift 2
			;;
		--main-branch)
			MAIN_BRANCH="${2:-}"
			shift 2
			;;
		--force)
			FORCE=1
			shift 1
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Unknown option: $1"
			usage
			exit 1
			;;
	esac
done

if [ -z "$PROJECT_NAME" ]; then
	echo "Missing required flag: --project-name"
	usage
	exit 1
fi

mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
TODAY="$(date +%Y-%m-%d)"
PROJECT_SLUG="$(printf '%s' "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')"

copy_file() {
	local src="$1"
	local dest="$2"

	if [ -e "$dest" ] && [ "$FORCE" -ne 1 ]; then
		echo "[setup] keep existing: ${dest#$TARGET_DIR/}"
		return 0
	fi

	mkdir -p "$(dirname "$dest")"
	cp "$src" "$dest"
	echo "[setup] wrote: ${dest#$TARGET_DIR/}"
}

copy_tree() {
	local src_root="$1"
	local rel=""
	while IFS= read -r -d '' file; do
		rel="${file#$src_root/}"
		copy_file "$file" "$TARGET_DIR/$rel"
	done < <(find "$src_root" -type f -print0)
}

replace_placeholders() {
	local file="$1"
	python3 - "$file" "$PROJECT_NAME" "$PROJECT_SLUG" "$PROJECT_SUMMARY" "$PROJECT_STACK" "$PROJECT_PHASE" "$PROJECT_DEADLINE" "$MAIN_BRANCH" "$TODAY" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
replacements = {
    "__PROJECT_NAME__": sys.argv[2],
    "__PROJECT_SLUG__": sys.argv[3],
    "__PROJECT_SUMMARY__": sys.argv[4],
    "__PROJECT_STACK__": sys.argv[5],
    "__PROJECT_PHASE__": sys.argv[6],
    "__PROJECT_DEADLINE__": sys.argv[7],
    "__MAIN_BRANCH__": sys.argv[8],
    "__TODAY__": sys.argv[9],
}
for old, new in replacements.items():
    text = text.replace(old, new)
path.write_text(text)
PY
}

write_context_config() {
	local config_path="$TARGET_DIR/context-kit.json"
	local surface_json
	surface_json="$(python3 - "$PROJECT_SURFACES" <<'PY'
import json
import sys

surfaces = [item.strip() for item in sys.argv[1].split(",") if item.strip()]
if not surfaces:
    surfaces = ["core"]

items = []
for index, surface in enumerate(surfaces):
    default_route = "/" if index == 0 else f"/{surface}"
    items.append({
        "id": surface,
        "label": f"{surface.title()} surface",
        "summary": f"Primary responsibilities for the {surface} surface.",
        "spec": f"docs/product-specs/{surface}.md",
        "routes": [default_route],
        "stores": [],
        "apis": [],
    })
print(json.dumps(items, indent=2))
PY
)"

	cat > "$config_path" <<EOF
{
  "version": 1,
  "project": {
    "name": "$PROJECT_NAME",
    "slug": "$PROJECT_SLUG",
    "summary": "$PROJECT_SUMMARY",
    "stack": "$PROJECT_STACK",
    "phase": "$PROJECT_PHASE",
    "deadline": "$PROJECT_DEADLINE"
  },
  "git": {
    "mainBranch": "$MAIN_BRANCH"
  },
  "discovery": {
    "routesDir": "src/routes",
    "storesDir": "src/lib/stores",
    "apiDir": "src/routes/api"
  },
  "claude": {
    "enabled": true,
    "settingsPath": ".claude/settings.json",
    "riskyPathHints": [
      "src/auth",
      "src/persistence",
      "infra"
    ]
  },
  "surfaces": $surface_json,
  "harness": {
    "pages": [
      "/"
    ],
    "apis": [],
    "browserPages": [
      "/"
    ]
  },
	  "coordination": {
	    "requireClaimOnFeatureBranches": true,
	    "requirePathsOnFeatureBranches": true,
	    "featureBranchPrefixes": [
	      "codex/"
	    ],
	    "defaultLeaseMinutes": 240,
	    "lockStaleMinutes": 15,
	    "failOnExpiredClaims": true,
	    "failOnPathOverlap": true,
	    "failOnUnscopedSurfaceOverlap": true,
	    "sharedPathPrefixes": [
      "docs/AGENT_WATCH_LOG.md",
      "docs/generated/",
      ".agent-context/"
	    ]
	  },
	  "registry": {
	    "enabled": true,
	    "manifestPath": "docs/generated/context-registry.json",
	    "publicBaseUrl": "",
	    "publishTags": [
	      "$PROJECT_SLUG",
	      "context-kit"
	    ],
	    "searchKinds": [
	      "surface",
	      "doc",
	      "command",
	      "retrieval",
	      "agent",
	      "tool"
	    ]
	  },
	  "agents": {
	    "enabled": true,
	    "dir": "agents",
	    "catalogPath": "docs/generated/agent-catalog.json",
	    "defaultSurface": "$(printf '%s' "$PROJECT_SURFACES" | cut -d',' -f1 | tr -d ' ')"
	  },
	  "tools": {
	    "enabled": true,
	    "dir": "tools",
	    "catalogPath": "docs/generated/tool-catalog.json",
	    "defaultSurface": "$(printf '%s' "$PROJECT_SURFACES" | cut -d',' -f1 | tr -d ' ')"
	  },
	  "telemetry": {
	    "enabled": true,
	    "runsDir": ".agent-context/telemetry/runs",
	    "eventsDir": ".agent-context/telemetry/events",
	    "activeDir": ".agent-context/telemetry/active",
	    "lockPath": ".agent-context/telemetry/telemetry.lock",
	    "lockStaleMinutes": 5,
	    "reportPath": "docs/generated/agent-usage-report.json",
	    "defaults": {
	      "taskComplexity": "moderate",
	      "skillLevel": "experienced",
	      "purpose": "product-development",
	      "autonomy": "assisted"
	    }
	  },
	  "retrieval": {
	    "enabled": true,
	    "includePaths": [
	      "README.md",
	      "AGENTS.md",
	      "ARCHITECTURE.md",
	      "docs/SYSTEM_INTENT.md",
	      "docs/CONTEXT_ENGINEERING.md",
	      "docs/CONTEXT_EVALUATION.md",
	      "docs/CONTEXT_PLATFORM.md",
	      "docs/CONTEXTUAL_RETRIEVAL.md",
	      "docs/AGENT_FACTORY.md",
	      "docs/TOOL_DESIGN.md",
	      "docs/AGENT_OBSERVABILITY.md",
	      "docs/MULTI_AGENT_COORDINATION.md",
	      "docs/SANDBOX_POLICY.md",
	      "docs/DESIGN.md",
	      "docs/ENGINEERING.md",
	      "docs/PLANS.md",
	      "docs/PRODUCT_SENSE.md",
	      "docs/QUALITY_SCORE.md",
	      "docs/RELIABILITY.md",
	      "docs/SECURITY.md",
	      "docs/HARNESS.md",
	      "agents/",
	      "tools/",
	      "docs/design-docs/",
	      "docs/product-specs/"
	    ],
	    "excludePaths": [
	      "docs/archive/",
	      "docs/generated/",
	      ".agent-context/"
	    ],
	    "chunkWords": 120,
	    "overlapWords": 30,
	    "defaultTopK": 5,
	    "contextualWeight": 0.65,
	    "rawWeight": 0.35,
	    "pathBoost": 0.8,
	    "headingBoost": 0.5,
	    "surfaceBoost": 0.75,
	    "indexPath": "docs/generated/contextual-retrieval-index.json"
	  },
	  "sandbox": {
	    "enabled": true,
	    "allowReadPaths": [
	      "README.md",
	      "AGENTS.md",
	      "ARCHITECTURE.md",
	      "context-kit.json",
	      "docs/",
	      "agents/",
	      "tools/",
	      "src/",
	      "package.json"
	    ],
	    "allowWritePaths": [
	      ".agent-context/",
	      "docs/generated/",
	      "scripts/dev/"
	    ],
	    "allowNetworkHosts": [
	      "127.0.0.1",
	      "localhost"
	    ],
	    "denyCommandPrefixes": [
	      "rm -rf",
	      "git reset --hard",
	      "git checkout --",
	      "curl | sh"
	    ],
	    "requireApprovalCommandPrefixes": [
	      "git push",
	      "npm publish",
	      "docker push"
	    ],
	    "credentialEnvAllowlist": []
	  },
	  "evaluation": {
	    "targets": {
	      "smallMapReductionVsCanonicalPct": 40,
      "smallMapReductionVsAllDocsPct": 55,
      "surfaceReductionVsAllDocsPct": 50,
      "smallMapMaxApproxTokens": 3800,
      "smallMapMaxFiles": 6,
      "canonicalMaxApproxTokens": 12000,
      "noiseRateMaxPct": 10
    },
	    "benchmark": {
	      "runs": 3,
	      "warmupRuns": 1,
	      "mode": "smoke",
	      "maxDurationCvPct": 15
	    },
	    "ab": {
	      "minComparisons": 1,
	      "targetDocsBeforeFirstEdit": 6,
	      "targetResumeLatencyMinutes": 3
	    }
	  },
	  "commands": {
    "check": "",
    "build": "",
    "gate": ""
  }
}
EOF
	echo "[setup] wrote: context-kit.json"
}

write_agent_manifests() {
	python3 - "$TARGET_DIR" "$PROJECT_SURFACES" "$FORCE" <<'PY'
from pathlib import Path
import json
import sys

target = Path(sys.argv[1])
surfaces = [item.strip() for item in sys.argv[2].split(",") if item.strip()]
force = sys.argv[3] == "1"
surface = surfaces[0] if surfaces else "core"
agents_dir = target / "agents"
agents_dir.mkdir(parents=True, exist_ok=True)

presets = [
    {
        "id": "planner",
        "name": "Planner",
        "role": "planner",
        "summary": "Plans and routes ambiguous work before implementation begins.",
        "surfaces": [surface],
        "reads": [
            "README.md",
            "AGENTS.md",
            "docs/README.md",
            "ARCHITECTURE.md",
            "docs/SYSTEM_INTENT.md",
            "docs/PLANS.md",
            "docs/CONTEXT_ENGINEERING.md",
            "docs/AGENT_FACTORY.md",
        ],
        "writes": [
            "docs/exec-plans/active/",
            ".agent-context/",
            "docs/AGENT_WATCH_LOG.md",
        ],
        "outputs": ["execution-plan", "checkpoint"],
        "handoff": "checkpoint",
        "prompt": "Break requested work into minimal execution steps, route the next canonical docs, and record plan-level handoff state.",
        "public": True,
    },
    {
        "id": "implementer",
        "name": "Implementer",
        "role": "implementer",
        "summary": "Implements code changes against declared context and ownership boundaries.",
        "surfaces": [surface],
        "reads": [
            "README.md",
            "AGENTS.md",
            "docs/README.md",
            "ARCHITECTURE.md",
            "docs/DESIGN.md",
            "docs/ENGINEERING.md",
            "docs/PRODUCT_SENSE.md",
            "docs/CONTEXT_ENGINEERING.md",
            "docs/AGENT_FACTORY.md",
        ],
        "writes": [
            "src/",
            ".agent-context/",
            "docs/AGENT_WATCH_LOG.md",
        ],
        "outputs": ["code-change", "brief"],
        "handoff": "brief",
        "prompt": "Implement scoped changes against the canonical docs, keep edits inside owned paths, and leave a concise resume brief.",
        "public": True,
    },
    {
        "id": "reviewer",
        "name": "Reviewer",
        "role": "reviewer",
        "summary": "Reviews work for drift, risk, and boundary compliance.",
        "surfaces": [surface],
        "reads": [
            "README.md",
            "AGENTS.md",
            "docs/README.md",
            "docs/QUALITY_SCORE.md",
            "docs/RELIABILITY.md",
            "docs/SECURITY.md",
            "docs/CONTEXT_EVALUATION.md",
            "docs/AGENT_FACTORY.md",
        ],
        "writes": [
            ".agent-context/",
            "docs/AGENT_WATCH_LOG.md",
        ],
        "outputs": ["review-findings", "handoff"],
        "handoff": "handoff",
        "prompt": "Review changes for correctness, drift, and boundary violations, then leave a handoff artifact with findings or release status.",
        "public": True,
    },
]

for manifest in presets:
    path = agents_dir / f"{manifest['id']}.json"
    if force or not path.exists():
        path.write_text(json.dumps(manifest, indent=2) + "\n")
PY
	echo "[setup] wrote: agents/*.json"
}

write_tool_manifests() {
	python3 - "$TARGET_DIR" "$PROJECT_SURFACES" "$FORCE" <<'PY'
from pathlib import Path
import json
import sys

target = Path(sys.argv[1])
surfaces = [item.strip() for item in sys.argv[2].split(",") if item.strip()]
force = sys.argv[3] == "1"
surface = surfaces[0] if surfaces else "core"
tools_dir = target / "tools"
tools_dir.mkdir(parents=True, exist_ok=True)

presets = [
    {
        "id": "context-retrieve",
        "name": "Context Retrieve",
        "summary": "Query canonical docs through the contextual retrieval index when static routing is not enough.",
        "scope": "context-api",
        "surfaces": [surface],
        "reads": [
            "docs/generated/contextual-retrieval-index.json",
            "docs/CONTEXTUAL_RETRIEVAL.md",
        ],
        "writes": ["docs/generated/"],
        "inputs": [
            {"name": "query", "type": "string", "required": True, "description": "Natural-language retrieval query."},
            {"name": "surface", "type": "string", "required": False, "description": "Optional surface bias for ranking."},
        ],
        "outputs": [
            {"name": "results", "type": "json", "description": "Ranked retrieval results with scores and chunk excerpts."},
        ],
        "invocation": {"kind": "npm-script", "script": "retrieve:query"},
        "safety": {"sideEffects": "read-only", "approvalRequired": False},
        "public": True,
    },
    {
        "id": "registry-search",
        "name": "Registry Search",
        "summary": "Search surfaces, docs, agents, tools, and commands from the local context registry.",
        "scope": "context-api",
        "surfaces": [surface],
        "reads": [
            "docs/generated/context-registry.json",
            "docs/CONTEXT_PLATFORM.md",
        ],
        "writes": ["docs/generated/"],
        "inputs": [
            {"name": "query", "type": "string", "required": True, "description": "Lookup term."},
            {"name": "kind", "type": "string", "required": False, "description": "Optional kind filter such as agent, tool, doc, or surface."},
        ],
        "outputs": [
            {"name": "results", "type": "json", "description": "Matching manifest entries."},
        ],
        "invocation": {"kind": "npm-script", "script": "registry:query"},
        "safety": {"sideEffects": "read-only", "approvalRequired": False},
        "public": True,
    },
    {
        "id": "coord-claim",
        "name": "Coordination Claim",
        "summary": "Claim a scoped surface and path boundary before feature work begins.",
        "scope": "coordination",
        "surfaces": [surface],
        "reads": [
            "docs/MULTI_AGENT_COORDINATION.md",
            ".agent-context/coordination/",
        ],
        "writes": [".agent-context/coordination/"],
        "inputs": [
            {"name": "workId", "type": "string", "required": True, "description": "Stable work identifier."},
            {"name": "path", "type": "string", "required": True, "description": "Owned repo path prefix."},
        ],
        "outputs": [
            {"name": "claim", "type": "json", "description": "Stored claim manifest with lease metadata."},
        ],
        "invocation": {"kind": "npm-script", "script": "coord:claim"},
        "safety": {"sideEffects": "writes-generated", "approvalRequired": False},
        "public": True,
    },
]

for manifest in presets:
    path = tools_dir / f"{manifest['id']}.json"
    if force or not path.exists():
        path.write_text(json.dumps(manifest, indent=2) + "\n")
PY
	echo "[setup] wrote: tools/*.json"
}

write_surface_docs() {
	python3 - "$TARGET_DIR" "$PROJECT_SURFACES" "$FORCE" <<'PY'
from pathlib import Path
import sys

target = Path(sys.argv[1])
surfaces = [item.strip() for item in sys.argv[2].split(",") if item.strip()]
force = sys.argv[3] == "1"
if not surfaces:
    surfaces = ["core"]

docs = target / "docs" / "product-specs"
docs.mkdir(parents=True, exist_ok=True)

table_lines = [
    "# Product Specs",
    "",
    "This folder contains the canonical surface specs referenced by `docs/README.md` and `context-kit.json`.",
    "",
    "## Surface Specs",
    "",
]

for index, surface in enumerate(surfaces):
    route = "/" if index == 0 else f"/{surface}"
    spec_path = docs / f"{surface}.md"
    if force or not spec_path.exists():
        spec_path.write_text(
            "\n".join(
                [
                    f"# Surface Spec: {surface}",
                    "",
                    f"- Status: active",
                    f"- Canonical route entry: `{route}`",
                    f"- Surface ID: `{surface}`",
                    "",
                    "## Purpose",
                    f"Replace this placeholder with the real user-facing value and system role of `{surface}`.",
                    "",
                    "## Done Means",
                    "- Replace this with measurable outcomes for this surface.",
                    "- Replace this with the boundaries this surface must not violate.",
                    "",
                    "## Context Contracts",
                    "",
                    "### Routes",
                    f"- `{route}`",
                    "",
                    "### Stores",
                    "- none",
                    "",
                    "### APIs",
                    "- none",
                    "",
                    "## Deep Links",
                    "- `docs/DESIGN.md`",
                    "- `docs/ENGINEERING.md`",
                    "- Add design docs or active plans here as the surface evolves.",
                    "",
                ]
            )
        )
    table_lines.append(f"- `{surface}` -> `docs/product-specs/{surface}.md`")

    if index == 0:
        harness_pages = [route]
    else:
        harness_pages = []

(docs / "index.md").write_text("\n".join(table_lines) + "\n")
PY
	echo "[setup] wrote: docs/product-specs/*.md"
}

ensure_gitignore() {
	local gitignore="$TARGET_DIR/.gitignore"
	local lines=(
		".agent-context/"
		"context-kit.local.json"
		".codex/"
	)
	touch "$gitignore"
	for line in "${lines[@]}"; do
		if ! grep -Fqx "$line" "$gitignore"; then
			printf '%s\n' "$line" >> "$gitignore"
			echo "[setup] appended to .gitignore: $line"
		fi
	done
}

copy_tree "$TEMPLATE_DIR"

while IFS= read -r -d '' file; do
	replace_placeholders "$file"
done < <(find "$TARGET_DIR" -type f -name '*.md' -print0)

write_context_config
write_surface_docs
write_agent_manifests
write_tool_manifests
ensure_gitignore

chmod +x "$TARGET_DIR"/scripts/dev/*.sh || true
chmod +x "$TARGET_DIR"/.githooks/* || true
chmod +x "$TARGET_DIR"/.claude/hooks/*.sh || true

if command -v node >/dev/null 2>&1; then
	if [ "$FORCE" -eq 1 ]; then
		node "$TARGET_DIR/scripts/dev/inject-package-scripts.mjs" "$TARGET_DIR" --overwrite-managed
	else
		node "$TARGET_DIR/scripts/dev/inject-package-scripts.mjs" "$TARGET_DIR"
	fi
		(
			cd "$TARGET_DIR"
			node scripts/dev/refresh-generated-context.mjs
			node scripts/dev/refresh-context-retrieval.mjs
			node scripts/dev/refresh-agent-catalog.mjs
			node scripts/dev/refresh-tool-catalog.mjs
			node scripts/dev/refresh-agent-usage-report.mjs
			node scripts/dev/refresh-context-registry.mjs
			node scripts/dev/refresh-context-ab-report.mjs
			node scripts/dev/refresh-sandbox-policy-report.mjs
			node scripts/dev/refresh-doc-governance.mjs
			node scripts/dev/bootstrap-project-truth.mjs
			node scripts/dev/bootstrap-claude-compat.mjs
			node scripts/dev/refresh-generated-context.mjs
			node scripts/dev/refresh-context-retrieval.mjs
			node scripts/dev/refresh-context-registry.mjs
			node scripts/dev/refresh-doc-governance.mjs
			node scripts/dev/refresh-context-metrics.mjs
			node scripts/dev/refresh-context-value-demo.mjs
		)
else
	echo "[setup] node not found. Skipped package.json script injection."
fi

if git -C "$TARGET_DIR" rev-parse --show-toplevel >/dev/null 2>&1; then
	git -C "$TARGET_DIR" config core.hooksPath .githooks || true
	(
		cd "$TARGET_DIR"
		bash scripts/dev/bootstrap-git-config.sh || true
	)
	echo "[setup] configured git hooks path: .githooks"
fi

echo ""
echo "Context kit applied to: $TARGET_DIR"
echo "Next steps:"
echo "  1. Review context-kit.json"
echo "  2. Read docs/generated/project-truth-bootstrap.md and fill canonical docs with repo-specific truth"
echo "  3. Run: cd \"$TARGET_DIR\" && npm run adopt:bootstrap"
echo "  4. Run: cd \"$TARGET_DIR\" && npm run docs:refresh && npm run docs:check"
echo "  5. Run: cd \"$TARGET_DIR\" && npm run safe:hooks"
