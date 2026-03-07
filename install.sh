#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  bash install.sh --project-name <name> [setup options] [install options]

Install options:
  --skip-hooks     Skip npm run safe:hooks after setup
  --skip-verify    Skip npm run docs:refresh and npm run docs:check after setup
  -h, --help       Show help

All other flags are forwarded to setup.sh.

Example:
  bash /path/to/memento-kit/install.sh \
    --project-name MyProject \
    --summary "One-line summary" \
    --stack "TypeScript / SvelteKit" \
    --surfaces core,admin
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="$ROOT_DIR/setup.sh"

if [ ! -f "$SETUP_SCRIPT" ]; then
	echo "[install] setup.sh not found next to install.sh"
	exit 1
fi

TARGET_DIR=""
SKIP_HOOKS=0
SKIP_VERIFY=0
FORWARDED_ARGS=()

while [ "$#" -gt 0 ]; do
	case "$1" in
		--skip-hooks)
			SKIP_HOOKS=1
			shift 1
			;;
		--skip-verify)
			SKIP_VERIFY=1
			shift 1
			;;
		--target)
			TARGET_DIR="${2:-}"
			FORWARDED_ARGS+=("$1" "$TARGET_DIR")
			shift 2
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			FORWARDED_ARGS+=("$1")
			shift 1
			;;
	esac
done

if [ -z "$TARGET_DIR" ]; then
	TARGET_DIR="$(pwd)"
	FORWARDED_ARGS+=("--target" "$TARGET_DIR")
fi

bash "$SETUP_SCRIPT" "${FORWARDED_ARGS[@]}"

if [ ! -d "$TARGET_DIR" ]; then
	echo "[install] target directory missing after setup: $TARGET_DIR"
	exit 1
fi

if [ ! -f "$TARGET_DIR/package.json" ]; then
	echo "[install] package.json not found in target. Skipping npm post-install steps."
	exit 0
fi

if ! command -v npm >/dev/null 2>&1; then
	echo "[install] npm not found. Skipping npm post-install steps."
	exit 0
fi

if [ "$SKIP_HOOKS" -ne 1 ]; then
	echo "[install] running npm run safe:hooks"
	(
		cd "$TARGET_DIR"
		npm run safe:hooks
	)
fi

echo "[install] running npm run adopt:bootstrap"
(
	cd "$TARGET_DIR"
	npm run adopt:bootstrap
)

if [ "$SKIP_VERIFY" -ne 1 ]; then
	echo "[install] running npm run docs:refresh"
	(
		cd "$TARGET_DIR"
		npm run docs:refresh
	)
	echo "[install] running npm run docs:check"
	(
		cd "$TARGET_DIR"
		npm run docs:check
	)
fi

echo "[install] complete: $TARGET_DIR"
