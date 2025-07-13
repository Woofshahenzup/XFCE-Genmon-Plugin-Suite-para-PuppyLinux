#!/usr/bin/env bash
# Dependencies: bash>=3.2, coreutils, gawk, grep, lm_sensors, sed, btop

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            LABEL_CORE="Núcleo"
            LABEL_FREQ="MHz"
            LABEL_MODEL="Modelo de CPU"
            HEADER_TOP="┌"
            LINE_MID="├─"
            LINE_END="└─"
            CLICK_LABEL="Abrir monitor (btop)"
            ;;
        *)
            LABEL_CORE="CPU"
            LABEL_FREQ="MHz"
            LABEL_MODEL="CPU Model"
            HEADER_TOP="┌"
            LINE_MID="├─"
            LINE_END="└─"
            CLICK_LABEL="Open monitor (btop)"
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 🎨 Configuración visual centralizada ===

COLOR_LOW="#FFFFFF"
COLOR_MEDIUM="#E5C07B"
COLOR_HIGH="#E06C75"
COLOR_TEXT="#FFFFFF"
COLOR_MODEL="#81A1C1"
COLOR_FREQ="#A3BE8C"

ICON_CPU=""

TOOLTIP_FONT="Terminess Nerd Font"
TOOLTIP_SIZE="16000"
TOOLTIP_WEIGHT="bold"

HIDE_FILE_CPU="$HOME/.config/genmon-hide/cpu"

# === 🕵️‍♂️ Ocultar si está activado ===
if [ -f "$HIDE_FILE_CPU" ]; then
  echo -e "<txt></txt>"
  echo -e "<tool></tool>"
  exit 0
fi

# === 📊 Lectura de uso de CPU ===
read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
IDLE=$idle
TOTAL=$((user + nice + system + idle + iowait + irq + softirq + steal))

sleep 0.9

read -r _ user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 guest2 guest_nice2 < /proc/stat
IDLE2=$idle2
TOTAL2=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2 + steal2))

DELTA_IDLE=$((IDLE2 - IDLE))
DELTA_TOTAL=$((TOTAL2 - TOTAL))

if (( DELTA_TOTAL > 0 )); then
    CPU_USAGE=$((100 * (DELTA_TOTAL - DELTA_IDLE) / DELTA_TOTAL))
else
    CPU_USAGE=0
fi

# === 🎨 Asignar color según uso ===
if (( CPU_USAGE <= 30 )); then
    ICON_COLOR="$COLOR_LOW"
elif (( CPU_USAGE <= 70 )); then
    ICON_COLOR="$COLOR_MEDIUM"
else
    ICON_COLOR="$COLOR_HIGH"
fi

# === 🖼️ Línea principal ===
DISPLAY_LINE="<span foreground='$ICON_COLOR'> $ICON_CPU </span><span foreground='$COLOR_TEXT'>$CPU_USAGE% </span>"

# === 🧠 Modelo de CPU ===
CPU_MODEL=$(awk -F': ' '/model name/ {print $2; exit}' /proc/cpuinfo | sed 's/^[ \t]*//')

# === 🔄 Frecuencias por núcleo ===
mapfile -t CPU_FREQS < <(awk -F': ' '/cpu MHz/ {gsub(/^[ \t]+/, "", $2); print $2}' /proc/cpuinfo)
TOTAL_CPUS=${#CPU_FREQS[@]}

# === 🧾 Tooltip ===
MORE_INFO="<tool>"
MORE_INFO+="<span font_family='$TOOLTIP_FONT' font_size='$TOOLTIP_SIZE' weight='$TOOLTIP_WEIGHT'>"
MORE_INFO+="$HEADER_TOP <span foreground='$COLOR_MODEL'>$LABEL_MODEL: $CPU_MODEL</span>\n"
for ((i = 0; i < TOTAL_CPUS; i++)); do
    PREFIX="$LINE_MID"
    (( i == TOTAL_CPUS - 1 )) && PREFIX="$LINE_END"
    MHZ="${CPU_FREQS[i]}"
    MORE_INFO+="$PREFIX $LABEL_CORE $i: <span foreground='$COLOR_FREQ'>${MHZ} $LABEL_FREQ</span>\n"
done
MORE_INFO+="</span></tool>"

# === 🖱️ Acción al hacer clic ===
INFO="<txt>$DISPLAY_LINE</txt>"
INFO+="<txtclick>xfce4-terminal --geometry=90x24 -e btop</txtclick>"

# === 📤 Salida final ===
echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$MORE_INFO"
echo -e "$INFO"
