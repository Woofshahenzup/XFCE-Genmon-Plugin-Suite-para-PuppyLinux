#!/bin/bash

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            WEEKDAYS_FULL="Domingo Lunes Martes Miércoles Jueves Viernes Sábado"
            WEEKDAYS_SHORT="Do Lu Ma Mi Ju Vi Sá"
            MONTHS_FULL=( "" "Enero" "Febrero" "Marzo" "Abril" "Mayo" "Junio" "Julio" "Agosto" "Septiembre" "Octubre" "Noviembre" "Diciembre" )
            DATE_FORMAT="%a %d %b %Y"
            CAL_LOCALE="es_ES.UTF-8"
            WEEKDAYS_TRANSLATED=("Sun" "Mon" "Tue" "Wed" "Thu" "Fri" "Sat")
            ;;
        *)
            WEEKDAYS_FULL="Sunday Monday Tuesday Wednesday Thursday Friday Saturday"
            WEEKDAYS_SHORT="Su Mo Tu We Th Fr Sa"
            MONTHS_FULL=( "" "January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December" )
            DATE_FORMAT="%a %d %b %Y"
            CAL_LOCALE="en_US.UTF-8"
            WEEKDAYS_TRANSLATED=("Sun" "Mon" "Tue" "Wed" "Thu" "Fri" "Sat")
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 🎨 Configuración visual centralizada ===
COLOR_FG_TEXT="#FFFFFF"
COLOR_TODAY="#35C5B9"
COLOR_WEEKDAY="#FF5733"
ICON_DATE=""
TOOLTIP_FONT="Terminess Nerd Font"
TOOLTIP_SIZE="16000"
HIDE_FILE_DATE="$HOME/.config/genmon-hide/date"

if [ -f "$HIDE_FILE_DATE" ]; then
    DISPLAY_LINE=""
    MORE_INFO="<tool></tool>"
    INFO=""
else
    # === 📅 Obtener fecha actual ===
    full_date=$(LC_ALL="$CAL_LOCALE" date +"$DATE_FORMAT")

    # Traducción manual del día y mes si el idioma es español
    if [ "$LANG_CODE" = "es" ]; then
        full_date=$(echo "$full_date" | sed \
            -e 's/Sun/Dom/' -e 's/Mon/Lun/' -e 's/Tue/Mar/' -e 's/Wed/Mié/' \
            -e 's/Thu/Jue/' -e 's/Fri/Vie/' -e 's/Sat/Sáb/' \
            -e 's/Jan/Ene/' -e 's/Feb/Feb/' -e 's/Mar/Mar/' -e 's/Apr/Abr/' \
            -e 's/May/May/' -e 's/Jun/Jun/' -e 's/Jul/Jul/' -e 's/Aug/Ago/' \
            -e 's/Sep/Sep/' -e 's/Oct/Oct/' -e 's/Nov/Nov/' -e 's/Dec/Dic/')
    fi

    current_day=$(date +"%e" | sed 's/^ //')
    current_day=$(printf "%d" "$current_day")
    current_weekday=$(date +"%A")
    current_month_num=$(date +"%m")

    # === Generar calendario con día resaltado ===
    t=$(cal | awk -v day="$current_day" -v current_weekday_name="$current_weekday" \
        -v color_day="$COLOR_TODAY" -v color_week="$COLOR_WEEKDAY" \
        -v weekdays_full_str="$WEEKDAYS_FULL" -v weekdays_short_str="$WEEKDAYS_SHORT" \
        -v current_month_num="$current_month_num" \
        -v months_full_str="${MONTHS_FULL[*]}" '
    BEGIN {
        split(weekdays_full_str, weekdays_full, " ")
        split(weekdays_short_str, weekdays_short, " ")
        split(months_full_str, months_full, " ")

        for (i = 1; i <= 7; i++) {
            weekday_index_map[weekdays_full[i]] = i - 1;
        }
    }
    NR == 1 {
        $1 = months_full[current_month_num + 0];
        month_length = length($0);
        spaces = int((20 - month_length) / 2);
        $0 = sprintf("%*s", spaces + month_length, $0);
        print "<span foreground=\"#928374\"><b>" $0 "</b></span>";
        next;
    }
    NR == 2 {
        for (i = 1; i <= NF; i++) {
            current_weekday_index = weekday_index_map[current_weekday_name];
            if (i == current_weekday_index + 1) {
                $i = "<span foreground=\"" color_week "\"><b>" weekdays_short[i] "</b></span>";
            } else {
                $i = weekdays_short[i];
            }
        }
        print;
        next;
    }
    {
        for (i = 1; i <= NF; i++) {
            if ($i == day) {
                $i = "<span foreground=\"" color_day "\"><b>" $i "</b></span>";
            }
        }
        print;
    }')

    # === Tooltip con estilo ===
    t="<span font_family='$TOOLTIP_FONT' font_size='$TOOLTIP_SIZE'>$t</span>"

    # === Línea principal del panel ===
    DISPLAY_LINE="<span foreground='$COLOR_FG_TEXT'> $ICON_DATE  $full_date </span>"

    # === Acción al hacer clic ===
    INFO="<txt>$DISPLAY_LINE</txt>"
    INFO+="<txtclick>set-time-for-puppy</txtclick>"

    # === Tooltip con calendario ===
    MORE_INFO="<tool>$t</tool>"
fi

# === 📤 Salida final ===
echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$INFO"
echo -e "$MORE_INFO"
