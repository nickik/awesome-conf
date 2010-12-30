#!/bin/bash
################################################################
#
# checkvpn
# Ueberprueft, ob eine VPN-Verbindung besteht
#
# Copyright 2010 Emanuel Duss
# Licensed under GNU General Public License
#
# 2010-12-29; Emanuel Duss; Erste Version
#
################################################################

################################################################
# Variabeln
IP=`curl --connect-timeout 5 -s icanhazip.com`
RANGE="80.190"

################################################################
# Main

case "$IP" in
  "")
    echo -e "Offline"
    ;;
  $RANGE*)
    echo -e "VPN ($IP)"
    ;;
  *)
    echo -e "Internet ($IP)"
    ;;
esac


# EOF

