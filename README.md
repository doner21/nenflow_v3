# NenFlow v3

NenFlow v3 is a lighter, adaptive Planner-Executor-Verifier (PEV) orchestration plugin for Claude Code. It improves on v2 with an explicit INTAKE stage, no mandatory human gate on the default route, a looser validator, and 6 routing paths including context-rot management.

---

## Installation

### Mac / Linux

```sh
git clone https://github.com/doner21/nenflow_v3.git
cd nenflow_v3
chmod +x install.sh
./install.sh
```

### Windows

```bat
git clone https://github.com/doner21/nenflow_v3.git
cd nenflow_v3
.\install.bat
```

Then **restart Claude Code** to activate the commands.

---

## Usage

Add the `nenflow_v3/` project directory to any project you want to use it in:

```sh
# Mac / Linux
cp -r /path/to/nenflow_v3/nenflow_v3 /path/to/your-project/nenflow_v3

# Windows
xcopy /E /I nenflow_v3 C:\path\to\your-project\nenflow_v3
```

Then invoke from Claude Code:

```
/nenflow_v3 <task description>
```

---

## Commands Installed

| Command | Purpose |
|---------|-------------------|
| `/nenflow_v3` | Main orchestrator — run the full INTAKE → PEV loop |
| `/nenflow-v3-planner` | Planner role (used by orchestrator) |
| `/nenflow-v3-executor` | Executor role (used by orchestrator) |
| `/nenflow-v3-verifier` | Verifier role (used by orchestrator) |
| `/nenflow-v3-researcher` | Researcher role (Route B, conditional) |

---

## What's New in v3

| Feature | v2 | v3 |
|---------|----|---------|
| INTAKE stage | Not present | Step 0 of every run — shapes prompt before routing |
| Human gate | Mandatory every run | Optional (Route C only) |
| Validator | 7 fields, section checks | 3 fields, no section checks |
| Context-rot handling | Not handled | CONTINUATION contracts at 65% saturation |
| Routing | One path + retry | 6 routes (A–F) |
| Run directory | `nenflow/runs/` | `nenflow_v3/runs/` |

---

## Uninstallation

```sh
# Mac / Linux
./uninstall.sh

# Windows
uninstall.bat
```

Note: the `nenflow_v3/` directory inside your projects is **not** removed by uninstall. Remove it manually if needed.

---

## Coexistence with v2

v3 is fully independent of v2. Both can be installed simultaneously. They use separate run directories and separate command namespaces (`/nenflow_v3` vs `/nenflow_v2`).

Full technical details: `nenflow_v3/SYSTEM_DESIGN.md`
