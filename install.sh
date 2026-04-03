#!/bin/sh
# install.sh — Install the NenFlow v3 PEV plugin globally for Claude Code
# Supports: Mac, Linux
#
# Usage:
#   chmod +x install.sh
#   ./install.sh

set -e

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing NenFlow v3 PEV plugin..."
echo ""

# 1. Create ~/.claude/commands/ if needed
mkdir -p "$HOME/.claude/commands"
echo "[1/2] Checked ~/.claude/commands/"

# 2. Copy all command files
cp "$PLUGIN_DIR/commands/nenflow_v3.md"             "$HOME/.claude/commands/nenflow_v3.md"
cp "$PLUGIN_DIR/commands/nenflow-v3-planner.md"     "$HOME/.claude/commands/nenflow-v3-planner.md"
cp "$PLUGIN_DIR/commands/nenflow-v3-executor.md"    "$HOME/.claude/commands/nenflow-v3-executor.md"
cp "$PLUGIN_DIR/commands/nenflow-v3-verifier.md"    "$HOME/.claude/commands/nenflow-v3-verifier.md"
cp "$PLUGIN_DIR/commands/nenflow-v3-researcher.md"  "$HOME/.claude/commands/nenflow-v3-researcher.md"
echo "[2/2] Copied 5 command files to ~/.claude/commands/"

echo ""
echo "==> Installation complete."
echo ""
echo "    Commands installed:"
echo "      /nenflow_v3              — run the v3 PEV orchestrator (with INTAKE stage)"
echo "      /nenflow-v3-planner      — Planner role (used by orchestrator)"
echo "      /nenflow-v3-executor     — Executor role (used by orchestrator)"
echo "      /nenflow-v3-verifier     — Verifier role (used by orchestrator)"
echo "      /nenflow-v3-researcher   — Researcher role (Route B, conditional)"
echo ""
echo "    Restart Claude Code to activate the commands."
echo ""
echo "    Then add the nenflow_v3/ directory to each project you want to use it in:"
echo "      cp -r $PLUGIN_DIR/nenflow_v3 /path/to/your-project/nenflow_v3"
echo ""
