#!/usr/bin/env bash
# Deps: wmctrl, xrandr, bash>=3.2

export LC_ALL=en_US.UTF-8

# === 🌐 Detectar idioma del sistema ===
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

# === 🗣️ Textos según idioma ===
set_texts() {
    case "$1" in
        es)
            LABEL_SWITCH_WINDOWS="Cambiar ventanas"
            ;;
        *)
            LABEL_SWITCH_WINDOWS="Switch windows"
            ;;
    esac
}

set_texts "$LANG_CODE"

# === 🎨 Paleta de colores ===
COLOR_BG0="#F5E0DC"
COLOR_BG1="#3B4252"
COLOR_ICON="#FFFFFF"
COLOR_TRASH_FULL="#EB9191"
COLOR_TOOLTIP_TITLE="#81A1C1"
COLOR_TOOLTIP_TEXT="#FFFFFF"

# === 🖋️ Fuente y estilo ===
FONT_MAIN="Terminess Nerd Font"
FONT_SIZE_TOOLTIP="16000"
FONT_WEIGHT="bold"

# === 📁 Rutas ===
TRASH_PATH="$HOME/.local/share/Trash/files"

# === 🧠 Estado de la papelera ===
IS_TRASH_FULL=$(if [[ -d "$TRASH_PATH" && "$(ls -A "$TRASH_PATH" 2>/dev/null)" ]]; then echo "true"; else echo "false"; fi)
PAPELERA_COLOR=$([[ "$IS_TRASH_FULL" == "true" ]] && echo "$COLOR_TRASH_FULL" || echo "$COLOR_ICON")

# === 🪟 Detectar gestor de ventanas ===
WM_NAME=$(wmctrl -m | awk -F: '/Name/ {print $2}' | xargs)

if [[ "$WM_NAME" == "fusilli" ]]; then
  VP_INFO=$(wmctrl -d | grep '\*')
  VP_POS=$(echo "$VP_INFO" | awk '{print $6}' | cut -d':' -f2)
  VP_X=$(echo "$VP_POS" | cut -d',' -f1)
  SCREEN_WIDTH=$(xrandr | grep '*' | head -n1 | awk '{print $1}' | cut -d'x' -f1)
  VP_X_END=$((VP_X + SCREEN_WIDTH))
  WINDOWS=$(wmctrl -lGx | awk -v x_start="$VP_X" -v x_end="$VP_X_END" '$3 >= x_start && $3 < x_end')
else
  CURRENT_DESKTOP=$(wmctrl -d | awk '/\*/ {print $1}')
  WINDOWS=$(wmctrl -lGx | awk -v desk="$CURRENT_DESKTOP" '$2 == desk')
fi

# === 🧩 Íconos por aplicación ===
declare -A APP_ICONS=(
  ["Firefox"]="󰖟 " ["Geany"]="󰧭 " ["Thunar"]=" " ["Terminal"]=" " ["kitty"]="󰆍 "
  ["Xfce Terminal"]=" " ["LibreOffice"]="󰈬 " ["Spotify"]="󰓇 " ["Celluloid"]=" "
  ["DeaDBeeF"]="󰎆 " ["GParted"]="󰋊 " ["Trash"]=" " ["Synaptic"]=" " ["Abiword"]="󱎒 "
  ["Gnumeric"]="󱎏 " ["guvcview"]="󰖠 " ["Mtpaint"]=" " ["PackIt"]=" " ["Gimp"]=" "
  ["Inkscape"]=" " ["Audacity"]=" " ["Cbatticon"]="󱊣 " ["Samba"]=" " ["flSynclient"]=" "
  ["Wine"]="" ["quicksetup"]=" " ["grub2config"]=" " ["UExtract"]="󰿺 " ["brave-browser"]="󰖟 "
)

# === 🧮 Contar instancias ===
declare -A APP_COUNT
APPS_OPEN=()
WINDOWS_DISPLAY=""

while read -r win_id desk x y w h wm_class win_title; do
  class_name=$(echo "$wm_class" | cut -d'.' -f2)
  for app in "${!APP_ICONS[@]}"; do
    if [[ "${class_name,,}" == "${app,,}" || "$win_title" == *"$app"* ]]; then
      ((APP_COUNT["$app"]++))
      APPS_OPEN+=("$app")
      break
    fi
  done
done <<< "$WINDOWS"

# Papelera abierta
if wmctrl -lGx | grep -iq "thunar.*trash"; then
  ((APP_COUNT["Trash"]++))
  APPS_OPEN+=("Trash")
fi

# === 🖼 Visualización en el panel ===
for app in "${!APP_COUNT[@]}"; do
  for ((i = 0; i < APP_COUNT[$app]; i++)); do
    ICON_COLOR="$COLOR_ICON"
    [[ "$app" == "Trash" ]] && ICON_COLOR="$PAPELERA_COLOR"
    WINDOWS_DISPLAY+="<span foreground='$ICON_COLOR'> ${APP_ICONS[$app]} </span>"
  done
done

[[ -z "$WINDOWS_DISPLAY" ]] && WINDOWS_DISPLAY="<span foreground='$COLOR_ICON'>  APPS </span>"

# === 🧾 Tooltip ===
MORE_INFO="<tool>"
MORE_INFO+="<span font_family='$FONT_MAIN' font_size='$FONT_SIZE_TOOLTIP' weight='$FONT_WEIGHT'>"
MORE_INFO+="<span foreground='$COLOR_TOOLTIP_TITLE'> $LABEL_SWITCH_WINDOWS</span>\n"
total_apps=${#APP_COUNT[@]}
count=0
for app in "${!APP_COUNT[@]}"; do
  ((count++))
  PREFIX="├─"
  [[ "$count" -eq "$total_apps" ]] && PREFIX="└─"
  MORE_INFO+="$PREFIX <span foreground='$COLOR_TOOLTIP_TEXT'>${APP_ICONS[$app]} $app (${APP_COUNT[$app]})</span>\n"
done
MORE_INFO+="</span></tool>"

# === 🖱️ Acción al hacer clic ===
INFO="<txt>$WINDOWS_DISPLAY</txt>"
INFO+="<txtclick>bash -c '${0%/*}/skippy-xd-wrapper'</txtclick>"

# === 📤 Salida final ===
echo -e "$INFO"
echo -e "$MORE_INFO"
