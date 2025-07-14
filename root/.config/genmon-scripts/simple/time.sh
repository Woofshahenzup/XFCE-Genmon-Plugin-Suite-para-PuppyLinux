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
            MONTHS_FULL=( "" "Enero" "Febrero" "Marzo" "Abril" "Mayo" "Junio" "Julio" "Agosto" "Septiembre" "Octubre" "Noviembre" "Diciembre" )
            ;;
        *)
            WEEKDAYS="Sunday Monday Tuesday Wednesday Thursday Friday Saturday"
            SHORT_DAYS="Su Mo Tu We Th Fr Sa"
            MONTHS_FULL=( "" "January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December" )
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

HIDE_FILE_TIME="$HOME/.config/genmon-hide/time"

if [ -f "$HIDE_FILE_TIME" ]; then
  echo -e "<txt></txt>\n<tool></tool>"
  exit 0
fi

# === 🕒 Obtener hora actual ===
current_time=$(date +"%I:%M %p")
current_day=$(date +"%e" | sed 's/^ //')
current_day_num=$(printf "%d" "$current_day")
current_weekday=$(date +"%A")
current_month_num=$(date +"%m")

# === 📅 Generar calendario enriquecido ===
calendar=$(cal | awk -v day="$current_day_num" -v weekday="$current_weekday" \
  -v color_day="$COLOR_DAY_HIGHLIGHT" -v color_week="$COLOR_WEEKDAY_HIGHLIGHT" \
  -v weekdays_full="$WEEKDAYS" -v short_days="$SHORT_DAYS" \
  -v month_num="$current_month_num" -v lang="$LANG_CODE" '
BEGIN {
    split(weekdays_full, wd_full, " ")
    split(short_days, wd_short, " ")
    split(" Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre", months_es, " ")
    split(" January February March April May June July August September October November December", months_en, " ")

    for (i = 1; i <= 7; i++) {
        weekday_index[wd_full[i]] = i - 1
    }
}
NR == 1 {
    month_name = (lang == "es") ? months_es[month_num + 0] : months_en[month_num + 0]
    pad = int((20 - length(month_name)) / 2)
    print "<span foreground=\"#928374\"><b>" sprintf("%*s", pad + length(month_name), month_name) "</b></span>"
    next
}
NR == 2 {
    for (i = 1; i <= NF; i++) {
        if (i - 1 == weekday_index[weekday]) $i = "<span foreground=\"" color_week "\"><b>" wd_short[i] "</b></span>"
        else $i = wd_short[i]
    }
    print
    next
}
{
    for (i = 1; i <= NF; i++) {
        if ($i == day) $i = "<span foreground=\"" color_day "\"><b>" $i "</b></span>"
    }
    print
}')

# === 🧾 Tooltip con calendario estilizado ===
MORE_INFO="<tool><span font_family='$FONT_MAIN' font_size='$TOOLTIP_FONT_SIZE'>$calendar</span></tool>"

# === 🖼 Línea principal con reloj e ícono ===
DISPLAY_LINE="<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_MAIN' foreground='$COLOR_ACCENT'> $ICON_CLOCK  $current_time </span>"

# === 🖱️ Acción al hacer clic (personalizable) ===
INFO="<txt>$DISPLAY_LINE</txt>"
INFO+="<txtclick>set-time-for-puppy</txtclick>"

# === 📤 Salida final ===
echo -e "$INFO"
echo -e "$MORE_INFO"
