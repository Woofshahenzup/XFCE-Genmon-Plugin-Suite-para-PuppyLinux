#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            LABEL_CURRENT_DESKTOP="Escritorio actual"
            LABEL_TOTAL_DESKTOPS="Total de escritorios virtuales"
            ;;
        *)
            LABEL_CURRENT_DESKTOP="Current Desktop"
            LABEL_TOTAL_DESKTOPS="Total Virtual Desktops"
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 📂 Ruta de ocultación ===
HIDE_FILE_DESKTOPS="$HOME/.config/genmon-hide/desktops"

# === 🎨 Estilo visual centralizado ===
ICON_ACTIVE=" "
ICON_INACTIVE=" "

COLOR_ACTIVE="#FFFFFF"
COLOR_INACTIVE="#DD908C"
COLOR_TOOLTIP_TITLE="#FFBC00"
COLOR_TOOLTIP_LABEL="#FF5733"
COLOR_TOOLTIP_VALUE="#DD908C"

FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_MAIN="12000"
TOOLTIP_FONT_SIZE="16000"
TOOLTIP_WEIGHT="bold"

# === 🕵️‍♂️ Ocultar si está activado ===
if [ -f "$HIDE_FILE_DESKTOPS" ]; then
    echo "<txt></txt>"
    echo "<tool></tool>"
    exit 0
fi

# === 🧠 Obtener escritorios virtuales ===
CURRENT_DESKTOP=$(wmctrl -d | grep '*' | awk '{print $1}')
TOTAL_DESKTOPS=$(wmctrl -d | wc -l)

# === 🖼 Construir línea de escritorios ===
DESKTOP_ICONS=()
for i in $(seq 0 $((TOTAL_DESKTOPS - 1))); do
  if [[ "$i" -eq "$CURRENT_DESKTOP" ]]; then
    DESKTOP_ICONS+=("<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_MAIN' foreground='$COLOR_ACTIVE'> $ICON_ACTIVE </span>")
  else
    DESKTOP_ICONS+=("<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_MAIN' foreground='$COLOR_INACTIVE'> $ICON_INACTIVE </span>")
  fi
done

DESKTOP_LINE=$(IFS=""; echo "${DESKTOP_ICONS[*]}")

# === 🧾 Tooltip con localización ===
MORE_INFO="<tool>"
MORE_INFO+="<span font_family='$FONT_MAIN' font_size='$TOOLTIP_FONT_SIZE' weight='$TOOLTIP_WEIGHT'>"
MORE_INFO+="┌ <span foreground='$COLOR_TOOLTIP_TITLE'>$LABEL_CURRENT_DESKTOP: $((CURRENT_DESKTOP + 1))</span>\n"
MORE_INFO+="└ <span foreground='$COLOR_TOOLTIP_LABEL'>$LABEL_TOTAL_DESKTOPS:</span> <span foreground='$COLOR_TOOLTIP_VALUE'>$TOTAL_DESKTOPS</span>"
MORE_INFO+="</span></tool>"

# === 🖱️ Acción al hacer clic: cambiar al siguiente escritorio ===
CLICK_ACTION="<txtclick>wmctrl -s $(( (CURRENT_DESKTOP + 1) % TOTAL_DESKTOPS ))</txtclick>"

# === 📤 Salida final ===
echo -e "<txt>$DESKTOP_LINE</txt>"
echo -e "$CLICK_ACTION"
echo -e "$MORE_INFO"
