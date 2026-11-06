#!/bin/zsh
# SUDO_ASKPASS helper: pops a native macOS dialog to collect whatever sudo/PAM
# is asking for, then writes it to stdout. Used when sudo is invoked with -A from
# a context that has no controlling terminal (e.g. Claude Code's Bash tool).
#
# sudo passes its actual prompt as $1 (e.g. "Password:", a YubiKey PIN prompt,
# etc.), so the dialog mirrors whatever auth method is configured rather than
# assuming a password. The secret is typed by a human each time and never stored.
prompt="${1:-Authentication required:}"

/usr/bin/osascript - "$prompt" <<'APPLESCRIPT'
on run argv
	set thePrompt to item 1 of argv
	set theMessage to "Claude Code requested administrator (sudo) access." & return & return & thePrompt
	return text returned of (display dialog theMessage default answer "" with hidden answer with title "sudo — Claude Code" with icon caution giving up after 120)
end run
APPLESCRIPT
