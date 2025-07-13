#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Establecer texto según idioma ===
set_tooltip_text() {
    case "$1" in
        es) TOOLTIP_TEXT="Haz clic para abrir\nThunar";;
        *)  TOOLTIP_TEXT="Click to open\nThunar";;
    esac
}

set_tooltip_text "$LANG_CODE"

# === 🎨 Configuración visual centralizada ===

# --- Paleta de colores ---
COLOR_BG_MAIN="#13131C"
COLOR_FG_TEXT="#D1A1C1"
COLOR_ACCENT="#D1A1C1"
COLOR_HIGHLIGHT="#FFFFFF"

# --- Separadores Powerline (opcional) ---
SEP_LEFT="\uE0B4"   # 
SEP_RIGHT="\uE0B6"  # 

# --- Íconos Nerd Font ---
ICON_FILE_MANAGER="󱂶 "

# --- Fuente y estilo ---
FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_MAIN="14000"
TOOLTIP_FONT_SIZE="16000"
TOOLTIP_WEIGHT="bold"

# === 📂 Ruta de ocultación ===
HIDE_FILE_MANAGER="$HOME/.config/genmon-hide/filemanager"

# === 🕵️‍♂️ Ocultar si está activado ===
if [ -f "$HIDE_FILE_MANAGER" ]; then
  echo -e "<txt></txt>\n<tool></tool>"
  exit 0
fi

# === 🖼 Línea principal ===
DISPLAY_LINE="<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_MAIN' foreground='$COLOR_HIGHLIGHT'> $ICON_FILE_MANAGER </span>"

# === 🧾 Tooltip ===
MORE_INFO="<tool>"
MORE_INFO+="<span font_family='$FONT_MAIN' font_size='$TOOLTIP_FONT_SIZE' weight='$TOOLTIP_WEIGHT' foreground='$COLOR_HIGHLIGHT'>"
MORE_INFO+="$TOOLTIP_TEXT"
MORE_INFO+="</span>"
MORE_INFO+="</tool>"

# === 🖱️ Acción al hacer clic ===
ACTION="<txtclick>thunar</txtclick>"

# === 📤 Salida final para GenMon ===
echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$MORE_INFO"
echo -e "$ACTION"
