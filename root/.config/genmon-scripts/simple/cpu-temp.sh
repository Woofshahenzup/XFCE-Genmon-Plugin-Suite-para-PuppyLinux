#!/usr/bin/env bash
# Dependencies: bash>=3.2, coreutils, gawk, grep, lm_sensors, btop

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            LABEL_CPU="CPU"
            LABEL_ZONE="Zona"
            LABEL_TEMP="Temperatura"
            LABEL_UNIT="°C"
            LABEL_DISPLAY="Temp CPU"
            WARNING=" Revisa el sistema de refrigeración, temperatura alta."
            CLICK_LABEL="Abrir monitor (btop)"
            ;;
        *)
            LABEL_CPU="CPU"
            LABEL_ZONE="Zone"
            LABEL_TEMP="Temp"
            LABEL_UNIT="°C"
            LABEL_DISPLAY="CPU Temp"
            WARNING=" Check cooling system, high temperature."
            CLICK_LABEL="Open monitor (btop)"
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 🎨 Configuración visual centralizada ===

COLOR_DEFAULT="#FFFFFF"
COLOR_COOL="#A3BE8C"
COLOR_WARM="#E5C07B"
COLOR_HOT="#E06C75"

ICON_COOL=""
ICON_MILD=""
ICON_WARM=""
ICON_HOT=""

TOOLTIP_FONT="Terminess Nerd Font"
TOOLTIP_SIZE="14000"
TOOLTIP_WEIGHT="bold"

HIDE_FILE_TEMP="$HOME/.config/genmon-hide/cpu-temp"
CPU_CACHE_FILE="/tmp/genmon-hide/cpu-vendor"

# === 🕵️‍♂️ Ocultar si está activado ===
if [ -f "$HIDE_FILE_TEMP" ]; then
    echo -e "<txt></txt>\n<tool></tool>"
    exit 0
fi

# === 🔍 Detectar zona térmica ===
TEMP_PATH=""
for zone in /sys/class/thermal/thermal_zone*; do
    [ -f "$zone/temp" ] || continue
    TEMP_PATH="$zone/temp"
    ZONE_NAME="${zone##*/}"
    break
done

# === 🔄 Alternativas si no se detecta zona térmica ===
if [ -z "$TEMP_PATH" ]; then
    if ls /sys/class/drm/card0/device/hwmon/hwmon*/temp1_input &>/dev/null; then
        TEMP_PATH=$(ls /sys/class/drm/card0/device/hwmon/hwmon*/temp1_input 2>/dev/null | head -n 1)
        ZONE_NAME="GPU/APU"
    elif ls /sys/class/hwmon/hwmon*/temp1_input &>/dev/null; then
        TEMP_PATH="/sys/class/hwmon/hwmon*/temp1_input"
        ZONE_NAME="hwmon"
    fi
fi

# === 🚫 Salir si no hay fuente válida ===
[ -z "$TEMP_PATH" ] && echo -e "<txt></txt>\n<tool></tool>" && exit 0

# === 🌡️ Leer temperatura ===
read -r CPU_TEMP_RAW < "$TEMP_PATH"
CPU_TEMP=$((CPU_TEMP_RAW / 1000))

# === 🧠 Detectar tipo de CPU (con caché) ===
if [ -f "$CPU_CACHE_FILE" ]; then
    CPU_BRAND=$(<"$CPU_CACHE_FILE")
else
    CPU_VENDOR=$(awk -F ': ' '/vendor_id/ {print $2; exit}' /proc/cpuinfo)
    case "$CPU_VENDOR" in
        GenuineIntel) CPU_BRAND="Intel" ;;
        AuthenticAMD) CPU_BRAND="AMD" ;;
        *) CPU_BRAND="Desconocido" ;;
    esac
    echo "$CPU_BRAND" > "$CPU_CACHE_FILE"
fi

# === 🎨 Selección de color, ícono y recomendación ===
ICON="$ICON_COOL"
TEMP_COLOR="$COLOR_DEFAULT"
RECOMMENDATION=""

if (( CPU_TEMP > 40 && CPU_TEMP <= 55 )); then
    TEMP_COLOR="$COLOR_COOL"
    ICON="$ICON_MILD"
elif (( CPU_TEMP > 55 && CPU_TEMP <= 70 )); then
    TEMP_COLOR="$COLOR_WARM"
    ICON="$ICON_WARM"
elif (( CPU_TEMP > 70 )); then
    TEMP_COLOR="$COLOR_HOT"
    ICON="$ICON_HOT"
    RECOMMENDATION="\n$WARNING"
fi

# === 🖼️ Línea principal ===
DISPLAY="<span foreground='$TEMP_COLOR' font_family='Terminess Nerd Font' weight='bold'> $ICON $LABEL_DISPLAY $CPU_TEMP $LABEL_UNIT </span>"

# === 🧾 Tooltip ===
TOOLTIP="<tool>"
TOOLTIP+="<span font_family='$TOOLTIP_FONT' font_size='$TOOLTIP_SIZE' weight='$TOOLTIP_WEIGHT'>"
TOOLTIP+="$LABEL_CPU: $CPU_BRAND\n"
TOOLTIP+="$LABEL_ZONE: $ZONE_NAME\n"
TOOLTIP+="$LABEL_TEMP: <span foreground='$TEMP_COLOR'>$CPU_TEMP $LABEL_UNIT</span>$RECOMMENDATION"
TOOLTIP+="</span></tool>"

# === 🖱️ Acción al hacer clic ===
CLICK_ACTION="<txtclick>xfce4-terminal --geometry=90x24 -e btop</txtclick>"

# === 📤 Salida final ===
echo -e "<txt>$DISPLAY</txt>"
echo -e "$TOOLTIP"
echo -e "$CLICK_ACTION"
