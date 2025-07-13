#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            LABEL_LAYOUT="Distribución"
            LABEL_CAPS="Bloq Mayús"
            LABEL_NUM="Bloq Num"
            TITLE_YAD="Seleccionar teclado"
            FIELD_YAD="Idioma"
            ;;
        *)
            LABEL_LAYOUT="Layout"
            LABEL_CAPS="Caps Lock"
            LABEL_NUM="Num Lock"
            TITLE_YAD="Select Keyboard"
            FIELD_YAD="Language"
            ;;
    esac
}

set_texts "$LANG_CODE"

# --- CONFIGURACIÓN MANUAL DEL ESQUEMA DE COLOR ---
PANEL_COLOR_SCHEME="auto" 

# --- INICIO DEL CÓDIGO DE DETECCIÓN DE TEMA Y PALETA DE COLORES ---
is_dark_theme() {
    if [[ "$PANEL_COLOR_SCHEME" == "dark" ]]; then
        return 0
    elif [[ "$PANEL_COLOR_SCHEME" == "light" ]]; then
        return 1
    fi

    if command -v gsettings &>/dev/null; then
        PREFER_DARK=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)
        if [[ "$PREFER_DARK" == "'prefer-dark'" ]]; then
            return 0
        fi
        DARK_THEME_VARIANT=$(gsettings get org.gnome.desktop.interface gtk-application-prefer-dark-theme 2>/dev/null)
        if [[ "$DARK_THEME_VARIANT" == "true" ]]; then
            return 0
        fi
    fi

    THEME_NAME=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
    if [[ "$THEME_NAME" =~ [Dd]ark ]]; then
        return 0
    fi

    return 1
}

if is_dark_theme; then
    BG_MAIN="#313244"
    FG_TEXT="#FFFFFF"
    ACCENT_COLOR="#F5E0DC"
    HIGHLIGHT_COLOR="#56B6C2"
    CAPS_ON_COLOR="#F28FAD"
    CAPS_OFF_COLOR="#6C7086"
    NUM_ON_COLOR="#A6E3A1"
    NUM_OFF_COLOR="#6C7086"
else
    BG_MAIN="#F0F0F0"
    FG_TEXT="#E4E4E4"
    ACCENT_COLOR="#9B59B6"
    HIGHLIGHT_COLOR="#007ACC"
    CAPS_ON_COLOR="#D32F2F"
    CAPS_OFF_COLOR="#757575"
    NUM_ON_COLOR="#388E3C"
    NUM_OFF_COLOR="#757575"
fi

# --- FIN DEL CÓDIGO DE DETECCIÓN DE TEMA Y PALETA DE COLORES ---

# Íconos por layout
declare -A ICONS
ICONS["us"]="🇺🇸 US"
ICONS["es"]="🇪🇸 ES"
ICONS["latam"]="🌍 LAT"
ICONS["fr"]="🇫🇷 FR"
ICONS["de"]="🇩🇪 DE"
ICONS["jp"]="🇯🇵 JP"
ICONS["it"]="🇮🇹 IT"
ICONS["pt"]="🇵🇹 PT"
ICONS["br"]="🇧🇷 BR"
ICONS["ca"]="🇨🇦 CA"
ICONS["gb"]="🇬🇧 GB"
ICONS["ru"]="🇷🇺 RU"
ICONS["cn"]="🇨🇳 CN"
ICONS["kr"]="🇰🇷 KR"

HIDE_FILE_KEYBOARD="$HOME/.config/genmon-hide/keyboard"

CURRENT_LAYOUT=$(setxkbmap -query | grep layout | awk '{print $2}')
ICON_DATA="${ICONS[$CURRENT_LAYOUT]:-?? UNKNOWN}"
ICON_EMOJI=$(echo "$ICON_DATA" | awk '{print $1}')
ICON_TEXT=$(echo "$ICON_DATA" | awk '{print $2}')

CAPS_STATE=$(xset q | grep "Caps Lock:" | awk '{print $4}')
CAPS_ICON=$([ "$CAPS_STATE" == "on" ] && echo "󰬈 " || echo "")
CAPS_COLOR=$([ "$CAPS_STATE" == "on" ] && echo "$CAPS_ON_COLOR" || echo "$CAPS_OFF_COLOR")

NUM_STATE=$(xset q | grep "Num Lock:" | awk '{print $8}')
NUM_ICON=$([ "$NUM_STATE" == "on" ] && echo "󰎤 " || echo "")
NUM_COLOR=$([ "$NUM_STATE" == "on" ] && echo "$NUM_ON_COLOR" || echo "$NUM_OFF_COLOR")

if [ -f "$HIDE_FILE_KEYBOARD" ]; then
    DISPLAY_LINE=""
    MORE_INFO="<tool></tool>"
    ACTION=""
else
    DISPLAY_LINE=""
    DISPLAY_LINE+=" <span font_family='Noto Color Emoji' font_size='12000' foreground='$HIGHLIGHT_COLOR'>$ICON_EMOJI</span> "
    DISPLAY_LINE+="<span font_family='Terminess Nerd Font' weight='bold' foreground='$FG_TEXT'>$ICON_TEXT</span> "
    DISPLAY_LINE+="<span font_family='Terminess Nerd Font' foreground='$CAPS_COLOR'>$CAPS_ICON</span> "
    DISPLAY_LINE+="<span font_family='Terminess Nerd Font' foreground='$NUM_COLOR'>$NUM_ICON</span>"

    MORE_INFO="<tool>"
    MORE_INFO+="<span font_family='Terminess Nerd Font' font_size='16000' foreground='$FG_TEXT'>"
    MORE_INFO+="$LABEL_LAYOUT: $CURRENT_LAYOUT\n$LABEL_CAPS: $CAPS_STATE\n$LABEL_NUM: $NUM_STATE"
    MORE_INFO+="</span>"
    MORE_INFO+="</tool>"

    CURRENT_LAYOUT=${CURRENT_LAYOUT:-"us"}

    ACTION="<txtclick>bash -c 'layout=\$(yad --title=\"$TITLE_YAD\" --form --field=\"$FIELD_YAD\":CB \"$CURRENT_LAYOUT!us!es!latam!fr!de!jp!it!pt!br!ca!gb!ru!cn!kr\" --center --width=400 --height=100); layout=\${layout%|}; [ -n \"\$layout\" ] && setxkbmap \$layout'</txtclick>"
fi

echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$MORE_INFO"
echo -e "$ACTION"
