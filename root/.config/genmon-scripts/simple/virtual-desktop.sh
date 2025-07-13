#!/usr/bin/env bash

# === 🌐 Localización ===
export LC_ALL=en_US.UTF-8
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

set_texts() {
    case "$1" in
        es)
            LABEL_CURRENT="Escritorio actual"
            LABEL_TOTAL="Total de escritorios"
            ;;
        *)
            LABEL_CURRENT="Current Desktop"
            LABEL_TOTAL="Total Desktops"
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 📂 Ruta de ocultación ===
HIDE_FILE_DESKTOPS="$HOME/.config/genmon-hide/desktops"

if [ -f "$HIDE_FILE_DESKTOPS" ]; then
    echo "<txt></txt>"
    echo "<tool></tool>"
    exit 0
fi

# === 🎨 Paleta de colores personalizada ===
BG0="#161320"
BG1="#161320"
COLOR_ACTIVE="#cc241d"
COLOR_INACTIVE="#98971a"
COLOR_ICON="#CD4025"
COLOR_PACMAN="#FFFFFF"
COLOR_GHOST="#915663"
COLOR_TEXT_ACTIVE="#FFFFFF"
COLOR_TEXT_INACTIVE="#FFFFFF"

# === 🖋️ Fuente y estilo ===
FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_MAIN="14000"
TOOLTIP_FONT_SIZE="16000"
TOOLTIP_WEIGHT="bold"

SEP_LEFT="\uE0B4"
SEP_RIGHT="\uE0B6"

# === 🕹️ Íconos personalizados ===
ICON_OTHER="<span foreground='$COLOR_GHOST'>  </span>"
ICON_CURRENT="<span foreground='$COLOR_PACMAN'>  </span>"

# === 🧠 Detectar gestor de ventanas ===
WM_NAME=$(wmctrl -m | grep -oP 'Name: \K\S+')
SCREEN_WIDTH=$(xrandr | grep '*' | head -n 1 | awk '{print $1}' | cut -d'x' -f1)

CURRENT_DESKTOP=0
TOTAL_DESKTOPS=1
NEXT_DESKTOP=0
VIEWPORT_SWITCH_CMD=""

# === 🧭 Modo Fusilli (viewports) ===
if [[ "$WM_NAME" == "fusilli" ]]; then
  VP_INFO=$(wmctrl -d | grep '*')
  VP_SIZE=$(echo "$VP_INFO" | awk '{print $4}' | cut -d':' -f2)
  VP_POS=$(echo "$VP_INFO" | awk '{print $6}' | cut -d':' -f2)

  TOTAL_WIDTH=$(echo "$VP_SIZE" | cut -d'x' -f1)
  TOTAL_DESKTOPS=$((TOTAL_WIDTH / SCREEN_WIDTH))

  CURRENT_X=$(echo "$VP_POS" | cut -d',' -f1)
  CURRENT_DESKTOP=$((CURRENT_X / SCREEN_WIDTH))
  NEXT_DESKTOP=$(( (CURRENT_DESKTOP + 1) % TOTAL_DESKTOPS ))
  NEXT_X=$((NEXT_DESKTOP * SCREEN_WIDTH))

  VIEWPORT_SWITCH_CMD="wmctrl -o $NEXT_X,0"
else
  DESKTOP_INFO=$(wmctrl -d)
  CURRENT_DESKTOP=$(echo "$DESKTOP_INFO" | grep '*' | awk '{print $1}')
  TOTAL_DESKTOPS=$(echo "$DESKTOP_INFO" | wc -l)
  NEXT_DESKTOP=$(( (CURRENT_DESKTOP + 1) % TOTAL_DESKTOPS ))

  VIEWPORT_SWITCH_CMD="wmctrl -s $NEXT_DESKTOP"
fi

# === 🎨 Construcción visual ===
DESKTOP_BLOCKS=()
PREV_BG="$BG0"

for i in $(seq 0 $((TOTAL_DESKTOPS - 1))); do
  BG_COLOR=$([ $((i % 2)) -eq 0 ] && echo "$BG0" || echo "$BG1")
  ICON=$ICON_OTHER
  [[ "$i" -eq "$CURRENT_DESKTOP" ]] && ICON=$ICON_CURRENT
  TEXT_COLOR=$([ "$i" -eq "$CURRENT_DESKTOP" ] && echo "$COLOR_TEXT_ACTIVE" || echo "$COLOR_TEXT_INACTIVE")
  DESKTOP_BLOCKS+=("<span foreground='$TEXT_COLOR'>$ICON</span> ")
  PREV_BG="$BG_COLOR"
done

DESKTOP_LINE=$(IFS=""; echo "${DESKTOP_BLOCKS[*]}")
INFO="<txt> $DESKTOP_LINE</txt>"

# === 🧾 Tooltip con localización ===
MORE_INFO="<tool>"
MORE_INFO+="<span font_family='$FONT_MAIN' font_size='$TOOLTIP_FONT_SIZE' weight='$TOOLTIP_WEIGHT'>"
MORE_INFO+="$LABEL_CURRENT: <span foreground='$COLOR_ACTIVE'>$((CURRENT_DESKTOP + 1))</span>\n"
MORE_INFO+="$LABEL_TOTAL: <span foreground='$COLOR_INACTIVE'>$TOTAL_DESKTOPS</span>"
MORE_INFO+="</span></tool>"

# === 📤 Salida final ===
echo -e "$INFO"
echo "<txtclick>$VIEWPORT_SWITCH_CMD</txtclick>"
echo -e "$MORE_INFO"
