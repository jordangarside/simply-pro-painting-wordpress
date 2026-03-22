# Simply Pro Painting LLC

Website: https://www.simplypropaintingllc.com/

## Project Overview

We are rebuilding/managing the WordPress website for Simply Pro Painting LLC. The goal is to create a clean, fast site that the business owner can update himself, while we handle the theme and scaffolding.

## Architecture Decisions

- **Theme**: Custom WordPress block theme (`theme/`) — "Simply Pro Painting", built from scratch
- **Page Builder**: WordPress block editor (Gutenberg) only — no heavy page builders (no Elementor, WPBakery, Divi, etc.)
- **Block Patterns**: Custom patterns in `theme/patterns/` — no external block plugin dependencies
- **Custom Styling**: `theme/assets/css/custom.css` — enqueued by the theme, not via the customizer
- **Owner Editing**: Block type restrictions lock down the editor role to a curated set of blocks on pages (see `functions.php`). Dashboard widgets provide image guidelines and a site editing guide.

### Why This Stack

- Clean, fast code without page builder bloat
- `theme.json` controls design tokens (colors, typography, spacing) — single source of truth
- Block editor is built into WordPress — no extra plugin needed for visual editing
- Self-hosted fonts (Nunito, Quicksand) for performance — no Google Fonts dependency
- Custom block patterns provide reusable, branded sections

## Theme Structure

```
theme/
├── style.css              # Theme metadata (WP header)
├── theme.json             # Design tokens: colors, typography, spacing, layout
├── functions.php          # Asset enqueuing, shortcodes, block restrictions, dashboard widgets
├── assets/
│   ├── css/
│   │   ├── custom.css     # All custom styles
│   │   └── editor.css     # Editor-specific styles
│   ├── fonts/
│   │   ├── nunito-latin.woff2
│   │   └── quicksand-latin.woff2
│   └── js/
│       ├── navigation.js  # Mobile nav toggle
│       └── animations.js  # Scroll-based animations (IntersectionObserver)
├── parts/
│   ├── header.html
│   └── footer.html
├── templates/
│   ├── front-page.html    # Homepage (static front page)
│   ├── page.html          # Default page
│   ├── page-gallery.html  # Gallery page (custom template)
│   ├── page-quote.html    # Quote page (custom template)
│   ├── index.html         # Blog/archive fallback
│   └── 404.html
└── patterns/
    ├── hero.php
    ├── about.php
    ├── services.php
    ├── gallery-preview.php
    ├── gallery-full.php
    ├── quote-form.php
    └── wavy-divider-*.php  # Decorative section dividers (blue, blue-flip, white, yellow)
```

### Design Tokens (theme.json)

- **Colors**: Primary (amber `#fbbf24`), Secondary (orange `#f97316`), Tertiary (sky blue `#38bdf8`), Navy (`#0f172a`), Green (`#22c55e`), plus light/bg variants
- **Typography**: Nunito (headings, weight 800) + Quicksand (body, weight 400–700)
- **Spacing**: Fluid clamp-based scale (xs through xl)
- **Layout**: Content 1280px, Wide 1440px
- **Custom**: Border radius tokens (12px, 20px, pill)

## Integrations

### PaintScout Lead Form

Available as a shortcode `[paintscout_form]` (registered in `functions.php`), or embed directly:

```html
<div id="widget-container"></div>
<script src="https://forms.paintscout.com/lead-form-widget.js"
    data-company-id="infazywchkmwmuuq"
    data-lead-form-key="5ee99a2e-9204-441b-ace1-7bef76ff7a0c">
</script>
```

## Deployment

### Scripts

- `scripts/deploy.sh` — Full deploy: rsync theme to server → run setup → run verify
- `scripts/setup.sh` — Activate theme, create/verify pages (Home, Gallery, Quote, Warranty), set static front page, set permalinks to `/%postname%/`
- `scripts/verify.sh` — Verify theme active, pages exist, templates assigned, reading settings, permalinks, site responds HTTP 200

### Deploy Workflow

```bash
# Full deploy (theme sync + setup + verify)
./scripts/deploy.sh

# Or run steps individually:
./scripts/setup.sh    # Configure WordPress settings via WP-CLI
./scripts/verify.sh   # Check everything is correct
```

## Server Access

- **Host:** `173.201.191.4`
- **cPanel User:** `qgj0jvvkems3`
- **SSH Key:** `~/.ssh/id_github`
- **WordPress Root:** `/home/qgj0jvvkems3/public_html`
- **Theme on server:** `/home/qgj0jvvkems3/public_html/wp-content/themes/simply-pro-painting`

### Running WP-CLI Commands

WP-CLI is installed on the server. Run commands from your local machine via SSH:

```bash
ssh -i ~/.ssh/id_github qgj0jvvkems3@173.201.191.4 "cd /home/qgj0jvvkems3/public_html && wp <command>"
```

Examples:

```bash
# List themes
ssh -i ~/.ssh/id_github qgj0jvvkems3@173.201.191.4 "cd /home/qgj0jvvkems3/public_html && wp theme list"

# Get site URL
ssh -i ~/.ssh/id_github qgj0jvvkems3@173.201.191.4 "cd /home/qgj0jvvkems3/public_html && wp option get siteurl"
```

Note: The local `wp --ssh=` flag has a PHP compatibility issue with the Homebrew WP-CLI version. Use the `ssh` wrapper above instead.

## Tooling

- **Package Manager**: pnpm
- **Playwright**: Installed for browser automation / screenshots during development
- **Playwright MCP**: Configured in `.mcp.json` — allows taking screenshots and interacting with the live site via the Playwright MCP server

## Repo Structure

```
assets/                    # Source images (not in theme — used during development)
├── gallery/               # Project photos (01-exterior-work.jpg through 14-commercial.jpg, etc.)
├── hero/                  # Hero images (hero-main.jpg, house-exterior.jpg, van.jpg, etc.)
└── logo/                  # Logo files (logo.png, logo-alt.jpg)
original-screenshots/      # Full-page screenshots of the original site (pre-rebuild)
screenshots/               # Screenshots of the new site during development
variations/                # HTML design mockups (10 variations + index.html)
new-design.html            # Selected design reference (variation 09 — colorful friendly)
scripts/                   # Deployment and setup scripts
theme/                     # WordPress block theme (deployed to server)
TODO.md                    # Outstanding tasks
```

## Pages

The current site has these pages:

- `/` — Homepage (static front page)
- `/gallery/` — Gallery (custom `page-gallery` template)
- `/quote/` — Get a Quote (custom `page-quote` template, PaintScout form)
- `/warranty-information/` — Warranty Information
