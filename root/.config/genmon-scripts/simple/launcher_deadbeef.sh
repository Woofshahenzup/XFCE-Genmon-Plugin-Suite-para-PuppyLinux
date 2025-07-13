#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Establecer texto según idioma ===
set_tooltip_text() {
    case "$1" in
        es) TOOLTIP_TEXT="Haz clic para abrir\nDeaDBeeF";;
        *)  TOOLTIP_TEXT="Click to open\nDeaDBeeF";;
    esac
}

set_tooltip_text "$LANG_CODE"

# === 🎨 Configuración visual centralizada ===

# --- Paleta de colores ---
COLOR_BG_MAIN="#313244"
COLOR_FG_TEXT="#13131C"
COLOR_ACCENT="#FFFFFF"
COLOR_HIGHLIGHT="#56B6C2"

# --- Separadores Powerline (opcional) ---
SEP_LEFT="\uE0B0"
SEP_RIGHT="\uE0B2"

# --- Ícono Nerd Font ---
ICON_DEADBEEF=" 󰎅 "

# --- Fuente del tooltip ---
TOOLTIP_FONT="Terminess Nerd Font"
TOOLTIP_SIZE="16000"
TOOLTIP_WEIGHT="bold"

# === 📂 Ruta de ocultación ===
HIDE_FILE_DEADBEEF="$HOME/.config/genmon-hide/deadbeef"

# === 🕵️‍♂️ Ocultar si está activado ===
if [ -f "$HIDE_FILE_DEADBEEF" ]; then
  DISPLAY_LINE=""
  TOOLTIP="<tool></tool>"
else
  # === 🖼 Línea principal ===
  DISPLAY_LINE="<span foreground='$COLOR_ACCENT' font_family='Terminess Nerd Font'> $ICON_DEADBEEF </span>"

  # === 🧾 Tooltip ===
  TOOLTIP="<tool>"
  TOOLTIP+="<span font_family='$TOOLTIP_FONT' font_size='$TOOLTIP_SIZE' weight='$TOOLTIP_WEIGHT' foreground='$COLOR_ACCENT'>"
  TOOLTIP+="$TOOLTIP_TEXT"
  TOOLTIP+="</span>"
  TOOLTIP+="</tool>"
fi

# === 🖱️ Acción al hacer clic ===
INFO="<txt>$DISPLAY_LINE</txt>$TOOLTIP"
if [ -n "$DISPLAY_LINE" ]; then
  INFO+="<txtclick>deadbeef</txtclick>"
fi

# === 📤 Mostrar resultado final ===
echo -e "$INFO"
