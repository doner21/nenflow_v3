#!/bin/sh
# uninstall.sh — Remove the NenFlow v3 PEV plugin from Claude Code
# Supports: Mac, Linux

echo "==> Uninstalling NenFlow v3 PEV plugin..."
echo ""

FILES="nenflow_v3.md nenflow-v3-planner.md nenflow-v3-executor.md nenflow-v3-verifier.md nenflow-v3-researcher.md"

i=1
for f in $FILES; do
    if [ -f "$HOME/.claude/commands/$f" ]; then
        rm "$HOME/.claude/commands/$f"
        echo "[$i/5] Removed ~/.claude/commands/$f"
    else
        echo "[$i/5] Not found (skipping): ~/.claude/commands/$f"
    fi
    i=$((i + 1))
done

echo ""
echo "==> Uninstall complete."
echo ""
echo "    Note: the nenflow_v3/ directory inside your projects was NOT removed."
echo "    To remove it from a project, run:"
echo "      rm -rf /path/to/your-project/nenflow_v3"
echo ""
echo "    Restart Claude Code to deactivate the removed commands."
echo ""
