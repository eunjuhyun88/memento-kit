#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  bash setup-runtime.sh --target <dir> --agent-name <name> --core-repo <path> --memory-workspace <path> [options]

Options:
  --target <dir>              Target runtime workspace path
  --agent-name <name>         Human-readable agent name
  --core-repo <path>          Path to the repo-local Memento core
  --memory-workspace <path>   Path to the agent memory workspace
  --platform <text>           Runtime platform label. Default: generic
  --summary <text>            One-line runtime summary
  --force                     Overwrite existing files from the template
  -h, --help                  Show help
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$ROOT_DIR/templates/agent-runtime"

TARGET_DIR=""
AGENT_NAME=""
CORE_REPO=""
MEMORY_WORKSPACE=""
PLATFORM="generic"
SUMMARY="Agent runtime workspace."
FORCE=0

while [ "$#" -gt 0 ]; do
	case "$1" in
		--target)
			TARGET_DIR="${2:-}"
			shift 2
			;;
		--agent-name)
			AGENT_NAME="${2:-}"
			shift 2
			;;
		--core-repo)
			CORE_REPO="${2:-}"
			shift 2
			;;
		--memory-workspace)
			MEMORY_WORKSPACE="${2:-}"
			shift 2
			;;
		--platform)
			PLATFORM="${2:-}"
			shift 2
			;;
		--summary)
			SUMMARY="${2:-}"
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

if [ -z "$TARGET_DIR" ] || [ -z "$AGENT_NAME" ] || [ -z "$CORE_REPO" ] || [ -z "$MEMORY_WORKSPACE" ]; then
	echo "Missing required flags."
	usage
	exit 1
fi

mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
CORE_REPO="$(cd "$CORE_REPO" && pwd)"
MEMORY_WORKSPACE="$(cd "$MEMORY_WORKSPACE" && pwd)"
AGENT_SLUG="$(printf '%s' "$AGENT_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')"

copy_file() {
	local src="$1"
	local dest="$2"
	if [ -e "$dest" ] && [ "$FORCE" -ne 1 ]; then
		echo "[setup-runtime] keep existing: ${dest#$TARGET_DIR/}"
		return 0
	fi
	mkdir -p "$(dirname "$dest")"
	cp "$src" "$dest"
	echo "[setup-runtime] wrote: ${dest#$TARGET_DIR/}"
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
	python3 - "$file" "$AGENT_NAME" "$AGENT_SLUG" "$CORE_REPO" "$MEMORY_WORKSPACE" "$PLATFORM" "$SUMMARY" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
replacements = {
    "__AGENT_NAME__": sys.argv[2],
    "__AGENT_SLUG__": sys.argv[3],
    "__CORE_REPO__": sys.argv[4],
    "__MEMORY_WORKSPACE__": sys.argv[5],
    "__RUNTIME_PLATFORM__": sys.argv[6],
    "__RUNTIME_SUMMARY__": sys.argv[7],
}
for old, new in replacements.items():
    text = text.replace(old, new)
path.write_text(text)
PY
}

copy_tree "$TEMPLATE_DIR"

while IFS= read -r -d '' file; do
	replace_placeholders "$file"
done < <(find "$TARGET_DIR" -type f \( -name '*.md' -o -name '*.json' -o -name '*.mjs' \) -print0)

if [ ! -d "$TARGET_DIR/.git" ]; then
	git -C "$TARGET_DIR" init -q
	echo "[setup-runtime] initialized git repository"
fi

echo ""
echo "Runtime workspace applied to: $TARGET_DIR"
echo "Next steps:"
echo "  1. Run: cd \"$TARGET_DIR\" && node scripts/check-runtime-config.mjs"
echo "  2. Run: cd \"$TARGET_DIR\" && node scripts/build-project-context-bundle.mjs"
echo "  3. Run: cd \"$TARGET_DIR\" && node scripts/build-memory-index.mjs"
echo "  4. Run: cd \"$TARGET_DIR\" && node scripts/distill-memory.mjs"
