#!/usr/bin/env bash
# Deps plugin de Whisker Menu, debe ir a un lado sin icono y con un título vacío.

# === 📂 Archivos de estado ===
HIDE_FILE_WHISKER="$HOME/.config/genmon-hide/whisker"
STATE_FILE="/tmp/genmon-whisker-opened"

# === 🌐 Localización ===
export LC_ALL=en_US.UTF-8
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Establecer texto según idioma ===
set_tooltip_text() {
    case "$1" in
        es) TOOLTIP_TEXT="Haz clic para abrir\nWhisker Menu";;
        *)  TOOLTIP_TEXT="Click to open\nWhisker Menu";;
    esac
}

set_tooltip_text "$LANG_CODE"

# === 🎨 Configuración visual centralizada ===
COLOR_BG_PRIMARY="#1E1E2E"
COLOR_BG_SECONDARY="#13131C"
COLOR_TEXT="#FFFFFF"
COLOR_HIGHLIGHT="#FFFFFF"
COLOR_ACTIVE="#FFD845"
COLOR_MENU="#F5E0DC"

# === 🧩 Separadores Powerline (opcional) ===
SEP_LEFT="\uE0B6"   # 
SEP_RIGHT="\uE0B4"  # 

# === 🖼 Ícono del menú ===
MENU_TITLE=" "
FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_TOOLTIP="16000"
FONT_WEIGHT="bold"

# === 🕵️‍♂️ Ocultar si está activado ===
if [ -f "$HIDE_FILE_WHISKER" ]; then
    echo -e "<txt></txt>\n<tool></tool>"
    exit 0
fi

# === 🎯 Determinar color dinámico del ícono ===
if [ -f "$STATE_FILE" ]; then
    ICON_COLOR="$COLOR_ACTIVE"
else
    ICON_COLOR="$COLOR_TEXT"
fi

# === 🖼 Línea principal ===
DISPLAY_LINE="<span foreground='$ICON_COLOR'>$MENU_TITLE</span>"

# === 🧾 Tooltip ===
TOOLTIP="<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_TOOLTIP' weight='$FONT_WEIGHT' foreground='$COLOR_HIGHLIGHT'>$TOOLTIP_TEXT</span>"

# === 🖱️ Acción al hacer clic ===
INFO="<txtclick>bash -c 'touch $STATE_FILE; xfce4-popup-whiskermenu; sleep 6; rm -f $STATE_FILE'</txtclick>"

# === 📤 Salida final para GenMon ===
echo -e "<txt>${DISPLAY_LINE}</txt>"
echo -e "<tool>${TOOLTIP}</tool>"
echo -e "$INFO"
