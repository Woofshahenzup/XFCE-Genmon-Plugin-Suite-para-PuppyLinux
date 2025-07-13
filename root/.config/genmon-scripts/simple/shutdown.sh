#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            LABEL_CLICK="Haz clic para apagar"
            LABEL_SAVE="Asegúrate de guardar tu trabajo"
            LABEL_BEFORE="antes de continuar."
            ;;
        *)
            LABEL_CLICK="Click to shut down"
            LABEL_SAVE="Ensure all work is saved"
            LABEL_BEFORE="before proceeding."
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 📂 Archivos de estado ===
HIDE_FILE_SHUTDOWN="$HOME/.config/genmon-hide/shutdown"
ANIMATION_ACTIVE_FILE="/tmp/genmon_shutdown_blinking_active"
BLINK_STATE_FILE="/tmp/genmon_shutdown_blinking_state"

# === 🎨 Estilo visual ===
ICON_SHUTDOWN="⏻ "
COLOR_NORMAL="#FFFFFF"
COLOR_BLINK_ON="#FF5733"
COLOR_BLINK_OFF="#6C7A89"

FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_TOOLTIP="16000"
FONT_WEIGHT="bold"

# === 🕵️‍♂️ Ocultar si está activado ===
if [[ -f "$HIDE_FILE_SHUTDOWN" ]]; then
    echo "<txt></txt>"
    echo "<tool></tool>"
    exit 0
fi

# === 🔁 Función de animación ===
run_blinking_animation() {
    touch "$ANIMATION_ACTIVE_FILE"
    echo "OFF" > "$BLINK_STATE_FILE"

    local duration=11
    local interval=1
    local num_flashes=$((duration / interval))

    for ((i=0; i < num_flashes; i++)); do
        if [[ $(cat "$BLINK_STATE_FILE") == "ON" ]]; then
            echo "OFF" > "$BLINK_STATE_FILE"
        else
            echo "ON" > "$BLINK_STATE_FILE"
        fi
        sleep "$interval"
    done

    rm -f "$ANIMATION_ACTIVE_FILE" "$BLINK_STATE_FILE"
}

# === 🚀 Iniciar animación si se invoca con argumento ===
if [[ "$1" == "start_animation" ]]; then
    run_blinking_animation
    exit 0
fi

# === 🎯 Determinar color del ícono ===
CURRENT_ICON_COLOR="$COLOR_NORMAL"
if [[ -f "$ANIMATION_ACTIVE_FILE" ]]; then
    BLINK_STATE=$(cat "$BLINK_STATE_FILE")
    if [[ "$BLINK_STATE" == "ON" ]]; then
        CURRENT_ICON_COLOR="$COLOR_BLINK_ON"
    else
        CURRENT_ICON_COLOR="$COLOR_BLINK_OFF"
    fi
fi

# === 🖼 Línea principal ===
DISPLAY_LINE="<span font_family='$FONT_MAIN' foreground='$CURRENT_ICON_COLOR'> $ICON_SHUTDOWN </span>"

# === 🧾 Tooltip ===
MORE_INFO="<tool>"
MORE_INFO+="<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_TOOLTIP' weight='$FONT_WEIGHT'>"
MORE_INFO+="$LABEL_CLICK\n$LABEL_SAVE\n$LABEL_BEFORE"
MORE_INFO+="</span></tool>"

# === 🖱️ Acción al hacer clic ===
INFO="<txt>$DISPLAY_LINE</txt>"
INFO+="<txtclick>bash -c '${0%/*}/shutdown-gui & ${0} start_animation &'</txtclick>"

# === 📤 Salida final ===
echo -e "$INFO"
echo -e "$MORE_INFO"
