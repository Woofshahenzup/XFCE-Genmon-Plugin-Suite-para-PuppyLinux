#!/bin/bash -x
#nilsonmorales

# 🧨 Matar Fusilli (por nombre del proceso relacionado a Desktop-Animations)
ps aux | grep 'text=Desktop-Animations' | grep -v grep | awk '{print $2}' | xargs -r kill

# 💤 Esperar un momento para que Fusilli cierre completamente
sleep 1

# 🛠 Restaurar escritorios virtuales en XFCE (asegura 4 escritorios)
xfconf-query -c xfwm4 -p /general/workspace_count -s 4

# 🔄 Reiniciar el gestor de ventanas de XFCE
xfwm4 --replace &

# 🧹 Eliminar archivo que marca inicio automático de Fusilli
rm -f /root/Startup/fusilli-al-inicio


