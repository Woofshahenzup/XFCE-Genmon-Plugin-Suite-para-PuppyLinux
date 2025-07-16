#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            STATUS_ENABLE="Activado"
            STATUS_DISABLE="Desactivado"
            STATUS_OFF="Cortile apagado"
            TOOLTIP_TITLE="Cortile"
            TOOLTIP_ACTIVE="Activo"
            TOOLTIP_DISABLED="Activo pero desactivado"
            BTN_ACTIVATE="Activar Cortile"
            BTN_TOGGLE="Activar/Desactivar (Ctrl+Shift+4)"
            BTN_FULLSCREEN="Pantalla completa (Ctrl+Shift+5)"
            BTN_LEFT="Vertical izquierda (Ctrl+Shift+6)"
            BTN_RIGHT="Vertical derecha (Ctrl+Shift+7)"
            BTN_TOP="Horizontal arriba (Ctrl+Shift+8)"
            BTN_BOTTOM="Horizontal abajo (Ctrl+Shift+9)"
            BTN_ADD_MASTER="Agregar maestro (Ctrl+Shift+L)"
            BTN_REMOVE_MASTER="Quitar maestro (Ctrl+Shift+H)"
            BTN_ADD_SLAVE="Agregar esclavo (Ctrl+Shift+K)"
            BTN_REMOVE_SLAVE="Quitar esclavo (Ctrl+Shift+J)"
            BTN_SHORTCUTS="Lista de atajos"
            BTN_EXIT="Salir (Ctrl+Shift+0)"
            ;;
        *)
            STATUS_ENABLE="Enable"
            STATUS_DISABLE="Disable"
            STATUS_OFF="Cortile OFF"
            TOOLTIP_TITLE="Cortile"
            TOOLTIP_ACTIVE="Active"
            TOOLTIP_DISABLED="Active but Disabled"
            BTN_ACTIVATE="Activate Cortile"
            BTN_TOGGLE="Enable/Disable (Ctrl+Shift+4)"
            BTN_FULLSCREEN="Fullscreen (Ctrl+Shift+5)"
            BTN_LEFT="Vertical Left (Ctrl+Shift+6)"
            BTN_RIGHT="Vertical Right (Ctrl+Shift+7)"
            BTN_TOP="Horizontal Top (Ctrl+Shift+8)"
            BTN_BOTTOM="Horizontal Bottom (Ctrl+Shift+9)"
            BTN_ADD_MASTER="Add Master (Ctrl+Shift+L)"
            BTN_REMOVE_MASTER="Remove Master (Ctrl+Shift+H)"
            BTN_ADD_SLAVE="Add Slave (Ctrl+Shift+K)"
            BTN_REMOVE_SLAVE="Remove Slave (Ctrl+Shift+J)"
            BTN_SHORTCUTS="Shortcut list"
            BTN_EXIT="Exit (Ctrl+Shift+0)"
            ;;
    esac
}

generate_shortcuts_text() {
    case "$LANG_CODE" in
        es)
            SHORTCUTS_TEXT=$(cat << 'EOF'
Control+Shift+1    → Activar mosaico
Control+Shift+2    → Desactivar mosaico
Control+Shift+3    → Restaurar ventanas
Control+Shift+4    → Alternar mosaico
Control+Shift+5    → Pantalla completa
Control+Shift+6    → Vertical izquierda
Control+Shift+7    → Vertical derecha
Control+Shift+8    → Horizontal arriba
Control+Shift+9    → Horizontal abajo
Control+Shift+L    → Agregar maestro
Control+Shift+H    → Quitar maestro
Control+Shift+K    → Agregar esclavo
Control+Shift+J    → Quitar esclavo
Control+Shift+A    → Convertir ventana activa en maestro
Control+Shift+N    → Convertir siguiente ventana en maestro
Control+Shift+P    → Convertir ventana anterior en maestro
Control+Shift+W    → Aumentar proporción maestro-esclavo
Control+Shift+Q    → Disminuir proporción maestro-esclavo
Control+Shift+F    → Enfocar siguiente ventana
Control+Shift+D    → Enfocar ventana anterior
Control+Shift+0    → Salir de Cortile
EOF
)
            ;;
        *)
            SHORTCUTS_TEXT=$(cat << 'EOF'
Control+Shift+1    → Enable tiling
Control+Shift+2    → Disable tiling
Control+Shift+3    → Restore windows
Control+Shift+4    → Toggle tiling
Control+Shift+5    → Fullscreen layout
Control+Shift+6    → Vertical Left
Control+Shift+7    → Vertical Right
Control+Shift+8    → Horizontal Top
Control+Shift+9    → Horizontal Bottom
Control+Shift+L    → Add Master
Control+Shift+H    → Remove Master
Control+Shift+K    → Add Slave
Control+Shift+J    → Remove Slave
Control+Shift+A    → Make active window master
Control+Shift+N    → Make next window master
Control+Shift+P    → Make previous window master
Control+Shift+W    → Increase master-slave ratio
Control+Shift+Q    → Decrease master-slave ratio
Control+Shift+F    → Focus next window
Control+Shift+D    → Focus previous window
Control+Shift+0    → Exit Cortile
EOF
)
            ;;
    esac
}

set_texts "$LANG_CODE"
generate_shortcuts_text

# === 🎨 Configuración visual centralizada ===

COLOR_ACTIVE="#2ECC71"
COLOR_INACTIVE="#E74C3C"
COLOR_TEXT="#FFFFFF"
COLOR_TOOLTIP_TITLE="#FFFFFF"

ICON_ENABLED="󰖲"
ICON_DISABLED="󱂬"

TOOLTIP_FONT="Terminess Nerd Font propo"
TOOLTIP_SIZE="16000"
TOOLTIP_WEIGHT="bold"

LOCK_FILE="$HOME/.config/genmon-hide/tiling_enabled"
HIDE_FILE="$HOME/.config/genmon-hide/hidden"
mkdir -p "$(dirname "$LOCK_FILE")"

if [[ -f "$HIDE_FILE" ]]; then
    echo -e "<txt></txt>"
    echo -e "<tool></tool>"
    exit 0
fi

if pgrep -x "cortile" >/dev/null; then
    if [[ -f "$LOCK_FILE" ]]; then
        STATUS="$STATUS_DISABLE"
        TOOL_STATUS="$TOOLTIP_DISABLED"
        COLOR="$COLOR_INACTIVE"
        ICON="$ICON_DISABLED"
    else
        STATUS="$STATUS_ENABLE"
        TOOL_STATUS="$TOOLTIP_ACTIVE"
        COLOR="$COLOR_ACTIVE"
        ICON="$ICON_ENABLED"
    fi
else
    STATUS="$STATUS_OFF"
    TOOL_STATUS="$STATUS_OFF"
    COLOR="$COLOR_INACTIVE"
    ICON="$ICON_DISABLED"
fi

DISPLAY_LINE="<span font_size='18000' foreground='$COLOR'> $ICON </span><span foreground='$COLOR_TEXT'> $TOOL_STATUS </span>"

MORE_INFO="<tool>"
MORE_INFO+="<span font_family='$TOOLTIP_FONT' font_size='$TOOLTIP_SIZE' weight='$TOOLTIP_WEIGHT' foreground='$COLOR_TOOLTIP_TITLE'>$TOOLTIP_TITLE</span>\n"
MORE_INFO+="<span font_family='$TOOLTIP_FONT' font_size='$TOOLTIP_SIZE' foreground='$COLOR'>$TOOL_STATUS</span>"
MORE_INFO+="</tool>"

TOGGLE_SCRIPT="/tmp/cortile-toggle.sh"
cat << EOF > "$TOGGLE_SCRIPT"
#!/usr/bin/env bash
LOCK_FILE="$LOCK_FILE"
if [[ -f "\$LOCK_FILE" ]]; then
    rm -f "\$LOCK_FILE"
else
    touch "\$LOCK_FILE"
fi
xdotool key Control+Shift+4
EOF
chmod +x "$TOGGLE_SCRIPT"

SHORTCUTS_SCRIPT="/tmp/cortile-shortcuts.sh"
cat << EOF > "$SHORTCUTS_SCRIPT"
#!/usr/bin/env bash
yad --title="$BTN_SHORTCUTS" --width=450 --height=400 --center --text-info --fontname="Monospace 10" --fore="#FFFFFF" --back="#2C3E50" <<EOF_SHORTCUTS
$SHORTCUTS_TEXT
EOF_SHORTCUTS
EOF
chmod +x "$SHORTCUTS_SCRIPT"

ACTION="<txtclick>bash -c 'yad --title=\"$TOOLTIP_TITLE Control\" --width=400 --height=390 --form --center --scroll \
    --field=\"$BTN_ACTIVATE\":fbtn \"bash -c \\\"pgrep -x cortile >/dev/null || (cortile &); sleep 1; if [ ! -f $LOCK_FILE ]; then xdotool key Control+Shift+4; fi\\\"\" \
    --field=\"$BTN_TOGGLE\":fbtn \"bash -c \\\"$TOGGLE_SCRIPT\\\"\" \
    --field=\"$BTN_FULLSCREEN\":fbtn \"xdotool key Control+Shift+5\" \
    --field=\"$BTN_LEFT\":fbtn \"xdotool key Control+Shift+6\" \
    --field=\"$BTN_RIGHT\":fbtn \"xdotool key Control+Shift+7\" \
    --field=\"$BTN_TOP\":fbtn \"xdotool key Control+Shift+8\" \
    --field=\"$BTN_BOTTOM\":fbtn \"xdotool key Control+Shift+9\" \
    --field=\"$BTN_ADD_MASTER\":fbtn \"xdotool key Control+Shift+L\" \
    --field=\"$BTN_REMOVE_MASTER\":fbtn \"xdotool key Control+Shift+H\" \
    --field=\"$BTN_ADD_SLAVE\":fbtn \"xdotool key Control+Shift+K\" \
    --field=\"$BTN_REMOVE_SLAVE\":fbtn \"xdotool key Control+Shift+J\" \
    --field=\"$BTN_SHORTCUTS\":fbtn \"bash -c \\\"$SHORTCUTS_SCRIPT\\\"\" \
    --field=\"$BTN_EXIT\":fbtn \"xdotool key Control+Shift+0\"'</txtclick>"

echo -e "<txt>$DISPLAY_LINE</txt>"
echo -e "$ACTION"
echo -e "$MORE_INFO"
