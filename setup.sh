#!/usr/bin/env bash
# ==============================================================================
# Apple Silicon LLM — One-Click Setup, Model Manager & Shell Aliases
# ==============================================================================
#
#   Built by @buildwithfiroz
#   https://github.com/buildwithfiroz
#
# Writes standalone shell functions DIRECTLY into ~/.zshrc with concrete paths
# so all commands work anywhere across your entire Mac.
#
# ==============================================================================

set -euo pipefail

# ANSI Colors
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_CYAN='\033[1;36m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_MAGENTA='\033[1;35m'
C_BLUE='\033[1;34m'
C_WHITE='\033[1;37m'
C_RED='\033[1;31m'

# Resolve repository directory dynamically
if [ -n "${ZSH_VERSION:-}" ]; then
    CURRENT_SCRIPT="${(%):-%x}"
elif [ -n "${BASH_SOURCE[0]:-}" ]; then
    CURRENT_SCRIPT="${BASH_SOURCE[0]}"
else
    CURRENT_SCRIPT="$0"
fi
REPO_DIR="$(cd "$(dirname "$CURRENT_SCRIPT")" && pwd)"
export MLX_AI_DIR="$REPO_DIR"

VENV_PATH="$REPO_DIR/myenv"
VENV_PYTHON="$VENV_PATH/bin/python"
VENV_PIP="$VENV_PATH/bin/pip"
VENV_GENERATE="$VENV_PATH/bin/mlx_lm.generate"
VENV_CHAT="$VENV_PATH/bin/mlx_lm.chat"

# Central model definitions (100% robust & configurable)
MODEL_PHI="mlx-community/Phi-4-mini-instruct-4bit"
MODEL_QWEN="mlx-community/Qwen2.5-Coder-3B-Instruct-4bit"

# If called with --help, show usage and exit
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    echo "Usage: ./setup.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  (no args)           Interactive installation with arrow-key model picker"
    echo "  --download-models   Install and download both Phi-4 Mini and Qwen2.5-Coder"
    echo "  --skip-models       Install MLX framework and utilities only (no models)"
    echo "  --aliases-only, -a  Source aliases in current session and exit"
    echo "  --help, -h          Show this help message"
    exit 0
fi

# If called with --aliases-only, define functions and exit
if [ "${1:-}" = "--aliases-only" ] || [ "${1:-}" = "-a" ]; then
    mlxphi() {
        source "$REPO_DIR/myenv/bin/activate"
        mlx_lm.chat --model "$MODEL_PHI" --max-tokens 8192 "$@"
    }
    mlxphig() {
        source "$REPO_DIR/myenv/bin/activate"
        mlx_lm.generate --model "$MODEL_PHI" --max-tokens 8192 --prompt "$*"
    }
    mlxqwen() {
        source "$REPO_DIR/myenv/bin/activate"
        mlx_lm.chat --model "$MODEL_QWEN" --max-tokens 8192 "$@"
    }
    mlxqweng() {
        source "$REPO_DIR/myenv/bin/activate"
        mlx_lm.generate --model "$MODEL_QWEN" --max-tokens 4096 --prompt "$*"
    }
    return 0 2>/dev/null || exit 0
fi

# =============================================================================
# CLI INSTALLER
# =============================================================================
clear 2>/dev/null || true

echo -e "${C_CYAN}╭─────────────────────────────────────────────────────────────────────────────╮${C_RESET}"
echo -e "${C_CYAN}│${C_RESET}   ${C_BOLD}${C_MAGENTA}__  __ _     __  __       _     ___${C_RESET}                                       ${C_CYAN}│${C_RESET}"
echo -e "${C_CYAN}│${C_RESET}  ${C_BOLD}${C_MAGENTA}|  \/  | |    \ \/ /      / \   |_ _|${C_RESET}                                      ${C_CYAN}│${C_RESET}"
echo -e "${C_CYAN}│${C_RESET}  ${C_BOLD}${C_MAGENTA}| |\/| | |     \  /      / _ \   | |${C_RESET}                                       ${C_CYAN}│${C_RESET}"
echo -e "${C_CYAN}│${C_RESET}  ${C_BOLD}${C_MAGENTA}| |  | | |___  /  \     / ___ \  | |${C_RESET}                                       ${C_CYAN}│${C_RESET}"
echo -e "${C_CYAN}│${C_RESET}  ${C_BOLD}${C_MAGENTA}|_|  |_|_____|/_/\_\   /_/   \_\|___|${C_RESET}                                      ${C_CYAN}│${C_RESET}"
echo -e "${C_CYAN}│${C_RESET}                                                                             ${C_CYAN}│${C_RESET}"
echo -e "${C_CYAN}│${C_RESET}   ${C_BOLD}${C_WHITE}Apple Silicon LLM — Native MLX Local AI Toolkit${C_RESET}                           ${C_CYAN}│${C_RESET}"
echo -e "${C_CYAN}│${C_RESET}   ${C_DIM}Built by @buildwithfiroz • https://github.com/buildwithfiroz/apple-silicon-llm${C_RESET}    ${C_CYAN}│${C_RESET}"
echo -e "${C_CYAN}╰─────────────────────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""

# -----------------------------------------------------------------------------
# 1. System & Hardware Check
# -----------------------------------------------------------------------------
echo -e "${C_BOLD}${C_BLUE}╭── [1/4] SYSTEM & ACCELERATION ──────────────────────────────────────────────╮${C_RESET}"
OS_NAME="$(uname -s)"
ARCH_NAME="$(uname -m)"

if [ "$OS_NAME" != "Darwin" ] || [ "$ARCH_NAME" != "arm64" ]; then
    echo -e "${C_BLUE}│${C_RESET}  ${C_RED}✖ Error: macOS on Apple Silicon (arm64) required.${C_RESET}"
    echo -e "${C_BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${C_RESET}"
    exit 1
fi
echo -e "${C_BLUE}│${C_RESET}  ${C_GREEN}✔${C_RESET} Platform:      ${C_BOLD}${C_WHITE}macOS (${ARCH_NAME} Apple Silicon)${C_RESET}"

if ! command -v python3 >/dev/null 2>&1; then
    echo -e "${C_BLUE}│${C_RESET}  ${C_RED}✖ Error: python3 not found.${C_RESET}"
    echo -e "${C_BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${C_RESET}"
    exit 1
fi
PY_VER="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}")')"
echo -e "${C_BLUE}│${C_RESET}  ${C_GREEN}✔${C_RESET} Host Python:   ${C_WHITE}Python $PY_VER${C_RESET}"
echo -e "${C_BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""

# -----------------------------------------------------------------------------
# 2. Virtual Environment Setup
# -----------------------------------------------------------------------------
echo -e "${C_BOLD}${C_BLUE}╭── [2/4] ENVIRONMENT (myenv) ────────────────────────────────────────────────╮${C_RESET}"
if [ ! -d "$VENV_PATH" ]; then
    echo -e "${C_BLUE}│${C_RESET}  ⚡ Creating virtual environment 'myenv'..."
    python3 -m venv "$VENV_PATH"
fi
echo -e "${C_BLUE}│${C_RESET}  ${C_GREEN}✔${C_RESET} Location:      ${C_WHITE}$VENV_PATH${C_RESET}"

"$VENV_PIP" install --quiet --upgrade pip 2>/dev/null
if [ -f "$REPO_DIR/requirements.txt" ]; then
    "$VENV_PIP" install --quiet -r "$REPO_DIR/requirements.txt" 2>/dev/null
else
    "$VENV_PIP" install --quiet -U mlx-lm 2>/dev/null
fi

VERSIONS="$("$VENV_PYTHON" -c "from importlib.metadata import version; print(f'mlx=={version(\"mlx\")}  mlx-lm=={version(\"mlx-lm\")}')" 2>/dev/null || echo "mlx installed")"
echo -e "${C_BLUE}│${C_RESET}  ${C_GREEN}✔${C_RESET} Packages:      ${C_BOLD}${C_GREEN}$VERSIONS${C_RESET}"

GPU_TEST="$("$VENV_PYTHON" -c "import mlx.core as mx; print(mx.default_device())" 2>/dev/null || true)"
echo -e "${C_BLUE}│${C_RESET}  ${C_GREEN}✔${C_RESET} Acceleration:  ${C_BOLD}${C_GREEN}Apple Metal GPU ($GPU_TEST)${C_RESET}"
echo -e "${C_BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""

# -----------------------------------------------------------------------------
# 3. Model Downloads (SvelteKit-Style Interactive Arrow-Key Selector)
# -----------------------------------------------------------------------------
CACHE_DIR="$HOME/.cache/huggingface/hub"
PHI_DIR="$CACHE_DIR/models--${MODEL_PHI//\//--}"
QWEN_DIR="$CACHE_DIR/models--${MODEL_QWEN//\//--}"

PHI_CACHED=false
QWEN_CACHED=false
[ -d "$PHI_DIR" ] && PHI_CACHED=true
[ -d "$QWEN_DIR" ] && QWEN_CACHED=true

DOWNLOAD_FLAG="${1:-}"
SELECTED_MODELS=()

if [ "$DOWNLOAD_FLAG" = "--skip-models" ]; then
    SELECTED_MODELS=()
elif [ "$DOWNLOAD_FLAG" = "--download-models" ]; then
    SELECTED_MODELS=(1 2)
else
    # Launch SvelteKit-style arrow-key multi-select menu via Python
    PICKER_OUTPUT="$("$VENV_PYTHON" -c '
import os, sys, select, tty, termios

models = [
    {
        "id": "1",
        "name": "Phi-4 Mini (3.8B)",
        "size": "2.0 GB",
        "desc": "Reasoning, Logic & General Chat",
        "icon": "🧠",
        "checked": True,
    },
    {
        "id": "2",
        "name": "Qwen2.5-Coder (3B)",
        "size": "1.6 GB",
        "desc": "Dedicated Fast Code Generation",
        "icon": "💻",
        "checked": True,
    },
    {
        "id": "all",
        "name": "Install Both (All)",
        "size": "3.6 GB",
        "desc": "Complete Suite: Chat + Coding",
        "icon": "📦",
        "checked": True,
    },
]

# Check if /dev/tty is available for interactive navigation
try:
    tty_fd = os.open("/dev/tty", os.O_RDWR)
    old_attr = termios.tcgetattr(tty_fd)
except Exception:
    # Non-interactive fallback: select both
    print("1 2")
    sys.exit(0)

C_CYAN = "\033[1;36m"
C_GREEN = "\033[1;32m"
C_MAGENTA = "\033[1;35m"
C_DIM = "\033[2m"
C_BOLD = "\033[1m"
C_RESET = "\033[0m"

def draw(cursor, first=False):
    lines = []
    if not first:
        lines.append(f"\r\033[{len(models) + 4}A")
    lines.append(f"\r\033[K{C_CYAN}┌── [3/4] SELECT MODELS TO INSTALL ───────────────────────────────────────────┐{C_RESET}\n")
    lines.append(f"\r\033[K{C_CYAN}│{C_RESET}\n")
    for i, m in enumerate(models):
        chk = f"[{C_GREEN}●{C_RESET}]" if m["checked"] else f"[{C_DIM}○{C_RESET}]"
        cur = f"{C_CYAN}◆{C_RESET} " if i == cursor else f"{C_DIM}◇{C_RESET} "
        icon = m["icon"]
        name = m["name"].ljust(22)
        size = m["size"].rjust(6)
        desc = m["desc"]
        lines.append(
            f"\r\033[K{C_CYAN}│{C_RESET}  {cur}{chk} {icon} {C_BOLD}{name}{C_RESET} {C_MAGENTA}{size}{C_RESET}  {C_DIM}• {desc}{C_RESET}\n"
        )
    lines.append(f"\r\033[K{C_CYAN}│{C_RESET}\n")
    lines.append(
        f"\r\033[K{C_CYAN}└── Use ↑/↓ to navigate • Space to toggle • Enter to confirm • a for all{C_RESET}\n"
    )
    os.write(tty_fd, "".join(lines).encode("utf-8"))

cursor = 0
tty.setraw(tty_fd)
draw(cursor, first=True)

selected = []
try:
    while True:
        ch = os.read(tty_fd, 1).decode("latin1", errors="ignore")
        if ch == "\x03":
            os.write(tty_fd, b"\r\n")
            sys.exit(130)
        elif ch == "\x1b":
            r, _, _ = select.select([tty_fd], [], [], 0.05)
            if r:
                ch2 = os.read(tty_fd, 1).decode("latin1", errors="ignore")
                if ch2 == "[":
                    r3, _, _ = select.select([tty_fd], [], [], 0.05)
                    if r3:
                        ch3 = os.read(tty_fd, 1).decode("latin1", errors="ignore")
                        if ch3 == "A":
                            cursor = (cursor - 1) % len(models)
                        elif ch3 == "B":
                            cursor = (cursor + 1) % len(models)
            else:
                selected = []
                break
        elif ch in ("\r", "\n"):
            if cursor == 2:
                selected = ["1", "2"]
            else:
                selected = [m["id"] for m in models[:2] if m["checked"]]
            break
        elif ch == " ":
            if cursor == 2:
                new_state = not models[2]["checked"]
                for m in models:
                    m["checked"] = new_state
            else:
                models[cursor]["checked"] = not models[cursor]["checked"]
                models[2]["checked"] = models[0]["checked"] and models[1]["checked"]
        elif ch == "1":
            models[0]["checked"] = not models[0]["checked"]
            models[2]["checked"] = models[0]["checked"] and models[1]["checked"]
        elif ch == "2":
            models[1]["checked"] = not models[1]["checked"]
            models[2]["checked"] = models[0]["checked"] and models[1]["checked"]
        elif ch == "3":
            new_state = not models[2]["checked"]
            for m in models:
                m["checked"] = new_state
        elif ch in ("k", "K"):
            cursor = (cursor - 1) % len(models)
        elif ch in ("j", "J"):
            cursor = (cursor + 1) % len(models)
        elif ch in ("a", "A"):
            new_state = not models[2]["checked"]
            for m in models:
                m["checked"] = new_state
        elif ch in ("s", "S", "q", "Q"):
            selected = []
            break
        draw(cursor)
finally:
    os.write(tty_fd, b"\r\n")
    termios.tcsetattr(tty_fd, termios.TCSADRAIN, old_attr)
    os.close(tty_fd)

print(" ".join(selected))
' || echo "1 2")"

    IFS=' ' read -r -a SELECTED_MODELS <<< "$PICKER_OUTPUT"
fi

DOWNLOAD_PHI=false
DOWNLOAD_QWEN=false

for sel in "${SELECTED_MODELS[@]+"${SELECTED_MODELS[@]}"}"; do
    [ "$sel" = "1" ] && DOWNLOAD_PHI=true
    [ "$sel" = "2" ] && DOWNLOAD_QWEN=true
done

echo -e "${C_BOLD}${C_BLUE}╭── MODEL STATUS & DOWNLOADS ────────────────────────────────────────────────╮${C_RESET}"

if [ "$DOWNLOAD_PHI" = false ] && [ "$DOWNLOAD_QWEN" = false ]; then
    echo -e "${C_BLUE}│${C_RESET}  ${C_DIM}ℹ No models selected for download. You can download anytime using mlxadd.${C_RESET}"
fi

# Phi-4 Mini
if [ "$DOWNLOAD_PHI" = true ]; then
    if [ "$PHI_CACHED" = true ]; then
        sz="$(du -shL "$PHI_DIR" 2>/dev/null | awk '{print $1}')"
        echo -e "${C_BLUE}│${C_RESET}  ${C_GREEN}✔${C_RESET} 🧠 Phi-4 Mini (3.8B)     ${C_GREEN}[Already cached — $sz]${C_RESET}"
    else
        echo -e "${C_BLUE}│${C_RESET}  ⬇ Downloading 🧠 Phi-4 Mini (3.8B)..."
        "$VENV_GENERATE" --model "$MODEL_PHI" --prompt "hello" --max-tokens 1
        sz="$(du -shL "$PHI_DIR" 2>/dev/null | awk '{print $1}' || echo "2.0G")"
        echo -e "${C_BLUE}│${C_RESET}  ${C_GREEN}✔${C_RESET} 🧠 Phi-4 Mini downloaded successfully (${sz})."
        PHI_CACHED=true
    fi
fi

# Qwen2.5-Coder 3B
if [ "$DOWNLOAD_QWEN" = true ]; then
    if [ "$QWEN_CACHED" = true ]; then
        sz="$(du -shL "$QWEN_DIR" 2>/dev/null | awk '{print $1}')"
        echo -e "${C_BLUE}│${C_RESET}  ${C_GREEN}✔${C_RESET} 💻 Qwen2.5-Coder (3B)    ${C_GREEN}[Already cached — $sz]${C_RESET}"
    else
        echo -e "${C_BLUE}│${C_RESET}  ⬇ Downloading 💻 Qwen2.5-Coder (3B)..."
        "$VENV_GENERATE" --model "$MODEL_QWEN" --prompt "hello" --max-tokens 1
        sz="$(du -shL "$QWEN_DIR" 2>/dev/null | awk '{print $1}' || echo "1.6G")"
        echo -e "${C_BLUE}│${C_RESET}  ${C_GREEN}✔${C_RESET} 💻 Qwen2.5-Coder downloaded successfully (${sz})."
        QWEN_CACHED=true
    fi
fi

echo -e "${C_BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""

# -----------------------------------------------------------------------------
# 4. Inject Concrete Dynamic Functions Directly into ~/.zshrc
# -----------------------------------------------------------------------------
echo -e "${C_BOLD}${C_BLUE}╭── [4/4] WRITING DYNAMIC COMMANDS INTO ~/.zshrc ─────────────────────────────╮${C_RESET}"
ZSHRC="$HOME/.zshrc"
START_MARK="# >>> mlx-ai aliases >>>"
END_MARK="# <<< mlx-ai aliases <<<"

touch "$ZSHRC" 2>/dev/null || true

if [ -w "$ZSHRC" ]; then
    sed -i '' "/# >>> mlx-ai environment >>>/,/# <<< mlx-ai environment <<</d" "$ZSHRC" 2>/dev/null || true
    sed -i '' "/$START_MARK/,/$END_MARK/d" "$ZSHRC" 2>/dev/null || true

    # Start writing block
    cat >> "$ZSHRC" << ALIAS_HEADER

$START_MARK
# Apple Silicon LLM — @buildwithfiroz
# Commands work from ANY folder on your MacBook

export MLX_AI_DIR="$REPO_DIR"
export PATH="\$MLX_AI_DIR/myenv/bin:\$PATH"

ALIAS_HEADER

    # Write Phi aliases only if selected by user
    if [ "$DOWNLOAD_PHI" = true ]; then
        cat >> "$ZSHRC" << PHI_BLOCK
# Chat with Phi-4 Mini (3.8B)
mlxphi() {
    source "$REPO_DIR/myenv/bin/activate"
    mlx_lm.chat --model $MODEL_PHI --max-tokens 8192 "\$@"
}

# One-shot prompt with Phi-4 Mini (3.8B)
mlxphig() {
    source "$REPO_DIR/myenv/bin/activate"
    mlx_lm.generate --model $MODEL_PHI --max-tokens 8192 --prompt "\$*"
}

PHI_BLOCK
        # Also define in current session immediately
        eval "mlxphi() { source \"$REPO_DIR/myenv/bin/activate\"; mlx_lm.chat --model $MODEL_PHI --max-tokens 8192 \"\$@\"; }"
        eval "mlxphig() { source \"$REPO_DIR/myenv/bin/activate\"; mlx_lm.generate --model $MODEL_PHI --max-tokens 8192 --prompt \"\$*\"; }"
    else
        unset -f mlxphi mlxphig 2>/dev/null || true
    fi

    # Write Qwen aliases only if selected by user
    if [ "$DOWNLOAD_QWEN" = true ]; then
        cat >> "$ZSHRC" << QWEN_BLOCK
# Chat with Qwen2.5-Coder (3B)
mlxqwen() {
    source "$REPO_DIR/myenv/bin/activate"
    mlx_lm.chat --model $MODEL_QWEN --max-tokens 8192 "\$@"
}

# One-shot code generation with Qwen2.5-Coder (3B)
mlxqweng() {
    source "$REPO_DIR/myenv/bin/activate"
    mlx_lm.generate --model $MODEL_QWEN --max-tokens 4096 --prompt "\$*"
}

QWEN_BLOCK
        # Also define in current session immediately
        eval "mlxqwen() { source \"$REPO_DIR/myenv/bin/activate\"; mlx_lm.chat --model $MODEL_QWEN --max-tokens 8192 \"\$@\"; }"
        eval "mlxqweng() { source \"$REPO_DIR/myenv/bin/activate\"; mlx_lm.generate --model $MODEL_QWEN --max-tokens 4096 --prompt \"\$*\"; }"
    else
        unset -f mlxqwen mlxqweng 2>/dev/null || true
    fi

    # Core utilities: mlxmodels, mlxrun, mlxadd
    cat >> "$ZSHRC" << UTIL_BLOCK
# View cached models, sizes & shortcuts
mlxmodels() {
    local cache="\$HOME/.cache/huggingface/hub"
    echo ""
    echo -e "\033[1;36m╔═════════════════════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;36m║\033[0m   \033[1;37mMLX LOCAL MODELS INVENTORY\033[0m   \033[2m• @buildwithfiroz\033[0m                                 \033[1;36m║\033[0m"
    echo -e "\033[1;36m╚═════════════════════════════════════════════════════════════════════════════╝\033[0m"
    echo ""
    printf "  \033[1;37m%-25s %-10s %-12s %-12s\033[0m\n" "MODEL" "SIZE" "CHAT" "GENERATE"
    printf "  \033[2m%-25s %-10s %-12s %-12s\033[0m\n" "─────────────────────────" "──────────" "────────────" "────────────"

    local phi="\$cache/models--mlx-community--Phi-4-mini-instruct-4bit"
    local qwen="\$cache/models--mlx-community--Qwen2.5-Coder-3B-Instruct-4bit"

    if [ -d "\$phi" ]; then
        printf "  %-25s \033[1;35m%-10s\033[0m \033[1;36m%-12s\033[0m \033[1;36m%-12s\033[0m\n" \
            "Phi-4 Mini" \
            "\$(du -shL "\$phi/snapshots" 2>/dev/null | awk '{print \$1}')" \
            "mlxphi" \
            "mlxphig"
    fi

    if [ -d "\$qwen" ]; then
        printf "  %-25s \033[1;35m%-10s\033[0m \033[1;36m%-12s\033[0m \033[1;36m%-12s\033[0m\n" \
            "Qwen Coder 3B" \
            "\$(du -shL "\$qwen/snapshots" 2>/dev/null | awk '{print \$1}')" \
            "mlxqwen" \
            "mlxqweng"
    fi

    local mdir
    for mdir in "\$cache"/models--mlx-community--*; do
        [ ! -d "\$mdir" ] && continue
        case "\$mdir" in
            *Phi-4-mini*|*Qwen2.5-Coder-3B*) continue ;;
        esac
        local dname="\$(basename "\$mdir" | sed 's/^models--mlx-community--//' | sed 's/-4bit\$//' | sed 's/-/ /g')"
        local sz="\$(du -shL "\$mdir/snapshots" 2>/dev/null | awk '{print \$1}' || echo '?')"
        local prefix="\$(basename "\$mdir" | sed 's/^models--mlx-community--//' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g' | cut -c1-6)"
        printf "  %-25s \033[1;35m%-10s\033[0m \033[1;36m%-12s\033[0m \033[1;36m%-12s\033[0m\n" \
            "\${dname:0:25}" "\$sz" "mlx\${prefix}" "mlx\${prefix}g"
    done
    echo ""
}

# Run any model by repo ID
mlxrun() {
    source "$REPO_DIR/myenv/bin/activate"
    if [ \$# -eq 0 ]; then
        echo "Usage: mlxrun <model-repo-id> \"prompt\" (or mlxrun --chat <model-repo-id>)"
        return 1
    fi
    if [ "\$1" = "--chat" ] || [ "\$1" = "-c" ]; then
        shift
        local m="\$1"; shift
        mlx_lm.chat --model "\$m" --max-tokens 8192 "\$@"
    else
        local m="\$1"; shift
        mlx_lm.generate --model "\$m" --max-tokens 4096 --prompt "\$*"
    fi
}

# Download any new model and automatically create its shell shortcuts in ~/.zshrc
mlxadd() {
    source "$REPO_DIR/myenv/bin/activate"
    local model_id="\$1"
    if [ -z "\$model_id" ]; then
        echo "Usage: mlxadd mlx-community/<model-name>"
        echo "Example: mlxadd mlx-community/Llama-3.2-3B-Instruct-4bit"
        return 1
    fi

    echo "⬇ Downloading \$model_id..."
    mlx_lm.generate --model "\$model_id" --prompt "hello" --max-tokens 1

    local raw_name="\$(echo "\$model_id" | sed 's/^mlx-community\///' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g' | cut -c1-6)"
    local chat_cmd="mlx\${raw_name}"
    local gen_cmd="mlx\${raw_name}g"

    local zshrc="\$HOME/.zshrc"
    if [ -w "\$zshrc" ]; then
        cat << NEWCMD >> "\$zshrc"

# Added by mlxadd for \$model_id
\${chat_cmd}() {
    source "$REPO_DIR/myenv/bin/activate"
    mlx_lm.chat --model \$model_id --max-tokens 8192 "\\\$@"
}
\${gen_cmd}() {
    source "$REPO_DIR/myenv/bin/activate"
    mlx_lm.generate --model \$model_id --max-tokens 4096 --prompt "\\\$*"
}
NEWCMD

        eval "\${chat_cmd}() { source \"$REPO_DIR/myenv/bin/activate\"; mlx_lm.chat --model \$model_id --max-tokens 8192 \"\\\$@\"; }"
        eval "\${gen_cmd}() { source \"$REPO_DIR/myenv/bin/activate\"; mlx_lm.generate --model \$model_id --max-tokens 4096 --prompt \"\\\$*\"; }"

        echo ""
        echo "✅ Model installed and new shortcuts created in ~/.zshrc:"
        echo "   Chat:     \${chat_cmd}"
        echo "   Generate: \${gen_cmd} \"prompt\""
    fi
}
$END_MARK
UTIL_BLOCK

    eval "mlxmodels() { source \"$REPO_DIR/myenv/bin/activate\"; mlxmodels; }" 2>/dev/null || true

    echo -e "${C_BLUE}│${C_RESET}  ${C_GREEN}✔${C_RESET} Standalone commands dynamically injected into ${C_WHITE}~/.zshrc${C_RESET}:"
    if [ "$DOWNLOAD_PHI" = true ]; then
        echo -e "${C_BLUE}│${C_RESET}    • ${C_BOLD}${C_CYAN}mlxphi${C_RESET}   (Phi-4 Mini Chat)"
        echo -e "${C_BLUE}│${C_RESET}    • ${C_BOLD}${C_CYAN}mlxphig${C_RESET}  (Phi-4 Mini Generate)"
    fi
    if [ "$DOWNLOAD_QWEN" = true ]; then
        echo -e "${C_BLUE}│${C_RESET}    • ${C_BOLD}${C_CYAN}mlxqwen${C_RESET}  (Qwen2.5-Coder Chat)"
        echo -e "${C_BLUE}│${C_RESET}    • ${C_BOLD}${C_CYAN}mlxqweng${C_RESET} (Qwen2.5-Coder Generate)"
    fi
    echo -e "${C_BLUE}│${C_RESET}    • ${C_BOLD}${C_CYAN}mlxmodels${C_RESET}(Inventory Table)"
    echo -e "${C_BLUE}│${C_RESET}    • ${C_BOLD}${C_CYAN}mlxadd${C_RESET}   (Add model & auto-create shortcuts)"
    echo -e "${C_BLUE}│${C_RESET}    • ${C_BOLD}${C_CYAN}mlxrun${C_RESET}   (Run any model by ID)"
fi
echo -e "${C_BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""

# -----------------------------------------------------------------------------
# Summary & Auto-Reload
# -----------------------------------------------------------------------------
echo -e "${C_GREEN}╔═════════════════════════════════════════════════════════════════════════════╗${C_RESET}"
echo -e "${C_GREEN}║${C_RESET}  ${C_BOLD}${C_GREEN}🎉 SETUP COMPLETE! YOUR COMMANDS ARE ACTIVE EVERYWHERE ON YOUR MAC${C_RESET}       ${C_GREEN}║${C_RESET}"
echo -e "${C_GREEN}╚═════════════════════════════════════════════════════════════════════════════╝${C_RESET}"
echo ""
echo -e "  ${C_BOLD}${C_WHITE}COMMANDS READY IN YOUR SHELL:${C_RESET}"
if [ "$DOWNLOAD_PHI" = true ]; then
    echo -e "    ${C_BOLD}${C_CYAN}mlxphi${C_RESET}                  ${C_WHITE}Interactive chat with Phi-4 Mini (3.8B)${C_RESET}"
    echo -e "    ${C_BOLD}${C_CYAN}mlxphig \"prompt\"${C_RESET}        ${C_WHITE}One-shot reasoning prompt with Phi-4 Mini${C_RESET}"
fi
if [ "$DOWNLOAD_QWEN" = true ]; then
    echo -e "    ${C_BOLD}${C_CYAN}mlxqwen${C_RESET}                 ${C_WHITE}Interactive chat with Qwen2.5-Coder (3B)${C_RESET}"
    echo -e "    ${C_BOLD}${C_CYAN}mlxqweng \"prompt\"${C_RESET}       ${C_WHITE}One-shot code generation with Qwen2.5-Coder${C_RESET}"
fi
if [ "$DOWNLOAD_PHI" = false ] && [ "$DOWNLOAD_QWEN" = false ]; then
    echo -e "    ${C_DIM}(No model shortcuts configured. Run mlxadd to add one anytime)${C_RESET}"
fi
echo -e "    ${C_BOLD}${C_CYAN}mlxmodels${C_RESET}               ${C_WHITE}View cached models, real disk sizes & shortcuts${C_RESET}"
echo -e "    ${C_BOLD}${C_CYAN}mlxadd <model-id>${C_RESET}       ${C_WHITE}Download any HF model & auto-generate its shortcuts${C_RESET}"
echo -e "    ${C_BOLD}${C_CYAN}mlxrun <model> \"prompt\"${C_RESET} ${C_WHITE}Run any model by Hugging Face repo ID${C_RESET}"
echo ""
echo -e "  ${C_DIM}Built by @buildwithfiroz • https://github.com/buildwithfiroz/apple-silicon-llm${C_RESET}"
echo ""

# Auto-reload shell for user's interactive terminal session
if [ -t 0 ] && [ -t 1 ] && [ -z "${ANTIGRAVITY_CSRF_TOKEN:-}" ] && [ -z "${ANTIGRAVITY_AGENT:-}" ] && [ -z "${CI:-}" ]; then
    echo -e "  ${C_GREEN}⚡ Auto-activating your shell... All commands are ready right now!${C_RESET}"
    sleep 0.5
    exec zsh -l
else
    echo -e "  ${C_GREEN}⚡ Commands registered! In other open terminal tabs, run:${C_RESET} ${C_BOLD}${C_WHITE}source ~/.zshrc${C_RESET}"
    echo ""
fi
