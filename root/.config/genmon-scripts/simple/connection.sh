#!/usr/bin/env bash
# Dependencies: bash>=3.2, coreutils, curl, jq, printf

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Establecer textos según idioma ===
set_tooltip_texts() {
    case "$1" in
        es)
            LABEL_SSID="SSID:"
            LABEL_INTERFACE="Interfaz:"
            LABEL_LOCAL_IP="IPv4 local:"
            LABEL_PUBLIC_IP="IPv4 pública:"
            LABEL_SIGNAL="Intensidad de señal:"
            LABEL_TRAFFIC="Tráfico:"
            SSID_PPP="Conexión PPP"
            SSID_WIRED="Cableada"
            SSID_VPN="VPN"
            SSID_USB="Compartida por USB"
            SSID_WWAN="Datos móviles"
            ;;
        *)
            LABEL_SSID="SSID:"
            LABEL_INTERFACE="Interface:"
            LABEL_LOCAL_IP="Local IPv4:"
            LABEL_PUBLIC_IP="Public IPv4:"
            LABEL_SIGNAL="Signal Strength:"
            LABEL_TRAFFIC="Traffic:"
            SSID_PPP="PPP Connection"
            SSID_WIRED="Wired"
            SSID_VPN="VPN"
            SSID_USB="USB Tethering"
            SSID_WWAN="Mobile Data"
            ;;
    esac
}

set_tooltip_texts "$LANG_CODE"

# === 🎨 Configuración visual centralizada ===

# --- Colores generales ---
COLOR_WHITE="#FFFFFF"
COLOR_GREEN="#6FCF97"
COLOR_ORANGE="#E7A23F"
COLOR_RED="#E76F51"
COLOR_NO_INTERNET="#C18D8C"
COLOR_WWAN_DISCONNECTED="#E9A3A3"
COLOR_VPN="#6C7F8C"
COLOR_PPP="#A4D7FF"
COLOR_USB="#D5C06D"

# --- Colores para conexión cableada según actividad ---
COLOR_WIRED_HIGH="#8FE2D7"
COLOR_WIRED_MODERATE="#A5E8D2"
COLOR_WIRED_LOW="#C7F0CA"
COLOR_WIRED_VERY_LOW="#E0F5E0"
COLOR_WIRED_INACTIVE="#F8F8F8"

# --- Colores para tooltip ---
TOOLTIP_LABEL_COLOR="#35C5B9"
TOOLTIP_INTERFACE_COLOR="#FFBC00"
TOOLTIP_PUBLIC_IP_COLOR="#FF5733"
TOOLTIP_PUBLIC_IP_VALUE_COLOR="#A1D36E"
TOOLTIP_TRAFFIC_COLOR="$COLOR_GREEN"

# --- Fuente del tooltip ---
TOOLTIP_FONT="Terminess Nerd Font"
TOOLTIP_SIZE="14000"
TOOLTIP_WEIGHT="bold"

# --- Íconos Nerd Font ---
ICON_WWAN="󰠕"
ICON_USB="󱎔"
ICON_VPN="󰳌"
ICON_PPP=""
ICON_WIRED="󰈀"
ICON_WIFI_NONE="󰌙"
ICON_WIFI_EXCELLENT="󰤨"
ICON_WIFI_GOOD="󰤥"
ICON_WIFI_FAIR="󰤢"
ICON_WIFI_WEAK="󰤟"

# === 📂 Rutas de archivos temporales ===
HIDE_NETWORK="$HOME/.config/genmon-hide/connection"
EXTERNAL_IP_FILE="/tmp/genmon-hide/external_ip_cache.txt"
CACHE_DIR="/tmp/genmon-hide/network-cache"
mkdir -p "$CACHE_DIR"

PACKET_CACHE_FILE="$CACHE_DIR/packet_stats.txt"
BYTE_CACHE_FILE="$CACHE_DIR/byte_stats.txt"

[[ -f "$HIDE_NETWORK" ]] && { echo -e "<txt></txt>"; exit 0; }

# === 📡 Detectar interfaz activa ===
ACTIVE_IFACE=$(ip route | awk '/default/ {print $5}' | head -n 1)
WIFI_IFACE=$(iw dev | awk '$1=="Interface"{print $2}')
WWAN_IFACE="wwan0"
USB_IFACE="usb0"
VPN_IFACE=$(ip link show | grep -oP 'tun\d+' || echo "")
PPP_IFACE="ppp0"

# === 🌍 Comprobar conexión a Internet ===
INTERNET_CONNECTED=$(timeout 0.5 ping -q -c 1 8.8.8.8 &>/dev/null && echo true || echo false)

# === 📊 Obtener tráfico y paquetes ===
TX_BYTES=$(cat /sys/class/net/"$ACTIVE_IFACE"/statistics/tx_bytes 2>/dev/null)
RX_BYTES=$(cat /sys/class/net/"$ACTIVE_IFACE"/statistics/rx_bytes 2>/dev/null)
TX_PACKETS=$(cat /sys/class/net/"$ACTIVE_IFACE"/statistics/tx_packets 2>/dev/null)
RX_PACKETS=$(cat /sys/class/net/"$ACTIVE_IFACE"/statistics/rx_packets 2>/dev/null)
CURRENT_TIME=$(date +%s%N)

read -r PREV_TX_PACKETS PREV_RX_PACKETS PREV_PACKET_TIME < "$PACKET_CACHE_FILE" 2>/dev/null
DIFF_PACKET_TIME=$((CURRENT_TIME - PREV_PACKET_TIME))
TOTAL_PACKETS_PER_SECOND=0
if [[ "$DIFF_PACKET_TIME" -gt 0 ]]; then
    TOTAL_PACKETS_PER_SECOND=$(( (TX_PACKETS - PREV_TX_PACKETS + RX_PACKETS - PREV_RX_PACKETS) * 1000000000 / DIFF_PACKET_TIME ))
fi
echo "$TX_PACKETS $RX_PACKETS $CURRENT_TIME" > "$PACKET_CACHE_FILE"

read -r PREV_TX_BYTES PREV_RX_BYTES PREV_BYTE_TIME < "$BYTE_CACHE_FILE" 2>/dev/null
DIFF_BYTE_TIME=$((CURRENT_TIME - PREV_BYTE_TIME))
TOTAL_BYTES_PER_SECOND=0
if [[ "$DIFF_BYTE_TIME" -gt 0 ]]; then
    TOTAL_BYTES_PER_SECOND=$(( (TX_BYTES - PREV_TX_BYTES + RX_BYTES - PREV_RX_BYTES) * 1000000000 / DIFF_BYTE_TIME ))
fi
echo "$TX_BYTES $RX_BYTES $CURRENT_TIME" > "$BYTE_CACHE_FILE"

if (( TOTAL_BYTES_PER_SECOND > 0 )); then
    if (( TOTAL_BYTES_PER_SECOND * 8 / 1000000 > 1 )); then
        FORMATTED_TRAFFIC="$(echo "scale=2; $TOTAL_BYTES_PER_SECOND * 8 / 1000000" | bc) Mbps"
    else
        FORMATTED_TRAFFIC="$(echo "scale=1; $TOTAL_BYTES_PER_SECOND * 8 / 1000" | bc) Kbps"
    fi
else
    FORMATTED_TRAFFIC="0.0 Kbps"
fi

ICON="$ICON_WIFI_NONE"
COLOR="$COLOR_NO_INTERNET"
SSID=""

if [[ "$ACTIVE_IFACE" == "$WWAN_IFACE"* ]]; then
    ICON="$ICON_WWAN"
    COLOR=$([[ "$INTERNET_CONNECTED" == "true" ]] && echo "$COLOR_WHITE" || echo "$COLOR_WWAN_DISCONNECTED")
    SSID="$SSID_WWAN"

elif [[ "$ACTIVE_IFACE" == "$USB_IFACE"* ]]; then
    ICON="$ICON_USB"
    COLOR="$COLOR_USB"
    SSID="$SSID_USB"

elif [[ "$VPN_IFACE" =~ ^tun ]]; then
    ICON="$ICON_VPN"
    COLOR="$COLOR_VPN"
    SSID="$SSID_VPN"

elif [[ "$ACTIVE_IFACE" == "$PPP_IFACE"* ]]; then
    ICON="$ICON_PPP"
    COLOR="$COLOR_PPP"
    SSID="$SSID_PPP"

elif [[ "$ACTIVE_IFACE" =~ ^(eth|en|eno|ens|enp).* ]]; then
    ICON="$ICON_WIRED"
    SSID="$SSID_WIRED"
    case $TOTAL_PACKETS_PER_SECOND in
        [5-9]*|[1-9][0-9][0-9][0-9]*) COLOR="$COLOR_WIRED_HIGH" ;;
        [1-4][0-9][0-9][0-9]) COLOR="$COLOR_WIRED_MODERATE" ;;
        [2-9][0-9][0-9]) COLOR="$COLOR_WIRED_LOW" ;;
        [5-9][0-9]) COLOR="$COLOR_WIRED_VERY_LOW" ;;
        *) COLOR="$COLOR_WIRED_INACTIVE" ;;
    esac

elif [[ -n "$WIFI_IFACE" && -d "/sys/class/net/$WIFI_IFACE" ]]; then
    SSID=$(iw dev "$WIFI_IFACE" link | awk -F': ' '/SSID/ {print $2}')
    if [[ -z "$SSID" ]]; then
        ICON="$ICON_WIFI_NONE"
        COLOR="$COLOR_NO_INTERNET"
    else
        SIGNAL_LEVEL=$(awk '/'"$WIFI_IFACE"'/ {print int($3)}' /proc/net/wireless)
        SIGNAL_PERCENT=$(( SIGNAL_LEVEL * 100 / 70 ))
        [[ $SIGNAL_PERCENT -gt 100 ]] && SIGNAL_PERCENT=100
        [[ $SIGNAL_PERCENT -lt 0 ]] && SIGNAL_PERCENT=0
        if (( SIGNAL_PERCENT >= 70 )); then
            ICON="$ICON_WIFI_EXCELLENT"; COLOR="$COLOR_WHITE"; SIGNAL_QUALITY="Excellent"
        elif (( SIGNAL_PERCENT >= 40 )); then
            ICON="$ICON_WIFI_GOOD"; COLOR="$COLOR_GREEN"; SIGNAL_QUALITY="Good"
        elif (( SIGNAL_PERCENT >= 20 )); then
            ICON="$ICON_WIFI_FAIR"; COLOR="$COLOR_ORANGE"; SIGNAL_QUALITY="Fair"
        else
            ICON="$ICON_WIFI_WEAK"; COLOR="$COLOR_RED"; SIGNAL_QUALITY="Weak"
        fi
    fi
fi

DISPLAY_LINE="<span foreground='$COLOR'> $ICON </span><span foreground='$COLOR_WHITE'> $SSID </span>"

IP_FILE="$CACHE_DIR/local_ip"
if [[ ! -f "$IP_FILE" || $(find "$IP_FILE" -mmin +0.05) ]]; then
    LOCAL_IP=$(ip -4 addr show "$ACTIVE_IFACE" | awk '/inet/ {print $2; exit}' | cut -d'/' -f1)
    echo "$LOCAL_IP" > "$IP_FILE"
else
    LOCAL_IP=$(cat "$IP_FILE")
fi
[[ -z "$LOCAL_IP" ]] && LOCAL_IP="N/A"

EXTERNAL_IP="N/A"
if [[ -f "$EXTERNAL_IP_FILE" ]] && find "$EXTERNAL_IP_FILE" -mmin -10 &>/dev/null; then
    EXTERNAL_IP=$(cat "$EXTERNAL_IP_FILE")
else
    (
        TEMP_IP=$(timeout 3 curl -s --connect-timeout 2 https://ipv4.icanhazip.com || curl -s --connect-timeout 2 https://checkip.amazonaws.com)
        [[ -n "$TEMP_IP" ]] && echo "$TEMP_IP" > "$EXTERNAL_IP_FILE"
    ) &
fi
[[ -f "$EXTERNAL_IP_FILE" ]] && EXTERNAL_IP=$(cat "$EXTERNAL_IP_FILE")

MORE_INFO="<tool>"
MORE_INFO+="<span font_family='$TOOLTIP_FONT' font_size='$TOOLTIP_SIZE' weight='$TOOLTIP_WEIGHT'>"
MORE_INFO+="<span foreground='$TOOLTIP_LABEL_COLOR'>$LABEL_SSID</span> <span foreground='$COLOR'>$ICON  $SSID</span>\n"
MORE_INFO+="<span foreground='$COLOR_WHITE'>$LABEL_INTERFACE</span> <span foreground='$COLOR_WHITE'>$ACTIVE_IFACE</span>\n"
MORE_INFO+="<span foreground='$TOOLTIP_INTERFACE_COLOR'>$LABEL_LOCAL_IP</span> <span foreground='$TOOLTIP_LABEL_COLOR'>$LOCAL_IP</span>\n"
MORE_INFO+="<span foreground='$TOOLTIP_PUBLIC_IP_COLOR'>$LABEL_PUBLIC_IP</span> <span foreground='$TOOLTIP_PUBLIC_IP_VALUE_COLOR'>$EXTERNAL_IP</span>\n"
[[ "$CONNECTION_TYPE" == "wifi" ]] && MORE_INFO+="<span foreground='$COLOR'>$LABEL_SIGNAL</span> <span foreground='$COLOR'>$SIGNAL_PERCENT% ($SIGNAL_QUALITY)</span>\n"
MORE_INFO+="<span foreground='$COLOR_WHITE'>$LABEL_TRAFFIC</span> <span foreground='$TOOLTIP_TRAFFIC_COLOR'>$FORMATTED_TRAFFIC</span>\n"
MORE_INFO+="</span>"
MORE_INFO+="</tool>"

ACTION="<txtclick>defaultconnect</txtclick>"

echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$ACTION"
echo -e "$MORE_INFO"
