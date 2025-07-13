#!/bin/bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            TITLE_WINDOW="Configuración del sistema"
            TITLE1="  Configuración del escritorio"
            TITLE2="  Administrador de tareas"
            TITLE3="󰖲 Ajustes de ventanas"
            TITLE4="󰸉  Fondos de pantalla"
            TITLE5="󰀻 Obtener aplicaciones"
            TITLE6="  Gestor de paquetes"
            TITLE7="󱕒  Touchpad"
            TITLE9="  Notificaciones"
            TITLE10="  Cargar SFS"
            TITLE11="  Captura de pantalla"
            TITLE12="󰹑  PupControl"
            TITLE13="󰟀  Acerca de"
            TITLE14="  Mostrar/ocultar elementos del panel"
            TITLE15="󱄄  Monitor"
            ;;
        *)
            TITLE_WINDOW="System Configuration"
            TITLE1="  Desktop Settings"
            TITLE2="  Task Manager"
            TITLE3="󰖲 Windows Tweaks"
            TITLE4="󰸉  Wallpapers"
            TITLE5="󰀻 Get Apps"
            TITLE6="  Package Manager"
            TITLE7="󱕒  Touchpad"
            TITLE9="  Notifier"
            TITLE10="  Load SFS"
            TITLE11="  Screen Capture"
            TITLE12="󰹑  PupControl"
            TITLE13="󰟀  About"
            TITLE14="  Show/hide panel items"
            TITLE15="󱄄  Monitor"
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 📂 Ruta de iconos ===
export pics="/opt/panelyfusilli/"

# === 🖱️ Ejecutar YAD con botones localizados ===
yad --form \
  --title="$TITLE_WINDOW" \
  --width=400 --height=300 --columns=2 --no-buttons \
  --field="$TITLE14":btn "panel-config.py" \
  --field="$TITLE13":btn "about.sh" \
  --field="$TITLE15":btn "xfce4-display-settings" \
  --field="$TITLE1":btn "xfce4-settings-manager" \
  --field="$TITLE2":btn "pprocess" \
  --field="$TITLE3":btn "xfwm4-tweaks-settings" \
  --field="$TITLE9":btn "xfce4-notifyd-config" \
  --field="$TITLE5":btn "/usr/local/quickpet-Devuanpup/quickpet_devuan" \
  --field="$TITLE6":btn "ppm" \
  --field="$TITLE12":btn "pupcontrol" \
  --field="$TITLE7":btn "xfce4-mouse-settings" \
  --field="$TITLE4":btn "xfdesktop-settings" \
  --field="$TITLE10":btn "sfs_load" \
  --field="$TITLE11":btn "xfce4-screenshooter" \
  --window-icon="${pics}desktop.svg"
