#!/bin/bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            WEEKDAYS="Domingo Lunes Martes Miércoles Jueves Viernes Sábado"
            SHORT_DAYS="Do Lu Ma Mi Ju Vi Sá"
            ;;
        *)
            WEEKDAYS="Sunday Monday Tuesday Wednesday Thursday Friday Saturday"
            SHORT_DAYS="Su Mo Tu We Th Fr Sa"
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 🎨 Estilo visual centralizado ===
COLOR_BG_MAIN="#13131C"
COLOR_FG_TEXT="#FFFFFF"
COLOR_ACCENT="#FFFFFF"
COLOR_HIGHLIGHT="#56B6C2"
COLOR_DAY_HIGHLIGHT="#35C5B9"
COLOR_WEEKDAY_HIGHLIGHT="#FF5733"

FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_MAIN="12000"
TOOLTIP_FONT_SIZE="16000"
TOOLTIP_WEIGHT="bold"

ICON_CLOCK=""

SEP_LEFT="\uE0B4"
SEP_RIGHT="\uE0B6"

HIDE_FILE_TIME="$HOME/.config/genmon-hide/time"

if [ -f "$HIDE_FILE_TIME" ]; then
  echo -e "<txt></txt>\n<tool></tool>"
  exit 0
fi

# === 🕒 Obtener hora actual ===
current_time=$(date +"%I:%M %p")
current_day=$(date +"%e")
current_weekday=$(date +"%A")

# === 📅 Generar calendario con día resaltado ===
calendar=$(cal | awk -v day="$current_day" -v weekday="$current_weekday" \
  -v wcolor="$COLOR_WEEKDAY_HIGHLIGHT" -v dcolor="$COLOR_DAY_HIGHLIGHT" \
  -v weekdays="$WEEKDAYS" -v short_days="$SHORT_DAYS" '
BEGIN {
    split(weekdays, wd, " ")
    split(short_days, sd, " ")
    for (i = 1; i <= 7; i++) {
        if (wd[i] == weekday) sd[i] = "<span foreground=\"" wcolor "\"><b>" sd[i] "</b></span>"
    }
}
NR == 2 {
    for (i = 1; i <= NF; i++) $i = sd[i]
}
{
    for (i = 1; i <= NF; i++) {
        if ($i == day) $i = "<span foreground=\"" dcolor "\"><b>" $i "</b></span>"
    }
    print
}')

# === 🧾 Tooltip con calendario ===
MORE_INFO="<tool><span font_family='$FONT_MAIN' font_size='$TOOLTIP_FONT_SIZE'>$calendar</span></tool>"

# === 🖼 Línea principal con ícono ===
DISPLAY_LINE="<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_MAIN' foreground='$COLOR_ACCENT'> $ICON_CLOCK  $current_time </span>"

# === 🖱️ Acción al hacer clic ===
INFO="<txt>$DISPLAY_LINE</txt>"
INFO+="<txtclick>set-time-for-puppy</txtclick>"

# === 📤 Salida final ===
echo -e "$INFO"
echo -e "$MORE_INFO"
