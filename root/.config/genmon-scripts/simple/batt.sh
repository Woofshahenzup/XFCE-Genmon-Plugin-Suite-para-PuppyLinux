#!/usr/bin/env bash
# Deps: cbatticon, nerd fonts terminess, yad

# === 🌐 Localización ===
export LC_ALL=en_US.UTF-8
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Texto según idioma ===
set_tooltip_texts() {
    case "$1" in
        es)
            TOOLTIP_STATUS="Estado de la batería"
            TOOLTIP_LEVEL="Nivel"
            TOOLTIP_NO_BATTERY="<tool><span foreground='#FF5733'>Batería no detectada</span></tool>"
            ;;
        *)
            TOOLTIP_STATUS="Battery status"
            TOOLTIP_LEVEL="Level"
            TOOLTIP_NO_BATTERY="<tool><span foreground='#FF5733'>No Battery Detected</span></tool>"
            ;;
    esac
}

set_tooltip_texts "$LANG_CODE"

# === Visual Settings ===

# --- Font Settings ---
FONT_NAME="Terminess Nerd Font"
FONT_SIZE="12000"
FONT_WEIGHT="bold"

# --- Icon Set (Nerd Fonts) ---
ICON_SET_DISCHARGING=( "" "" "" "" "" )
ICON_SET_CHARGING=( "󰢜" "󰢝" "󰢞" "󰢟" "󰢟" )

# Indexes for readability
IDX_FULL=0
IDX_HIGH=1
IDX_MEDIUM=2
IDX_LOW=3
IDX_CRITICAL=4

# --- Color Palette ---
COLOR_WHITE="#FFFFFF"
COLOR_ORANGE="#E67E22"
COLOR_RED="#E74C3C"
COLOR_CHARGING="#3498DB"
COLOR_BLINK_ON_CRITICAL="#DB805F"
COLOR_BLINK_OFF_CRITICAL="#FF2643"

# === Simulation Settings ===
SIMULATE_BATTERY="false"
# SIMULATED_STATUS="Discharging"; SIMULATED_PERCENT=10
# SIMULATED_STATUS="Charging"; SIMULATED_PERCENT=75
# SIMULATED_STATUS="Discharging"; SIMULATED_PERCENT=90
# SIMULATED_STATUS="Discharging"; SIMULATED_PERCENT=25
# SIMULATED_STATUS="Full"; SIMULATED_PERCENT=100

# === Runtime Logic ===

BLINK_STATE_FILE="$HOME/.config/genmon-hide/genmon_battery_blink_state"
HIDE_BATTERY_FILE="$HOME/.config/genmon-hide/batt"
mkdir -p "$HOME/.config/genmon-hide"

if [ -f "$HIDE_BATTERY_FILE" ]; then
    echo -e "<txt></txt>"
    echo -e "<tool></tool>"
    exit 0
fi

if [[ "$SIMULATE_BATTERY" == "true" ]]; then
    STATUS="$SIMULATED_STATUS"
    PERCENT="$SIMULATED_PERCENT"
    BAT_INFO="Simulated Battery Present"
else
    BAT_INFO=$(acpi -b 2>/dev/null)
    if [[ -z "$BAT_INFO" ]]; then
        echo -e "<txt></txt>"
        echo -e "$TOOLTIP_NO_BATTERY"
        exit 0
    else
        STATUS=$(echo "$BAT_INFO" | awk -F'[,:%]+' '{print $2}' | tr -d ' ')
        PERCENT=$(echo "$BAT_INFO" | awk -F'[,:%]+' '{print $3}' | tr -d ' ')
    fi
fi

if ! [[ "$PERCENT" =~ ^[0-9]+$ ]]; then
    PERCENT=0
fi

case "$STATUS" in
    Charging)
        COLOR="$COLOR_CHARGING"
        if (( PERCENT <= 20 )); then ICON="${ICON_SET_CHARGING[0]}"
        elif (( PERCENT <= 40 )); then ICON="${ICON_SET_CHARGING[1]}"
        elif (( PERCENT <= 60 )); then ICON="${ICON_SET_CHARGING[2]}"
        elif (( PERCENT <= 80 )); then ICON="${ICON_SET_CHARGING[3]}"
        else ICON="${ICON_SET_CHARGING[4]}"
        fi
        rm -f "$BLINK_STATE_FILE"
        ;;
    Full)
        ICON="${ICON_SET_DISCHARGING[$IDX_FULL]}"
        COLOR="$COLOR_WHITE"
        rm -f "$BLINK_STATE_FILE"
        ;;
    *)
        if (( PERCENT <= 15 )); then
            ICON="${ICON_SET_DISCHARGING[$IDX_CRITICAL]}"
            if [[ -f "$BLINK_STATE_FILE" ]]; then
                CURRENT_STATE=$(cat "$BLINK_STATE_FILE")
            else
                CURRENT_STATE="ON"
            fi
            if [[ "$CURRENT_STATE" == "ON" ]]; then
                COLOR="$COLOR_BLINK_OFF_CRITICAL"
                echo "OFF" > "$BLINK_STATE_FILE"
            else
                COLOR="$COLOR_BLINK_ON_CRITICAL"
                echo "ON" > "$BLINK_STATE_FILE"
            fi
        elif (( PERCENT <= 49 )); then
            ICON="${ICON_SET_DISCHARGING[$IDX_LOW]}"
            COLOR="$COLOR_ORANGE"
            rm -f "$BLINK_STATE_FILE"
        elif (( PERCENT <= 79 )); then
            ICON="${ICON_SET_DISCHARGING[$IDX_MEDIUM]}"
            COLOR="$COLOR_WHITE"
            rm -f "$BLINK_STATE_FILE"
        else
            ICON="${ICON_SET_DISCHARGING[$IDX_HIGH]}"
            COLOR="$COLOR_WHITE"
            rm -f "$BLINK_STATE_FILE"
        fi
        ;;
esac

DISPLAY_LINE="<span foreground='$COLOR'> $ICON  $PERCENT% </span>"

MORE_INFO="<tool>"
MORE_INFO+="<span font_family='$FONT_NAME' font_size='$FONT_SIZE' weight='$FONT_WEIGHT'>"
MORE_INFO+="$TOOLTIP_STATUS: <span foreground='$COLOR'>$STATUS</span>\n"
MORE_INFO+="$TOOLTIP_LEVEL: <span foreground='$COLOR'>$PERCENT%</span>"
MORE_INFO+="</span>"
MORE_INFO+="</tool>"

INFO="<txtclick>/usr/local/bin/notificador-bateria.sh</txtclick>"

echo -e "<txt>${DISPLAY_LINE}</txt>"
echo -e "$MORE_INFO"
echo -e "$INFO"
