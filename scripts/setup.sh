#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

SSH_KEY="$HOME/.ssh/id_github"
SSH_HOST="qgj0jvvkems3@173.201.191.4"
WP_ROOT="/home/qgj0jvvkems3/public_html"

# Helper: run WP-CLI on server
wpr() {
  ssh -i "$SSH_KEY" "$SSH_HOST" "cd $WP_ROOT && wp $*"
}

echo "=== Simply Pro Painting — Setup ==="

# 1. Activate theme
echo ""
echo "1. Activating theme..."
CURRENT_THEME=$(wpr theme list --status=active --field=name)
if [ "$CURRENT_THEME" = "simply-pro-painting" ]; then
  echo "   Theme already active."
else
  wpr theme activate simply-pro-painting
  echo "   Theme activated."
fi

# 2. Create/verify pages
echo ""
echo "2. Setting up pages..."

# Home page — check if exists
HOME_ID=$(wpr post list --post_type=page --name=home --field=ID 2>/dev/null || echo "")
if [ -z "$HOME_ID" ]; then
  # Try "Home" title
  HOME_ID=$(wpr post list --post_type=page --title="Home" --field=ID 2>/dev/null || echo "")
fi
if [ -z "$HOME_ID" ]; then
  HOME_ID=$(wpr post create --post_type=page --post_title="Home" --post_status=publish --post_name=home --porcelain)
  echo "   Created Home page (ID: $HOME_ID)"
else
  echo "   Home page exists (ID: $HOME_ID)"
fi

# Gallery page — check if exists by slug
GALLERY_ID=$(wpr post list --post_type=page --name=gallery --field=ID 2>/dev/null || echo "")
if [ -z "$GALLERY_ID" ]; then
  GALLERY_ID=$(wpr post create --post_type=page --post_title="Gallery" --post_status=publish --post_name=gallery --porcelain)
  echo "   Created Gallery page (ID: $GALLERY_ID)"
else
  echo "   Gallery page exists (ID: $GALLERY_ID)"
fi
# Assign gallery template
wpr post meta update "$GALLERY_ID" _wp_page_template page-gallery
echo "   Gallery template assigned."

# Quote page — check if exists by slug
QUOTE_ID=$(wpr post list --post_type=page --name=quote --field=ID 2>/dev/null || echo "")
if [ -z "$QUOTE_ID" ]; then
  QUOTE_ID=$(wpr post create --post_type=page --post_title="Get a Quote" --post_status=publish --post_name=quote --porcelain)
  echo "   Created Quote page (ID: $QUOTE_ID)"
else
  echo "   Quote page exists (ID: $QUOTE_ID)"
fi
# Assign quote template
wpr post meta update "$QUOTE_ID" _wp_page_template page-quote
echo "   Quote template assigned."

# Warranty page — check if exists
WARRANTY_ID=$(wpr post list --post_type=page --name=warranty-information --field=ID 2>/dev/null || echo "")
if [ -z "$WARRANTY_ID" ]; then
  WARRANTY_ID=$(wpr post create --post_type=page --post_title="Warranty Information" --post_status=publish --post_name=warranty-information --porcelain)
  echo "   Created Warranty Information page (ID: $WARRANTY_ID)"
else
  echo "   Warranty Information page exists (ID: $WARRANTY_ID)"
fi

# 3. Seed Home page content (if empty)
echo ""
echo "3. Seeding Home page content..."
CONTENT_FILE="$SCRIPT_DIR/homepage-content.html"
if [ -f "$CONTENT_FILE" ]; then
  CURRENT_CONTENT=$(wpr post get "$HOME_ID" --field=post_content 2>/dev/null || echo "")
  if [ -z "$CURRENT_CONTENT" ]; then
    REMOTE_TMP="/tmp/spp-homepage-content-$$.html"
    scp -i "$SSH_KEY" "$CONTENT_FILE" "$SSH_HOST:$REMOTE_TMP"
    ssh -i "$SSH_KEY" "$SSH_HOST" "cd $WP_ROOT && wp eval '\$c = file_get_contents(\"$REMOTE_TMP\"); wp_update_post(array(\"ID\" => $HOME_ID, \"post_content\" => \$c));' && rm -f '$REMOTE_TMP'"
    echo "   Home page content populated."
  else
    echo "   Home page already has content, skipping."
  fi
else
  echo "   WARNING: $CONTENT_FILE not found, skipping content seed."
fi

# 4. Set Reading options
echo ""
echo "4. Setting reading options..."
wpr option update show_on_front page
wpr option update page_on_front "$HOME_ID"
wpr option update page_for_posts 0
echo "   Static front page set to Home (ID: $HOME_ID)"

# 5. Set permalink structure
echo ""
echo "5. Setting permalinks..."
CURRENT_STRUCTURE=$(wpr option get permalink_structure)
if [ "$CURRENT_STRUCTURE" = "/%postname%/" ]; then
  echo "   Permalinks already set to /%postname%/"
else
  wpr rewrite structure '/%postname%/'
  wpr rewrite flush
  echo "   Permalinks set to /%postname%/"
fi

echo ""
echo "=== Setup complete ==="
