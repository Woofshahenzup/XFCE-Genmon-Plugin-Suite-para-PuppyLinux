#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

set_texts() {
    case "$1" in
        es)
            LABEL_CITY_NOT_FOUND="Ciudad no encontrada"
            LABEL_FETCH_ERROR="No se pudo obtener información del clima para"
            LABEL_FORMAT_HINT="Intenta usar el formato: Ciudad,CódigoDePaís (ej. San Salvador,SV)"
            LABEL_LOCATION="Ubicación"
            LABEL_TEMP="Temperatura"
            LABEL_FEELS="Sensación térmica"
            LABEL_HUMIDITY="Humedad"
            LABEL_WIND="Viento"
            LABEL_CONDITION="Condición"
            LABEL_CITY_PROMPT="Ingresa ciudad con código de país (ej. San Salvador,SV o\nParis,FR)"
            ;;
        *)
            LABEL_CITY_NOT_FOUND="City not found"
            LABEL_FETCH_ERROR="Could not fetch weather information for"
            LABEL_FORMAT_HINT="Try using format: City,CountryCode (e.g. San Salvador,SV)"
            LABEL_LOCATION="Location"
            LABEL_TEMP="Temperature"
            LABEL_FEELS="Feels like"
            LABEL_HUMIDITY="Humidity"
            LABEL_WIND="Wind"
            LABEL_CONDITION="Condition"
            LABEL_CITY_PROMPT="Enter city with country code (e.g. San Salvador,SV or\nParis,FR)"
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 📂 Archivos y rutas ===
CONFIG_DIR="$HOME/.config"
CITY_FILE="$CONFIG_DIR/genmon-weather-city.txt"
HIDE_FILE="$CONFIG_DIR/genmon-hide/weather"
mkdir -p "$CONFIG_DIR"

# === 🔑 API Key de OpenWeather ===
API_KEY="8076408f67bc29a0be840a5a58f6e334"

# === 🎨 Estilo visual ===
FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_MAIN="14000"
TOOLTIP_FONT_SIZE="14000"
TOOLTIP_WEIGHT="bold"

COLOR_ICON="#F5E0DC"
COLOR_TEXT="#FFFFFF"

COLOR_LOC="#FAB387"
COLOR_TEMP="#F38BA8"
COLOR_FEELS="#F9E2AF"
COLOR_HUMID="#94E2D5"
COLOR_WIND="#89B4FA"
COLOR_COND="#CBA6F7"

# === 🌍 Ciudad por defecto ===
CITY=$(cat "$CITY_FILE" 2>/dev/null | xargs)
CITY=${CITY:-"San Salvador,SV"}
ENCODED_CITY=$(echo "$CITY" | sed 's/ /%20/g')

# === 🕵️‍♂️ Ocultar si está activado ===
if [ -f "$HIDE_FILE" ]; then
    echo -e "<txt></txt>\n<tool></tool>"
    exit 0
fi

# === 🌦 Obtener datos del clima ===
RAW_DATA=$(curl -s --max-time 5 "https://api.openweathermap.org/data/2.5/weather?q=${ENCODED_CITY}&appid=${API_KEY}&units=metric")

if [[ -z "$RAW_DATA" || $(echo "$RAW_DATA" | jq -r '.cod') != "200" ]]; then
    DISPLAY_LINE="<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_MAIN' foreground='$COLOR_LOC'>   $LABEL_CITY_NOT_FOUND </span>"
    TOOLTIP_INFO="<tool>$LABEL_FETCH_ERROR '${CITY}'.\n$LABEL_FORMAT_HINT</tool>"
else
    LOC=$(echo "$RAW_DATA" | jq -r '.name + ", " + .sys.country')
    CONDITION=$(echo "$RAW_DATA" | jq -r '.weather[0].description' | sed 's/.*/\u&/')
    TEMP=$(echo "$RAW_DATA" | jq -r '.main.temp')
    FEELS=$(echo "$RAW_DATA" | jq -r '.main.feels_like')
    HUMID=$(echo "$RAW_DATA" | jq -r '.main.humidity')
    WIND=$(echo "$RAW_DATA" | jq -r '.wind.speed')
    MAIN=$(echo "$RAW_DATA" | jq -r '.weather[0].main')

    case "$MAIN" in
        "Clear") ICON="" ;;
        "Clouds") ICON="" ;;
        "Rain") ICON="" ;;
        "Drizzle") ICON="󰖗" ;;
        "Thunderstorm") ICON="" ;;
        "Snow") ICON="" ;;
        "Mist"|"Fog") ICON="󰖑" ;;
        "Smoke"|"Haze") ICON="" ;;
        "Dust"|"Sand"|"Ash") ICON="" ;;
        "Squall"|"Tornado") ICON="󰢘" ;;
        *) ICON="" ;;
    esac

    DISPLAY_LINE="<span font_family='$FONT_MAIN' foreground='$COLOR_ICON'> $ICON </span> "
    DISPLAY_LINE+="<span font_family='$FONT_MAIN' weight='bold' foreground='$COLOR_TEXT'>$LOC </span>"

    TOOLTIP_INFO="<tool><span font_family='$FONT_MAIN' font_size='$TOOLTIP_FONT_SIZE'>"
    TOOLTIP_INFO+="<span foreground='$COLOR_LOC'>󰟙  $LABEL_LOCATION: $LOC</span>\n"
    TOOLTIP_INFO+="<span foreground='$COLOR_TEMP'>  $LABEL_TEMP: ${TEMP}°C</span>\n"
    TOOLTIP_INFO+="<span foreground='$COLOR_FEELS'>  $LABEL_FEELS: ${FEELS}°C</span>\n"
    TOOLTIP_INFO+="<span foreground='$COLOR_HUMID'>  $LABEL_HUMIDITY: ${HUMID}%</span>\n"
    TOOLTIP_INFO+="<span foreground='$COLOR_WIND'>  $LABEL_WIND: ${WIND} m/s</span>\n"
    TOOLTIP_INFO+="<span foreground='$COLOR_COND'>  $LABEL_CONDITION: $CONDITION</span>"
    TOOLTIP_INFO+="</span></tool>"
fi

ACTION="<txtclick>bash -c '
NEW_CITY=\$(yad --entry --title=\"City for weather\" --text=\"$LABEL_CITY_PROMPT\" --entry-text=\"$CITY\");
if [ -n \"\$NEW_CITY\" ]; then
    echo \"\$NEW_CITY\" > \"$CITY_FILE\"
fi
'</txtclick>"

echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$TOOLTIP_INFO"
echo -e "$ACTION"

