#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8
TIMEOUT=5
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')
FONT_TEMP="Terminess Nerd Font"

convert_to_nerd_font() {
    local text="$1"
    text="${text//☀️/}"
    text="${text//🌙/󰖔}"
    text="${text//☁️/}"
    text="${text//🌧️/}"
    text="${text//❄️/}"
    text="${text//⛈️/󰖓}"
    text="${text//🌫️/󰖑}"
    text="${text//🌬️/󰖝}"
    text="${text//🌨️/󰖒}"
    text="${text//🌪️/}"
    text="${text//🌡/󰜬}"
    echo "$text"
}
case "$LANG_CODE" in
    es)
        # Etiquetas generales
        LABEL_CITY_NOT_FOUND="Ciudad no encontrada"
        LABEL_FETCH_ERROR="No se pudo obtener el clima para"
        LABEL_CITY_PROMPT="Ingresa ciudad (ej. Londres, Nueva York)"
        LABEL_CITY_UPDATED="Ciudad actualizada"
        LABEL_CITY_UPDATED_MSG="Se cambió a"

        # Etiquetas abreviadas
        LABEL_WIND="Vto"
        LABEL_HUMIDITY="Hum"
        LABEL_MAX="Max"
        LABEL_MIN="Min"

        # Descripciones de clima
        WEATHER_DESC_CLEAR="Despejado"
        WEATHER_DESC_SUN="Soleado"
        WEATHER_DESC_CLOUD="Nublado"
        WEATHER_DESC_OVERCAST="Cubierto"
        WEATHER_DESC_RAIN="Lluvia"
        WEATHER_DESC_SHOWER="Chubascos"
        WEATHER_DESC_DRIZZLE="Llovizna"
        WEATHER_DESC_SNOW="Nieve"
        WEATHER_DESC_SLEET="Aguanieve"
        WEATHER_DESC_BLIZZARD="Ventisca"
        WEATHER_DESC_THUNDER="Tormenta eléctrica"
        WEATHER_DESC_STORM="Tormenta"
        WEATHER_DESC_MIST="Bruma"
        WEATHER_DESC_FOG="Niebla"
        WEATHER_DESC_HAZE="Calina"
        WEATHER_DESC_WIND="Viento"
        WEATHER_DESC_HAIL="Granizo"
        WEATHER_DESC_DUST="Polvoriento"
        ;;
    *)
        LABEL_CITY_NOT_FOUND="City not found"
        LABEL_FETCH_ERROR="Could not fetch weather for"
        LABEL_CITY_PROMPT="Enter city"
        LABEL_CITY_UPDATED="City Updated"
        LABEL_CITY_UPDATED_MSG="Changed to"

        LABEL_WIND="Wind"
        LABEL_HUMIDITY="Hum"
        LABEL_MAX="Max"
        LABEL_MIN="Min"

        WEATHER_DESC_CLEAR="Clear"
        WEATHER_DESC_SUN="Sunny"
        WEATHER_DESC_CLOUD="Cloudy"
        WEATHER_DESC_OVERCAST="Overcast"
        WEATHER_DESC_RAIN="Rain"
        WEATHER_DESC_SHOWER="Showers"
        WEATHER_DESC_DRIZZLE="Drizzle"
        WEATHER_DESC_SNOW="Snow"
        WEATHER_DESC_SLEET="Sleet"
        WEATHER_DESC_BLIZZARD="Blizzard"
        WEATHER_DESC_THUNDER="Thunderstorm"
        WEATHER_DESC_STORM="Storm"
        WEATHER_DESC_MIST="Mist"
        WEATHER_DESC_FOG="Fog"
        WEATHER_DESC_HAZE="Haze"
        WEATHER_DESC_WIND="Wind"
        WEATHER_DESC_HAIL="Hail"
        WEATHER_DESC_DUST="Widespread Dust"
        ;;
esac
translate_weather_desc() {
    case "$1" in
        *clear*) echo "$WEATHER_DESC_CLEAR" ;;
        *sun*) echo "$WEATHER_DESC_SUN" ;;
        *cloud*) echo "$WEATHER_DESC_CLOUD" ;;
        *overcast*) echo "$WEATHER_DESC_OVERCAST" ;;
        *rain*) echo "$WEATHER_DESC_RAIN" ;;
        *shower*) echo "$WEATHER_DESC_SHOWER" ;;
        *drizzle*) echo "$WEATHER_DESC_DRIZZLE" ;;
        *snow*) echo "$WEATHER_DESC_SNOW" ;;
        *sleet*) echo "$WEATHER_DESC_SLEET" ;;
        *blizzard*) echo "$WEATHER_DESC_BLIZZARD" ;;
        *thunder*) echo "$WEATHER_DESC_THUNDER" ;;
        *storm*) echo "$WEATHER_DESC_STORM" ;;
        *mist*) echo "$WEATHER_DESC_MIST" ;;
        *fog*) echo "$WEATHER_DESC_FOG" ;;
        *haze*) echo "$WEATHER_DESC_HAZE" ;;
        *wind*) echo "$WEATHER_DESC_WIND" ;;
        *hail*) echo "$WEATHER_DESC_HAIL" ;;
        *dust*) echo "$WEATHER_DESC_DUST" ;;
        *) echo "$1" ;;
    esac
}

CONFIG_DIR="$HOME/.config"
CITY_FILE="$CONFIG_DIR/genmon-weather-city.txt"
HIDE_FILE="$CONFIG_DIR/genmon-hide/weather"
mkdir -p "$CONFIG_DIR"
[ ! -f "$CITY_FILE" ] && echo "San Salvador" > "$CITY_FILE"

CITY=$(<"$CITY_FILE")
ENCODED_CITY="${CITY// /+}"

if [ -f "$HIDE_FILE" ]; then
    echo -e "<txt></txt>\n<tool></tool>"
    exit 0
fi

CITY_MD5=$(echo -n "$ENCODED_CITY" | md5sum | cut -d ' ' -f1)
CACHE_FILE="/tmp/genmon_weather_cache_$CITY_MD5.json"
CACHE_TTL=300
FORECAST=""

if [ -f "$CACHE_FILE" ]; then
    LAST_MOD=$(stat -c %Y "$CACHE_FILE")
    NOW=$(date +%s)
    (( NOW - LAST_MOD < CACHE_TTL )) && FORECAST=$(<"$CACHE_FILE")
fi

if [ -z "$FORECAST" ]; then
    FETCHED=$(curl -s --max-time "$TIMEOUT" -f -H "Accept-Language: $LANG_CODE" "https://wttr.in/$ENCODED_CITY?format=j1")
    if [ -z "$FETCHED" ] || ! echo "$FETCHED" | jq . >/dev/null 2>&1; then
        echo "<txt> $LABEL_CITY_NOT_FOUND</txt>"
        echo "<tool>$LABEL_FETCH_ERROR: $CITY</tool>"
        exit 0
    else
        FORECAST="$FETCHED"
        echo "$FETCHED" > "$CACHE_FILE"
    fi
fi

mapfile -t DATA < <(echo "$FORECAST" | jq -r '
    .current_condition[0].temp_C,
    .current_condition[0].weatherDesc[0].value,
    .weather[0].maxtempC,
    .weather[0].mintempC,
    .nearest_area[0].areaName[0].value,
    .nearest_area[0].country[0].value')

TEMP="${DATA[0]}"
DESC="${DATA[1]}"
ORIGINAL_DESC="$DESC"
MAX="${DATA[2]}"
MIN="${DATA[3]}"
CITY_NAME="${DATA[4]}"
COUNTRY="${DATA[5]}"
WIND=$(echo "$FORECAST" | jq -r '.current_condition[0].windspeedKmph')
HUMIDITY=$(echo "$FORECAST" | jq -r '.current_condition[0].humidity')

# Traducción de descripción
DESC_LOWER=$(echo "$ORIGINAL_DESC" | tr '[:upper:]' '[:lower:]')
DESC=$(translate_weather_desc "$DESC_LOWER")

hour_now=$(date +%H)
is_day=true
(( hour_now >= 6 && hour_now <= 18 )) || is_day=false

DESC_LOWER=$(echo "$ORIGINAL_DESC" | tr '[:upper:]' '[:lower:]')
RAW_DESC="$DESC_LOWER"
ICON_COLOR="#FFB6C1"
case "$DESC_LOWER" in
    *sun*|*clear*) ICON="☀️"; ICON_COLOR="#FFB347" ;;
    *cloud*|*overcast*) ICON="☁️"; ICON_COLOR="#D3D3D3" ;;
    *rain*|*shower*|*drizzle*) ICON="🌧️"; ICON_COLOR="#ADD8E6" ;;
    *snow*|*sleet*|*blizzard*) ICON="❄️"; ICON_COLOR="#B0E0E6" ;;
    *storm*|*thunder*) ICON="⛈️"; ICON_COLOR="#FFCC99" ;;
    *mist*|*fog*|*haze*) ICON="🌫️"; ICON_COLOR="#D8BFD8" ;;
    *wind*) ICON="🌬️"; ICON_COLOR="#AFEEEE" ;;
    *hail*) ICON="🌨️"; ICON_COLOR="#B0E0E6" ;;
    *dust*) ICON="🌪️"; ICON_COLOR="#C2B280" ;;  # Arena pálida o beige
    *) ICON="🌡"; ICON_COLOR="#FF6347" ;;
esac

[[ "$is_day" == false && "$DESC_LOWER" == *sun* || "$DESC_LOWER" == *clear* ]] && {
    ICON="🌙"; ICON_COLOR="#B0E0E6"
}

ICON_FOR_FONT="☀️"
if [[ "$RAW_DESC" == *clear* || "$RAW_DESC" == *sun* ]]; then
    ICON_FOR_FONT=$([[ "$is_day" == true ]] && echo "☀️" || echo "🌙")
else
    ICON_FOR_FONT="$ICON"
fi

DISPLAY_LINE=" <span size=\"16000\" foreground=\"$ICON_COLOR\" weight='bold'>$ICON_FOR_FONT </span><span weight='bold'> $DESC $TEMP°C</span> "


TOOLTIP="<tool>"
TOOLTIP+="  $CITY_NAME, $COUNTRY\n "
TOOLTIP+="──────────────────────────\n "
TOOLTIP+="   <span font_family=\"$FONT_ICON\" size=\"32000\" foreground=\"$ICON_COLOR\">$ICON</span> <span font_family=\"$FONT_TEMP\" size=\"36000\" foreground=\"$ICON_COLOR\"> $TEMP°C</span>\n "
TOOLTIP+="──────────────────────────\n"
TOOLTIP+="<span foreground=\"#FFB347\"></span>  ${LABEL_MAX} $MAX°C / <span foreground=\"#FFB347\"></span>  ${LABEL_MIN} $MIN°C\n "
TOOLTIP+="<span foreground=\"#76D7C4\"> </span> ${LABEL_WIND} ${WIND} km/h / <span size=\"22000\" foreground=\"#5DADE2\"></span> ${LABEL_HUMIDITY} ${HUMIDITY}%\n "
TOOLTIP+="──────────────────────────\n"
FORECAST_DAYS=$(echo "$FORECAST" | jq -r '.weather[:3][] | "\(.date)|\(.avgtempC)|\(.hourly[4].weatherDesc[0].value)"')
while IFS='|' read -r date temp desc; do
    day=$(LANG=$LANG_CODE.UTF-8 date -d "$date" +%a)
    if [[ "$LANG_CODE" == "es" ]]; then
    case "$day" in
        Mon) day="Lun" ;;
        Tue) day="Mar" ;;
        Wed) day="Mié" ;;
        Thu) day="Jue" ;;
        Fri) day="Vie" ;;
        Sat) day="Sáb" ;;
        Sun) day="Dom" ;;
    esac
fi
    desc_lower=$(echo "$desc" | tr '[:upper:]' '[:lower:]')
    local_icon="🌡️"
    local_icon_color="#FF6347"
    case "$desc_lower" in
        *sun*|*clear*) local_icon="☀️"; local_icon_color="#FFB347" ;;
        *cloud*|*overcast*) local_icon="☁️"; local_icon_color="#D3D3D3" ;;
        *rain*|*shower*|*drizzle*) local_icon="🌧️"; local_icon_color="#ADD8E6" ;;
        *snow*|*sleet*|*blizzard*) local_icon="❄️"; local_icon_color="#B0E0E6" ;;
        *storm*|*thunder*) local_icon="⛈️"; local_icon_color="#FFCC99" ;;
        *mist*|*fog*|*haze*) local_icon="🌫️"; local_icon_color="#D8BFD8" ;;
        *wind*) local_icon="🌬️"; local_icon_color="#AFEEEE" ;;
        *hail*) local_icon="🌨️"; local_icon_color="#B0E0E6" ;;
    esac

 desc=$(translate_weather_desc "$desc_lower")

    TOOLTIP+="    $day  $temp °C <span foreground=\"$local_icon_color\"> $local_icon </span> $desc\n"
done <<< "$FORECAST_DAYS"

TOOLTIP+="</tool>"
WINDOW_ICON="weather-clear"

# Acción clic para cambiar ciudad
TXTCLICK="<txtclick>bash -c '
NEW_CITY=\$(yad --entry \
    --title=\"$LABEL_CITY_UPDATED\" \
    --text=\"$LABEL_CITY_PROMPT\" \
    --entry-text=\"$CITY\" \
    --center \
    --width=350 \
    --window-icon=$WINDOW_ICON);

if [ -n \"\$NEW_CITY\" ] && [ \${#NEW_CITY} -ge 3 ]; then
    ENCODED=\$(echo \"\$NEW_CITY\" | sed \"s/ /+/g\")
    NEW_CITY_MD5=\$(echo -n \"\$ENCODED\" | md5sum | cut -d \" \" -f1)
    OLD_CITY_MD5=\$(echo -n \"$ENCODED_CITY\" | md5sum | cut -d \" \" -f1)
    rm -f \"/tmp/genmon_weather_cache_\$OLD_CITY_MD5.json\"

    FETCH_RESULT=\$(curl -s --max-time 4 -f -H \"Accept-Language: $LANG_CODE\" \"https://wttr.in/\$ENCODED?format=j1\")
    if [ -n \"\$FETCH_RESULT\" ] && echo \"\$FETCH_RESULT\" | jq . >/dev/null 2>&1; then
        echo \"\$NEW_CITY\" > \"$CITY_FILE\"
        echo \"\$FETCH_RESULT\" > \"/tmp/genmon_weather_cache_\$NEW_CITY_MD5.json\"
        yad --title=\"$LABEL_CITY_UPDATED\" \
            --text=\"$LABEL_CITY_UPDATED_MSG \$NEW_CITY\" \
            --button=OK \
            --center \
            --width=350 \
            --timeout=3 \
            --window-icon=weather-clear
    else
        yad --title=\"Error\" \
            --text=\"$LABEL_FETCH_ERROR: \$NEW_CITY\" \
            --button=OK \
            --center \
            --width=300 \
            --timeout=5 \
            --window-icon=dialog-error
    fi
fi
'</txtclick>"

# Aplicar conversión final a Nerd Font
DISPLAY_LINE=$(convert_to_nerd_font "$DISPLAY_LINE")
TOOLTIP=$(convert_to_nerd_font "$TOOLTIP")
TXTCLICK=$(convert_to_nerd_font "$TXTCLICK")

# Salida final para Genmon
echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$TOOLTIP"
echo -e "$TXTCLICK"
