# staticgen Test Environment

This is a complete test environment for validating the staticgen local development workflow before applying it to production codebases.

## What This Tests

✅ **Multiple Layouts**
- `public.html` - Default layout with header and footer
- `dashboard.html` - Protected layout with sidebar navigation

✅ **Shared Includes**
- `header.html` - Site-wide header with navigation
- `footer.html` - Footer with template variables (Year, BuildTimestamp)
- `nav.html` - Dashboard sidebar navigation

✅ **Nested Page Structure**
- Root pages: `index.html`, `privacy.html`
- Protected pages: `protected/voyages.html`, `protected/guests.html`

✅ **Template Features**
- Layout switching via `{{define "layout_name"}}`
- Template variables: `{{.Year}}`, `{{.BuildTimestamp}}`
- Shared components via `{{template "header" .}}`

✅ **Build Pipeline**
- File watching with `entr`
- Automatic rebuilds via `staticgen`
- Tailwind CSS compilation
- Live browser reload with browser-sync

## Project Structure

```
test/
├── src/
│   ├── _includes/
│   │   ├── header.html
│   │   ├── footer.html
│   │   └── nav.html
│   ├── _layouts/
│   │   ├── public.html
│   │   └── dashboard.html
│   ├── pages/
│   │   ├── index.template.html
│   │   ├── privacy.template.html
│   │   └── protected/
│   │       ├── voyages.template.html
│   │       └── guests.template.html
│   └── input.css
├── site/                       # Generated output
│   └── js/
│       ├── utils.js
│       └── auth.js
├── local-dev.sh               # Development script
├── package.json
└── tailwind.config.js
```

## Prerequisites

1. **staticgen** - Install from [releases](https://github.com/zacsketches/staticgen/releases)
2. **Node.js & npm** - For Tailwind CSS and browser-sync
3. **entr** - File watching utility
   ```bash
   # macOS
   brew install entr
   
   # Linux
   sudo apt-get install entr  # Debian/Ubuntu
   sudo yum install entr       # CentOS/RHEL
   ```

## Setup

1. **Navigate to test directory:**
   ```bash
   cd test
   ```

2. **Install Node dependencies:**
   ```bash
   npm install
   ```

3. **Make script executable:**
   ```bash
   chmod +x local-dev.sh
   ```

## Usage

Start the development environment:

```bash
./local-dev.sh
```

The script will:
- ✓ Build all templates with staticgen
- ✓ Watch for changes in `src/`
- ✓ Compile Tailwind CSS
- ✓ Serve at `http://localhost:3000` with live reload

Press `Ctrl+C` to stop all watchers.

## Testing Steps

### 1. Verify Initial Build

Open your browser to `http://localhost:3000` and check:
- ✅ Home page loads with header and footer
- ✅ Footer shows current year and build timestamp
- ✅ Navigation links work

### 2. Test Public Layout

Visit pages using the public layout:
- **Home**: `http://localhost:3000/`
- **Privacy**: `http://localhost:3000/privacy.html`

Expected: Both pages share the same header/footer but different content.

### 3. Test Dashboard Layout

Visit pages using the dashboard layout:
- **Voyages**: `http://localhost:3000/protected/voyages.html`
- **Guests**: `http://localhost:3000/protected/guests.html`

Expected: Both pages have sidebar navigation instead of top nav.

### 4. Test File Watching

**Edit a template:**
```bash
# In another terminal
echo "<!-- test change -->" >> src/pages/index.template.html
```

Expected:
- Console shows "⚡ Template changed, rebuilding..."
- staticgen runs and outputs build log
- Browser automatically refreshes
- Your change appears on the page

### 5. Test Nested Directory Output

Check that protected pages output to correct paths:
```bash
ls -la site/protected/
# Should show: voyages.html, guests.html
```

### 6. Test Template Variables

Check the footer on any page:
- Year should be current year ({{.Year}})
- Build timestamp should match when you started the server

### 7. Test Tailwind CSS

Edit `src/input.css`:
```css
@layer components {
  .test-class {
    @apply bg-red-500 text-white p-4;
  }
}
```

Expected: Tailwind recompiles and browser refreshes.

### 8. Test Layout Switching

Edit `src/pages/privacy.template.html` and add at the top:
```html
{{define "layout_name"}}dashboard{{end}}
```

Expected: Privacy page now uses dashboard layout with sidebar.

## Success Criteria

✅ All pages render without errors  
✅ Templates rebuild automatically on file changes  
✅ Browser refreshes without manual reload  
✅ Nested directories work correctly  
✅ Both layouts render properly  
✅ Template variables display correctly  
✅ Tailwind CSS compiles and applies styles  
✅ Shared includes work across all pages  

## Troubleshooting

### staticgen not found
```bash
# Install from releases
# https://github.com/zacsketches/staticgen/releases
```

### entr not found
```bash
brew install entr  # macOS
```

### browser-sync not found
```bash
npm install -g browser-sync
```

### Port 3000 already in use
```bash
# Kill existing process
lsof -ti:3000 | xargs kill -9
```

### Templates not rebuilding
```bash
# Check entr is working
find src -type f -name '*.html' | entr echo "File changed"
# Then edit a template - should see "File changed"
```

## Next Steps

Once all tests pass, apply this workflow to your production codebase:
1. Copy `local-dev.sh` to your frontend directory
2. Adjust paths to match your structure
3. Update `package.json` and `tailwind.config.js`
4. Run and iterate!

## License

MIT