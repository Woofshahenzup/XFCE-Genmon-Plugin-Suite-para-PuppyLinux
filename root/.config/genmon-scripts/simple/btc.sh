#!/usr/bin/env bash
# Dependencies: bash>=3.2, coreutils, curl, jq, printf

# === 🌐 Localización ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Texto según idioma ===
set_tooltip_texts() {
    case "$1" in
        es)
            TOOLTIP_HEADER="Principales Criptos (USD)"
            TOOLTIP_BTC="BTC Bitcoin"
            TOOLTIP_ETH="ETH Ethereum"
            ;;
        *)
            TOOLTIP_HEADER="Top Cryptos (USD)"
            TOOLTIP_BTC="BTC Bitcoin"
            TOOLTIP_ETH="ETH Ethereum"
            ;;
    esac
}

set_tooltip_texts "$LANG_CODE"

# === Configuración visual centralizada ===

# --- Paleta de colores ---
COLOR_BTC="#fabd2f"         # Amarillo Gruvbox
COLOR_ETH="#b16286"         # Púrpura Gruvbox
COLOR_PANEL="#FFFFFF"       # Blanco
COLOR_TOOLTIP_HEADER="#ff9800"  # Naranja vibrante
COLOR_TOOLTIP_BTC="#ffcc00"     # Dorado moderno
COLOR_TOOLTIP_ETH="#66ff66"     # Verde brillante

# --- Íconos Nerd Font ---
ICON_BTC=""
ICON_ETH="󰡪"

# --- Fuente para tooltip ---
TOOLTIP_FONT="Terminess Nerd Font"
TOOLTIP_SIZE="16000"
TOOLTIP_WEIGHT="bold"

# === Ruta de ocultación ===
HIDE_CRYPTO_PANEL="$HOME/.config/genmon-hide/btc"

# === Lógica principal ===
if [ -f "$HIDE_CRYPTO_PANEL" ]; then
    DISPLAY_LINE=""
    MORE_INFO="<tool></tool>"
    INFO=""
else
    # Obtener precios
    BTC_PRICE_RAW=$(curl -s --compressed "https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT" | jq -r '.price')
    BTC_PRICE=$(printf "%.2f" "$BTC_PRICE_RAW" | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')

    ETH_PRICE_RAW=$(curl -s --compressed "https://api.binance.com/api/v3/ticker/price?symbol=ETHUSDT" | jq -r '.price')
    ETH_PRICE=$(printf "%.2f" "$ETH_PRICE_RAW" | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')

    # Línea principal
    DISPLAY_LINE="<span foreground='$COLOR_PANEL'> $ICON_BTC  ${BTC_PRICE} USD </span>"

    # Tooltip estilizado
    MORE_INFO="<tool>"
    MORE_INFO+="<span font_family='$TOOLTIP_FONT' font_size='$TOOLTIP_SIZE' weight='$TOOLTIP_WEIGHT'>"
    MORE_INFO+="<span foreground='$COLOR_TOOLTIP_HEADER'> $TOOLTIP_HEADER </span>\n"
    MORE_INFO+="$ICON_BTC $TOOLTIP_BTC: <span foreground='$COLOR_TOOLTIP_BTC'>${BTC_PRICE} USD</span>\n"
    MORE_INFO+="$ICON_ETH $TOOLTIP_ETH: <span foreground='$COLOR_TOOLTIP_ETH'>${ETH_PRICE} USD</span>\n"
    MORE_INFO+="</span>"
    MORE_INFO+="</tool>"

    # Acción al hacer clic
    INFO="<txt>$DISPLAY_LINE</txt>"
    INFO+="<txtclick>xdg-open https://www.binance.com/en/price/bitcoin</txtclick>"
fi

# Mostrar salida en Genmon
echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$MORE_INFO"
echo -e "$INFO"
