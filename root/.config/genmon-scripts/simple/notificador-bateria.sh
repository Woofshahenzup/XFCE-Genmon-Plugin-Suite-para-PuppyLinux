#!/bin/bash -x
# Deps: acpi, cbatticon, terminess nerd fonts

export LC_ALL=en_US.UTF-8
export DISPLAY=:0.0

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            TEXT_CHARGING="Cargando"
            TEXT_UNTIL="Hasta carga completa"
            TEXT_DISCHARGING="Descargando"
            TEXT_REMAINING="Restante"
            TEXT_UNKNOWN="Desconocido"
            TEXT_PERCENT="Porcentaje"
            TEXT_STATUS="Estado"
            TEXT_TITLE="Notificador de batería"
            TEXT_NEED_ACPI="Se necesita ACPI para ejecutar esta notificación"
            ;;
        *)
            TEXT_CHARGING="Charging"
            TEXT_UNTIL="Until Charged"
            TEXT_DISCHARGING="Discharging"
            TEXT_REMAINING="Remaining"
            TEXT_UNKNOWN="Unknown"
            TEXT_PERCENT="Percent"
            TEXT_STATUS="Status"
            TEXT_TITLE="Battery Notifier"
            TEXT_NEED_ACPI="Need ACPI to run this notifier"
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 🔋 Obtener datos de batería ===
battery_percent=$(acpi -b | grep -oP '(?<=: ).*(?=%)' | grep -oP '[0-9:]+')
battery_Charging=$(acpi -b | grep -oP '(\d+:\d+):\d+ until charged' | sed 's/ until charged//' | paste -sd: - | cut -d: -f1,2)
battery_Discharging=$(acpi -b | grep -o '[0-9:]* remaining' | sed 's/ remaining//' | awk -F: '{printf "%d horas %d min.\n", $1, $2}')

# === 🎨 Estilo visual ===
icon_theme=$(grep gtk-icon-theme-name ~/.gtkrc-2.0 | cut -d= -f2 | tr -d ' ' | sed 's/"//g')
icon_name=battery
icon_path=$(find /usr/share/icons/$icon_theme -type f -name "$icon_name.*" | head -n 1)

color1="#FFAC09"
color2="#00CDFF"
color3="#F2E400"
color4="#FF4D5D"
color5="#28FF61"
color6="#FFFFFF"
font1="Terminess Nerd Font 14"

# === ⚠️ Verificar si ACPI está instalado ===
if ! command -v acpi &> /dev/null; then
    yad --text="<span font='$font1' foreground='$color5'> $TEXT_NEED_ACPI</span>" --timeout=4 --no-buttons --undecorated
    exit 1
fi

# === 🖼️ Construir estado ===
if [ "$battery_percent" ]; then
    if [ "$battery_Charging" ]; then
        status="<span font='$font1' foreground='$color6'> $TEXT_CHARGING 󰢟</span>
<span font='$font1' foreground='$color6'> $battery_Charging </span> <span font='$font1' foreground='$color5'> $TEXT_UNTIL</span>"
    elif [ "$battery_Discharging" ]; then    
        status="<span font='$font1' foreground='$color6'>$TEXT_DISCHARGING 󱃍</span>\n<span font='$font1' foreground='$color6'>$battery_Discharging $TEXT_REMAINING</span>"
    else
        status="<span font='$font1' foreground='$color6'> $TEXT_UNKNOWN</span>"
    fi

    # === 🖥️ Mostrar notificación ===
    yad --title="$TEXT_TITLE" \
        --text-align=center \
        --text="<span font='$font1' foreground='$color2'>$TEXT_PERCENT:</span> <span font='$font1' foreground='$color6'>$battery_percent%</span>\n<span font='$font1' foreground='$color2'>$TEXT_STATUS:</span> $status" \
        --image="$icon_name" \
        --no-buttons \
        --skip-taskbar \
        --fixed \
        --undecorated \
        --timeout=3 \
        --mouse \
        --posx=-1 \
        --posy=0 \
        --width=300
fi
