#!/bin/bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            LABEL_PUPSAVE="Espacio en Pupsave"
            LABEL_LIVE="Espacio en modo live"
            LABEL_TOTAL="Total"
            LABEL_USED="Usado"
            LABEL_FREE="Libre"
            LABEL_NO_DATA="Sin datos para"
            LABEL_NO_MOUNT="No se encontró punto de montaje."
            ;;
        *)
            LABEL_PUPSAVE="Space in Pupsave"
            LABEL_LIVE="Space in live mode"
            LABEL_TOTAL="Total"
            LABEL_USED="Used"
            LABEL_FREE="Free"
            LABEL_NO_DATA="No data for"
            LABEL_NO_MOUNT="No mountpoint found."
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 🎨 Paleta pastel y estilo ===
COLOR_BG_MAIN="#13131C"
COLOR_BG_SECOND="#7D8CA3"
COLOR_TEXT="#D1A1C1"
COLOR_ACCENT="#FFFFFF"
COLOR_FREE="#A1EFD3"
COLOR_USED="#F2B5D4"
COLOR_TOTAL="#7D8CA3"
COLOR_LABEL="#FFA69E"
COLOR_HEADER="#56B6C2"
COLOR_ALERT="#FF0000"
COLOR_WARN="#FF8C00"
COLOR_MED="#FFD700"
COLOR_LOW="#A1EFD3"
COLOR_EMPTY="#66CCFF"

FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_MAIN="14000"
FONT_SIZE_TOOLTIP="16000"
FONT_WEIGHT="bold"

ICON_STORAGE="󱂵"

SEP_LEFT="\uE0B6"
SEP_RIGHT="\uE0B4"

MOUNT_POINT1="/initrd/mnt/dev_save"
MOUNT_POINT2="/initrd/pup_rw"

HIDE_STORAGE="$HOME/.config/genmon-hide/storage"

INFO=""
MORE_INFO=""
DISPLAY_LINE=""

if [ -f "$HIDE_STORAGE" ]; then
  echo -e "<txt></txt>\n<tool></tool>"
  exit 0
fi

get_storage_info() {
  local mount_point=$1
  if [ -d "$mount_point" ]; then
    local total_size=$(df -B1 "$mount_point" | awk 'NR==2 {printf "%.2f", $2 / 1073741824}')
    local used_space=$(df -B1 "$mount_point" | awk 'NR==2 {printf "%.2f", $3 / 1073741824}')
    local free_space=$(df -B1 "$mount_point" | awk 'NR==2 {printf "%.2f", $4 / 1073741824}')
    local percent_used=$(awk "BEGIN {printf \"%.0f\", ($used_space/$total_size)*100}")

    local description=""
    case "$mount_point" in
      "$MOUNT_POINT1") description="$LABEL_PUPSAVE" ;;
      "$MOUNT_POINT2") description="$LABEL_LIVE" ;;
      *) description="$mount_point" ;;
    esac

    MORE_INFO+="<tool>"
    MORE_INFO+="<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_TOOLTIP' font_weight='$FONT_WEIGHT'>"
    MORE_INFO+="<span foreground='$COLOR_ACCENT'>󱂵  $description</span>\n"
    MORE_INFO+="├─ <span foreground='$COLOR_FREE'>$LABEL_TOTAL:</span> <span foreground='$COLOR_TOTAL'>${total_size} GB</span>\n"
    MORE_INFO+="├─ <span foreground='$COLOR_LABEL'>$LABEL_USED:</span> <span foreground='$COLOR_USED'>${used_space} GB</span>\n"
    MORE_INFO+="└─ <span foreground='$COLOR_HEADER'>$LABEL_FREE:</span> <span foreground='$COLOR_FREE'>${free_space} GB</span>\n"
    MORE_INFO+="</span></tool>"

    local icon=""
    local icon_color=""
    if [ "$percent_used" -gt 80 ]; then
      icon="󰡴"; icon_color="$COLOR_ALERT"
    elif [ "$percent_used" -gt 60 ]; then
      icon="󰊚"; icon_color="$COLOR_WARN"
    elif [ "$percent_used" -gt 40 ]; then
      icon="󰡵"; icon_color="$COLOR_MED"
    elif [ "$percent_used" -gt 20 ]; then
      icon="󰡳"; icon_color="$COLOR_LOW"
    else
      icon="󰡳"; icon_color="$COLOR_EMPTY"
    fi

    DISPLAY_LINE+="<span foreground='$icon_color'> $icon</span><span foreground='$COLOR_ACCENT'>  ${percent_used}% </span>"
  else
    DISPLAY_LINE="<span foreground='$COLOR_TEXT'>$ICON_STORAGE N/A</span>"
    MORE_INFO="<tool><span font_family='$FONT_MAIN' font_size='$FONT_SIZE_TOOLTIP'>$LABEL_NO_DATA $mount_point</span></tool>"
  fi
}

if [ -d "$MOUNT_POINT1" ]; then
  get_storage_info "$MOUNT_POINT1"
elif [ -d "$MOUNT_POINT2" ]; then
  get_storage_info "$MOUNT_POINT2"
else
  DISPLAY_LINE="<span foreground='$COLOR_TEXT'>$ICON_STORAGE N/A</span>"
  MORE_INFO="<tool><span font_family='$FONT_MAIN' font_size='$FONT_SIZE_TOOLTIP'>$LABEL_NO_MOUNT</span></tool>"
fi

ACTION="<txtclick>pmount</txtclick>"

echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$ACTION"
echo -e "$MORE_INFO"
