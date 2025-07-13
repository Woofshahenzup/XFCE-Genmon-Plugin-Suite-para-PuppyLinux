#!/bin/bash -x

export TEXTDOMAIN=notificador-bateria
export OUTPUT_CHARSET=UTF-8
export DISPLAY=:0.0

battery_percent=$(acpi -b | grep -oP '(?<=: ).*(?=%)' | grep -oP '[0-9:]+')
battery_Charging=$(acpi -b | grep -oP '(\d+:\d+):\d+ until charged' | sed 's/ until charged//' | paste -sd: - | cut -d: -f1,2)
battery_Discharging=$(acpi -b | grep -o '[0-9:]* remaining' | sed 's/ remaining//' | awk -F: '{printf "%d horas %d min.\n", $1, $2}')

icon_theme=$(grep gtk-icon-theme-name ~/.gtkrc-2.0 | cut -d= -f2 | tr -d ' ' | sed 's/"//g')
icon_name=battery  #aqui va el nombre del icono que vas a usar y cambia segun el tema 
icon_path=$(find /usr/share/icons/$icon_theme -type f -name "$icon_name.*" | head -n 1)

color1="#FFAC09" # orange
color2="#00CDFF" #light blue
color3="#F2E400" #yellow
color4="#FF4D5D" #red
color5="#28FF61" #green
color6="#FFFFFF" #white
font1="Terminess Nerd Font 14"
font2="Terminess Nerd Font 16"
font3=
# Verificar si acpi está instalado
if ! command -v acpi &> /dev/null; then
    # Mostrar mensaje con YAD
    yad --text="<span font='$font1' foreground='$color5'> $(gettext 'Need ACPI to run this notifier')</span>" --timeout=4 --no-buttons --undecorated
fi
if [ "$battery_percent" ]; then
    if [ "$battery_Charging" ]; then
        status="<span font='$font1' foreground='$color6'> $(gettext 'Charging') 󰢟</span>
<span font='$font1' foreground='$color6'> $battery_Charging </span> <span font='$font1' foreground='$color5'> $(gettext 'Until Charged')</span> "
    elif [ "$battery_Discharging" ]; then    
    status="<span font='$font1' foreground='$color6'>$(gettext 'Discharging') 󱃍 </span>\n<span font='$font1' foreground='$color6'>$battery_Discharging $(gettext 'Remaining')</span>"
    else
        status="<span font='$font1' foreground='$color6'> $(gettext 'Unknow')</span>"
    fi

yad --title="Battery Notifier" \
    --text-align=center \
    --text="<span font='$font1' foreground='$color2'>$(gettext 'Percent:')</span> <span font='$font1' foreground='$color6'>$battery_percent%</span>\n<span font='$font1' foreground='$color2'>$(gettext 'Status:')</span>  $status" \
    --image="$icon_name" \
    --no-buttons \
    --skip-taskbar \
    --fixed \
    --undecorated \
    --timeout=3 \
    --mouse \
    --posx=-1 \
    --posy=0 \
    --width=300 \   
fi
