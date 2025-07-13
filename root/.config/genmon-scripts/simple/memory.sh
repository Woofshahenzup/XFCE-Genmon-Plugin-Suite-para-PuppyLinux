#!/usr/bin/env bash
# Dependencies: bash>=3.2, coreutils, file, gawk, dmidecode

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            LABEL_RAM_INFO="Información de RAM"
            LABEL_TOTAL_RAM="RAM total"
            LABEL_USED_RAM="RAM usada"
            LABEL_FREE_RAM="RAM libre"
            LABEL_SWAP="SWAP"
            LABEL_TOTAL_SWAP="SWAP total"
            LABEL_USED_SWAP="SWAP usada"
            LABEL_FREE_SWAP="SWAP libre"
            LABEL_CAPACITY="Capacidad"
            LABEL_TYPE="Tipo"
            LABEL_FREQUENCY="Frecuencia"
            LABEL_BRAND="Marca"
            LABEL_NO_MODULE="Sin módulo instalado"
            LABEL_REQUIRES_ROOT="Requiere root para mostrar información de módulos RAM (ejecuta con sudo)."
            ;;
        *)
            LABEL_RAM_INFO="RAM Info"
            LABEL_TOTAL_RAM="Total RAM"
            LABEL_USED_RAM="Used RAM"
            LABEL_FREE_RAM="Free RAM"
            LABEL_SWAP="SWAP"
            LABEL_TOTAL_SWAP="Total SWAP"
            LABEL_USED_SWAP="Used SWAP"
            LABEL_FREE_SWAP="Free SWAP"
            LABEL_CAPACITY="Capacity"
            LABEL_TYPE="Type"
            LABEL_FREQUENCY="Frequency"
            LABEL_BRAND="Brand"
            LABEL_NO_MODULE="No Module Installed"
            LABEL_REQUIRES_ROOT="Requires root to display RAM module info (run with sudo)."
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 🎨 Configuración visual ===
COLOR_ICON="#FFFFFF"
COLOR_TEXT="#FFFFFF"
COLOR_TITLE="#FFBC00"
COLOR_MODEL="#35C5B9"
COLOR_CAPACITY="#A1D36E"
COLOR_USED="#FF5733"
COLOR_FREE="#6F9B3F"
COLOR_SWAP_USED="#FFBC00"
FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_TOOLTIP="16000"
FONT_WEIGHT="bold"
ICON_RAM="󱜳"

# === 📂 Ocultar si archivo existe ===
HIDE_FILE_RAM="$HOME/.config/genmon-hide/ram"

if [ -f "$HIDE_FILE_RAM" ]; then
    DISPLAY_LINE=""
    MORE_INFO="<tool></tool>"
    INFO=""
else
    FREE_OUTPUT=$(free -b)
    RAM_INFO=$(echo "$FREE_OUTPUT" | awk '/Mem:/ {printf "%.2f %.2f %.2f %.0f", $2 / (1024^3), $3 / (1024^3), $4 / (1024^3), $3/$2 * 100}')
    read -r TOTAL USED FREE PERCENTAGE <<< "$RAM_INFO"

    SWAP_INFO=$(echo "$FREE_OUTPUT" | awk '/Swap:/ {printf "%.2f %.2f %.2f", $2 / (1024^3), $3 / (1024^3), $4 / (1024^3)}')
    read -r SWAP_TOTAL SWAP_USED SWAP_FREE <<< "$SWAP_INFO"

    BANKS_INFO=""
    if [ "$(id -u)" -eq 0 ]; then
        dmidecode_output=$(dmidecode -t memory)

        BANKS_INFO=$(echo "$dmidecode_output" | awk -F': ' -v label_capacity="$LABEL_CAPACITY" -v label_type="$LABEL_TYPE" -v label_frequency="$LABEL_FREQUENCY" -v label_brand="$LABEL_BRAND" -v label_no_module="$LABEL_NO_MODULE" '
            BEGIN {bank=""; size="N/A"; type="N/A"; speed="N/A"; manufacturer="N/A"; record=0}
            /Bank Locator:/ {bank = $2; record = 1}
            /Size:/ {size = $2}
            /Type:/ && !/Correction/ {type = $2}
            /Speed:/ {speed = $2 " MHz"}
            /Manufacturer:/ {manufacturer = $2}
            /^$/ {
                if (record && bank && size != "No Module Installed") {
                    printf "┌ <span foreground=\"#FFBC00\">%s</span>\n├─ <span foreground=\"#A1D36E\">%s:</span> <span foreground=\"#35C5B9\">%s</span>\n├─ <span foreground=\"#FF5733\">%s:</span> %s\n├─ <span foreground=\"#FFBC00\">%s:</span> %s\n└─ <span foreground=\"#6F9B3F\">%s:</span> %s\n\n",
                    bank, label_capacity, size, label_type, type, label_frequency, speed, label_brand, manufacturer
                } else if (record && bank && size == "No Module Installed") {
                    printf "┌ <span foreground=\"#FFBC00\">%s</span>\n└─ <span foreground=\"#FF5733\">%s</span>\n\n", bank, label_no_module
                }
                bank = ""; record = 0
            }
            END {
                if (record && bank && size != "No Module Installed") {
                    printf "┌ <span foreground=\"#FFBC00\">%s</span>\n├─ <span foreground=\"#A1D36E\">%s:</span> <span foreground=\"#35C5B9\">%s</span>\n├─ <span foreground=\"#FF5733\">%s:</span> %s\n├─ <span foreground=\"#FFBC00\">%s:</span> %s\n└─ <span foreground=\"#6F9B3F\">%s:</span> %s\n\n",
                    bank, label_capacity, size, label_type, type, label_frequency, speed, label_brand, manufacturer
                } else if (record && bank && size == "No Module Installed") {
                    printf "┌ <span foreground=\"#FFBC00\">%s</span>\n└─ <span foreground=\"#FF5733\">%s</span>\n\n", bank, label_no_module
                }
            }
        ')
    else

        BANKS_INFO="<span foreground='#FF5733'>$LABEL_REQUIRES_ROOT</span>"
    fi

    DISPLAY_LINE="<span foreground='$COLOR_ICON'> $ICON_RAM </span><span foreground='$COLOR_TEXT'> ${PERCENTAGE}% </span>"

    MORE_INFO="<tool>"
    MORE_INFO+="<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_TOOLTIP' weight='$FONT_WEIGHT'>  $ICON_RAM   $LABEL_RAM_INFO $ICON_RAM     </span>\n"
    MORE_INFO+="<span foreground='$COLOR_TITLE'>${BANKS_INFO}</span>\n\n"
    MORE_INFO+="┌ <span foreground='$COLOR_CAPACITY'>$LABEL_TOTAL_RAM:</span> <span foreground='$COLOR_MODEL'>${TOTAL} GB</span>\n"
    MORE_INFO+="├─ <span foreground='$COLOR_TITLE'>$LABEL_USED_RAM:</span> <span foreground='$COLOR_USED'>${USED} GB</span>\n"
    MORE_INFO+="└─ <span foreground='$COLOR_CAPACITY'>$LABEL_FREE_RAM:</span> <span foreground='$COLOR_FREE'>${FREE} GB</span>\n\n"
    MORE_INFO+="┌ <span foreground='$COLOR_TITLE'>$LABEL_SWAP</span>\n"
    MORE_INFO+="├─ <span foreground='$COLOR_USED'>$LABEL_TOTAL_SWAP:</span> <span foreground='$COLOR_MODEL'>${SWAP_TOTAL} GB</span>\n"
    MORE_INFO+="├─ <span foreground='$COLOR_USED'>$LABEL_USED_SWAP:</span> <span foreground='$COLOR_SWAP_USED'>${SWAP_USED} GB</span>\n"
    MORE_INFO+="└─ <span foreground='$COLOR_FREE'>$LABEL_FREE_SWAP:</span> <span foreground='$COLOR_CAPACITY'>${SWAP_FREE} GB</span>"
    MORE_INFO+="</tool>"

    INFO="<txt>$DISPLAY_LINE</txt>"
    INFO+="<txtclick>xfce4-terminal --geometry=90x24 -e btop</txtclick>"
fi

echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$MORE_INFO"
echo -e "$INFO"
