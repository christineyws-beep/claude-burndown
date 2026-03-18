#!/usr/bin/env bash
set -e

# claude-burndown uninstaller

echo "claude-burndown uninstaller"
echo "==========================="
echo ""

# Remove slash command
CMD_FILE="$HOME/.claude/commands/nightly-burndown.md"
if [ -f "$CMD_FILE" ]; then
    rm "$CMD_FILE"
    echo "Removed /nightly-burndown command."
else
    echo "No command file found."
fi

# Remove launchd job (macOS)
PLIST="$HOME/Library/LaunchAgents/com.claude.nightly-burndown.plist"
if [ -f "$PLIST" ]; then
    launchctl unload "$PLIST" 2>/dev/null || true
    rm "$PLIST"
    echo "Removed launchd job."
fi

# Remove systemd timer (Linux)
if systemctl --user is-enabled claude-burndown.timer 2>/dev/null; then
    systemctl --user stop claude-burndown.timer 2>/dev/null || true
    systemctl --user disable claude-burndown.timer 2>/dev/null || true
    rm -f "$HOME/.config/systemd/user/claude-burndown.service"
    rm -f "$HOME/.config/systemd/user/claude-burndown.timer"
    systemctl --user daemon-reload
    echo "Removed systemd timer."
fi

# Remove cron job
if crontab -l 2>/dev/null | grep -q "nightly-burndown"; then
    crontab -l 2>/dev/null | grep -v "nightly-burndown" | crontab -
    echo "Removed cron job."
fi

# Config and logs
echo ""
read -p "Remove config at ~/.config/claude-burndown/? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/.config/claude-burndown"
    echo "Removed config."
else
    echo "Kept config."
fi

echo ""
echo "Burndown logs at ~/burndown-logs/ were NOT removed."
echo "Delete manually if you want: rm -rf ~/burndown-logs/"
echo ""
echo "Uninstall complete."
