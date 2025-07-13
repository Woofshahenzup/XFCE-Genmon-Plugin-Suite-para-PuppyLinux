#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
import os
from gi.repository import Gtk, GLib

# === 🌐 Localización personalizada ===
LANG_CODE = os.environ.get("LANG", "en").split('_')[0].lower()

def set_texts(lang):
    if lang == "es":
        return {
            "title": "Configuración del Panel",
            "close": "Cerrar",
            "System": "Sistema",
            "Network & Security": "Red y Seguridad",
            "Applications": "Aplicaciones",
            "Launchers": "Lanzadores",
            "Panel": "Panel",
            "Brightness Xrandr": "Brillo Xrandr",
            "Brightness Sct": "Brillo Sct",
            "CPU Temperature": "Temperatura CPU",
            "RAM": "RAM",
            "Storage Live mode or Pupsave": "Almacenamiento (modo live o Pupsave)",
            "Battery": "Batería",
            "CPU": "CPU",
            "Date": "Fecha",
            "Time": "Hora",
            "Volume": "Volumen",
            "Connection": "Conexión",
            "Firewall": "Cortafuegos",
            "Keyboard": "Teclado",
            "Usb devices": "Dispositivos USB",
            "Celluloid": "Celluloid",
            "DeadBeef": "DeadBeef",
            "Favorites": "Favoritos",
            "Trash": "Papelera",
            "Fusilli": "Fusilli",
            "Geany": "Geany",
            "File Manager": "Gestor de archivos",
            "Browser": "Navegador",
            "Terminal": "Terminal",
            "Whisker-menu": "Menú Whisker",
            "Bitcoin": "Bitcoin",
            "Disk (HDSentinel)": "Disco (HDSentinel)",
            "Workspaces": "Espacios de trabajo",
            "Weather": "Clima",
            "Shutdown": "Apagar"
        }
    else:
        return {
            "title": "Panel Configuration",
            "close": "Close",
            "System": "System",
            "Network & Security": "Network & Security",
            "Applications": "Applications",
            "Launchers": "Launchers",
            "Panel": "Panel",
            "Brightness Xrandr": "Brightness Xrandr",
            "Brightness Sct": "Brightness Sct",
            "CPU Temperature": "CPU Temperature",
            "RAM": "RAM",
            "Storage Live mode or Pupsave": "Storage Live mode or Pupsave",
            "Battery": "Battery",
            "CPU": "CPU",
            "Date": "Date",
            "Time": "Time",
            "Volume": "Volume",
            "Connection": "Connection",
            "Firewall": "Firewall",
            "Keyboard": "Keyboard",
            "Usb devices": "Usb devices",
            "Celluloid": "Celluloid",
            "DeadBeef": "DeadBeef",
            "Favorites": "Favorites",
            "Trash": "Trash",
            "Fusilli": "Fusilli",
            "Geany": "Geany",
            "File Manager": "File Manager",
            "Browser": "Browser",
            "Terminal": "Terminal",
            "Whisker-menu": "Whisker-menu",
            "Bitcoin": "Bitcoin",
            "Disk (HDSentinel)": "Disk (HDSentinel)",
            "Workspaces": "Workspaces",
            "Weather": "Weather",
            "Shutdown": "Shutdown"
        }

TEXTS = set_texts(LANG_CODE)

# === 📂 Rutas y mapeos ===
HIDE_DIR = os.path.expanduser("~/.config/genmon-hide")
os.makedirs(HIDE_DIR, exist_ok=True)

OCULTACION_MAP = {
    "memory.sh": "ram",
    "virtual-desktop2.sh": "desktops",
    "menu.sh": "whisker",
    "launcher_filemanager.sh": "filemanager",
    "efects.sh": "fusilli",
    "cpu-temp.sh": "cpu-temp",
    "save-space.sh": "storage",
}

MODULOS_SYSTEM = [
    ("Brightness Xrandr", "brightness"),
    ("Brightness Sct", "brightness2"),
    ("CPU Temperature", "cpu-temp.sh"),
    ("RAM", "memory.sh"),
    ("Storage Live mode or Pupsave", "save-space.sh"),
    ("Battery", "batt"),
    ("CPU", "cpu"),
    ("Date", "date"),
    ("Time", "time"),
    ("Volume", "volume"),
]

MODULOS_NETWORK_SECURITY = [
    ("Connection", "connection"),
    ("Firewall", "firewall"),
    ("Keyboard", "keyboard"),
    ("Usb devices", "usb")
]

MODULOS_APPLICATIONS = [
    ("Celluloid", "celluloid"),
    ("DeadBeef", "deadbeef"),
    ("Favorites", "favorites"),
    ("Trash", "trash"),
    ("Fusilli", "efects.sh")
]

MODULOS_LAUNCHERS = [
    ("Geany", "geany"),
    ("File Manager", "launcher_filemanager.sh"),
    ("Browser", "browser"),
    ("Terminal", "terminal")
]

MODULOS_PANEL = [
    ("Whisker-menu", "menu.sh"),
    ("Bitcoin", "btc"),
    ("Disk (HDSentinel)", "hdsentinel"),
    ("Workspaces", "virtual-desktop2.sh"),
    ("Weather", "weather"),
    ("Shutdown", "shutdown")
]

TABS = {
    "System": MODULOS_SYSTEM,
    "Network & Security": MODULOS_NETWORK_SECURITY,
    "Applications": MODULOS_APPLICATIONS,
    "Launchers": MODULOS_LAUNCHERS,
    "Panel": MODULOS_PANEL,
}

PANEL_DIR = "/root/.config/xfce4/panel"

def find_genmon_id(file_id):
    try:
        script_name_to_find = next((k for k, v in OCULTACION_MAP.items() if v == file_id), file_id)
        for filename in os.listdir(PANEL_DIR):
            if filename.startswith("genmon-") and filename.endswith(".rc"):
                path = os.path.join(PANEL_DIR, filename)
                if not os.path.exists(path):
                    continue
                with open(path, "r", encoding="utf-8") as f:
                    for line in f:
                        if line.startswith("Command=") and (script_name_to_find in line or file_id in line):
                            genmon_id = filename.split("-")[1].split(".")[0]
                            return f"genmon-{genmon_id}"
    except Exception as e:
        print(f"Error searching genmon ID para {file_id}: {e}")
    return "genmon-?"

class ConfigTab(Gtk.Box):
    def __init__(self, modulos):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.set_border_width(15)
        self.switches = {}

        for name, file_id in modulos:
            hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
            genmon_id = find_genmon_id(file_id)
            label_text = f"{TEXTS.get(name, name)} ({genmon_id})" if genmon_id else TEXTS.get(name, name)
            label = Gtk.Label(label=label_text)
            label.set_xalign(0)

            switch = Gtk.Switch()
            switch.set_active(not self.is_hidden(file_id))
            switch.connect("notify::active", self.on_switch_toggled, file_id)

            self.switches[file_id] = switch
            hbox.pack_start(label, True, True, 0)
            hbox.pack_end(switch, False, False, 0)
            self.pack_start(hbox, False, False, 0)

        GLib.timeout_add_seconds(1, self.refresh_switches)

    def file_path(self, file_id):
        ocultacion_id = OCULTACION_MAP.get(file_id, file_id)
        return os.path.join(HIDE_DIR, ocultacion_id)

    def is_hidden(self, file_id):
        return os.path.exists(self.file_path(file_id))

    def on_switch_toggled(self, switch, _param, file_id):
        path = self.file_path(file_id)
        if switch.get_active():
            if os.path.exists(path):
                os.remove(path)
        else:
            open(path, 'a').close()

    def refresh_switches(self):
        for file_id, switch in self.switches.items():
            expected_state = not self.is_hidden(file_id)
            if switch.get_active() != expected_state:
                switch.handler_block_by_func(self.on_switch_toggled)
                switch.set_active(expected_state)
                switch.handler_unblock_by_func(self.on_switch_toggled)
        return True

class MainWindow(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title=TEXTS["title"])
        self.set_default_size(450, 400)

        notebook = Gtk.Notebook()
        self.add(notebook)

        for tab_name, modules in TABS.items():
            tab = ConfigTab(modules)
            close_btn = Gtk.Button(label=TEXTS["close"])
            close_btn.connect("clicked", lambda w: Gtk.main_quit())
            tab.pack_end(close_btn, False, False, 10)
            notebook.append_page(tab, Gtk.Label(label=TEXTS.get(tab_name, tab_name)))

        self.show_all()

if __name__ == "__main__":
    win = MainWindow()
    win.connect("destroy", Gtk.main_quit)
    Gtk.main()
