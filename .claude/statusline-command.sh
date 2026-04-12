#!/bin/sh
#
# Claude Code status line.
# Renders: model (session) [agent] style vim | context % | cost +lines -lines
#          | 5h bar + pace delta | 7d bar
#          dir | worktree | git branch +staged ~modified ?untracked ↑ahead ↓behind
#          current time
#
# Wire it up in ~/.claude/settings.json:
#     "statusLine": {
#         "type": "command",
#         "command": "sh ~/.claude/statusline-command.sh"
#     }
#
# Requires: jq (https://jqlang.github.io/jq/)
#     macOS:         brew install jq
#     Debian/Ubuntu: sudo apt install jq
#     Fedora/RHEL:   sudo dnf install jq
#     Arch:          sudo pacman -S jq
#     Alpine:        sudo apk add jq
#     Windows:       winget install jqlang.jq   (or: scoop install jq)
#
# POSIX sh; tested on GNU coreutils and BSD (macOS) date.

input=$(cat)

eval "$(printf '%s' "$input" | jq -r '
    {
        model: (.model.display_name // "Unknown Model"),
        used: (.context_window.used_percentage | if . != null then tostring else "" end),
        exceeds_200k: (if .exceeds_200k_tokens == true then "true" else "" end),
        worktree: (.worktree.name // ""),
        total_cost: (.cost.total_cost_usd | if . != null then tostring else "" end),
        lines_added: (.cost.total_lines_added | if . != null and . > 0 then tostring else "" end),
        lines_removed: (.cost.total_lines_removed | if . != null and . > 0 then tostring else "" end),
        current_dir: (.workspace.current_dir // .worktree.original_cwd // ""),
        session_name: (.session_name // ""),
        agent_name: (.agent.name // ""),
        output_style: ((.output_style.name // "") | if . == "default" or . == "" then "" else . end),
        vim_mode: (.vim.mode // ""),
        rl_5h_pct: (.rate_limits.five_hour.used_percentage | if . != null then (. + 0.5 | floor | tostring) else "" end),
        rl_5h_reset: (.rate_limits.five_hour.resets_at | if . != null then tostring else "" end),
        rl_7d_pct: (.rate_limits.seven_day.used_percentage | if . != null then (. + 0.5 | floor | tostring) else "" end),
        rl_7d_reset: (.rate_limits.seven_day.resets_at | if . != null then tostring else "" end)
    } | to_entries[] | "\(.key)=\(.value | @sh)"
')"

ESC=$(printf '\033')
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
RED="${ESC}[31m"
RESET="${ESC}[0m"

if [ -n "$used" ]; then
    usage_str="$(printf '%.0f' "$used")%"
else
    usage_str=""
fi

git_str=""
if git rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null)
    [ -z "$branch" ] && branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    staged=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' \t')
    modified=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' \t')
    untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' \t')

    # Ahead/behind upstream; silent when no upstream is configured.
    ahead=0
    behind=0
    updown=$(git rev-list --left-right --count '@{u}...HEAD' 2>/dev/null)
    if [ -n "$updown" ]; then
        behind=$(printf '%s' "$updown" | cut -f1)
        ahead=$(printf '%s' "$updown" | cut -f2)
    fi

    git_str="$branch"
    [ "${staged:-0}" -gt 0 ]    && git_str="${git_str} ${GREEN}+${staged}${RESET}"
    [ "${modified:-0}" -gt 0 ]  && git_str="${git_str} ${YELLOW}~${modified}${RESET}"
    [ "${untracked:-0}" -gt 0 ] && git_str="${git_str} ${RED}?${untracked}${RESET}"
    [ "${ahead:-0}" -gt 0 ]     && git_str="${git_str} ↑${ahead}"
    [ "${behind:-0}" -gt 0 ]    && git_str="${git_str} ↓${behind}"
else
    git_str="no branch"
fi

if [ -n "$total_cost" ]; then
    block_str=$(awk -v c="$total_cost" 'BEGIN { printf "$%.2f", c }')
else
    block_str=""
fi

# Portable strftime: tries BSD `date -r <epoch>` first, falls back to GNU
# `date -d @<epoch>`. Strips a single leading "0" when followed by 1-9 so
# `%I` (12-hour, zero-padded) renders like GNU's `%-I` on macOS too.
fmt_epoch() {
    ts=$1
    f=$2
    out=$(date -r "$ts" "$f" 2>/dev/null || date -d "@$ts" "$f" 2>/dev/null)
    case "$out" in
        0[1-9]*) out=${out#0} ;;
    esac
    printf '%s' "$out"
}

# Same zero-strip for `date` called on the current time.
fmt_now() {
    out=$(date "$1")
    case "$out" in
        0[1-9]*) out=${out#0} ;;
    esac
    printf '%s' "$out"
}

make_bar() {
    pct="$1"
    width=10
    filled=$((pct * width / 100))
    [ "$filled" -lt 0 ] && filled=0
    [ "$filled" -gt "$width" ] && filled=$width
    bar=""
    i=0
    while [ $i -lt $filled ]; do
        bar="${bar}█"
        i=$((i + 1))
    done
    while [ $i -lt $width ]; do
        bar="${bar}░"
        i=$((i + 1))
    done
    printf '%s' "$bar"
}

format_rl() {
    pct="$1"
    reset_ts="$2"
    date_fmt="$3"
    [ -z "$pct" ] && return
    if [ "$pct" -ge 90 ]; then
        color="$RED"
    elif [ "$pct" -ge 70 ]; then
        color="$YELLOW"
    else
        color="$GREEN"
    fi
    reset_time=$(fmt_epoch "$reset_ts" "$date_fmt")
    bar=$(make_bar "$pct")
    printf '%s%s %s%% 🗘 %s%s' "$color" "$bar" "$pct" "$reset_time" "$RESET"
}

now=$(date +%s)

rate_limit_5h_str="$(format_rl "$rl_5h_pct" "$rl_5h_reset" "+%I%p")"
if [ -n "$rl_5h_pct" ] && [ -n "$rl_5h_reset" ]; then
    diff=$((rl_5h_reset - now))
    if [ "$diff" -gt 0 ]; then
        hours=$((diff / 3600))
        minutes=$(((diff % 3600) / 60))
        if [ "$hours" -gt 0 ]; then
            rate_limit_5h_str="${rate_limit_5h_str} (${hours}h)"
        else
            rate_limit_5h_str="${rate_limit_5h_str} (${minutes}m)"
        fi
    fi

    # Pace delta: compare usage % against time-elapsed % of the 5h window.
    # Positive = burning faster than sustainable, negative = headroom.
    window=18000
    window_start=$((rl_5h_reset - window))
    elapsed=$((now - window_start))
    [ "$elapsed" -lt 0 ] && elapsed=0
    [ "$elapsed" -gt "$window" ] && elapsed=$window
    elapsed_pct=$((elapsed * 100 / window))
    pace_delta=$((rl_5h_pct - elapsed_pct))
    if [ "$pace_delta" -gt 0 ]; then
        rate_limit_5h_str="${rate_limit_5h_str} ${RED}⇡${pace_delta}%${RESET}"
    elif [ "$pace_delta" -lt 0 ]; then
        abs_delta=$((-pace_delta))
        rate_limit_5h_str="${rate_limit_5h_str} ${GREEN}⇣${abs_delta}%${RESET}"
    fi
fi

fmt="+%a"
if [ -n "$rl_7d_reset" ]; then
    today_date=$(date "+%Y-%m-%d")
    reset_date=$(fmt_epoch "$rl_7d_reset" "+%Y-%m-%d")
    if [ -n "$reset_date" ] && [ "$reset_date" = "$today_date" ]; then
        fmt="+%I%p"
    fi
fi

rate_limit_7d_str="$(format_rl "$rl_7d_pct" "$rl_7d_reset" "$fmt")"
if [ -n "$rl_7d_pct" ] && [ -n "$rl_7d_reset" ]; then
    diff=$((rl_7d_reset - now))
    if [ "$diff" -gt 0 ]; then
        days=$((diff / 86400))
        hours=$(((diff % 86400) / 3600))
        minutes=$(((diff % 3600) / 60))
        if [ "$days" -gt 0 ]; then
            rate_limit_7d_str="${rate_limit_7d_str} (${days}d)"
        elif [ "$hours" -gt 0 ]; then
            rate_limit_7d_str="${rate_limit_7d_str} (${hours}h)"
        else
            rate_limit_7d_str="${rate_limit_7d_str} (${minutes}m)"
        fi
    fi
fi

home="$HOME"
if [ -n "$current_dir" ]; then
    case "$current_dir" in
        "$home"*) dir_display="~${current_dir#$home}" ;;
        *) dir_display="$current_dir" ;;
    esac
else
    dir_display="$(pwd)"
    case "$dir_display" in
        "$home"*) dir_display="~${dir_display#$home}" ;;
    esac
fi

current_time=$(fmt_now "+%I:%M %p")
time_str="🕐 ${current_time}"

# Build line 1: model/identity → context → cost/lines → rate limits
line1="${model}"
[ -n "$session_name" ] && line1="${line1} (${session_name})"
[ -n "$agent_name" ] && line1="${line1} [${agent_name}]"
[ -n "$output_style" ] && line1="${line1} ${output_style}"
[ -n "$vim_mode" ] && line1="${line1} ${vim_mode}"

if [ -n "$usage_str" ]; then
    ctx="Context: ${usage_str}"
    [ -n "$exceeds_200k" ] && ctx="${ctx} (${RED}⚠ >200k${RESET})"
    line1="${line1} | ${ctx}"
fi

if [ -n "$block_str" ]; then
    cost_seg="Session: ${block_str}"
    lines_seg=""
    [ -n "$lines_added" ] && lines_seg="${GREEN}+${lines_added}${RESET}"
    if [ -n "$lines_removed" ]; then
        [ -n "$lines_seg" ] && lines_seg="${lines_seg} "
        lines_seg="${lines_seg}${RED}-${lines_removed}${RESET}"
    fi
    [ -n "$lines_seg" ] && cost_seg="${cost_seg} (${lines_seg})"
    line1="${line1} | ${cost_seg}"
fi

[ -n "$rate_limit_5h_str" ] && line1="${line1} | 5h: ${rate_limit_5h_str}"
[ -n "$rate_limit_7d_str" ] && line1="${line1} | 7d: ${rate_limit_7d_str}"
line2="📁 ${dir_display}"
[ -n "$worktree" ] && line2="${line2} | 🌳 ${worktree}"
line2="${line2} | 🌿 ${git_str}"

printf '%s\n%s\n%s' "$line1" "$line2" "$time_str"
