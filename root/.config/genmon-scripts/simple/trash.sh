#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            LABEL_STATUS="Estado de la papelera"
            LABEL_FULL="Llena"
            LABEL_EMPTY="Vacía"
            LABEL_CLICK="Haz clic para abrir la papelera"
            ;;
        *)
            LABEL_STATUS="Trash status"
            LABEL_FULL="Full"
            LABEL_EMPTY="Empty"
            LABEL_CLICK="Click to open the trash folder."
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 📂 Ruta de ocultación ===
HIDE_FILE="$HOME/.config/genmon-hide/trash"

# === 🎨 Estilo visual centralizado ===
ICON_TRASH="󰩺"
COLOR_BG_MAIN="#E0B971"
COLOR_EMPTY="#FFFFFF"
COLOR_FULL="#EB9191"
COLOR_TEXT="#FFFFFF"
COLOR_BORDER="#56B6C2"
COLOR_TOOLTIP_TEXT="#FFFFFF"

FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_MAIN="14000"
TOOLTIP_FONT_SIZE="16000"
TOOLTIP_WEIGHT="bold"

SEP_RIGHT="\uE0B2"

# === 📁 Ruta de la papelera ===
TRASH_PATH="$HOME/.local/share/Trash/files"

# === 🕵️‍♂️ Ocultar si está activado ===
if [ -f "$HIDE_FILE" ]; then
  echo -e "<txt></txt>\n<tool></tool>"
  exit 0
fi

# === 🧠 Verificar estado de la papelera ===
if [[ -d "$TRASH_PATH" && "$(ls -A "$TRASH_PATH" 2>/dev/null)" ]]; then
  TRASH_STATUS="$LABEL_FULL"
  ICON_COLOR="$COLOR_FULL"
else
  TRASH_STATUS="$LABEL_EMPTY"
  ICON_COLOR="$COLOR_EMPTY"
fi

# === 🖼 Línea principal ===
DISPLAY_LINE="<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_MAIN' foreground='$ICON_COLOR'> $ICON_TRASH </span>"

# === 🧾 Tooltip ===
MORE_INFO="<tool>"
MORE_INFO+="<span font_family='$FONT_MAIN' font_size='$TOOLTIP_FONT_SIZE' weight='$TOOLTIP_WEIGHT' foreground='$COLOR_TOOLTIP_TEXT'>"
MORE_INFO+="$LABEL_STATUS: <span foreground='$ICON_COLOR'>$TRASH_STATUS</span>\n"
MORE_INFO+="$LABEL_CLICK"
MORE_INFO+="</span></tool>"

# === 🖱️ Acción al hacer clic ===
ACTION="<txtclick>exo-open --launch FileManager trash:///</txtclick>"

# === 📤 Salida final ===
echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$MORE_INFO"
echo -e "$ACTION"
