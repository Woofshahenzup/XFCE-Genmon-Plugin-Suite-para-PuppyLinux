#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Establecer texto según idioma ===
set_tooltip_text() {
    case "$1" in
        es) TOOLTIP_TEXT="Haz clic para abrir\nla terminal";;
        *)  TOOLTIP_TEXT="Click to open\nthe terminal";;
    esac
}

set_tooltip_text "$LANG_CODE"

# === 🎨 Paleta moderna ===
COLOR_BG_MAIN="#161320"
COLOR_FG_TEXT="#13131C"
COLOR_ACCENT="#D1A1C1"
COLOR_HIGHLIGHT="#FFFFFF"

# === Separadores Powerline (opcional) ===
SEP_LEFT="\uE0B4"   # 
SEP_RIGHT="\uE0B6"  # 

# === Íconos Nerd Font ===
ICON_TERMINAL="󰆍 "

# === Fuente y estilo ===
FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_MAIN="14000"
TOOLTIP_FONT_SIZE="16000"
TOOLTIP_WEIGHT="bold"

# === 📂 Ruta de ocultación ===
HIDE_FILE_TERMINAL="$HOME/.config/genmon-hide/terminal"

# === 🕵️‍♂️ Ocultar si está activado ===
if [ -f "$HIDE_FILE_TERMINAL" ]; then
    echo -e "<txt></txt>\n<tool></tool>"
    exit 0
fi

# === 🖼 Línea principal ===
DISPLAY_LINE="<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_MAIN' foreground='$COLOR_HIGHLIGHT'> $ICON_TERMINAL </span>"

# === 🧾 Tooltip ===
MORE_INFO="<tool>"
MORE_INFO+="<span font_family='$FONT_MAIN' font_size='$TOOLTIP_FONT_SIZE' weight='$TOOLTIP_WEIGHT' foreground='$COLOR_ACCENT'>"
MORE_INFO+="$TOOLTIP_TEXT"
MORE_INFO+="</span>"
MORE_INFO+="</tool>"

# === 🖱️ Acción al hacer clic ===
ACTION="<txtclick>defaultterminal</txtclick>"

# === 📤 Salida final para GenMon ===
echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$MORE_INFO"
echo -e "$ACTION"
