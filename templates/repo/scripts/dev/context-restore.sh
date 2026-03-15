#!/usr/bin/env bash
set -euo pipefail

usage() {
	echo "Usage: bash scripts/dev/context-restore.sh --mode <resume|brief|handoff|context|files|list> [--branch <name>] [--work-id <id>] [--list]"
	echo ""
	echo "Modes:"
	echo "  --mode resume   show the active-work resume bundle (claim + state + artifacts)"
	echo "  --mode brief    show the compact branch/work brief"
	echo "  --mode handoff  show the fuller handoff artifact"
	echo "  --mode context  compatibility alias for --mode brief"
	echo "  --mode files    show file-recovery guidance only"
	echo "  --mode list     list available branch/work artifacts"
}

sanitize() {
	printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9._-]+/-/g; s/^-+|-+$//g'
}

extract_section() {
	local source="$1"
	local header="$2"
	[ -f "$source" ] || return 0
	awk -v h="## $header" '
		$0 == h {in_section=1; next}
		in_section && /^## / {exit}
		in_section {print}
	' "$source"
}

has_content() {
	local value="${1:-}"
	local compact
	compact="$(printf '%s' "$value" | tr -d '[:space:]')"
	[ -n "$compact" ] && [ "$value" != "null" ] && [ "$value" != "undefined" ]
}

choose_value() {
	local value
	for value in "$@"; do
		if has_content "$value"; then
			printf '%s' "$value"
			return 0
		fi
	done
	return 1
}

read_json_field() {
	local file="$1"
	local field="$2"
	node - "$file" "$field" <<'NODE'
const fs = require('node:fs');
const [file, field] = process.argv.slice(2);
if (!file || !field || !fs.existsSync(file)) {
  process.exit(1);
}
let value = JSON.parse(fs.readFileSync(file, 'utf8'));
for (const part of field.split('.')) {
  if (!part) continue;
  if (value == null || !(part in value)) {
    process.exit(1);
  }
  value = value[part];
}
if (value == null) {
  process.exit(1);
}
if (typeof value === 'string') {
  process.stdout.write(value);
} else if (typeof value === 'number' || typeof value === 'boolean') {
  process.stdout.write(String(value));
} else if (Array.isArray(value)) {
  process.stdout.write(value.join('\n'));
} else {
  process.stdout.write(JSON.stringify(value));
}
NODE
}

render_block() {
	local value="${1:-}"
	if has_content "$value"; then
		printf '%s\n' "$value"
	else
		echo "- none"
	fi
}

render_list() {
	local value="${1:-}"
	if ! has_content "$value"; then
		echo "- none"
		return 0
	fi
	while IFS= read -r line; do
		[ -n "$line" ] || continue
		case "$line" in
			-\ *) echo "$line" ;;
			*) echo "- $line" ;;
		esac
	done <<< "$value"
}

relative_path_or_none() {
	local file="${1:-}"
	if [ -n "$file" ] && [ -f "$file" ]; then
		printf '%s\n' "${file#$ROOT_DIR/}"
	else
		echo "none"
	fi
}

MODE=""
TARGET_BRANCH=""
WORK_ID=""
LIST_ONLY=0

while [ "$#" -gt 0 ]; do
	case "$1" in
		--mode)
			MODE="${2:-}"
			shift 2
			;;
		--branch)
			TARGET_BRANCH="${2:-}"
			shift 2
			;;
		--work-id)
			WORK_ID="${2:-}"
			shift 2
			;;
		--list)
			LIST_ONLY=1
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

if [ -z "$MODE" ]; then
	echo "[ctx:restore] ambiguous request."
	echo "[ctx:restore] choose explicit mode:"
	echo "  --mode resume"
	echo "  --mode brief"
	echo "  --mode handoff"
	echo "  --mode files"
	exit 1
fi

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

if [ -z "$TARGET_BRANCH" ]; then
	TARGET_BRANCH="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || echo HEAD)"
fi

BRANCH_SAFE="$(sanitize "${TARGET_BRANCH//\//-}")"
BASE_DIR="$ROOT_DIR/.agent-context"
BRANCH_POINTER_FILE="$BASE_DIR/coordination/branches/${BRANCH_SAFE}.json"
RUNTIME_WORK_ID_FILE="$BASE_DIR/runtime/${BRANCH_SAFE}.latest-work-id"
LEGACY_RUNTIME_WORK_ID_FILE="$BASE_DIR/runtime/${BRANCH_SAFE}.work-id"

resolve_effective_work_id() {
	if [ -n "$WORK_ID" ]; then
		printf '%s\n' "$WORK_ID"
		return 0
	fi
	if [ -f "$BRANCH_POINTER_FILE" ]; then
		read_json_field "$BRANCH_POINTER_FILE" "workId" 2>/dev/null && return 0
	fi
	if [ -f "$RUNTIME_WORK_ID_FILE" ]; then
		sed -n '1p' "$RUNTIME_WORK_ID_FILE"
		return 0
	fi
	if [ -f "$LEGACY_RUNTIME_WORK_ID_FILE" ]; then
		sed -n '1p' "$LEGACY_RUNTIME_WORK_ID_FILE"
		return 0
	fi
	return 1
}

WORK_ID_EFFECTIVE="$(resolve_effective_work_id 2>/dev/null || true)"
WORK_SAFE=""
BRIEF_WORK_FILE=""
HANDOFF_WORK_FILE=""
CHECKPOINT_WORK_FILE=""
STATE_WORK_FILE=""
CLAIM_WORK_FILE=""
HISTORY_WORK_FILE=""
ORCH_WORK_FILE=""

set_artifact_paths() {
	BRIEF_FILE="$BASE_DIR/briefs/${BRANCH_SAFE}-latest.md"
	HANDOFF_FILE="$BASE_DIR/handoffs/${BRANCH_SAFE}-latest.md"
	CHECKPOINT_FILE="$BASE_DIR/checkpoints/${BRANCH_SAFE}-latest.md"
		STATE_FILE=""
		CLAIM_FILE=""
		HISTORY_FILE=""
		ORCH_FILE=""

	if [ -n "$WORK_ID_EFFECTIVE" ]; then
		WORK_SAFE="$(sanitize "$WORK_ID_EFFECTIVE")"
		BRIEF_WORK_FILE="$BASE_DIR/briefs/${WORK_SAFE}.md"
		HANDOFF_WORK_FILE="$BASE_DIR/handoffs/${WORK_SAFE}.md"
		CHECKPOINT_WORK_FILE="$BASE_DIR/checkpoints/${WORK_SAFE}.md"
		STATE_WORK_FILE="$BASE_DIR/state/${WORK_SAFE}.json"
		CLAIM_WORK_FILE="$BASE_DIR/coordination/claims/${WORK_SAFE}.json"
			HISTORY_WORK_FILE="$BASE_DIR/coordination/history/${WORK_SAFE}-latest.json"
			ORCH_WORK_FILE="$BASE_DIR/orchestration/work-items/${WORK_SAFE}.json"

		if [ -f "$BRIEF_WORK_FILE" ]; then
			BRIEF_FILE="$BRIEF_WORK_FILE"
		fi
		if [ -f "$HANDOFF_WORK_FILE" ]; then
			HANDOFF_FILE="$HANDOFF_WORK_FILE"
		fi
		if [ -f "$CHECKPOINT_WORK_FILE" ]; then
			CHECKPOINT_FILE="$CHECKPOINT_WORK_FILE"
		fi
		if [ -f "$STATE_WORK_FILE" ]; then
			STATE_FILE="$STATE_WORK_FILE"
		fi
		if [ -f "$CLAIM_WORK_FILE" ]; then
			CLAIM_FILE="$CLAIM_WORK_FILE"
		fi
			if [ -f "$HISTORY_WORK_FILE" ]; then
				HISTORY_FILE="$HISTORY_WORK_FILE"
			fi
			if [ -f "$ORCH_WORK_FILE" ]; then
				ORCH_FILE="$ORCH_WORK_FILE"
			fi
		fi
	}

set_artifact_paths

if [ "$LIST_ONLY" -eq 1 ] || [ "$MODE" = "list" ]; then
	echo "[ctx:restore] branch=$TARGET_BRANCH"
	echo "[ctx:restore] resolved_work_id=${WORK_ID_EFFECTIVE:-none}"
	echo ""
	echo "checkpoint:"
	echo "- $(relative_path_or_none "$CHECKPOINT_FILE")"
	echo ""
	echo "brief:"
	echo "- $(relative_path_or_none "$BRIEF_FILE")"
	echo ""
	echo "handoff:"
	echo "- $(relative_path_or_none "$HANDOFF_FILE")"
	echo ""
	echo "state:"
	echo "- $(relative_path_or_none "$STATE_FILE")"
	echo ""
	echo "active_claim:"
	echo "- $(relative_path_or_none "$CLAIM_FILE")"
	echo ""
	echo "orchestration_work:"
	echo "- $(relative_path_or_none "$ORCH_FILE")"
	exit 0
fi

if [ "$MODE" = "files" ]; then
	echo "[ctx:restore] file recovery mode selected."
	echo "This command does not modify files automatically."
	echo ""
	echo "Recommended manual flow:"
	echo "1. git status --short --branch"
	echo "2. git log --oneline --decorate -n 20"
	echo "3. git diff <target> -- <file>"
	echo "4. If needed, create a safety branch before any restore operation."
	exit 0
fi

if [ "$MODE" = "context" ]; then
	echo "[ctx:restore] mode=context is now an alias for mode=brief."
	MODE="brief"
fi

if { [ "$MODE" = "brief" ] || [ "$MODE" = "resume" ]; } && [ ! -f "$BRIEF_FILE" ] && [ -f "$CHECKPOINT_FILE" ]; then
	echo "[ctx:restore] brief missing; regenerating from latest checkpoint/snapshot."
	if [ -n "$WORK_ID_EFFECTIVE" ]; then
		bash scripts/dev/context-compact.sh --work-id "$WORK_ID_EFFECTIVE" >/dev/null
	else
		bash scripts/dev/context-compact.sh >/dev/null
	fi
	set_artifact_paths
fi

if [ "$MODE" = "resume" ]; then
	STATE_STATUS="$(read_json_field "$STATE_FILE" "status" 2>/dev/null || true)"
	STATE_SURFACE="$(read_json_field "$STATE_FILE" "surface" 2>/dev/null || true)"
	STATE_OBJECTIVE="$(read_json_field "$STATE_FILE" "objective" 2>/dev/null || true)"
	STATE_NEXT_ACTIONS="$(read_json_field "$STATE_FILE" "nextActions" 2>/dev/null || true)"
	STATE_OPEN_QUESTIONS="$(read_json_field "$STATE_FILE" "openQuestions" 2>/dev/null || true)"
	STATE_OWNED_FILES="$(read_json_field "$STATE_FILE" "ownedFiles" 2>/dev/null || true)"
	STATE_CANONICAL_DOCS="$(read_json_field "$STATE_FILE" "canonicalDocs" 2>/dev/null || true)"
	STATE_SNAPSHOT_PATH="$(read_json_field "$STATE_FILE" "snapshotPath" 2>/dev/null || true)"
	STATE_CHECKPOINT_PATH="$(read_json_field "$STATE_FILE" "checkpointPath" 2>/dev/null || true)"
	STATE_BRIEF_PATH="$(read_json_field "$STATE_FILE" "briefPath" 2>/dev/null || true)"
		STATE_HANDOFF_PATH="$(read_json_field "$STATE_FILE" "handoffPath" 2>/dev/null || true)"
		ORCH_TITLE="$(read_json_field "$ORCH_FILE" "title" 2>/dev/null || true)"
		ORCH_STATUS="$(read_json_field "$ORCH_FILE" "status" 2>/dev/null || true)"
		ORCH_PRIORITY="$(read_json_field "$ORCH_FILE" "priority" 2>/dev/null || true)"
		ORCH_AGENT="$(read_json_field "$ORCH_FILE" "agent" 2>/dev/null || true)"
		ORCH_DEPENDS_ON="$(read_json_field "$ORCH_FILE" "dependsOn" 2>/dev/null || true)"
		ORCH_OUTPUTS="$(read_json_field "$ORCH_FILE" "outputs" 2>/dev/null || true)"
		ORCH_HANDOFF_TO="$(read_json_field "$ORCH_FILE" "handoffTo" 2>/dev/null || true)"

	CURRENT_OBJECTIVE="$(choose_value "$STATE_OBJECTIVE" "$(extract_section "$BRIEF_FILE" "Current Objective")" "$(extract_section "$CHECKPOINT_FILE" "Objective")" || true)"
	NEXT_ACTIONS="$(choose_value "$STATE_NEXT_ACTIONS" "$(extract_section "$BRIEF_FILE" "Immediate Next Step")" "$(extract_section "$HANDOFF_FILE" "Remaining Work")" "$(extract_section "$CHECKPOINT_FILE" "Next Actions")" || true)"
	OPEN_QUESTIONS="$(choose_value "$STATE_OPEN_QUESTIONS" "$(extract_section "$BRIEF_FILE" "Open Questions")" "$(extract_section "$HANDOFF_FILE" "Open Questions")" "$(extract_section "$CHECKPOINT_FILE" "Open Questions")" || true)"
	OWNED_FILES="$(choose_value "$STATE_OWNED_FILES" "$(extract_section "$BRIEF_FILE" "Owned Files")" "$(extract_section "$CHECKPOINT_FILE" "Owned Files")" || true)"
	READ_THESE_FIRST="$(choose_value "$STATE_CANONICAL_DOCS" "$(extract_section "$BRIEF_FILE" "Read These First")" "$(extract_section "$CHECKPOINT_FILE" "Canonical Docs Opened")" || true)"
	RISKS="$(choose_value "$(extract_section "$BRIEF_FILE" "Risks / Warnings")" "$(extract_section "$HANDOFF_FILE" "Risks / Traps")" || true)"

	COORD_SOURCE="none"
	COORD_STATUS=""
	COORD_AGENT=""
	COORD_SURFACE="$(choose_value "$STATE_SURFACE" || true)"
	COORD_SUMMARY=""
	COORD_WORKTREE=""
	COORD_LEASE=""
	COORD_RELEASED_AT=""
	COORD_HANDOFF_TO=""
	COORD_PATHS=""
	COORD_DOCS=""
	COORD_DEPENDS_ON=""

	if [ -f "$CLAIM_FILE" ]; then
		COORD_SOURCE="active-claim"
		COORD_STATUS="$(read_json_field "$CLAIM_FILE" "status" 2>/dev/null || true)"
		COORD_AGENT="$(read_json_field "$CLAIM_FILE" "agent" 2>/dev/null || true)"
		COORD_SURFACE="$(choose_value "$(read_json_field "$CLAIM_FILE" "surface" 2>/dev/null || true)" "$COORD_SURFACE" || true)"
		COORD_SUMMARY="$(read_json_field "$CLAIM_FILE" "summary" 2>/dev/null || true)"
		COORD_WORKTREE="$(read_json_field "$CLAIM_FILE" "worktree" 2>/dev/null || true)"
		COORD_LEASE="$(read_json_field "$CLAIM_FILE" "leaseExpiresAt" 2>/dev/null || true)"
		COORD_PATHS="$(read_json_field "$CLAIM_FILE" "paths" 2>/dev/null || true)"
		COORD_DOCS="$(read_json_field "$CLAIM_FILE" "docs" 2>/dev/null || true)"
		COORD_DEPENDS_ON="$(read_json_field "$CLAIM_FILE" "dependsOn" 2>/dev/null || true)"
	elif [ -f "$HISTORY_FILE" ]; then
		COORD_SOURCE="last-release"
		COORD_STATUS="$(read_json_field "$HISTORY_FILE" "status" 2>/dev/null || true)"
		COORD_AGENT="$(read_json_field "$HISTORY_FILE" "agent" 2>/dev/null || true)"
		COORD_SURFACE="$(choose_value "$(read_json_field "$HISTORY_FILE" "surface" 2>/dev/null || true)" "$COORD_SURFACE" || true)"
		COORD_SUMMARY="$(read_json_field "$HISTORY_FILE" "summary" 2>/dev/null || true)"
		COORD_WORKTREE="$(read_json_field "$HISTORY_FILE" "worktree" 2>/dev/null || true)"
		COORD_RELEASED_AT="$(read_json_field "$HISTORY_FILE" "releasedAt" 2>/dev/null || true)"
		COORD_HANDOFF_TO="$(read_json_field "$HISTORY_FILE" "handoffTo" 2>/dev/null || true)"
		COORD_PATHS="$(read_json_field "$HISTORY_FILE" "paths" 2>/dev/null || true)"
		COORD_DOCS="$(read_json_field "$HISTORY_FILE" "docs" 2>/dev/null || true)"
		COORD_DEPENDS_ON="$(read_json_field "$HISTORY_FILE" "dependsOn" 2>/dev/null || true)"
	fi

	DEFAULT_SNAPSHOT_SOURCE=""
	if [ -f "$BASE_DIR/latest-$BRANCH_SAFE.md" ]; then
		DEFAULT_SNAPSHOT_SOURCE=".agent-context/latest-$BRANCH_SAFE.md"
	fi
	DEFAULT_CHECKPOINT_SOURCE=""
	if [ -f "$CHECKPOINT_FILE" ]; then
		DEFAULT_CHECKPOINT_SOURCE="${CHECKPOINT_FILE#$ROOT_DIR/}"
	fi
	DEFAULT_BRIEF_SOURCE=""
	if [ -f "$BRIEF_FILE" ]; then
		DEFAULT_BRIEF_SOURCE="${BRIEF_FILE#$ROOT_DIR/}"
	fi
	DEFAULT_HANDOFF_SOURCE=""
	if [ -f "$HANDOFF_FILE" ]; then
		DEFAULT_HANDOFF_SOURCE="${HANDOFF_FILE#$ROOT_DIR/}"
	fi

	SNAPSHOT_SOURCE="$(choose_value "$STATE_SNAPSHOT_PATH" "$DEFAULT_SNAPSHOT_SOURCE" || true)"
	CHECKPOINT_SOURCE="$(choose_value "$STATE_CHECKPOINT_PATH" "$DEFAULT_CHECKPOINT_SOURCE" || true)"
	BRIEF_SOURCE="$(choose_value "$STATE_BRIEF_PATH" "$DEFAULT_BRIEF_SOURCE" || true)"
	HANDOFF_SOURCE="$(choose_value "$STATE_HANDOFF_PATH" "$DEFAULT_HANDOFF_SOURCE" || true)"

	echo "[ctx:restore] mode=resume"
	echo "[ctx:restore] branch=$TARGET_BRANCH"
	echo "[ctx:restore] resolved_work_id=${WORK_ID_EFFECTIVE:-none}"
	echo ""
	echo "## Coordination"
	echo "- source: ${COORD_SOURCE:-none}"
	echo "- status: $(choose_value "$COORD_STATUS" "$STATE_STATUS" || echo none)"
	echo "- agent: $(choose_value "$COORD_AGENT" || echo none)"
	echo "- surface: $(choose_value "$COORD_SURFACE" || echo none)"
	echo "- summary: $(choose_value "$COORD_SUMMARY" || echo none)"
	if has_content "$COORD_LEASE"; then
		echo "- lease_expires_at: $COORD_LEASE"
	fi
	if has_content "$COORD_RELEASED_AT"; then
		echo "- released_at: $COORD_RELEASED_AT"
	fi
	if has_content "$COORD_HANDOFF_TO"; then
		echo "- handoff_to: $COORD_HANDOFF_TO"
	fi
	if has_content "$COORD_WORKTREE"; then
		echo "- worktree: $COORD_WORKTREE"
	fi
	echo "- paths:"
	render_list "$COORD_PATHS"
	echo "- docs:"
	render_list "$COORD_DOCS"
	echo "- depends_on:"
	render_list "$COORD_DEPENDS_ON"
	echo ""
	echo "## Artifacts"
	echo "- snapshot: $(choose_value "$SNAPSHOT_SOURCE" || echo none)"
	echo "- checkpoint: $(choose_value "$CHECKPOINT_SOURCE" || echo none)"
	echo "- brief: $(choose_value "$BRIEF_SOURCE" || echo none)"
		echo "- handoff: $(choose_value "$HANDOFF_SOURCE" || echo none)"
		if [ -f "$ORCH_FILE" ]; then
			echo "- orchestration: ${ORCH_FILE#$ROOT_DIR/}"
		fi
		echo ""
		if [ -f "$ORCH_FILE" ]; then
			echo "## Orchestration"
			echo "- title: $(choose_value "$ORCH_TITLE" || echo none)"
			echo "- status: $(choose_value "$ORCH_STATUS" || echo none)"
			echo "- priority: $(choose_value "$ORCH_PRIORITY" || echo none)"
			echo "- agent: $(choose_value "$ORCH_AGENT" || echo none)"
			if has_content "$ORCH_HANDOFF_TO"; then
				echo "- handoff_to: $ORCH_HANDOFF_TO"
			fi
			echo "- depends_on:"
			render_list "$ORCH_DEPENDS_ON"
			echo "- outputs:"
			render_list "$ORCH_OUTPUTS"
			echo ""
		fi
		echo "## Current Objective"
	render_block "$CURRENT_OBJECTIVE"
	echo ""
	echo "## Immediate Next Step"
	render_block "$NEXT_ACTIONS"
	echo ""
	echo "## Open Questions"
	render_block "$OPEN_QUESTIONS"
	echo ""
	echo "## Owned Files"
	render_block "$OWNED_FILES"
	echo ""
	echo "## Read These First"
	render_block "$READ_THESE_FIRST"
	echo ""
	echo "## Risks / Warnings"
	render_block "$RISKS"
	echo ""
	echo "## Resume Commands"
	echo "- npm run ctx:resume"
	echo "- npm run ctx:restore -- --mode handoff"
	echo "- npm run coord:list -- --current-branch"
	exit 0
fi

SOURCE_FILE=""
case "$MODE" in
	brief)
		SOURCE_FILE="$BRIEF_FILE"
		;;
	handoff)
		SOURCE_FILE="$HANDOFF_FILE"
		;;
	*)
		echo "[ctx:restore] invalid mode: $MODE"
		usage
		exit 1
		;;
esac

if [ ! -f "$SOURCE_FILE" ]; then
	echo "[ctx:restore] no $MODE artifact found for branch $TARGET_BRANCH."
	echo "[ctx:restore] run: npm run ctx:save -- --title '<task>'"
	echo "[ctx:restore] and: npm run ctx:checkpoint -- --work-id '<W-ID>' --surface '<surface>' --objective '<objective>'"
	exit 1
fi

echo "[ctx:restore] mode=$MODE"
echo "[ctx:restore] source=${SOURCE_FILE#$ROOT_DIR/}"
echo ""
cat "$SOURCE_FILE"
