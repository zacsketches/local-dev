# local-dev

A local development environment that automatically watches for changes in HTML templates and rebuilds them using [staticgen](https://github.com/zacsketches/staticgen).

## Overview

This project provides a complete frontend development pipeline with:
- **Automatic template rebuilding** via [staticgen](https://github.com/zacsketches/staticgen)
- **Live CSS compilation** with Tailwind CSS
- **Browser auto-refresh** using browser-sync
- **File watching** to detect changes and trigger rebuilds

## How It Works

The `local-dev.sh` script orchestrates a development workflow that:

1. **Watches for template changes** - Monitors all `.html` files in the `src/` directory
2. **Rebuilds on detection** - When a template file changes, `staticgen` automatically: 
   - Collects page templates matching `pages/**/*.template.html`
   - Merges them with shared includes (`_includes/*.html`) and layouts (`_layouts/*.html`)
   - Renders final HTML pages using Go's `html/template` engine
   - Outputs built files to the `site/` directory
3. **Reloads the browser** - browser-sync detects changes in `site/` and refreshes your browser

### Template Processing with staticgen

The [staticgen](https://github.com/zacsketches/staticgen) tool is an ultra-light static site generator that: 

- Parses Go HTML templates with shared layouts and partials
- Supports custom template functions (e.g., `nowRFC3339`)
- Allows dynamic layout selection via `{{define "layout_name"}}...{{end}}`
- Injects build metadata (year, timestamp) into every page
- Transforms `pages/foo.template.html` → `site/foo.html`

## Project Structure

```
src/
├── _includes/             # Shared partials (header, footer, etc.)
├── _layouts/              # Layout templates (public, dashboard, etc.)
├── pages/                 # Page templates
│   └── *.template.html    # Pages to be rendered
└── input.css              # Tailwind CSS input

site/                      # Generated output (served locally)
```

## Prerequisites

1. **staticgen** - Install from [releases](https://github.com/zacsketches/staticgen/releases)
2. **Node.js & npm** - For Tailwind CSS and browser-sync
3. **entr** - File watching utility (`brew install entr` on macOS)

```bash
# Install browser-sync (optional but recommended)
npm install -g browser-sync

# Verify staticgen is installed
staticgen --help
```

## Usage

Start the development environment: 

```bash
./local-dev.sh
```

The script will:
- ✓ Build all templates initially
- ✓ Watch for template changes in `src/`
- ✓ Watch for CSS changes and recompile Tailwind
- ✓ Serve the site at `http://localhost:3000` with live reload

Press `Ctrl+C` to stop all watchers.

## Development Workflow

1. Edit templates in `src/pages/`, `src/_layouts/`, or `src/_includes/`
2. Save your changes
3. `staticgen` automatically rebuilds the affected templates
4. Browser-sync reloads your browser
5. See changes instantly! 

## staticgen Configuration

The script runs staticgen with these defaults:
```bash
staticgen -src src -dest site
```

You can customize staticgen's behavior by modifying the script or running it manually: 
```bash
# Custom page glob
staticgen -glob "pages/*.template.html"

# Custom build timestamp
staticgen -timestamp "2024-01-01 12:00:00 CST"
```

## License

MIT