#!/usr/bin/env bash

# Ejecutar upower -d para activar el servicio
initialize_upower() {
  echo "Inicializando upower..."
  upower -d > /dev/null 2>&1
  sleep 1  # Pausa breve para asegurarse de que esté listo
}
initialize_upower

font="Terminess Nerd Font"
T1="     ⏻  Shutdown      "
# Mensaje a mostrar
MESSAGE="<span font='Terminess Nerd Font' size='16000' line-height='1.0'>\n  󰢜  The battery percentage is too low.\n     We recommend connecting the charger.\n     This device will shut down.\n</span>"

# Duración del temporizador (en segundos)
TIMEOUT=60

# Obtener el tema de íconos
icon_theme=$(xfconf-query -c xsettings -p /Net/IconThemeName 2>/dev/null)
icon_name="preferences-system-power"
icon_path=$(find /usr/share/icons/$icon_theme -type f -name "$icon_name.*" 2>/dev/null | head -n 1)
if [ -z "$icon_path" ]; then
  icon_path="/usr/share/icons/Adwaita/48x48/actions/system-shutdown-symbolic.png"
fi

# Función para verificar el cargador
check_charger() {
  BATTERY=$(upower -e | grep 'BAT')
  echo "Detectando batería: $BATTERY"  # Mensaje de depuración
  if [ -n "$BATTERY" ]; then
    STATE=$(upower -i "$BATTERY" | grep state | awk '{print $2}')
    echo "Estado de la batería: $STATE"  # Mensaje de depuración
    if [ "$STATE" = "charging" ] || [ "$STATE" = "fully-charged" ]; then
      return 0
    fi
  fi
  return 1
}

# Mostrar la ventana con yad y manejar progresos
(
  for ((i = TIMEOUT; i >= 0; i--)); do
    if check_charger; then
      echo "100"
      echo "#⚡ Cargador conectado. Apagado cancelado."
      echo "Apagado cancelado porque se conectó el cargador."  # Depuración en tiempo real
      kill $$  # Termina el script
    fi
    echo $(( (TIMEOUT - i) * 100 / TIMEOUT ))
    echo "# $i Remaining seconds."
    sleep 1
  done
  echo "100"
) | yad --progress \
  --title="Low Battery Warning" \
  --undecorated \
  --window-icon="$icon_path" \
  --text="$MESSAGE" \
  --pango \
  --percentage=0 \
  --auto-close \
  --width=400 \
  --height=100 \
  --button="$T1:2" \
  --button="󰅚  Cancel:1" \
  --button="  Config Alerts:3" \
  --no-escape \
  --foreground="#333333" \
  --back="#E0F0FF"


EXIT_CODE=$?

if [ $EXIT_CODE -eq 2 ]; then
  echo "Botón de apagado presionado, ejecutando wmpoweroff."
  wmpoweroff || echo "Error ejecutando wmpoweroff."
  exit 0
fi

if [ $EXIT_CODE -eq 1 ]; then
  echo "Cancelado por el usuario."
  exit 0
fi

if [ $EXIT_CODE -eq 3 ]; then
  echo "Botón de configuración presionado, ejecutando cbatticon-gui."
  cbatticon-gui.sh || echo "Error ejecutando cbatticon-gui."
  exit 0
fi

if [ $EXIT_CODE -eq 0 ]; then
  echo "El temporizador terminó, ejecutando wmpoweroff."
  wmpoweroff || echo "Error ejecutando wmpoweroff."
  exit 0
fi

echo "Salida inesperada: $EXIT_CODE"
exit 0
