#!/usr/bin/env bash

# Configurar localización
export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Texto según idioma ===
set_texts() {
    case "$1" in
        es)
            LABEL_TOOLTIP="Mostrar/Ocultar módulos"
            ;;
        *)
            LABEL_TOOLTIP="Show/Hide Monitors"
            ;;
    esac
}

set_texts "$LANG_CODE"

# Archivos a alternar en ~/.config/genmon-hide/
FILES=("storage" "connection" "volume" "batt" "usb")

# Asegurar que el directorio existe
mkdir -p "$HOME/.config/genmon-hide"

# Archivo que mantiene el estado global del toggle
TOGGLE_STATE_FILE="$HOME/.config/genmon-hide/.toggle_state"

# Leer el estado del toggle
if [ -f "$TOGGLE_STATE_FILE" ]; then
    TOGGLE_STATE=$(cat "$TOGGLE_STATE_FILE")
else
    TOGGLE_STATE="hidden"
fi

# Alternar el estado general
if [[ "$1" == "toggle" ]]; then
    if [[ "$TOGGLE_STATE" == "hidden" ]]; then
        TOGGLE_STATE="visible"
        for FILE in "${FILES[@]}"; do
            FILE_PATH="$HOME/.config/genmon-hide/$FILE"
            if [ -f "$FILE_PATH" ]; then
                rm "$FILE_PATH"
            fi
        done
    else
        TOGGLE_STATE="hidden"
        for FILE in "${FILES[@]}"; do
            FILE_PATH="$HOME/.config/genmon-hide/$FILE"
            if [ ! -f "$FILE_PATH" ]; then
                touch "$FILE_PATH"
            fi
        done
    fi
    echo "$TOGGLE_STATE" > "$TOGGLE_STATE_FILE"
fi

# === 🎨 Iconos ===
ICON_UP=" "
ICON_RIGHT=" "
ICON_COLOR_UP="#FFFFFF"
ICON_COLOR_RIGHT="#D54A57"

# Determinar el estado general basado en "storage"
if [ -f "$HOME/.config/genmon-hide/storage" ]; then
    ICON="<span foreground='$ICON_COLOR_RIGHT' background='#383148'>$ICON_RIGHT</span>"
else
    ICON="<span foreground='$ICON_COLOR_UP' background='#383148'>$ICON_UP</span>"
fi

# Acción de clic
ACTION="<txtclick>/root/.config/genmon-scripts/simple/toggle_connection.sh toggle</txtclick>"

# Tooltip con localización
MOREINFO="<tool>$LABEL_TOOLTIP</tool>"

# Salida para GenMon
echo -e "<txt>${ICON}</txt>"
echo -e "$MOREINFO"
echo -e "$ACTION"
