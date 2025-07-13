#!/usr/bin/env bash

# Variables de brillo
BRIGHTNESS_ORIGINAL=1.0  # Brillo original
DIMMED_BRIGHTNESS=0.75   # Brillo reducido (3/4 del brillo original)
OUTPUT=$(xrandr --current | grep " connected" | awk '{print $1}')
LOG_FILE="/tmp/battery_script.log"

# Obtener el tema de íconos
icon_theme=$(xfconf-query -c xsettings -p /Net/IconThemeName 2>/dev/null)
icon_name="preferences-system-power"
icon_path=$(find /usr/share/icons/$icon_theme -type f -name "$icon_name.*" 2>/dev/null | head -n 1)
if [ -z "$icon_path" ]; then
  icon_path="/usr/share/icons/Adwaita/48x48/actions/system-shutdown-symbolic.png"
fi

# Función para verificar si el cargador está conectado
check_charger() {
  BATTERY=$(upower -e | grep 'BAT')
  if [ -n "$BATTERY" ]; then
    STATE=$(upower -i "$BATTERY" | grep state | awk '{print $2}')
    if [ "$STATE" = "charging" ] || [ "$STATE" = "fully-charged" ]; then
      return 0
    fi
  fi
  return 1
}

# Reducir el brillo de la pantalla
dim_screen() {
  xrandr --output "$OUTPUT" --brightness "$DIMMED_BRIGHTNESS" 2>>"$LOG_FILE"
  echo "$(date): Pantalla oscurecida" >> "$LOG_FILE"
}

# Restablecer el brillo de la pantalla
restore_brightness() {
  xrandr --output "$OUTPUT" --brightness "$BRIGHTNESS_ORIGINAL" 2>>"$LOG_FILE"
  echo "$(date): Brillo restaurado" >> "$LOG_FILE"
}

# Lanzar cbatticon-gui.sh
launch_config() {
  if [ -f "/usr/local/bin/cbatticon-gui.sh" ]; then
    if [ -x "/usr/local/bin/cbatticon-gui.sh" ]; then
      echo "$(date): Ejecutando cbatticon-gui.sh" >> "$LOG_FILE"
      /usr/local/bin/cbatticon-gui.sh &>> "$LOG_FILE" &
      disown  # Evitar que SIGHUP mate el proceso
      sleep 1
    else
      echo "$(date): ERROR: cbatticon-gui.sh no es ejecutable" >> "$LOG_FILE"
      yad --error --text="cbatticon-gui.sh no es ejecutable" --timeout=5
    fi
  else
    echo "$(date): ERROR: cbatticon-gui.sh no encontrado" >> "$LOG_FILE"
    yad --error --text="cbatticon-gui.sh no encontrado en /usr/local/bin" --timeout=5
  fi
}

# Mostrar ventana de diálogo con cuenta regresiva y botones
show_dialog_with_countdown() {
  SECONDS=60  # Duración en segundos
  (
    for ((i = SECONDS; i >= 0; i--)); do
      if check_charger; then
        echo "100"
        echo "#⚡ Cargador conectado. Cerrando diálogo."
        echo "$(date): Cargador detectado, restaurando brillo y cerrando" >> "$LOG_FILE"
        restore_brightness  # Restaurar brillo al conectar el cargador
        kill $$  # Terminar el script limpiamente
      fi
      progress=$((100 * (SECONDS - i) / SECONDS))
      echo "$progress"
      echo "# Tiempo restante: $i segundos"
      sleep 1
    done
  ) |
    yad --progress \
      --title="Batería Baja" \
      --undecorated \
      --window-icon="$icon_path" \
      --text="<span font='Terminess Nerd Font' size='14000'>\n 󰢜  Batería baja. \n  Por favor, conecta el cargador.</span>" \
      --button="󰛩  Restaurar Brillo:0" \
      --button="  Configurar Alertas:1" \
      --width=340 \
      --height=100 \
      --auto-close \
      --center 2>>"$LOG_FILE"
}

# Lógica principal
echo "$(date): Script iniciado" > "$LOG_FILE"
dim_screen

RESPONSE=$(show_dialog_with_countdown 2>/dev/null)
EXIT_CODE=$?
echo "$(date): Diálogo finalizó con código $EXIT_CODE" >> "$LOG_FILE"

case $EXIT_CODE in
  0)
    echo "$(date): Restaurar Brillo seleccionado" >> "$LOG_FILE"
    restore_brightness
    exit 0
    ;;
  1)
    echo "$(date): Configurar Alertas seleccionado" >> "$LOG_FILE"
    restore_brightness
    launch_config
    exit 0
    ;;
  70)
    echo "$(date): Ventana cerrada manualmente" >> "$LOG_FILE"
    restore_brightness
    exit 0
    ;;
  *)
    echo "$(date): Verificando cargador tras finalizar diálogo" >> "$LOG_FILE"
    if check_charger; then
      echo "$(date): Cargador conectado, saliendo" >> "$LOG_FILE"
      restore_brightness
      exit 0
    fi
    # Si no hay cargador y el temporizador termina, restaurar brillo como respaldo
    echo "$(date): Temporizador finalizado, restaurando brillo" >> "$LOG_FILE"
    restore_brightness
    exit 0
    ;;
esac
