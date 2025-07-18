#!/usr/bin/env bash

# Configurar localización
export LC_ALL=en_US.UTF-8

# Archivos a alternar en ~/.config/genmon-hide/
FILES=("trash" "brightness2" "ram" "firewall" "cpu" "brightness" "weather")
# === 🎨 Tipografía centralizada ===
FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_TOOLTIP="14"
FONT_WEIGHT="Bold"

# Asegurar que el directorio existe
mkdir -p "$HOME/.config/genmon-hide"

# Archivo que mantiene el estado global del toggle
TOGGLE_STATE_FILE="$HOME/.config/genmon-hide/.toggle_state_weather"

# Leer el estado del toggle
if [ -f "$TOGGLE_STATE_FILE" ]; then
    TOGGLE_STATE=$(cat "$TOGGLE_STATE_FILE")
else
    TOGGLE_STATE="hidden" # Estado inicial por defecto
fi

# Alternar el estado general respetando los estados manuales
if [[ "$1" == "toggle" ]]; then
    if [[ "$TOGGLE_STATE" == "hidden" ]]; then
        TOGGLE_STATE="visible"
        for FILE in "${FILES[@]}"; do
            FILE_PATH="$HOME/.config/genmon-hide/$FILE"
            if [ -f "$FILE_PATH" ]; then
                rm "$FILE_PATH" && echo "Restaurado: $FILE_PATH"
            fi
        done
    else
        TOGGLE_STATE="hidden"
        for FILE in "${FILES[@]}"; do
            FILE_PATH="$HOME/.config/genmon-hide/$FILE"
            if [ ! -f "$FILE_PATH" ]; then
                touch "$FILE_PATH" && echo "Ocultado: $FILE_PATH"
            fi
        done
    fi
    echo "$TOGGLE_STATE" > "$TOGGLE_STATE_FILE"  # Guardar el estado del toggle
fi

# Definir los iconos y colores
ICON_UP=" "  # Flecha hacia arriba
ICON_RIGHT=" "   # Flecha hacia la derecha
ICON_COLOR_UP="#FFBC00"
ICON_COLOR_RIGHT="#D54A57"

# Determinar el estado general basado en "trash"
ICON=""
if [ -f "$HOME/.config/genmon-hide/trash" ]; then
    ICON="<span foreground='$ICON_COLOR_RIGHT' background='#383148'>$ICON_RIGHT</span>"
else
    ICON="<span foreground='$ICON_COLOR_UP' background='#383148'>$ICON_UP</span>"
fi

# Acción de clic: ejecutar el script con el argumento "toggle"
ACTION="<txtclick>bash /root/.config/genmon-scripts/simple/toggle_weather.sh toggle</txtclick>"

# Tooltip
MOREINFO="<tool><span font_desc='${FONT_MAIN} ${FONT_WEIGHT} ${FONT_SIZE_TOOLTIP}'>Show/Hide elements</span></tool>"

# Salida para GenMon
echo -e "<txt>${ICON}</txt>"
echo -e "$MOREINFO"
echo -e "$ACTION"
