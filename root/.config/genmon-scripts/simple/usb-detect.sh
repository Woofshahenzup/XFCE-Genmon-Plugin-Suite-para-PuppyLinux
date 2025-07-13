#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            LABEL_HEADER="Dispositivos USB detectados"
            LABEL_NO_LABEL="Sin etiqueta"
            LABEL_UNKNOWN_FS="Sistema desconocido"
            LABEL_NOT_MOUNTED="No montado"
            LABEL_MOUNTED_AT="montado en"
            ;;
        *)
            LABEL_HEADER="Detected USB Devices"
            LABEL_NO_LABEL="No Label"
            LABEL_UNKNOWN_FS="Unknown FS"
            LABEL_NOT_MOUNTED="Not mounted"
            LABEL_MOUNTED_AT="mounted at"
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 📂 Ruta de ocultación ===
HIDE_FILE="$HOME/.config/genmon-hide/usb"

# === 🎨 Estilo visual centralizado ===
ICON_USB="󱊟"
FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_MAIN="12000"
TOOLTIP_FONT_SIZE="16000"
TOOLTIP_WEIGHT="bold"

COLORS=("#FFFFFF" "#35C5B9" "#FF8800" "#FFBC00" "#8A2BE2" "#FF69B4" "#4B0082" "#00FFFF")
COLOR_TOOLTIP_HEADER="#FFBC00"

SOUND_INSERT="/usr/share/sounds/insert.wav"
SOUND_REMOVE="/usr/share/sounds/remove.wav"

STATE_FILE="/tmp/usb_state"

if [ -f "$HIDE_FILE" ]; then
    echo -e "<txt></txt>\n<tool></tool>"
    exit 0
fi

PREV_USB_COUNT=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
USB_PARTS=()
MOUNTED_COUNT=0

while read -r DEV MOUNTPOINT; do
    if [[ -e "/dev/$DEV" ]] && udevadm info -q path -n "/dev/$DEV" | grep -q 'usb'; then
        USB_PARTS+=("$DEV|$MOUNTPOINT")
        [[ -n "$MOUNTPOINT" ]] && ((MOUNTED_COUNT++))
    fi
done < <(lsblk -rno NAME,MOUNTPOINT | grep -E '^sd[a-z][0-9]+\s')

NUM_USB=${#USB_PARTS[@]}

if (( NUM_USB > PREV_USB_COUNT )); then
    [[ -f "$SOUND_INSERT" ]] && aplay "$SOUND_INSERT" &>/dev/null &
elif (( NUM_USB < PREV_USB_COUNT )); then
    [[ -f "$SOUND_REMOVE" ]] && aplay "$SOUND_REMOVE" &>/dev/null &
fi
echo "$NUM_USB" > "$STATE_FILE"

if (( NUM_USB == 0 )); then
    echo -e "<txt></txt>\n<tool></tool>"
    exit 0
fi

ICON_COLOR="${COLORS[$((NUM_USB-1))]:-${COLORS[-1]}}"
DISPLAY_LINE="<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_MAIN' foreground='$ICON_COLOR'> $ICON_USB  USB:$NUM_USB </span>"

MORE_INFO="<tool>"
MORE_INFO+="<span font_family='$FONT_MAIN' font_size='$TOOLTIP_FONT_SIZE' weight='$TOOLTIP_WEIGHT'>"
MORE_INFO+="<span foreground='$COLOR_TOOLTIP_HEADER'>$LABEL_HEADER:</span>\n"

for ENTRY in "${USB_PARTS[@]}"; do
    DEV="${ENTRY%%|*}"
    MOUNT="${ENTRY##*|}"
    LABEL=$(blkid -o value -s LABEL "/dev/$DEV" 2>/dev/null || echo "$LABEL_NO_LABEL")
    FS=$(blkid -o value -s TYPE "/dev/$DEV" 2>/dev/null || echo "$LABEL_UNKNOWN_FS")
    SIZE=$(lsblk -o SIZE -nd "/dev/$DEV" 2>/dev/null || echo "?")
    MOUNT_INFO="$LABEL_NOT_MOUNTED"
    [[ -n "$MOUNT" ]] && MOUNT_INFO="$LABEL_MOUNTED_AT <b>$MOUNT</b>"

    MORE_INFO+="• <span foreground='$ICON_COLOR'>/dev/$DEV</span> ($LABEL) [$FS $SIZE $MOUNT_INFO]\n"
done

MORE_INFO+="</span></tool>"

CLICK_ACTION="<txtclick>bash -c 'for ENTRY in \"${USB_PARTS[@]}\"; do DEV=\"${ENTRY%%|*}\"; pmount /dev/$DEV; done'</txtclick>"

echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$MORE_INFO"
echo -e "$CLICK_ACTION"
