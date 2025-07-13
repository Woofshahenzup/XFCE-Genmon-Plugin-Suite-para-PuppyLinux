#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            LABEL_FAVORITES="Favoritos"
            ;;
        *)
            LABEL_FAVORITES="Favorites"
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 🎨 Configuración visual centralizada ===
COLOR_ICON="#FFFFFF"
COLOR_TOOLTIP="#FFBC00"
ICON_FAVORITES=" "
ICON_TOOLTIP=" "

# === 🖋️ Fuente y estilo ===
FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_MAIN="12000"
TOOLTIP_FONT_SIZE="14000"
TOOLTIP_WEIGHT="bold"

# === 📂 Ruta de ocultación ===
HIDE_FILE_FAVORITES="$HOME/.config/genmon-hide/favorites"

# === 🕵️‍♂️ Ocultar si está activado ===
if [ -f "$HIDE_FILE_FAVORITES" ]; then
  DISPLAY_LINE=""
  MORE_INFO=""
  INFO=""
else
  # === 🖼 Línea principal ===
  DISPLAY_LINE="<txt><span font_family='$FONT_MAIN' font_size='$FONT_SIZE_MAIN' foreground='$COLOR_ICON'> $ICON_FAVORITES </span></txt>"

  # === 🧾 Tooltip con localización ===
  MORE_INFO="<tool><span font_family='$FONT_MAIN' font_size='$TOOLTIP_FONT_SIZE' weight='$TOOLTIP_WEIGHT'><span foreground='$COLOR_TOOLTIP'>$ICON_TOOLTIP $LABEL_FAVORITES</span></span></tool>"

  # === 🖱️ Acción al hacer clic ===
  INFO="<txtclick>bash -c '\"$(dirname "$0")/favorites.sh\"'</txtclick>"
fi

# === 📤 Salida final ===
echo -e "$DISPLAY_LINE"
echo -e "$MORE_INFO"
echo -e "$INFO"
