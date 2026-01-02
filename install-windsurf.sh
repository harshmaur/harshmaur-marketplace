#!/bin/bash
# Install/Update Harsh Maur's TypeScript Rules for Windsurf
# Usage: curl -fsSL https://raw.githubusercontent.com/harshmaur/harshmaur-marketplace/main/install-windsurf.sh | bash

set -e

REPO_URL="https://raw.githubusercontent.com/harshmaur/harshmaur-marketplace/main"
WINDSURF_DIR=".windsurf"

echo "📦 Installing Harsh Maur's TypeScript Rules for Windsurf..."

# Create directories
mkdir -p "$WINDSURF_DIR/rules"
mkdir -p "$WINDSURF_DIR/workflows"

# Download rules
echo "⬇️  Downloading rules..."
curl -fsSL "$REPO_URL/skills/typescript-review/references/rules.md" \
  -o "$WINDSURF_DIR/rules/typescript-review.md"

# Download workflow
echo "⬇️  Downloading workflow..."
curl -fsSL "$REPO_URL/.windsurf/workflows/typescript-review.md" \
  -o "$WINDSURF_DIR/workflows/typescript-review.md"

# Create/update .windsurfrules if it doesn't mention our rules
if [ ! -f ".windsurfrules" ]; then
  echo "📝 Creating .windsurfrules..."
  cat > .windsurfrules << 'EOF'
# Harsh Maur's TypeScript Code Review

When reviewing TypeScript/JavaScript code, apply all rules from `.windsurf/rules/typescript-review.md`.

Use `/typescript-review` to trigger a full code review.
EOF
elif ! grep -q "typescript-review" .windsurfrules 2>/dev/null; then
  echo "📝 Adding reference to .windsurfrules..."
  echo "" >> .windsurfrules
  echo "# Harsh Maur's TypeScript Rules" >> .windsurfrules
  echo "When reviewing TypeScript code, apply rules from \`.windsurf/rules/typescript-review.md\`." >> .windsurfrules
fi

echo ""
echo "✅ Installed successfully!"
echo ""
echo "Usage:"
echo "  /typescript-review  - Run a code review"
echo "  /review-ts          - Alias"
echo ""
echo "To update later, run this script again."
