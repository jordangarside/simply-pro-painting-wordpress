#!/usr/bin/env bash
set -euo pipefail

SSH_KEY="$HOME/.ssh/id_github"
SSH_HOST="qgj0jvvkems3@173.201.191.4"
WP_ROOT="/home/qgj0jvvkems3/public_html"

wpr() {
  ssh -i "$SSH_KEY" "$SSH_HOST" "cd $WP_ROOT && wp $*" 2>/dev/null
}

echo "=== Simply Pro Painting — Verify ==="
PASS=0
FAIL=0

check() {
  local label="$1"
  local result="$2"
  if [ "$result" = "true" ]; then
    echo "  ✓ $label"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $label"
    FAIL=$((FAIL + 1))
  fi
}

# Theme active
ACTIVE_THEME=$(wpr theme list --status=active --field=name)
check "Theme active" "$([ "$ACTIVE_THEME" = "simply-pro-painting" ] && echo true || echo false)"

# Pages exist
HOME_ID=$(wpr post list --post_type=page --name=home --field=ID 2>/dev/null || echo "")
check "Home page exists" "$([ -n "$HOME_ID" ] && echo true || echo false)"

GALLERY_ID=$(wpr post list --post_type=page --name=gallery --field=ID 2>/dev/null || echo "")
check "Gallery page exists" "$([ -n "$GALLERY_ID" ] && echo true || echo false)"

WARRANTY_ID=$(wpr post list --post_type=page --name=warranty-information --field=ID 2>/dev/null || echo "")
check "Warranty page exists" "$([ -n "$WARRANTY_ID" ] && echo true || echo false)"

# Gallery template assigned
if [ -n "$GALLERY_ID" ]; then
  GALLERY_TEMPLATE=$(wpr post meta get "$GALLERY_ID" _wp_page_template)
  check "Gallery template assigned" "$([ "$GALLERY_TEMPLATE" = "page-gallery" ] && echo true || echo false)"
else
  check "Gallery template assigned" "false"
fi

# Reading settings
SHOW_ON_FRONT=$(wpr option get show_on_front)
check "Static front page enabled" "$([ "$SHOW_ON_FRONT" = "page" ] && echo true || echo false)"

if [ -n "$HOME_ID" ]; then
  PAGE_ON_FRONT=$(wpr option get page_on_front)
  check "Front page set to Home" "$([ "$PAGE_ON_FRONT" = "$HOME_ID" ] && echo true || echo false)"
fi

# Permalink structure
PERMALINK=$(wpr option get permalink_structure)
check "Permalinks set" "$([ "$PERMALINK" = "/%postname%/" ] && echo true || echo false)"

# Site accessible
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://www.simplypropaintingllc.com/ 2>/dev/null || echo "000")
check "Site responds (HTTP $HTTP_STATUS)" "$([ "$HTTP_STATUS" = "200" ] && echo true || echo false)"

echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
