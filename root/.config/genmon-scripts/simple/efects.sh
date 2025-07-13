#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Texto según idioma ===
set_texts() {
    case "$1" in
        es) TOOLTIP_TITLE="Gestor Fusilli";;
        *)  TOOLTIP_TITLE="Fusilli Manager";;
    esac
}

set_texts "$LANG_CODE"

# === 🎨 Configuración visual centralizada ===

COLOR_ICON="#FFFFFF"
COLOR_TOOLTIP_TITLE="#FFBC00"
COLOR_TOOLTIP_ICON="#FFFFFF"

ICON_FUSILLI="󰣏"

FONT_FAMILY="Terminess Nerd Font"
FONT_SIZE="14000"
FONT_WEIGHT="bold"

HIDE_FILE="$HOME/.config/genmon-hide/fusilli"

if [ -f "$HIDE_FILE" ]; then
  DISPLAY_LINE=""
  MORE_INFO=""
  INFO=""
else
  # === 🖼 Línea principal con estilo ===
  DISPLAY_LINE="<txt><span font_family='$FONT_FAMILY' font_size='$FONT_SIZE' foreground='$COLOR_ICON'> $ICON_FUSILLI </span></txt>"

  # === ℹ Tooltip con estilo ===
  MORE_INFO="<tool>"
  MORE_INFO+="<span font_family='$FONT_FAMILY' font_size='$FONT_SIZE' weight='$FONT_WEIGHT'>"
  MORE_INFO+="<span foreground='$COLOR_TOOLTIP_ICON'>$ICON_FUSILLI</span> "
  MORE_INFO+="<span foreground='$COLOR_TOOLTIP_TITLE'>$TOOLTIP_TITLE</span>"
  MORE_INFO+="</span>"
  MORE_INFO+="</tool>"

  # === 🖱️ Acción al hacer clic ===
  INFO="<txtclick>bash -c '${0%/*}/fusilli-menu.sh'</txtclick>"
fi

# === 📤 Salida final ===
echo -e "$DISPLAY_LINE"
echo -e "$MORE_INFO"
echo -e "$INFO"
