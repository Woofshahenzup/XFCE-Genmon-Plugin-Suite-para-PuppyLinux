#!/usr/bin/env bash

# Configurar el locale
export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            LABEL_STORAGE_MODE="Modo de almacenamiento"
            LABEL_CHANGES="Cambios guardados en RAM o periódicamente. Ver eventmanager"
            LABEL_CLICK_SAVE="Haz clic para guardar."
            LABEL_DESCRIPTION="Puppy Linux usa PUPMODE para definir cómo se configuran las capas de almacenamiento:"
            LABEL_PUPMODE_5="• PUPMODE 5: Primer arranque, sin almacenamiento persistente."
            LABEL_PUPMODE_12="• PUPMODE 12: Guarda directamente en el disco duro."
            LABEL_PUPMODE_13="• PUPMODE 13: Modo USB, guarda cambios periódicamente."
            LABEL_PUPMODE_2="• PUPMODE 2: Partición montada directamente, sin ramdisk."
            LABEL_PUPMODE_77="• PUPMODE 77: CD/DVD multisession, guarda al apagar."
            ;;
        *)
            LABEL_STORAGE_MODE="Storage mode"
            LABEL_CHANGES="Changes saved in RAM or periodically. See eventmanager"
            LABEL_CLICK_SAVE="Click to save."
            LABEL_DESCRIPTION="Puppy Linux uses PUPMODE to define how storage layers are configured:"
            LABEL_PUPMODE_5="• PUPMODE 5: First boot, no persistent storage."
            LABEL_PUPMODE_12="• PUPMODE 12: Saves directly to hard drive."
            LABEL_PUPMODE_13="• PUPMODE 13: USB mode, changes saved periodically."
            LABEL_PUPMODE_2="• PUPMODE 2: Partition mounted directly, no ramdisk."
            LABEL_PUPMODE_77="• PUPMODE 77: Multisession CD/DVD, saves on shutdown."
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 🎨 Configuración visual ===
ICON_SAVE="󰠘"
COLOR_ICON="#FFFFFF"
COLOR_HIGHLIGHT="#FFBC00"
COLOR_INFO="#35C5B9"
FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_MAIN="14000"
TOOLTIP_FONT_SIZE="14000"
TOOLTIP_WEIGHT="bold"

# === 📦 Obtener PUPMODE ===
PUPMODE=$(awk -F'=' '/PUPMODE/ {print $2}' /etc/rc.d/PUPSTATE)

# === 🕵️‍♂️ Ocultar si no es modo persistente ===
if [[ "$PUPMODE" != "13" && "$PUPMODE" != "77" ]]; then
    echo -e "<txt></txt>"
    echo -e "<tool></tool>"
    exit 0
fi

# === 🖼 Línea principal ===
DISPLAY_LINE="<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_MAIN' foreground='$COLOR_ICON'> $ICON_SAVE $LABEL_STORAGE_MODE: PUPMODE $PUPMODE </span>"

# === 🧾 Tooltip ===
MORE_INFO="<tool>"
MORE_INFO+="<span font_family='$FONT_MAIN' font_size='$TOOLTIP_FONT_SIZE' weight='$TOOLTIP_WEIGHT' foreground='$COLOR_HIGHLIGHT'>"
MORE_INFO+="$LABEL_STORAGE_MODE:\n"
MORE_INFO+="<span foreground='$COLOR_INFO'>PUPMODE $PUPMODE</span>\n"
MORE_INFO+="$LABEL_CHANGES\n"
MORE_INFO+="$LABEL_CLICK_SAVE\n\n"
MORE_INFO+="$LABEL_DESCRIPTION\n"
MORE_INFO+="$LABEL_PUPMODE_5\n"
MORE_INFO+="$LABEL_PUPMODE_12\n"
MORE_INFO+="$LABEL_PUPMODE_13\n"
MORE_INFO+="$LABEL_PUPMODE_2\n"
MORE_INFO+="$LABEL_PUPMODE_77"
MORE_INFO+="</span></tool>"

# === 🖱️ Acción al hacer clic ===
INFO="<txtclick>save2flash</txtclick>"

# === 📤 Salida final para GenMon ===
echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$MORE_INFO"
echo -e "$INFO"
