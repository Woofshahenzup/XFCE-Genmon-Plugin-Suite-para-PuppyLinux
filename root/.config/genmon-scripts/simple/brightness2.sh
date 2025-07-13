#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Establecer texto según idioma ===
set_tooltip_text() {
  case "$1" in
    es) TOOLTIP_TEXT="Nivel de brillo:";;
    *)  TOOLTIP_TEXT="Brightness level:";;
  esac
}

set_tooltip_text "$LANG_CODE"

# === Configuración visual centralizada ===

# --- Paleta de colores moderna ---
COLOR_BG_MAIN="#313244"
COLOR_FG_TEXT="#1E1E36"
COLOR_ACCENT="#FFFFFF"
COLOR_HIGHLIGHT="#56B6C2"
COLOR_LOW="#61AFEF"
COLOR_MEDIUM="#E5C07B"
COLOR_VERY_LOW="#BE5046"

# --- Separadores Powerline ---
SEP_RIGHT="\uE0B2"

# --- Íconos de brillo (Nerd Fonts) ---
ICON_BRIGHTNESS=(
  "󰃜"  # Muy bajo
  "󰃝"  # Bajo
  "󰃞"  # Medio
  "󰃟"  # Medio-alto
  "󰃠"  # Alto
)

# --- Colores asociados a niveles ---
COLOR_BRIGHTNESS=(
  "$COLOR_VERY_LOW"
  "$COLOR_LOW"
  "$COLOR_HIGHLIGHT"
  "$COLOR_MEDIUM"
  "$COLOR_ACCENT"
)

# --- Fuente para tooltip ---
TOOLTIP_FONT="Terminess Nerd Font"
TOOLTIP_SIZE="16000"
TOOLTIP_WEIGHT="bold"

# === Ruta de ocultación ===
HIDE_FILE_BRIGHTNESS_XRANDR="$HOME/.config/genmon-hide/brightness2"
mkdir -p "$HOME/.config/genmon-hide"

# === Obtener pantalla activa ===
display=$(xrandr --prop | grep " connected" | awk '{print $1}' | head -n1)

# === Función para obtener el brillo actual ===
get_brightness() {
  brightness=$(xrandr --verbose | grep -A5 "$display" | grep Brightness | awk '{print int($2 * 100)}')
  echo "${brightness:-N/A}"
}

# === Lógica principal ===
if [ -f "$HIDE_FILE_BRIGHTNESS_XRANDR" ]; then
  DISPLAY_LINE=""
  TOOLTIP=""
else
  BRIGHTNESS_PERCENT=$(get_brightness)

  # Determinar ícono y color según el nivel
  if (( BRIGHTNESS_PERCENT >= 120 )); then
    ICON="${ICON_BRIGHTNESS[4]}"
    COLOR_ICON="${COLOR_BRIGHTNESS[4]}"
  elif (( BRIGHTNESS_PERCENT >= 90 )); then
    ICON="${ICON_BRIGHTNESS[3]}"
    COLOR_ICON="${COLOR_BRIGHTNESS[3]}"
  elif (( BRIGHTNESS_PERCENT >= 70 )); then
    ICON="${ICON_BRIGHTNESS[2]}"
    COLOR_ICON="${COLOR_BRIGHTNESS[2]}"
  elif (( BRIGHTNESS_PERCENT >= 50 )); then
    ICON="${ICON_BRIGHTNESS[1]}"
    COLOR_ICON="${COLOR_BRIGHTNESS[1]}"
  else
    ICON="${ICON_BRIGHTNESS[0]}"
    COLOR_ICON="${COLOR_BRIGHTNESS[0]}"
  fi

  # Línea visual principal
  DISPLAY_LINE="<span foreground='$COLOR_ICON'> $ICON</span><span foreground='$COLOR_ACCENT'>  $BRIGHTNESS_PERCENT%</span>"

  # Tooltip estilizado
  TOOLTIP="<tool>"
  TOOLTIP+="<span font_family='$TOOLTIP_FONT' font_size='$TOOLTIP_SIZE' weight='$TOOLTIP_WEIGHT'>"
  TOOLTIP+="$TOOLTIP_TEXT <span foreground='$COLOR_ICON'>$BRIGHTNESS_PERCENT%</span>"
  TOOLTIP+="</span>"
  TOOLTIP+="</tool>"
fi

# Salida para GenMon
INFO="<txt>$DISPLAY_LINE</txt>$TOOLTIP"

# Acción al hacer clic
if [ -n "$DISPLAY_LINE" ]; then
  INFO+="<txtclick>/usr/local/dcontrol/dcontrol</txtclick>"
fi

# Mostrar resultado
echo -e "$INFO"
