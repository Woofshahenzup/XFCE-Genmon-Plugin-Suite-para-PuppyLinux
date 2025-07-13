#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            STATUS_ON="ACTIVO"
            STATUS_OFF="INACTIVO"
            LABEL_STATUS="Estado del cortafuegos:"
            LABEL_TOGGLE="Haz clic para alternar el cortafuegos."
            MSG_ON="Cortafuegos encendido."
            MSG_OFF="Cortafuegos apagado."
            ;;
        *)
            STATUS_ON="ON"
            STATUS_OFF="OFF"
            LABEL_STATUS="Firewall status:"
            LABEL_TOGGLE="Click to toggle the firewall."
            MSG_ON="Firewall enabled."
            MSG_OFF="Firewall disabled."
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 🎨 Configuración visual centralizada ===

COLOR_BG_MAIN="#13131C"
COLOR_BG_SECOND="#3C4451"
COLOR_BG_LEFT="#2F8369"
COLOR_BG_RIGHT="#778899"

COLOR_TEXT="#FF6011"
COLOR_LEFT="#D3A39F"
COLOR_RIGHT="#13131C"
COLOR_ACCENT="#E06C75"

COLOR_FIREWALL_ON="#FFFFFF"
COLOR_FIREWALL_OFF="#DB2B5B"

ICON_FIREWALL_ON=""
ICON_FIREWALL_OFF=""

SEP_LEFT="\uE0B4"
SEP_RIGHT="\uE0B2"

TOOLTIP_FONT="Terminess Nerd Font"
TOOLTIP_SIZE="16000"
TOOLTIP_WEIGHT="bold"

HIDE_FILE_FIREWALL="$HOME/.config/genmon-hide/firewall"

if [ -f "$HIDE_FILE_FIREWALL" ]; then
  DISPLAY_LINE=""
  MORE_INFO="<tool></tool>"
  INFO=""
else
  FIREWALL_SCRIPT="/etc/init.d/rc.firewall"

  if iptables -S | grep -q "^-P INPUT DROP"; then
    FIREWALL_STATUS="$STATUS_ON"
    ICON="$ICON_FIREWALL_ON"
    COLOR="$COLOR_FIREWALL_ON"
  else
    FIREWALL_STATUS="$STATUS_OFF"
    ICON="$ICON_FIREWALL_OFF"
    COLOR="$COLOR_FIREWALL_OFF"
  fi

  if [[ "$1" == "toggle" ]]; then
    chmod +x "$FIREWALL_SCRIPT"
    if iptables -S | grep -q "^-P INPUT DROP"; then
      "$FIREWALL_SCRIPT" stop
      echo "$MSG_OFF"
    else
      "$FIREWALL_SCRIPT" start
      echo "$MSG_ON"
    fi
    exit 0
  fi

  DISPLAY_LINE="<span foreground='$COLOR'> $ICON  $FIREWALL_STATUS </span>"

  MORE_INFO="<tool>"
  MORE_INFO+="<span font_family='$TOOLTIP_FONT' font_size='$TOOLTIP_SIZE' weight='$TOOLTIP_WEIGHT'>"
  MORE_INFO+="<span foreground='$COLOR_ACCENT'>$LABEL_STATUS</span> <span foreground='$COLOR'>$FIREWALL_STATUS</span>\n"
  MORE_INFO+="$LABEL_TOGGLE"
  MORE_INFO+="</span>"
  MORE_INFO+="</tool>"

  INFO="<txt>$DISPLAY_LINE</txt>"
  INFO+="<txtclick>bash $0 toggle</txtclick>"
fi

echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$MORE_INFO"
echo -e "$INFO"
