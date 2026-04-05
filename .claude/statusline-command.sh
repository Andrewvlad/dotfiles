#!/bin/sh
input=$(cat)

eval "$(echo "$input" | jq -r '
  {
    model: (.model.display_name // "Unknown Model"),
    used: (.context_window.used_percentage | if . then tostring else "" end),
    worktree: (.worktree.name // ""),
    total_cost: (.cost.total_cost_usd | if . then tostring else "" end),
    current_dir: (.worktree.original_cwd // ""),
    rl_5h_pct: (.rate_limits.five_hour.used_percentage | if . then (. + 0.5 | floor | tostring) else "" end),
    rl_5h_reset: (.rate_limits.five_hour.resets_at | if . then tostring else "" end),
    rl_7d_pct: (.rate_limits.seven_day.used_percentage | if . then (. + 0.5 | floor | tostring) else "" end),
    rl_7d_reset: (.rate_limits.seven_day.resets_at | if . then tostring else "" end)
  } | to_entries[] | "\(.key)=\(.value | @sh)"
')"

if [ -n "$used" ]; then
	usage_str="$(printf "%.0f" "$used")%"
else
	usage_str=""
fi

worktree_str="${worktree:-no worktree}"

GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

git_str=""
if git rev-parse --git-dir >/dev/null 2>&1; then
	branch=$(git branch --show-current 2>/dev/null)
	[ -z "$branch" ] && branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
	staged=$(git diff --cached --numstat 2>/dev/null | wc -l)
	modified=$(git diff --numstat 2>/dev/null | wc -l)

	git_str="$branch"
	[ "$staged" -gt 0 ] && git_str="${git_str} $(printf "${GREEN}+${staged}${RESET}")"
	[ "$modified" -gt 0 ] && git_str="${git_str} $(printf "${YELLOW}~${modified}${RESET}")"
else
	git_str="no branch"
fi

if [ -n "$total_cost" ]; then
	block_str="\$$(awk "BEGIN { printf \"%.2f\", $total_cost }")"
else
	block_str=""
fi

make_bar() {
	pct="$1"
	width=10
	filled=$((pct * width / 100))
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
	printf "%s" "$bar"
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
	reset_time=$(date -r "$reset_ts" "$date_fmt" 2>/dev/null || date -d "@$reset_ts" "$date_fmt" 2>/dev/null)
	bar=$(make_bar "$pct")
	printf "${color}${bar} ${pct}%% 🗘 ${reset_time}${RESET}"
}

now=$(date +%s)

rate_limit_5h_str="$(format_rl "$rl_5h_pct" "$rl_5h_reset" "+%-I%p")"
if [ -n "$rl_5h_pct" ] && [ -n "$rl_5h_reset" ]; then
	diff=$((rl_5h_reset - now))
	if [ "$diff" -gt 0 ]; then
		hours=$((diff / 3600))
		if [ "$hours" -gt 0 ]; then
			rate_limit_5h_str="${rate_limit_5h_str} (${hours}h)"
		else
			rate_limit_5h_str="${rate_limit_5h_str} ($((diff / 60))m)"
		fi
	fi
fi

if ( (rl_7d_reset - now -lt 86000)); then
	fmt="+%-I%p"
else
	fmt="+%-a"
fi

rate_limit_7d_str="$(format_rl "$rl_7d_pct" "$rl_7d_reset" "$fmt")"
if [ -n "$rl_7d_pct" ] && [ -n "$rl_7d_reset" ]; then
	diff=$((rl_7d_reset - now))
	if [ "$diff" -gt 0 ]; then
		days=$((diff / 86400))
		hours=$(((diff % 86400) / 3600))
		minutes=$(((diff % 86400) / 60))
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

current_time=$(date "+%-I:%M %p")
time_str="🕐 ${current_time}"
line1="${model} | Context: ${usage_str} | Session: ${block_str}"
[ -n "$rate_limit_5h_str" ] && line1="${line1} | 5h: ${rate_limit_5h_str}"
[ -n "$rate_limit_7d_str" ] && line1="${line1} | 7d: ${rate_limit_7d_str}"
printf "%s\n📁 %s | 🌳 %s | 🌿 %s\n%s" "$line1" "$dir_display" "$worktree_str" "$git_str" "$time_str"
