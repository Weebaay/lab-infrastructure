# ==============================================================================
# ActiveDHCP.ps1
# Auteur      : Jean-Paul DIJEONT
# Formation   : TSSR - Session Été 2026
# Description : Passe toutes les interfaces réseau actives en mode DHCP
#               et réinitialise les serveurs DNS associés.
# Déploiement : GPO Startup - CreativeFusion-Studios.eu (via SYSVOL)
# ==============================================================================

# Récupération de toutes les interfaces réseau dont le statut est "Up"
$interfaces = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

# Boucle de traitement sur chaque interface active
foreach ($interface in $interfaces) {

    # Activation du mode DHCP sur l'interface
    Set-NetIPInterface -InterfaceIndex $interface.ifIndex -Dhcp Enabled

    # Réinitialisation des serveurs DNS (ils seront obtenus via DHCP)
    Set-DnsClientServerAddress -InterfaceIndex $interface.ifIndex -ResetServerAddresses

}
