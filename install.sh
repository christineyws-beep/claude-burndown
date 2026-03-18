#!/usr/bin/env bash
set -e

# claude-burndown installer
# Installs the /nightly-burndown slash command and optionally sets up scheduling.

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config/claude-burndown"
CLAUDE_CMD_DIR="$HOME/.claude/commands"

echo "claude-burndown installer"
echo "========================="
echo ""

# --- Step 1: Check prerequisites ---

CLAUDE_PATH="$(which claude 2>/dev/null || true)"
if [ -z "$CLAUDE_PATH" ]; then
    # Check common install locations
    for p in "$HOME/.local/bin/claude" "/usr/local/bin/claude" "$HOME/.claude/bin/claude"; do
        if [ -x "$p" ]; then
            CLAUDE_PATH="$p"
            break
        fi
    done
fi

if [ -z "$CLAUDE_PATH" ]; then
    echo "Error: claude CLI not found."
    echo "Install Claude Code first: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

echo "Found claude at: $CLAUDE_PATH"

# --- Step 2: Install the slash command ---

mkdir -p "$CLAUDE_CMD_DIR"

if [ -f "$CLAUDE_CMD_DIR/nightly-burndown.md" ]; then
    echo ""
    echo "Existing /nightly-burndown command found."
    read -p "Overwrite? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing command."
    else
        cp "$REPO_DIR/commands/nightly-burndown.md" "$CLAUDE_CMD_DIR/nightly-burndown.md"
        echo "Updated /nightly-burndown command."
    fi
else
    cp "$REPO_DIR/commands/nightly-burndown.md" "$CLAUDE_CMD_DIR/nightly-burndown.md"
    echo "Installed /nightly-burndown command."
fi

# --- Step 3: Set up configuration ---

mkdir -p "$CONFIG_DIR"

if [ -f "$CONFIG_DIR/burndown.yaml" ]; then
    echo "Configuration already exists at $CONFIG_DIR/burndown.yaml"
else
    cp "$REPO_DIR/config/burndown.example.yaml" "$CONFIG_DIR/burndown.yaml"
    echo "Created config at $CONFIG_DIR/burndown.yaml"
    echo "  -> Edit this file to add your projects before running."
fi

# --- Step 4: Set up log directory ---

LOG_DIR="$HOME/burndown-logs"
mkdir -p "$LOG_DIR"

# --- Step 5: Offer scheduling ---

echo ""
echo "Schedule nightly burndown?"
echo ""
echo "  1) macOS (launchd) — recommended for Mac"
echo "  2) Linux (systemd)"
echo "  3) Cron (any Unix)"
echo "  4) Skip — I'll run it manually"
echo ""
read -p "Choose [1-4]: " -n 1 -r SCHED_CHOICE
echo ""

HOUR=22
MINUTE=0

if [[ "$SCHED_CHOICE" =~ ^[1-3]$ ]]; then
    read -p "Run at what hour? (0-23, default 22): " HOUR_INPUT
    HOUR="${HOUR_INPUT:-22}"
    read -p "Minute? (0-59, default 0): " MIN_INPUT
    MINUTE="${MIN_INPUT:-0}"
fi

CLAUDE_BIN_DIR="$(dirname "$CLAUDE_PATH")"
WORKING_DIR="$HOME"

case "$SCHED_CHOICE" in
    1)
        # macOS launchd
        PLIST_DIR="$HOME/Library/LaunchAgents"
        PLIST_FILE="$PLIST_DIR/com.claude.nightly-burndown.plist"
        mkdir -p "$PLIST_DIR"

        # Unload existing if present
        launchctl unload "$PLIST_FILE" 2>/dev/null || true

        sed -e "s|__CLAUDE_PATH__|$CLAUDE_PATH|g" \
            -e "s|__WORKING_DIR__|$WORKING_DIR|g" \
            -e "s|__HOUR__|$HOUR|g" \
            -e "s|__MINUTE__|$MINUTE|g" \
            -e "s|__LOG_DIR__|$LOG_DIR|g" \
            -e "s|__CLAUDE_BIN_DIR__|$CLAUDE_BIN_DIR|g" \
            -e "s|__HOME__|$HOME|g" \
            "$REPO_DIR/scheduling/launchd/com.claude.nightly-burndown.plist.template" \
            > "$PLIST_FILE"

        launchctl load "$PLIST_FILE"
        echo "Installed launchd job. Runs daily at ${HOUR}:$(printf '%02d' $MINUTE)."
        echo "  Manage: launchctl unload $PLIST_FILE"
        ;;
    2)
        # Linux systemd
        SYSTEMD_DIR="$HOME/.config/systemd/user"
        mkdir -p "$SYSTEMD_DIR"

        sed -e "s|__CLAUDE_PATH__|$CLAUDE_PATH|g" \
            -e "s|__WORKING_DIR__|$WORKING_DIR|g" \
            -e "s|__LOG_DIR__|$LOG_DIR|g" \
            -e "s|__CLAUDE_BIN_DIR__|$CLAUDE_BIN_DIR|g" \
            -e "s|__HOME__|$HOME|g" \
            "$REPO_DIR/scheduling/systemd/claude-burndown.service.template" \
            > "$SYSTEMD_DIR/claude-burndown.service"

        sed -e "s|__HOUR__|$HOUR|g" \
            -e "s|__MINUTE__|$(printf '%02d' $MINUTE)|g" \
            "$REPO_DIR/scheduling/systemd/claude-burndown.timer.template" \
            > "$SYSTEMD_DIR/claude-burndown.timer"

        systemctl --user daemon-reload
        systemctl --user enable claude-burndown.timer
        systemctl --user start claude-burndown.timer
        echo "Installed systemd timer. Runs daily at ${HOUR}:$(printf '%02d' $MINUTE)."
        echo "  Status: systemctl --user status claude-burndown.timer"
        echo "  Disable: systemctl --user disable claude-burndown.timer"
        ;;
    3)
        # Cron
        bash "$REPO_DIR/scheduling/cron/install-cron.sh" "$HOUR" "$MINUTE"
        ;;
    4)
        echo "Skipping scheduling."
        echo "  Run manually anytime: claude -p /nightly-burndown"
        ;;
    *)
        echo "Skipping scheduling."
        ;;
esac

# --- Done ---

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Edit your config:  $CONFIG_DIR/burndown.yaml"
echo "     Add your projects (paths, names, exclude patterns)"
echo ""
echo "  2. Test it:  claude -p /nightly-burndown"
echo ""
echo "  3. Check logs: $LOG_DIR/"
echo ""
