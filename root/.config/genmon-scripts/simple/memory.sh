#!/usr/bin/env bash
# Dependencies: bash>=3.2, coreutils, file, gawk, dmidecode

export LC_ALL=en_US.UTF-8

# === 🎨 Configuración visual centralizada ===
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

# === 📂 Ruta de ocultación ===
HIDE_FILE_RAM="$HOME/.config/genmon-hide/ram"

if [ -f "$HIDE_FILE_RAM" ]; then
    DISPLAY_LINE=""
    MORE_INFO="<tool></tool>"
    INFO=""
else
    # Obtener información de RAM y SWAP
    FREE_OUTPUT=$(free -b)
    RAM_INFO=$(echo "$FREE_OUTPUT" | awk '/Mem:/ {printf "%.2f %.2f %.2f %.0f", $2 / (1024^3), $3 / (1024^3), $4 / (1024^3), $3/$2 * 100}')
    read -r TOTAL USED FREE PERCENTAGE <<< "$RAM_INFO"

    SWAP_INFO=$(echo "$FREE_OUTPUT" | awk '/Swap:/ {printf "%.2f %.2f %.2f", $2 / (1024^3), $3 / (1024^3), $4 / (1024^3)}')
    read -r SWAP_TOTAL SWAP_USED SWAP_FREE <<< "$SWAP_INFO"

    # Información de módulos RAM
    BANKS_INFO=""
    if [ "$(id -u)" -eq 0 ]; then
        dmidecode_output=$(dmidecode -t memory)

        BANKS_INFO=$(echo "$dmidecode_output" | awk -F': ' '
            BEGIN {bank=""; size="N/A"; type="N/A"; speed="N/A"; manufacturer="N/A"; record=0}
            /Bank Locator:/ {bank = $2; record = 1}
            /Size:/ {size = $2}
            /Type:/ && !/Correction/ {type = $2}
            /Speed:/ {speed = $2 " MHz"}
            /Manufacturer:/ {manufacturer = $2}
            /^$/ {
                if (record && bank && size != "No Module Installed") {
                    printf "┌ <span foreground=\"#FFBC00\">%s</span>\n├─ <span foreground=\"#A1D36E\">Capacity:</span> <span foreground=\"#35C5B9\">%s</span>\n├─ <span foreground=\"#FF5733\">Type:</span> %s\n├─ <span foreground=\"#FFBC00\">Frequency:</span> %s\n└─ <span foreground=\"#6F9B3F\">Brand:</span> %s\n\n",
                    bank, size, type, speed, manufacturer
                } else if (record && bank && size == "No Module Installed") {
                    printf "┌ <span foreground=\"#FFBC00\">%s</span>\n└─ <span foreground=\"#FF5733\">No Module Installed</span>\n\n", bank
                }
                bank = ""; record = 0
            }
            END {
                if (record && bank && size != "No Module Installed") {
                    printf "┌ <span foreground=\"#FFBC00\">%s</span>\n├─ <span foreground=\"#A1D36E\">Capacity:</span> <span foreground=\"#35C5B9\">%s</span>\n├─ <span foreground=\"#FF5733\">Type:</span> %s\n├─ <span foreground=\"#FFBC00\">Frequency:</span> %s\n└─ <span foreground=\"#6F9B3F\">Brand:</span> %s\n\n",
                    bank, size, type, speed, manufacturer
                } else if (record && bank && size == "No Module Installed") {
                    printf "┌ <span foreground=\"#FFBC00\">%s</span>\n└─ <span foreground=\"#FF5733\">No Module Installed</span>\n\n", bank
                }
            }
        ')
    else
        BANKS_INFO="<span foreground='#FF5733'>Requires root to display RAM module info (run with sudo).</span>"
    fi
    # Línea en el panel
    DISPLAY_LINE="<span foreground='$COLOR_ICON'> $ICON_RAM </span><span foreground='$COLOR_TEXT'> ${PERCENTAGE}% </span>"

    # Tooltip completo
    MORE_INFO="<tool>"
    MORE_INFO+="<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_TOOLTIP' weight='$FONT_WEIGHT'>  $ICON_RAM   RAM Info $ICON_RAM     </span>\n"
MORE_INFO+="<span font_desc='${FONT_MAIN} ${FONT_WEIGHT} 14'>"
MORE_INFO+="<span foreground='$COLOR_TITLE'>${BANKS_INFO}</span>\n\n"
MORE_INFO+="┌ <span foreground='$COLOR_CAPACITY'>Total RAM:</span> <span foreground='$COLOR_MODEL'>${TOTAL} GB</span>\n"
MORE_INFO+="├─ <span foreground='$COLOR_TITLE'>Used RAM:</span> <span foreground='$COLOR_USED'>${USED} GB</span>\n"
MORE_INFO+="└─ <span foreground='$COLOR_CAPACITY'>Free RAM:</span> <span foreground='$COLOR_FREE'>${FREE} GB</span>\n\n"
MORE_INFO+="┌ <span foreground='$COLOR_TITLE'>SWAP</span>\n"
MORE_INFO+="├─ <span foreground='$COLOR_USED'>Total SWAP:</span> <span foreground='$COLOR_MODEL'>${SWAP_TOTAL} GB</span>\n"
MORE_INFO+="├─ <span foreground='$COLOR_USED'>Used SWAP:</span> <span foreground='$COLOR_SWAP_USED'>${SWAP_USED} GB</span>\n"
MORE_INFO+="└─ <span foreground='$COLOR_FREE'>Free SWAP:</span> <span foreground='$COLOR_CAPACITY'>${SWAP_FREE} GB</span>\n"
MORE_INFO+="</span>"
MORE_INFO+="</tool>"


    INFO="<txt>$DISPLAY_LINE</txt>"
    INFO+="<txtclick>xfce4-terminal --geometry=90x24 -e btop</txtclick>"
fi

# Salida final
echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$MORE_INFO"
echo -e "$INFO"
