#!/bin/bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            TITLE_WINDOW="Menú Fusilli"
            TITLE1="󱅠  Activar gestor de ventanas Fusilli"
            TITLE2="  Gestor de configuración Fusilli"
            TITLE3="  Gestor de temas Rotini"
            TITLE4="  Volver al gestor de ventanas XFCE"
            TITLE5="󰖲  Temas de ventanas XFCE"
            TITLE6="󱕷  Apariencia"
            ;;
        *)
            TITLE_WINDOW="Fusilli Menu"
            TITLE1="󱅠  Enable Fusilli Windows Manager"
            TITLE2="  Fusilli Settings Manager"
            TITLE3="  Rotini Theme Manager"
            TITLE4="  Back to XFCE Windows Manager"
            TITLE5="󰖲  Xfce windows themes"
            TITLE6="󱕷  Appearance"
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 📂 Ruta de iconos ===
pics="/opt/panelyfusilli/"

# === 🖱️ Crear menú en YAD con los elementos localizados ===
yad --title="$TITLE_WINDOW" --window-icon="${pics}image-numix.svg" --width=500 --height=100 --no-buttons \
--form \
--field="$TITLE1":BTN "bash -c '/usr/local/bin/fusilli-rotini.sh'" \
--field="$TITLE2":BTN "bash -c 'fsm'" \
--field="$TITLE3":BTN "bash -c 'rotini-theme-manager -i'" \
--field="$TITLE4":BTN "bash -c '/root/.config/genmon-scripts/simple/fusilli-off.sh'" \
--field="$TITLE5":BTN "bash -c 'xfwm4-settings'" \
--field="$TITLE6":BTN "bash -c 'xfce4-appearance-settings'"
