# 🐾 XFCE Genmon Plugin Suite for Puppy Linux

📗 [Versión en español](README.md)

A modular collection of scripts designed for the Genmon plugin in XFCE, allowing you to 
build **fully functional panels exclusively with scripts**, without the need for additional applets. 
This suite is optimized for Puppy Linux and integrates directly into its filesystem.

🔗 **Official Genmon plugin reference:**  
[docs.xfce.org → xfce4-genmon-plugin](https://docs.xfce.org/panel-plugins/xfce4-genmon-plugin/start)

![Panel](images/panels.png)

---

## 🧩 What does this suite include?

- 🖥️ Complete panels with:
  - Main menu  
  - Application launchers  
  - Virtual desktops  
  - Open windows  
- 📊 Monitors:
  - CPU, RAM, network, volume  
  - Current weather status  
  - Real-time Bitcoin price  
- ⚙️ Configuration tools:
  - Enable/disable scripts  
  - Conditional hiding  
  - Visual customization  

---

## 🧭 Compatibility and Recommendations for Puppy Linux and Mainstream Linux Users

These scripts are designed to integrate with the XFCE environment and the Genmon plugin, offering a rich visual experience with system information, weather, devices, and more. While they work well on mainstream Linux distributions, they have been specially tested and optimized for Puppy Linux, proving that even on lightweight systems, a functional and attractive interface can be achieved.

### 🐾 Puppy Linux Users

Puppy Linux is a nimble, efficient, and surprisingly capable distribution. Despite its minimalist approach, you can run these scripts without any issues, as long as you keep the following in mind:

### ✅ Advantages

Fast boot and low power consumption: Puppy allows you to run these scripts without overloading the system, ideal for computers with limited resources.
Adaptable Environment: Although Puppy doesn't always include XFCE by default, it can be easily installed alongside Genmon to take advantage of its full functionality. Optional Persistence: Using Pupsave or frugal mode, configuration files like ~/.config/genmon-hide are persisted between sessions.

### ⚠️ Recommendations

Install minimal dependencies if not present:
curl jq yad wmctrl amixer pavucontrol pmount

## 🖥️ Mainstream Linux Users

On distributions like Debian, Ubuntu, Arch, Fedora, etc., these scripts
work more predictably, especially if using XFCE with Genmon.

### ✅ Recommended Requirements

XFCE environment with the Genmon plugin enabled.
Python 3 + PyGObject to run config-panel.py.
Nerd Font installed for visual icons.
Check deps  [Deps-per-scrit](./DEPS-PER-SCRIPT.txt)
## ⚠️ Considerations

Dependencies not always pre-installed. Some distros do not include tools such as jq, yad, pmount, or pavucontrol by default. You must install them manually.
Varied environments. If you don't use XFCE, you'll need to adapt some scripts that depend on Genmon or environment-specific tools.
More complex configuration. Unlike Puppy, which typically has a single-user structure, conventional distros may require per-user settings, permissions, or specific paths.

### ✅ Recommendations

Make sure you have XFCE installed with the Genmon plugin.
Install the necessary dependencies:
sudo apt install curl jq yad wmctrl amixer pavucontrol pmount or
use its equivalent on your system.

Verify that the scripts have access to paths such as ~/.config/xfce4/panel and ~/.config/genmon-hide.

### 🧠 Conclusion

These scripts have proven to be versatile, modular, and efficient,
both on lightweight systems like Puppy Linux and on conventional distributions.
While each environment has its own specificities, with minimal configuration,
it's possible to enjoy an informative, aesthetic, and functional interface.
The key is to adapt the modules to your workflow and graphical environment.

---

## 📂 System structure

The suite is organized to integrate directly into Puppy Linux's filesystem:

```bash
XFCE-Genmon-Plugin-Suite-for-PuppyLinux/
├── root/
│   └── .config/
│       ├── genmon-scripts/
│       │   └── simple/
│       │       ├── cpu.sh
│       │       ├── weather.sh
│       │       ├── btc.sh
│       │       └── ... (more scripts)
│       └── genmon-hide/
│           ├── .toggle_state
│           ├── .toggle_state_weather
│           ├── fusilli
│           └── ... (hide control files)
├── usr/
│   ├── bin/
│   │   └── skippy-xd
│   └── local/
│       └── bin/
│           ├── panel-config.py
│           ├── shutdown-gui
│           └── battery-notifier.sh
```
## ⚙️ Technical details
## 🌐 Automatic localization

Scripts detect the system language using the $LANG environment variable and dynamically 
adapt displayed text:
```bash
LANG_CODE=$(echo "$LANG" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')

set_tooltip_text() {
    case "$1" in
        es) TOOLTIP_TEXT="Haz clic para abrir\nla terminal";;
        *)  TOOLTIP_TEXT="Click to open\nthe terminal";;
    esac
}
set_tooltip_text "$LANG_CODE"
```
---
## 🙈 Conditional hiding (file-based)

Each module can be hidden if a specific file exists in ~/.config/genmon-hide/. For example, 
to hide the terminal icon:
```bash
HIDE_FILE_TERMINAL="$HOME/.config/genmon-hide/terminal"

if [ -f "$HIDE_FILE_TERMINAL" ]; then
    echo -e "<txt></txt>\n<tool></tool>"
    exit 0
fi
```
---
Simply create or delete the file ~/.config/genmon-hide/terminal to hide or 
show the module—no panel restart required

## 💡 Notes

    ✅ Fully compatible with XFCE on Puppy Linux distributions

    🔒 No root privileges required for most functions

    🧩 Modular: easily enable or disable any component
---   
## 🛠️ XFCE Panel Configuration with Genmon

This Python script (/usr/local/bin/panel-config.py) provides a graphical interface to manage XFCE panel modules that
use the Genmon plugin. It allows you to visually enable or disable components 
like brightness, CPU temperature, RAM, battery, network connection, favorite apps, 
launchers, and more.
### ✨ Features

   -  **GTK3**-based graphical interface
   -   Multilingual support: Spanish and English
   -   Organized into tabs:
   -   System
   -   Network & Security        
   -   Applications
   -   Launchers
   -   Panel

Toggles modules by creating/removing files in `~/.config/genmon-hide`
Automatically detects Genmon IDs from XFCE panel configuration (`~/.config/xfce4/panel`)

![Panel-config](https://raw.githubusercontent.com/Woofshahenzup/XFCE-Genmon-Plugin-Suite-para-PuppyLinux/main/images/panel-config.png)

![Preferencias del panel](https://raw.githubusercontent.com/Woofshahenzup/XFCE-Genmon-Plugin-Suite-para-PuppyLinux/main/images/preferencias.png)
---
## 🪟 Open Windows Viewer

This Bash script (open-windows.sh) located in /root/.config/genmon-scripts/ dynamically
 displays open windows on the current desktop or visible region (Fusilli window manager). 
 It uses custom icons to represent each open application and launches a visual 
 window selector (skippy-xd) on click.
### ✨ Features

  -  Auto-detects system language ($LANG) for localized tooltips
  -  Supports multiple window managers: XFCE and Fusilli
  -  Displays icons per application using Nerd Font
  -  Detects multiple instances of the same app
  -  Special indicator if the trash is full
  -  Tooltip with app list and instance count
  -  Click action: runs skippy-xd-wrapper to switch windows

### 🧩 Dependencies

   - wmctrl
   - xrandr
   - Bash ≥ 3.2
   - Recommended font: Terminess Nerd Font
   - skippy-xd    

### 🖼️ Example output on the panel
```bash
<txt>󰖟  󰧭    </txt>
<tool>
 Switch windows
├─ 󰖟 Firefox (1)
├─  Thunar (2)
└─  Terminal (1)
</tool>
```
## 🧭 What is Skippy-XD?

Skippy-XD is a full-screen task switcher for X11 systems, inspired by macOS's Exposé effect. 
When activated, it shows live thumbnails of all open windows on the current desktop, allowing 
fast switching via mouse or keyboard.
### ✨ Key features

   - Live, updated view of all open windows
   - Compatible with lightweight environments like XFCE, LXDE, Openbox
   - Lightweight, fast, and highly configurable
   - Can be triggered via tools like Brightside using active screen corners
--- 
## 🎛️ Toggles ("Tirantes")

This script acts as a visual toggle in the XFCE panel: when clicked, it hides or shows multiple Genmon modules at once, simulating a dropdown effect. Perfect for keeping the panel clean and showing only essential elements when needed.
### ✨ Features

  -  Toggles multiple modules (storage, volume, batt, usb, connection) with a single click
  -  Uses visual icons (, ) to indicate visibility state
  -  Stores current state in ~/.config/genmon-hide/.toggle_state
  -  Multilingual tooltip support
  -  Genmon-compatible output: <txt>, <tool>, <txtclick>

### ⚙️ Technical detail

The script works by creating or deleting empty files in ~/.config/genmon-hide/. 
Each Genmon module checks for its corresponding file to decide whether to show or hide. 
When run with the toggle parameter, it switches the global state (visible ↔ hidden) 
and updates all control files.

    📌 Ideal for dynamic panels where modules “drop down” when interacting with the toggle. 
```bash
# Read toggle status
if [ -f "$TOGGLE_STATE_FILE" ]; then 
TOGGLE_STATE=$(cat "$TOGGLE_STATE_FILE")
else 
TOGGLE_STATE="hidden"
fi

# Toggle general status
if [[ "$1" == "toggle" ]]; then 
if [[ "$TOGGLE_STATE" == "hidden" ]]; then 
TOGGLE_STATE="visible" 
for FILE in "${FILES[@]}"; do 
FILE_PATH="$HOME/.config/genmon-hide/$FILE" 
if [ -f "$FILE_PATH" ]; then 
rm "$FILE_PATH" 
fi 
donated 
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
```
---

![TOGGLE](https://i.postimg.cc/SKQyCNch/animated2.gif)

## 🛠️ Custom Layouts with Genmon: Unlimited Creativity!

Genmon isn't just for displaying text in the XFCE panel: it also lets you
create highly customized visual widgets using ASCII code, decorative segments, and
Pango tags to apply styles like colors, fonts, sizes, and more.

### 🎨 What can you do?

With Genmon, you can build widgets similar to Conky's, but with additional benefits such as:

- <txtclick>: Execute commands on click.
- <tool>: Display additional information on hover (tooltip).
- Pango Styles: Use tags like <span> to change colors, fonts, sizes, weight, etc.
- ASCII Decoration: Add borders, boxes, lines, and symbols for visual style.
- Dynamic Segments: Display information that changes in real time (battery status, trash, network, etc.).

### 📦 Example: Trash Widget

This script displays the status of the trash (empty or full) with an icon, dynamic colors, decorative borders, and interactive actions:
```bash
#!/usr/bin/env bash

# Icon and colors
ICON_TRASH="󰩺"
COLOR_EMPTY="#2ECC71"
COLOR_FULL="#95A5A6"
TRASH_PATH="$HOME/.local/share/Trash/files"

# Check if there are files in the trash
if [[ -d "$TRASH_PATH" && "$(ls -A "$TRASH_PATH")" ]]; then 
TRASH_STATUS="Full" 
COLOR="$COLOR_FULL"
else 
TRASH_STATUS="Empty" 
COLOR="$COLOR_EMPTY"
fi

# Main line with color and icon
DISPLAY_LINE="<span foreground='$COLOR'>$ICON_TRASH Trash</span>"

# Decorative borders
WIDTH=${#DISPLAY_LINE}
TOP="╭──────╮"
MID="<span foreground='#35C5B9'>│ $DISPLAY_LINE │</span>"
BOTTOM="╰──────╯"

# Output for Genmon
echo -e "<txt><span foreground='#ADD387'>$TOP</span>\n$MID\n<span foreground='#ADD387'>$BOTTOM</span></txt>"
echo -e "<tool><span font_family='Terminess Nerd Font' font_size='16000' weight='bold'>Trash status: $TRASH_STATUS\nClick to open the trash folder.</span></tool>"
echo -e "<txtclick>exo-open --launch FileManager trash:///</txtclick>"
```
Result:

![Trash Widget in XFCE](https://i.postimg.cc/kXLvdcv1/Screenshot-2025-05-01-02-59-17.png)

## 🛠️ What can you customize? 

- Visual design with borders, icons, and colors.
- Typographic styling with <span> tags using Pango.
- Direct interaction with clicks and tooltips.
- Conky-like widgets, but integrated into the XFCE panel.
---

![STYLES](https://i.postimg.cc/QMwxK0w7/cpuram.gif)

---
## 🌦️ Genmon Weather Scripts (Bash + Nerd Fonts + wttr.in and Openweather)
This script is designed to integrate with the Genmon plugin in panel environments
 such as XFCE or GNOME, displaying the current weather in your taskbar 
 with stylized icons thanks to Nerd Fonts. I will try to explain it in more detail.

### 📌 What does this script do?
  - Gets the weather for your city using the wttr.in public API.
  - Displays the current, maximum, and minimum temperatures for the day.
  - Includes wind and humidity information.
  - Automatically changes the weather icon based on the weather (sun, rain, fog, snow, etc.).
  - Automatically updates every 5 minutes (thanks to a caching system).
  - Supports languages: currently Spanish (es) and English (by default).
  - Uses Nerd Fonts to display beautiful, custom icons.
  - Clicking on the icon, you can easily change the city using
  a graphical dialog (yad).

### 📌 How does it work on a technical level?
  - Use curl to get JSON data from wttr.in.
  - Parse the data using jq.
  - Save the result to a temporary file (/tmp) to avoid unnecessary queries.
  - Translate weather descriptions into your local language based on the $LANG environment variable.
  - Save the current city to ~/.config/genmon-weather-city.txt.
  - Weather icons like ☀️ or 🌧️ are converted to Nerd Fonts-compatible glyphs for consistent display.

### 📸 Example script output (text mode)
```xml
<txt> 󰖔 Clear 25°C </txt> The Panel

<tootip> San Salvador, El Salvador 
────────────────────────── 
              󰖔 25°C 
────────────────────────── 
      Max 30°C /  Min 20°C 
     Vto 4 km/h /  Hum 89%
──────────────────────────────
      Wed 24 °C  Sunny
      Thu 24 °C  Sunny
      Fri 24 °C  Sunny </tooltip>
---
