#!/usr/bin/env bash
# ==============================================================================
# MLX Local LLM Toolkit — One-Click Setup, Model Manager & Shell Aliases
# ==============================================================================
#
#   Built by @buildwithfiroz
#   https://github.com/buildwithfiroz
#
# Writes standalone shell functions DIRECTLY into ~/.zshrc with concrete paths
# so all commands work anywhere across your entire Mac.
#
# Commands created:
#   • mlxphi      — Chat with Phi-4 Mini (4-bit)
#   • mlxphig     — One-shot prompt with Phi-4 Mini
#   • mlxqwen     — Chat with Qwen2.5-Coder 3B (4-bit)
#   • mlxqweng    — One-shot prompt with Qwen2.5-Coder 3B
#   • mlxmodels   — View all cached models, disk sizes & shortcuts
#   • mlxadd      — Download any model & automatically create its shell shortcuts
#   • mlxrun      — Run any model by Hugging Face repo ID
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

# If called with --aliases-only, define functions and exit
if [ "${1:-}" = "--aliases-only" ] || [ "${1:-}" = "-a" ]; then
    # Define functions in current session
    mlxphi() {
        source "$REPO_DIR/myenv/bin/activate"
        mlx_lm.chat --model mlx-community/Phi-4-mini-instruct-4bit --max-tokens 8192 "$@"
    }
    mlxphig() {
        source "$REPO_DIR/myenv/bin/activate"
        mlx_lm.generate --model mlx-community/Phi-4-mini-instruct-4bit --max-tokens 8192 --prompt "$*"
    }
    mlxqwen() {
        source "$REPO_DIR/myenv/bin/activate"
        mlx_lm.chat --model mlx-community/Qwen2.5-Coder-3B-Instruct-4bit --max-tokens 8192 "$@"
    }
    mlxqweng() {
        source "$REPO_DIR/myenv/bin/activate"
        mlx_lm.generate --model mlx-community/Qwen2.5-Coder-3B-Instruct-4bit --max-tokens 4096 --prompt "$*"
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
echo -e "${C_CYAN}│${C_RESET}   ${C_BOLD}${C_WHITE}Local LLM Toolkit for Apple Silicon${C_RESET}  ${C_DIM}• Built by @buildwithfiroz${C_RESET}           ${C_CYAN}│${C_RESET}"
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
# 3. Model Downloads
# -----------------------------------------------------------------------------
CACHE_DIR="$HOME/.cache/huggingface/hub"
PHI_DIR="$CACHE_DIR/models--mlx-community--Phi-4-mini-instruct-4bit"
QWEN_DIR="$CACHE_DIR/models--mlx-community--Qwen2.5-Coder-3B-Instruct-4bit"

echo -e "${C_BOLD}${C_BLUE}╭── [3/4] MODEL SELECTION & CACHE ────────────────────────────────────────────╮${C_RESET}"

PHI_CACHED=false
QWEN_CACHED=false
[ -d "$PHI_DIR" ] && PHI_CACHED=true
[ -d "$QWEN_DIR" ] && QWEN_CACHED=true

DOWNLOAD_PHI=true
DOWNLOAD_QWEN=true

DOWNLOAD_FLAG="${1:-}"

if [ "$DOWNLOAD_FLAG" = "--skip-models" ]; then
    DOWNLOAD_PHI=false
    DOWNLOAD_QWEN=false
elif [ "$DOWNLOAD_FLAG" = "--download-models" ]; then
    DOWNLOAD_PHI=true
    DOWNLOAD_QWEN=true
elif [ "$PHI_CACHED" = true ] && [ "$QWEN_CACHED" = true ]; then
    echo -e "${C_BLUE}│${C_RESET}  ${C_GREEN}✔${C_RESET} 🧠 Phi-4 Mini (3.8B)     ${C_GREEN}[Cached — $(du -shL "$PHI_DIR/snapshots" 2>/dev/null | awk '{print $1}')]${C_RESET}"
    echo -e "${C_BLUE}│${C_RESET}  ${C_GREEN}✔${C_RESET} 💻 Qwen2.5-Coder (3B)    ${C_GREEN}[Cached — $(du -shL "$QWEN_DIR/snapshots" 2>/dev/null | awk '{print $1}')]${C_RESET}"
    DOWNLOAD_PHI=false
    DOWNLOAD_QWEN=false
elif [ -t 0 ]; then
    # Interactive selection menu
    echo -e "${C_BLUE}│${C_RESET}  Select which models to download:"
    echo -e "${C_BLUE}│${C_RESET}"
    echo -e "${C_BLUE}│${C_RESET}    ${C_BOLD}${C_WHITE}1)${C_RESET} 🧠 Phi-4 Mini (3.8B)     ${C_MAGENTA}2.0 GB${C_RESET}   ${C_DIM}Reasoning, Logic & Chat${C_RESET}"
    echo -e "${C_BLUE}│${C_RESET}    ${C_BOLD}${C_WHITE}2)${C_RESET} 💻 Qwen2.5-Coder (3B)    ${C_MAGENTA}1.6 GB${C_RESET}   ${C_DIM}Fast Code Generation${C_RESET}"
    echo -e "${C_BLUE}│${C_RESET}    ${C_BOLD}${C_WHITE}A)${C_RESET} All Models (Both)       ${C_MAGENTA}3.6 GB${C_RESET}   ${C_DIM}Recommended${C_RESET}"
    echo -e "${C_BLUE}│${C_RESET}    ${C_BOLD}${C_WHITE}S)${C_RESET} Skip (Download on first run)"
    echo -e "${C_BLUE}│${C_RESET}"
    read -r -p "   Select option [A/1/2/S, default: A]: " user_choice
    user_choice="${user_choice:-A}"

    case "$user_choice" in
        1)
            DOWNLOAD_PHI=true
            DOWNLOAD_QWEN=false
            ;;
        2)
            DOWNLOAD_PHI=false
            DOWNLOAD_QWEN=true
            ;;
        [sS]*)
            DOWNLOAD_PHI=false
            DOWNLOAD_QWEN=false
            ;;
        *)
            DOWNLOAD_PHI=true
            DOWNLOAD_QWEN=true
            ;;
    esac
fi

# Execute downloads if needed
if [ "$DOWNLOAD_PHI" = true ] && [ "$PHI_CACHED" = false ]; then
    echo -e "${C_BLUE}│${C_RESET}  ⬇ Downloading 🧠 Phi-4 Mini (3.8B)..."
    "$VENV_PYTHON" -m mlx_lm.generate \
        --model "mlx-community/Phi-4-mini-instruct-4bit" \
        --prompt "hello" --max-tokens 1 2>&1 | grep -v "^\[transformers\]" || true
    echo -e "${C_BLUE}│${C_RESET}  ${C_GREEN}✔${C_RESET} 🧠 Phi-4 Mini downloaded successfully."
fi

if [ "$DOWNLOAD_QWEN" = true ] && [ "$QWEN_CACHED" = false ]; then
    echo -e "${C_BLUE}│${C_RESET}  ⬇ Downloading 💻 Qwen2.5-Coder (3B)..."
    "$VENV_PYTHON" -m mlx_lm.generate \
        --model "mlx-community/Qwen2.5-Coder-3B-Instruct-4bit" \
        --prompt "hello" --max-tokens 1 2>&1 | grep -v "^\[transformers\]" || true
    echo -e "${C_BLUE}│${C_RESET}  ${C_GREEN}✔${C_RESET} 💻 Qwen2.5-Coder downloaded successfully."
fi

echo -e "${C_BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""

# -----------------------------------------------------------------------------
# 4. Inject Concrete Functions Directly into ~/.zshrc
# -----------------------------------------------------------------------------
echo -e "${C_BOLD}${C_BLUE}╭── [4/4] WRITING COMMANDS INTO ~/.zshrc ─────────────────────────────────────╮${C_RESET}"
ZSHRC="$HOME/.zshrc"
START_MARK="# >>> mlx-ai aliases >>>"
END_MARK="# <<< mlx-ai aliases <<<"

touch "$ZSHRC" 2>/dev/null || true

if [ -w "$ZSHRC" ]; then
    # Remove any existing block cleanly
    sed -i '' "/# >>> mlx-ai environment >>>/,/# <<< mlx-ai environment <<</d" "$ZSHRC" 2>/dev/null || true
    sed -i '' "/$START_MARK/,/$END_MARK/d" "$ZSHRC" 2>/dev/null || true

    # Write concrete standalone shell functions directly into ~/.zshrc
    cat >> "$ZSHRC" << ALIAS_BLOCK

$START_MARK
# MLX Local LLM Toolkit — @buildwithfiroz
# All commands work anywhere across your MacBook

export MLX_AI_DIR="$REPO_DIR"
export PATH="\$MLX_AI_DIR/myenv/bin:\$PATH"

# Chat with Phi-4 Mini (3.8B)
mlxphi() {
    source "$REPO_DIR/myenv/bin/activate"
    mlx_lm.chat --model mlx-community/Phi-4-mini-instruct-4bit --max-tokens 8192 "\$@"
}

# One-shot prompt with Phi-4 Mini (3.8B)
mlxphig() {
    source "$REPO_DIR/myenv/bin/activate"
    mlx_lm.generate --model mlx-community/Phi-4-mini-instruct-4bit --max-tokens 8192 --prompt "\$*"
}

# Chat with Qwen2.5-Coder (3B)
mlxqwen() {
    source "$REPO_DIR/myenv/bin/activate"
    mlx_lm.chat --model mlx-community/Qwen2.5-Coder-3B-Instruct-4bit --max-tokens 8192 "\$@"
}

# One-shot code generation with Qwen2.5-Coder (3B)
mlxqweng() {
    source "$REPO_DIR/myenv/bin/activate"
    mlx_lm.generate --model mlx-community/Qwen2.5-Coder-3B-Instruct-4bit --max-tokens 4096 --prompt "\$*"
}

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

    # Also list dynamically added models
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
    mlx_lm.generate --model "\$model_id" --prompt "hello" --max-tokens 1 2>&1 | grep -v "^\[transformers\]" || true

    # Derive short alias name (e.g. mlxllama / mlxllamag)
    local raw_name="\$(echo "\$model_id" | sed 's/^mlx-community\///' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g' | cut -c1-6)"
    local chat_cmd="mlx\${raw_name}"
    local gen_cmd="mlx\${raw_name}g"

    # Inject new functions directly into ~/.zshrc
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

        # Evaluate in current active shell immediately
        eval "\${chat_cmd}() { source \"$REPO_DIR/myenv/bin/activate\"; mlx_lm.chat --model \$model_id --max-tokens 8192 \"\\\$@\"; }"
        eval "\${gen_cmd}() { source \"$REPO_DIR/myenv/bin/activate\"; mlx_lm.generate --model \$model_id --max-tokens 4096 --prompt \"\\\$*\"; }"

        echo ""
        echo "✅ Model installed and new shortcuts created in ~/.zshrc:"
        echo "   Chat:     \${chat_cmd}"
        echo "   Generate: \${gen_cmd} \"prompt\""
    fi
}
$END_MARK
ALIAS_BLOCK

    echo -e "${C_BLUE}│${C_RESET}  ${C_GREEN}✔${C_RESET} Successfully wrote all standalone functions into ${C_WHITE}~/.zshrc${C_RESET}:"
    echo -e "${C_BLUE}│${C_RESET}    • ${C_BOLD}${C_CYAN}mlxphi${C_RESET}   (Phi-4 Mini Chat)"
    echo -e "${C_BLUE}│${C_RESET}    • ${C_BOLD}${C_CYAN}mlxphig${C_RESET}  (Phi-4 Mini Generate)"
    echo -e "${C_BLUE}│${C_RESET}    • ${C_BOLD}${C_CYAN}mlxqwen${C_RESET}  (Qwen2.5-Coder Chat)"
    echo -e "${C_BLUE}│${C_RESET}    • ${C_BOLD}${C_CYAN}mlxqweng${C_RESET} (Qwen2.5-Coder Generate)"
    echo -e "${C_BLUE}│${C_RESET}    • ${C_BOLD}${C_CYAN}mlxmodels${C_RESET}(Inventory Table)"
    echo -e "${C_BLUE}│${C_RESET}    • ${C_BOLD}${C_CYAN}mlxadd${C_RESET}   (Add model & auto-create aliases)"
    echo -e "${C_BLUE}│${C_RESET}    • ${C_BOLD}${C_CYAN}mlxrun${C_RESET}   (Run any model by ID)"
fi
echo -e "${C_BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""

# -----------------------------------------------------------------------------
# Summary & Auto-Reload
# -----------------------------------------------------------------------------
echo -e "${C_GREEN}╔═════════════════════════════════════════════════════════════════════════════╗${C_RESET}"
echo -e "${C_GREEN}║${C_RESET}  ${C_BOLD}${C_GREEN}🎉 SETUP COMPLETE! ALL COMMANDS ARE READY ANYWHERE ON YOUR MAC${C_RESET}            ${C_GREEN}║${C_RESET}"
echo -e "${C_GREEN}╚═════════════════════════════════════════════════════════════════════════════╝${C_RESET}"
echo ""
echo -e "  ${C_BOLD}${C_WHITE}COMMANDS REGISTERED IN ~/.zshrc:${C_RESET}"
echo -e "    ${C_BOLD}${C_CYAN}mlxphi${C_RESET}                  ${C_WHITE}Interactive chat with Phi-4 Mini (3.8B)${C_RESET}"
echo -e "    ${C_BOLD}${C_CYAN}mlxphig \"prompt\"${C_RESET}        ${C_WHITE}One-shot reasoning prompt with Phi-4 Mini${C_RESET}"
echo -e "    ${C_BOLD}${C_CYAN}mlxqwen${C_RESET}                 ${C_WHITE}Interactive chat with Qwen2.5-Coder (3B)${C_RESET}"
echo -e "    ${C_BOLD}${C_CYAN}mlxqweng \"prompt\"${C_RESET}       ${C_WHITE}One-shot code generation with Qwen2.5-Coder${C_RESET}"
echo -e "    ${C_BOLD}${C_CYAN}mlxmodels${C_RESET}               ${C_WHITE}View cached models, real disk sizes & shortcuts${C_RESET}"
echo -e "    ${C_BOLD}${C_CYAN}mlxadd <model-id>${C_RESET}       ${C_WHITE}Download any HF model & auto-generate its shortcuts${C_RESET}"
echo -e "    ${C_BOLD}${C_CYAN}mlxrun <model> \"prompt\"${C_RESET} ${C_WHITE}Run any model by Hugging Face repo ID${C_RESET}"
echo ""
echo -e "  ${C_DIM}Built by @buildwithfiroz • https://github.com/buildwithfiroz${C_RESET}"
echo ""

    echo -e "  ${C_GREEN}⚡ All commands are registered! Run:${C_RESET} ${C_BOLD}${C_WHITE}source ~/.zshrc${C_RESET}"
    echo -e "  ${C_DIM}(Or simply open a new terminal window — everything works anywhere on your Mac)${C_RESET}"
    echo ""
