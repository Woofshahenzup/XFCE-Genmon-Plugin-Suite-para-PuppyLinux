#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

set_texts() {
    case "$1" in
        es)
            LABEL_MUTED="Silenciado"
            LABEL_VERY_LOW="Muy bajo"
            LABEL_LOW="Bajo"
            LABEL_MEDIUM="Medio"
            LABEL_HIGH="Alto"
            LABEL_LEVEL="Nivel de volumen"
            LABEL_CLICK="Haz clic para abrir"
            LABEL_APP="Control de volumen de PulseAudio"
            ;;
        *)
            LABEL_MUTED="Muted"
            LABEL_VERY_LOW="Very Low"
            LABEL_LOW="Low"
            LABEL_MEDIUM="Medium"
            LABEL_HIGH="High"
            LABEL_LEVEL="Volume level"
            LABEL_CLICK="Click to open"
            LABEL_APP="PulseAudio Volume Control"
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 🎨 Paleta de colores ===
COLOR_BG_MAIN="#13131C"
COLOR_BG_ALT="#14131C"
COLOR_TEXT="#FFFFFF"
COLOR_MUTE="#95A5A6"
COLOR_LOW="#F1C40F"
COLOR_MEDIUM="#D1A1C1"
COLOR_HIGH="#FFFFFF"
COLOR_VERY_LOW="#E74C3C"
COLOR_LOWEST="#C0392B"

# === 🖋️ Fuente y estilo ===
FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_MAIN="12000"
TOOLTIP_FONT_SIZE="16000"
TOOLTIP_WEIGHT="bold"

SEP_LEFT="\uE0B0"
SEP_RIGHT="\uE0B2"

# === 🔊 Íconos por nivel de volumen ===
declare -A ICONS=(
    ["mute"]=""
    ["low"]=""
    ["medium"]=""
    ["high"]=""
    ["full"]=""
)

# === 🎨 Colores por nivel de volumen ===
declare -A COLORS=(
    ["mute"]="$COLOR_MUTE"
    ["low"]="$COLOR_LOW"
    ["medium"]="$COLOR_MEDIUM"
    ["high"]="$COLOR_HIGH"
    ["full"]="$COLOR_HIGH"
    ["very_low"]="$COLOR_VERY_LOW"
    ["lowest"]="$COLOR_LOWEST"
)

# === 📂 Ruta de ocultación ===
HIDE_VOLUME="$HOME/.config/genmon-hide/volume"

if [ -f "$HIDE_VOLUME" ]; then
    echo -e "<txt></txt>\n<tool></tool>"
    exit 0
fi

# === 📊 Obtener volumen y estado ===
AUDIO_INFO=$(amixer get Master | awk -F'[][]' '/Front Left:/ {print $2, $4}')
read -r VOLUME MUTED <<< "$(echo "$AUDIO_INFO" | awk '{print $1, $2}')"
VOLUME=${VOLUME%\%}

# === 🔍 Determinar ícono y color ===
if [[ "$MUTED" != "on" || "$VOLUME" -eq 0 ]]; then
    ICON="${ICONS[mute]}"
    COLOR="${COLORS[mute]}"
    VOLUME_STATUS="$LABEL_MUTED"
elif [[ "$VOLUME" -ge 90 ]]; then
    ICON="${ICONS[high]}"
    COLOR="${COLORS[high]}"
    VOLUME_STATUS="$LABEL_HIGH"
elif [[ "$VOLUME" -ge 50 ]]; then
    ICON="${ICONS[medium]}"
    COLOR="${COLORS[medium]}"
    VOLUME_STATUS="$LABEL_MEDIUM"
elif [[ "$VOLUME" -ge 30 ]]; then
    ICON="${ICONS[low]}"
    COLOR="${COLORS[low]}"
    VOLUME_STATUS="$LABEL_LOW"
elif [[ "$VOLUME" -ge 10 ]]; then
    ICON="${ICONS[low]}"
    COLOR="${COLORS[very_low]}"
    VOLUME_STATUS="$LABEL_VERY_LOW"
else
    ICON="${ICONS[mute]}"
    COLOR="${COLORS[lowest]}"
    VOLUME_STATUS="$LABEL_MUTED"
fi

# === 🖼 Línea principal ===
DISPLAY_LINE="<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_MAIN' foreground='$COLOR'> $ICON </span><span foreground='$COLOR_TEXT'> $VOLUME% </span>"

# === 🧾 Tooltip con localización ===
MORE_INFO="<tool>"
MORE_INFO+="<span font_family='$FONT_MAIN' font_size='$TOOLTIP_FONT_SIZE' weight='$TOOLTIP_WEIGHT' foreground='$COLOR'>"
MORE_INFO+="$LABEL_LEVEL: <span foreground='$COLOR'>$VOLUME_STATUS</span>\n"
MORE_INFO+="$LABEL_CLICK\n$LABEL_APP."
MORE_INFO+="</span></tool>"

# === 🖱️ Acción al hacer clic ===
ACTION="<txtclick>pavucontrol</txtclick>"

# === 📤 Salida final ===
echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$ACTION"
echo -e "$MORE_INFO"
