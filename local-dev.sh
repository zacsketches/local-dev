#!/bin/bash
# frontend/dev.sh - Development environment

set -e

# Paths (override with SRC_DIR / OUT_DIR env vars)
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="${SRC_DIR:-src}"
OUT_DIR="${OUT_DIR:-site}"

# Globs to render (Go's filepath.Glob doesn't support **, so we cover root + one level deep)
STATICGEN_GLOBS=("pages/*.template.html" "pages/*/*.template.html")
STATICGEN_GLOBS_ESCAPED=$(printf '%q ' "${STATICGEN_GLOBS[@]}")

# Resolve absolute paths for src/out
case "$SRC_DIR" in
  /*) SRC_PATH="$SRC_DIR" ;;
  *) SRC_PATH="$ROOT_DIR/$SRC_DIR" ;;
esac

case "$OUT_DIR" in
  /*) OUT_PATH="$OUT_DIR" ;;
  *) OUT_PATH="$ROOT_DIR/$OUT_DIR" ;;
esac

# Where to run npm/npx commands from (prefer the src parent if it has package.json)
SRC_PARENT="$(cd "$SRC_PATH/.." && pwd)"
if [ -f "$SRC_PARENT/package.json" ]; then
  NODE_WORKDIR="$SRC_PARENT"
else
  NODE_WORKDIR="$ROOT_DIR"
fi

INPUT_CSS="$SRC_PATH/input.css"
OUTPUT_CSS="$OUT_PATH/styles/output.css"

run_staticgen() {
  for glob in "${STATICGEN_GLOBS[@]}"; do
    staticgen -src "$SRC_PATH" -out "$OUT_PATH" -glob "$glob"
  done
}

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Frontend Development Environment   ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"

# Check dependencies
command -v staticgen >/dev/null 2>&1 || { 
  echo -e "${RED}✗ staticgen not found. Install from: https://github.com/zacsketches/staticgen${NC}"
  exit 1
}

command -v entr >/dev/null 2>&1 || {
  echo -e "${RED}✗ entr not found. Install with: brew install entr (macOS) or your distro package manager${NC}"
  exit 1
}

# Resolve Tailwind binary (prefer local node_modules/.bin)
if [ -x "$NODE_WORKDIR/node_modules/.bin/tailwindcss" ]; then
  TAILWIND_CMD="$NODE_WORKDIR/node_modules/.bin/tailwindcss"
elif command -v tailwindcss >/dev/null 2>&1; then
  TAILWIND_CMD="$(command -v tailwindcss)"
else
  echo -e "${RED}✗ tailwindcss not found. Install in ${NODE_WORKDIR} (npm install) or globally.${NC}"
  exit 1
fi

# Resolve browser-sync (use local if available, otherwise expect global)
BROWSER_SYNC_CMD="browser-sync"
if [ -x "$NODE_WORKDIR/node_modules/.bin/browser-sync" ]; then
  BROWSER_SYNC_CMD="$NODE_WORKDIR/node_modules/.bin/browser-sync"
fi

if ! command -v "$BROWSER_SYNC_CMD" >/dev/null 2>&1; then
  echo -e "${YELLOW}⚠ browser-sync not found. Install with: npm install -g browser-sync or npm install in ${NODE_WORKDIR}${NC}"
fi

# Kill background jobs on exit
trap 'kill $(jobs -p) 2>/dev/null; echo -e "\n${YELLOW}Shutting down...${NC}"' EXIT

# Initial build
echo -e "${BLUE}Building templates...${NC}"
run_staticgen
echo -e "${GREEN}✓ Templates built${NC}"

mkdir -p "$(dirname "$OUTPUT_CSS")"

# Watch templates (all HTML files in src/)
echo -e "${BLUE}Watching templates (${SRC_PATH}/)...${NC}"
(
  while true; do
    find "$SRC_PATH" -type f -name '*.html' | entr -d -c bash -c "echo -e '${YELLOW}⚡ Template changed, rebuilding...${NC}'; for glob in \"pages/*.template.html\" \"pages/*/*.template.html\"; do staticgen -src \"$SRC_PATH\" -out \"$OUT_PATH\" -glob \"\$glob\" 2>&1 | grep -v '^$' || true; done; echo -e '${GREEN}✓ Build complete${NC}'"
    sleep 0.5
  done
) &

# Watch Tailwind CSS
echo -e "${BLUE}Watching Tailwind CSS (${INPUT_CSS})...${NC}"
(
  cd "$NODE_WORKDIR" || exit 1
  "$TAILWIND_CMD" -i "$INPUT_CSS" -o "$OUTPUT_CSS" --watch 2>&1 | grep -v "^$"
) &

# Serve with live reload
if command -v "$BROWSER_SYNC_CMD" >/dev/null 2>&1; then
  echo -e "${BLUE}Starting live server on http://localhost:3000${NC}"
  "$BROWSER_SYNC_CMD" start \
    --server "$OUT_PATH" \
    --files "${OUT_PATH}/**/*" \
    --no-notify \
    --no-open \
    --ignore "${OUT_PATH}/styles/output.css.map" &
else
  echo -e "${BLUE}Starting simple server on http://localhost:8000${NC}"
  cd "$OUT_PATH" && python3 -m http.server 8000 &
fi

echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ Development environment ready!    ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo -e "${BLUE}→ Source: ${SRC_PATH}/${NC}"
echo -e "${BLUE}→ Output: ${OUT_PATH}/${NC}"
echo -e "${BLUE}→ URL: http://localhost:3000${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all watchers${NC}"

wait
