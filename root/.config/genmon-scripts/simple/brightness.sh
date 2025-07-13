#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Establecer texto según idioma ===
set_tooltip_text() {
  case "$1" in
    es) TOOLTIP_TEXT="Brillo:";;
    *)  TOOLTIP_TEXT="Brightness:";;
  esac
}

set_tooltip_text "$LANG_CODE"

# === Configuración visual centralizada ===

# --- Paleta de colores moderna ---
COLOR_BG_MAIN="#343678"
COLOR_BG_SECOND="#3C4451"
COLOR_FG_TEXT="#ABB2BF"
COLOR_ACCENT="#FFFFFF"
COLOR_HIGHLIGHT="#56B6C2"

COLOR_BG_LEFT="#3C4451"
COLOR_FG_LEFT="#f6f7f9"
COLOR_BG_RIGHT="#778899"
COLOR_FG_RIGHT="#D3A39F"

# --- Separadores Powerline ---
SEP_LEFT="\uE0B0"
SEP_RIGHT="\uE0B2"

# --- Íconos de brillo (Nerd Fonts) ---
ICON_BRIGHTNESS=( "󰃜" "󰃝" "󰃞" "󰃟" "󰃠" )

# --- Colores asociados a niveles de brillo ---
COLOR_BRIGHTNESS=( "#BE5046" "#61AFEF" "$COLOR_HIGHLIGHT" "#E5C07B" "$COLOR_ACCENT" )

# --- Fuente para tooltip ---
TOOLTIP_FONT="Terminess Nerd Font"
TOOLTIP_SIZE="14000"
TOOLTIP_WEIGHT="bold"

# === Ruta de ocultación ===
HIDE_FILE_BRIGHTNESS="$HOME/.config/genmon-hide/brightness"
mkdir -p "$HOME/.config/genmon-hide"

# === Función para obtener el brillo actual ===
get_brightness() {
  if command -v brightnessctl &> /dev/null; then
    brightnessctl -m | awk -F, '{gsub("%", "", $4); print $4}'
  elif [ -d /sys/class/backlight ]; then
    dir=$(find /sys/class/backlight/ -type d | head -n1)
    if [[ -r "$dir/brightness" && -r "$dir/max_brightness" ]]; then
      max=$(cat "$dir/max_brightness")
      cur=$(cat "$dir/brightness")
      echo $(( 100 * cur / max ))
    else
      echo "N/A"
    fi
  else
    brightness=$(xrandr --verbose | grep -i brightness | awk '{print int($2 * 100)}' | head -n1)
    echo "${brightness:-N/A}"
  fi
}

# === Lógica principal ===
if [ -f "$HIDE_FILE_BRIGHTNESS" ]; then
  DISPLAY_LINE=""
  MORE_INFO=""
  INFO=""
else
  BRIGHTNESS_PERCENT=$(get_brightness)

  # Determinar ícono y color según el nivel
  if [[ "$BRIGHTNESS_PERCENT" -ge 80 ]]; then
    ICON="${ICON_BRIGHTNESS[4]}"
    COLOR_ICON="${COLOR_BRIGHTNESS[4]}"
  elif [[ "$BRIGHTNESS_PERCENT" -ge 60 ]]; then
    ICON="${ICON_BRIGHTNESS[3]}"
    COLOR_ICON="${COLOR_BRIGHTNESS[3]}"
  elif [[ "$BRIGHTNESS_PERCENT" -ge 40 ]]; then
    ICON="${ICON_BRIGHTNESS[2]}"
    COLOR_ICON="${COLOR_BRIGHTNESS[2]}"
  elif [[ "$BRIGHTNESS_PERCENT" -ge 20 ]]; then
    ICON="${ICON_BRIGHTNESS[1]}"
    COLOR_ICON="${COLOR_BRIGHTNESS[1]}"
  else
    ICON="${ICON_BRIGHTNESS[0]}"
    COLOR_ICON="${COLOR_BRIGHTNESS[0]}"
  fi

  # Línea principal
  DISPLAY_LINE="<span foreground='$COLOR_ICON'> $ICON</span><span foreground='$COLOR_ACCENT'>  $BRIGHTNESS_PERCENT% </span>"

  # Tooltip estilizado
  MORE_INFO="<tool>"
  MORE_INFO+="<span font_family='$TOOLTIP_FONT' font_size='$TOOLTIP_SIZE' weight='$TOOLTIP_WEIGHT'>"
  MORE_INFO+="$TOOLTIP_TEXT <span foreground='$COLOR_ICON'>$BRIGHTNESS_PERCENT%</span>"
  MORE_INFO+="</span>"
  MORE_INFO+="</tool>"
fi

# Generar salida final para GenMon
INFO="<txt>$DISPLAY_LINE</txt>$MORE_INFO"
if [ -n "$DISPLAY_LINE" ]; then
  INFO+="<txtclick>dcontrol</txtclick>"
fi

echo -e "$DISPLAY_LINE"
echo -e "$MORE_INFO"
echo -e "$INFO"
