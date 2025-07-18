#!/usr/bin/env bash

# Configurar localización
export LC_ALL=en_US.UTF-8

# Archivos a alternar en ~/.config/genmon-hide/
FILES=("filemanager" "terminal" "geany" "browser" "celluloid" "deadbeef")

# Asegurar que el directorio existe
mkdir -p "$HOME/.config/genmon-hide"

# Archivo que mantiene el estado global del toggle
TOGGLE_STATE_FILE="$HOME/.config/genmon-hide/.toggle_state_launchers"
# === 🖋️ Tipografía personalizada ===
FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_TOOLTIP="14"
FONT_WEIGHT="Bold"

# Leer el estado del toggle
if [ -f "$TOGGLE_STATE_FILE" ]; then
    TOGGLE_STATE=$(cat "$TOGGLE_STATE_FILE")
else
    TOGGLE_STATE="hidden" # Estado inicial por defecto
fi

# Alternar el estado general
if [[ "$1" == "toggle" ]]; then
    if [[ "$TOGGLE_STATE" == "hidden" ]]; then
        TOGGLE_STATE="visible"
        for FILE in "${FILES[@]}"; do
            FILE_PATH="$HOME/.config/genmon-hide/$FILE"
            if [ -f "$FILE_PATH" ]; then
                rm "$FILE_PATH"  # Restaurar solo los ocultos
            fi
        done
    else
        TOGGLE_STATE="hidden"
        for FILE in "${FILES[@]}"; do
            FILE_PATH="$HOME/.config/genmon-hide/$FILE"
            if [ ! -f "$FILE_PATH" ]; then
                touch "$FILE_PATH"  # Ocultar solo los visibles
            fi
        done
    fi
    echo "$TOGGLE_STATE" > "$TOGGLE_STATE_FILE"  # Guardar el estado del toggle
fi

# Definir los iconos
ICON_UP=" "  # Flecha hacia arriba
ICON_RIGHT=" "   # Flecha hacia la derecha
ICON_COLOR_UP="#FFFFFF"  # Color del icono
ICON_COLOR_RIGHT="#D54A57"  # Color del icono

# Determinar el estado general basado en "file-manager"
if [ -f "$HOME/.config/genmon-hide/filemanager" ]; then
    ICON="<span foreground='$ICON_COLOR_RIGHT' background='#383148'>$ICON_RIGHT</span>"
else
    ICON="<span foreground='$ICON_COLOR_UP' background='#383148'>$ICON_UP</span>"
fi

# Acción de clic: ejecutar el script con el argumento "toggle"
ACTION="<txtclick>/root/.config/genmon-scripts/simple/toggle_launchers.sh toggle</txtclick>"

# Tooltip con estilo aplicado
MOREINFO="<tool><span font_desc='${FONT_MAIN} ${FONT_WEIGHT} ${FONT_SIZE_TOOLTIP}'>Show/Hide Launchers</span></tool>"


# Salida para GenMon
echo -e "<txt>${ICON}</txt>"
echo -e "$MOREINFO"
echo -e "$ACTION"
