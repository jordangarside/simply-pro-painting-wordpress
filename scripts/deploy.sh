#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

SSH_KEY="$HOME/.ssh/id_github"
SSH_HOST="qgj0jvvkems3@173.201.191.4"
WP_ROOT="/home/qgj0jvvkems3/public_html"
THEME_DIR="$WP_ROOT/wp-content/themes/simply-pro-painting"

echo "=== Simply Pro Painting — Deploy ==="

# 1. rsync theme to server
echo ""
echo "1. Syncing theme files to server..."
rsync -avz --delete \
  "$PROJECT_DIR/theme/" \
  "$SSH_HOST:$THEME_DIR/" \
  -e "ssh -i $SSH_KEY"
echo "   Done."

# 2. Run setup
echo ""
echo "2. Running setup..."
"$SCRIPT_DIR/setup.sh"

# 3. Verify
echo ""
echo "3. Running verification..."
"$SCRIPT_DIR/verify.sh"

echo ""
echo "=== Deploy complete ==="
