#!/bin/bash

# Claude Code Status Line - Rich metrics with progress bars
# Reads JSON from stdin with session/context data

input=$(cat)

# ── Parse JSON fields ──────────────────────────────────────────────
model_name=$(echo "$input" | jq -r '.model.display_name')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')
version=$(echo "$input" | jq -r '.version')
session_id=$(echo "$input" | jq -r '.session_id')

# Context window metrics
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // 100')


# Vim mode & agent info
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
agent_name=$(echo "$input" | jq -r '.agent.name // empty')

# ── Git info ───────────────────────────────────────────────────────
git_branch=""
git_status=""
if git -C "$current_dir" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$current_dir" --no-optional-locks branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        git_branch="$branch"
        if ! git -C "$current_dir" --no-optional-locks diff --quiet 2>/dev/null || \
           ! git -C "$current_dir" --no-optional-locks diff --cached --quiet 2>/dev/null; then
            git_status="*"
        fi
    fi
fi

# ── Helper: progress bar ──────────────────────────────────────────
progress_bar() {
    local percentage=$1
    local width=12
    local filled=$(printf "%.0f" $(echo "$percentage * $width / 100" | bc -l 2>/dev/null || echo "0"))
    local empty=$((width - filled))

    local color
    if [ "$percentage" -lt 50 ]; then
        color="32" # Green
    elif [ "$percentage" -lt 75 ]; then
        color="33" # Yellow
    else
        color="31" # Red
    fi

    printf "\033[${color}m"
    for ((i=0; i<filled; i++)); do printf "▓"; done
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "\033[0m"
}

# ── Helper: format large numbers ──────────────────────────────────
fmt() {
    local num=$1
    if [ "$num" -ge 1000000 ]; then
        printf "%.1fM" $(echo "scale=1; $num / 1000000" | bc)
    elif [ "$num" -ge 1000 ]; then
        printf "%.1fK" $(echo "scale=1; $num / 1000" | bc)
    else
        printf "%d" "$num"
    fi
}

# ── Build components ──────────────────────────────────────────────
parts=()

# Model
parts+=("$(printf "\033[38;5;208mClaude Code: %s\033[0m" "$model_name")")

# Output style (if not default)
if [ "$output_style" != "default" ]; then
    parts+=("$(printf "\033[96m◈ %s\033[0m" "$output_style")")
fi

# Git branch or working directory
if [ -n "$git_branch" ]; then
    parts+=("$(printf "\033[34m⎇ %s%s\033[0m" "$git_branch" "$git_status")")
else
    dir_display=$(basename "$current_dir")
    parts+=("$(printf "\033[34m%s\033[0m" "$dir_display")")
fi

# Vim mode
if [ -n "$vim_mode" ]; then
    if [ "$vim_mode" = "INSERT" ]; then
        parts+=("$(printf "\033[32m◆ INS\033[0m")")
    else
        parts+=("$(printf "\033[36m◇ NOR\033[0m")")
    fi
fi

# Agent mode
if [ -n "$agent_name" ]; then
    parts+=("$(printf "\033[91m⚡%s\033[0m" "$agent_name")")
fi

# Context window with progress bar
if [ "$total_input" -gt 0 ]; then
    used_int=$(printf "%.0f" "$used_pct")
    bar=$(progress_bar "$used_int")
    parts+=("$(printf "ctx %s %d%%" "$bar" "$used_int")")
fi

# Total session tokens
if [ "$total_input" -gt 0 ]; then
    total=$(fmt $((total_input + total_output)))
    parts+=("$(printf "\033[94m↕ %s\033[0m" "$total")")
fi



# ── Join with separator ───────────────────────────────────────────
sep=" \033[90m│\033[0m "
result=""
for i in "${!parts[@]}"; do
    if [ "$i" -gt 0 ]; then
        result+="$sep"
    fi
    result+="${parts[$i]}"
done

printf "%b\n" "$result"
