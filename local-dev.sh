#!/bin/bash
# frontend/dev.sh - Development environment

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Frontend Development Environment   ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"

# Check dependencies
command -v staticgen >/dev/null 2>&1 || { 
  echo -e "${RED}✗ staticgen not found. Install from: https://github.com/zacsketches/staticgen${NC}"
  exit 1
}

command -v browser-sync >/dev/null 2>&1 || {
  echo -e "${YELLOW}⚠ browser-sync not found. Install with: npm install -g browser-sync${NC}"
}

# Kill background jobs on exit
trap 'kill $(jobs -p) 2>/dev/null; echo -e "\n${YELLOW}Shutting down...${NC}"' EXIT

# Initial build
echo -e "${BLUE}Building templates...${NC}"
staticgen -src src -dest site
echo -e "${GREEN}✓ Templates built${NC}"

# Watch templates (all HTML files in src/)
echo -e "${BLUE}Watching templates (src/)...${NC}"
(
  while true; do
    find src -type f -name '*.html' | entr -d -c bash -c '
      echo -e "'"${YELLOW}⚡ Template changed, rebuilding...${NC}"'"
      staticgen -src src -dest site 2>&1 | grep -v "^$" || true
      echo -e "'"${GREEN}✓ Build complete${NC}"'"
    '
    sleep 0.5
  done
) &

# Watch Tailwind CSS
echo -e "${BLUE}Watching Tailwind CSS (src/input.css)...${NC}"
npx tailwindcss -i ./src/input.css -o ./site/styles/output.css --watch 2>&1 | \
  grep -v "^$" &

# Serve with live reload
if command -v browser-sync >/dev/null 2>&1; then
  echo -e "${BLUE}Starting live server on http://localhost:3000${NC}"
  browser-sync start \
    --server ./site \
    --files "site/**/*" \
    --no-notify \
    --no-open \
    --ignore "site/styles/output.css.map" &
else
  echo -e "${BLUE}Starting simple server on http://localhost:8000${NC}"
  cd site && python3 -m http.server 8000 &
fi

echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ Development environment ready!    ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo -e "${BLUE}→ Source: src/${NC}"
echo -e "${BLUE}→ Output: site/${NC}"
echo -e "${BLUE}→ URL: http://localhost:3000${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all watchers${NC}"

wait
