# 🐾 XFCE Genmon Plugin Suite para Puppy Linux

Una colección modular de scripts diseñados para el plugin Genmon en XFCE, que permite construir **paneles completos exclusivamente con scripts**, sin necesidad de applets adicionales. Esta suite está optimizada para Puppy Linux y se integra directamente en su sistema de archivos.

🔗 **Referencia oficial del plugin Genmon:**  
[docs.xfce.org → xfce4-genmon-plugin](https://docs.xfce.org/panel-plugins/xfce4-genmon-plugin/start)

![Panel](images/panels.png)

---

## 🧩 ¿Qué incluye esta suite?

- 🖥️ Paneles completos con:
  - Menú principal  
  - Lanzadores de aplicaciones  
  - Escritorios virtuales  
  - Ventanas abiertas  
- 📊 Monitores:
  - CPU, RAM, red, volumen  
  - Estado del clima actual  
  - Precio de Bitcoin en tiempo real  
- ⚙️ Herramientas de configuración:
  - Activación/desactivación de scripts  
  - Ocultación condicional  
  - Personalización visual  

---

## 📂 Estructura del sistema

La suite está organizada para integrarse directamente en el sistema de archivos de Puppy Linux:

```bash
XFCE-Genmon-Plugin-Suite-para-PuppyLinux/
├── root/
│   └── .config/
│       ├── genmon-scripts/
│       │   └── simple/
│       │       ├── cpu.sh
│       │       ├── weather.sh
│       │       ├── btc.sh
│       │       └── ... (más scripts)
│       └── genmon-hide/
│           ├── .toggle_state
│           ├── .toggle_state_weather
│           ├── fusilli
│           └── ... (archivos de ocultación)
├── usr/
│   ├── bin/
│   │   └── skippy-xd
│   └── local/
│       └── bin/
│           ├── panel-config.py
│           ├── shutdown-gui
│           └── notificador-bateria.sh
```
---

## ⚙️ Detalles técnicos

### 🌐 Localización automática

Los scripts detectan el idioma del sistema mediante la variable de entorno `$LANG`, 
y adaptan dinámicamente el texto mostrado:

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

## 🙈 Ocultación condicional (basada en archivo)

Cada módulo puede ocultarse si existe un archivo específico en ~/.config/genmon-hide/. 
Por ejemplo, para ocultar el icono del terminal:
HIDE_FILE_TERMINAL="$HOME/.config/genmon-hide/terminal"

```bash

if [ -f "$HIDE_FILE_TERMINAL" ]; then
    echo -e "<txt></txt>\n<tool></tool>"
    exit 0
fi
```
---

De este modo, basta con crear (o eliminar) el archivo ~/config/genmon-hide/terminal para que el 
módulo se oculte o reaparezca, sin reiniciar el panel.
## 💡 Notas

    Totalmente compatible con XFCE en distribuciones Puppy Linux.

    No requiere privilegios root para la mayoría de funciones.

    Modular: puedes activar o desactivar cualquier componente fácilmente.
---
## 🛠️ Configuración del Panel XFCE con Genmon

Este script en Python proporciona una interfaz gráfica para gestionar los módulos del panel
 XFCE que utilizan el plugin Genmon. Permite activar o desactivar visualmente componentes como 
 brillo, temperatura de CPU, RAM, batería, conexión de red, aplicaciones favoritas, lanzadores y más.

### ✨ Características

- Interfaz gráfica basada en **GTK3**
- Soporte multilingüe: **Español** e **Inglés**
- Organización por pestañas:
  - **Sistema**
  - **Red y Seguridad**
  - **Aplicaciones**
  - **Lanzadores**
  - **Panel**
- Conmutadores para ocultar o mostrar módulos mediante archivos en `~/.config/genmon-hide`
- Detección automática del ID de Genmon en la configuración del panel XFCE (`~/.config/xfce4/panel`)

![Panel-config](https://github.com/Woofshahenzup/XFCE-Genmon-Plugin-Suite-para-PuppyLinux/tree/main/images/panel-config.png)
![Preferencias del panel](https://github.com/Woofshahenzup/XFCE-Genmon-Plugin-Suite-para-PuppyLinux/tree/main/images/preferencias.png)
