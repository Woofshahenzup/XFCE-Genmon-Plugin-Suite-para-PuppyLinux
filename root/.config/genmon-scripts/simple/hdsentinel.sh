#!/bin/bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            LABEL_DISK_INFO="Información del disco"
            LABEL_USB_INFO="Información del dispositivo USB"
            LABEL_MODEL="Modelo"
            LABEL_SERIAL="Serie"
            LABEL_HEALTH="Salud"
            LABEL_TEMP="Temperatura"
            LABEL_POWER="Tiempo encendido"
            LABEL_SIZE="Tamaño"
            LABEL_TYPE="Tipo"
            LABEL_WRITTEN="Total escrito"
            LABEL_NO_DISKS="Sin discos"
            LABEL_NO_INFO="Sin información disponible"
            ;;
        *)
            LABEL_DISK_INFO="Disk Info"
            LABEL_USB_INFO="USB Device Info"
            LABEL_MODEL="Model"
            LABEL_SERIAL="Serial"
            LABEL_HEALTH="Health"
            LABEL_TEMP="Temperature"
            LABEL_POWER="Power on time"
            LABEL_SIZE="Size"
            LABEL_TYPE="Type"
            LABEL_WRITTEN="Total Written"
            LABEL_NO_DISKS="No disks"
            LABEL_NO_INFO="No info available"
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 🎨 Configuración visual centralizada ===

COLOR_PANEL="#FFFFFF"
COLOR_LABEL="#FFBC00"
COLOR_MODEL="#35C5B9"
COLOR_SERIAL="#FF5733"
COLOR_HEALTH="#35C5B9"
COLOR_TEMP="#FF5733"
COLOR_POWER="#6F9B3F"
COLOR_SIZE="#35C5B9"
COLOR_WRITTEN="#35C5B9"
COLOR_TYPE="#FFBC00"

TOOLTIP_FONT="Terminess Nerd Font"
TOOLTIP_SIZE="14000"
TOOLTIP_WEIGHT="bold"

HDSENTINEL_CMD="/bin/hdsentinel"
TEMP_LOG="/tmp/hdsentinel_report.log"
HIDE_FILE="$HOME/.config/genmon-hide/hdsentinel"

if [ -f "$HIDE_FILE" ]; then
  DISPLAY_LINE=""
  MORE_INFO=""
  INFO=""
else
  if ! [ -x "$HDSENTINEL_CMD" ]; then
    DISPLAY_LINE="<txt><span foreground='$COLOR_PANEL'>No hdsentinel</span></txt>"
    MORE_INFO=""
    INFO=""
  else
    "$HDSENTINEL_CMD" > "$TEMP_LOG"

    extract_disk_info_from_log() {
      local DEVICE="$1"
      local HDD_DATA=$(grep -A 12 -i "$DEVICE" "$TEMP_LOG")

      local MODEL=$(grep -i "Model ID" <<< "$HDD_DATA" | sed 's/.*Model ID *: //')
      local SERIAL=$(grep -i "Serial No" <<< "$HDD_DATA" | sed 's/.*Serial No *: //')
      local TEMP=$(grep -i "Temperature" <<< "$HDD_DATA" | sed 's/.*Temperature *: //; s/°C//')
      local HEALTH=$(grep -i "Health" <<< "$HDD_DATA" | sed 's/.*Health *: //; s/%//')
      local POWER_ON_TIME=$(grep -i "Power on time" <<< "$HDD_DATA" | sed 's/.*Power on time *: //')
      local SIZE=$(grep -i "HDD Size" <<< "$HDD_DATA" | sed 's/.*HDD Size *: //; s/ MB//')
      local TOTAL_WRITTEN=$(grep -i "Total written" <<< "$HDD_DATA" | sed 's/.*Total written *: //')

      local TYPE="HDD"
      if echo "$MODEL" | grep -qi "NVMe"; then
        TYPE="NVMe"
      elif echo "$MODEL" | grep -qiE "M\.2|SSD|Solid State|Samsung|Crucial|Kingston|SanDisk|Intel"; then
        TYPE="SSD"
      elif echo "$MODEL" | grep -qiE "Spin|SATA|Seagate|Western Digital|HGST|Toshiba"; then
        TYPE="HDD"
      fi

      echo "$MODEL|$SERIAL|$TEMP|$HEALTH|$POWER_ON_TIME|$SIZE|$TOTAL_WRITTEN|$TYPE"
    }

    should_exclude_from_panel() {
      local MODEL="$1"
      local DEVICE="$2"
      [[ "$MODEL" =~ [Kk]ingston.*[Dd]ata[Tt]raveler ]] || udevadm info --query=property --name="/dev/$DEVICE" | grep -q "ID_BUS=usb"
    }

    DEVICES=$(lsblk -dno NAME,TYPE | awk '$2 == "disk" {print $1}'; ls /dev/nvme* 2>/dev/null | awk -F'/' '{print $3}' | sort -u)

    DISPLAY_LINE=""
    TOOLTIP_OUTPUT=""

    for DEVICE in $DEVICES; do
      if grep -iq "$DEVICE" "$TEMP_LOG"; then
        DISK_INFO=$(extract_disk_info_from_log "$DEVICE")
        IFS="|" read -r MODEL SERIAL TEMP HEALTH POWER_ON_TIME SIZE TOTAL_WRITTEN TYPE <<< "$DISK_INFO"

        if should_exclude_from_panel "$MODEL" "$DEVICE"; then
          TOOLTIP_OUTPUT+="┌ <span foreground='$COLOR_LABEL'>$LABEL_USB_INFO ($DEVICE)</span>&#10;"
          TOOLTIP_OUTPUT+="├ <span foreground='$COLOR_LABEL'>$LABEL_MODEL:</span> <span foreground='$COLOR_MODEL'>$MODEL</span>&#10;"
          TOOLTIP_OUTPUT+="├ <span foreground='$COLOR_SERIAL'>$LABEL_SERIAL:</span> $SERIAL&#10;"
          TOOLTIP_OUTPUT+="├ <span foreground='$COLOR_LABEL'>$LABEL_HEALTH:</span> <span foreground='$COLOR_HEALTH'>$HEALTH%</span>&#10;"
          TOOLTIP_OUTPUT+="├ <span foreground='$COLOR_LABEL'>$LABEL_TEMP:</span> <span foreground='$COLOR_TEMP'>$TEMP°C</span>&#10;"
          TOOLTIP_OUTPUT+="├ <span foreground='$COLOR_POWER'>$LABEL_POWER:</span> $POWER_ON_TIME&#10;"
          TOOLTIP_OUTPUT+="├ <span foreground='$COLOR_LABEL'>$LABEL_SIZE:</span> <span foreground='$COLOR_SIZE'>$SIZE MB</span>&#10;"
          TOOLTIP_OUTPUT+="└ <span foreground='$COLOR_LABEL'>$LABEL_TYPE:</span> USB&#10;&#10;"
          continue
        fi

        DISPLAY_LINE+="<span foreground='$COLOR_PANEL'> $DEVICE:</span> <span foreground='$COLOR_PANEL'>$HEALTH%  $TEMP°C </span>"

        TOOLTIP_OUTPUT+="┌ <span foreground='$COLOR_LABEL'>$LABEL_DISK_INFO ($DEVICE)</span>&#10;"
        TOOLTIP_OUTPUT+="├ <span foreground='$COLOR_LABEL'>$LABEL_MODEL:</span> <span foreground='$COLOR_MODEL'>$MODEL</span>&#10;"
        TOOLTIP_OUTPUT+="├ <span foreground='$COLOR_SERIAL'>$LABEL_SERIAL:</span> $SERIAL&#10;"
        TOOLTIP_OUTPUT+="├ <span foreground='$COLOR_LABEL'>$LABEL_HEALTH:</span> <span foreground='$COLOR_HEALTH'>$HEALTH%</span>&#10;"
        TOOLTIP_OUTPUT+="├ <span foreground='$COLOR_LABEL'>$LABEL_TEMP:</span> <span foreground='$COLOR_TEMP'>$TEMP°C</span>&#10;"
        TOOLTIP_OUTPUT+="├ <span foreground='$COLOR_POWER'>$LABEL_POWER:</span> $POWER_ON_TIME&#10;"
        TOOLTIP_OUTPUT+="├ <span foreground='$COLOR_LABEL'>$LABEL_SIZE:</span> <span foreground='$COLOR_SIZE'>$SIZE MB</span>&#10;"
        TOOLTIP_OUTPUT+="└ <span foreground='$COLOR_LABEL'>$LABEL_TYPE:</span> $TYPE&#10;&#10;"

        if [[ "$TYPE" == "SSD" || "$TYPE" == "NVMe" ]]; then
          TOOLTIP_OUTPUT+="├ <span foreground='$COLOR_LABEL'>$LABEL_WRITTEN:</span> <span foreground='$COLOR_WRITTEN'>$TOTAL_WRITTEN</span>&#10;&#10;"
        fi
      fi
    done

    DISPLAY_LINE="<txt>${DISPLAY_LINE:-<span foreground='$COLOR_PANEL'>$LABEL_NO_DISKS</span>}</txt>"
    MORE_INFO="<tool><span font_family='$TOOLTIP_FONT' font_size='$TOOLTIP_SIZE' weight='$TOOLTIP_WEIGHT'>${TOOLTIP_OUTPUT:-$LABEL_NO_INFO}</span></tool>"
    INFO="<txtclick>gparted</txtclick>"
  fi
fi

echo -e "$DISPLAY_LINE"
echo -e "$MORE_INFO"
echo -e "$INFO"

[ -f "$TEMP_LOG" ] && rm -f "$TEMP_LOG"
