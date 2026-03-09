# 🖥️ Lab TSSR — Centralisation & Sécurisation d'un Système d'Information

> **Contexte :** Travaux Pratiques réalisés dans le cadre de la formation **Technicien Supérieur Systèmes et Réseaux (TSSR)** — Session Été 2026.  
> Environnement 100% virtualisé (VMware / Cisco Packet Tracer).

---

## 🎯 Objectif du lab

Déployer from scratch l'infrastructure complète d'une entreprise fictive (**CreativeFusion Studios**) :
authentification centralisée, segmentation réseau, gestion de parc, automatisation et sauvegarde.

---

## 🗂️ Architecture déployée

```
[Routeur R-Principal]
        |
   [SW-Coeur] — Trunk dot1Q
   /   |   |   |   \
VLAN10 20 30 40 50   VLAN60
(RH) ...           (Serveurs)
                   /        \
         CFS-ADSRV-01     GLPI-SRV
         (Win Server 2022) (Debian 12)
         AD DS / DHCP / DNS / FTP
```

---

## ⚙️ Technologies utilisées

| Domaine | Technologies |
|---|---|
| Système | Windows Server 2022 Datacenter, Debian 12 |
| Annuaire | Active Directory Domain Services (AD DS) |
| Réseau | Cisco IOS, VLANs, Routage inter-VLAN (dot1Q), DHCP |
| Gestion de parc | GLPI, connecteur LDAP |
| Automatisation | PowerShell, GPO (Group Policy Objects) |
| Sauvegarde | FTP (IIS), SVI VLAN 60 |
| Simulation | Cisco Packet Tracer |

---

## 📋 Modules réalisés

### 1. Active Directory (AD DS)
- Installation de **Windows Server 2022** en VM
- Nommage conforme **RFC1178** → `CFS-ADSRV-01`
- Promotion en **contrôleur de domaine** d'une nouvelle forêt `CreativeFusion-Studios.eu`
- Configuration IP statique `10.0.60.1/24`

### 2. Services réseau (DHCP)
- Déploiement du rôle DHCP, autorisé dans le domaine AD
- Création de **5 étendues /24** correspondant aux VLANs services
- Configuration des options `003` (gateway), `006` (DNS), `015` (suffixe domaine)

### 3. Gestion de parc (GLPI + LDAP) — Serveur Linux Debian 12
- Déploiement d'une VM **Debian 12 en mode console (sans interface graphique)** — choix délibéré pour optimiser les ressources serveur
- Configuration IP statique `10.0.60.2/24` sur l'interface **ens33** en ligne de commande
- Validation de la connectivité réseau par **ping** vers le contrôleur de domaine `10.0.60.1` avant toute configuration applicative
- Installation et configuration de **GLPI** depuis le terminal (sans GUI)
- Connecteur LDAP configuré : annuaire `Ad CreativeFusion`, port `389`, mapping sur attribut **`samaccountname`**
- Bind LDAP via DN complet : `CN=Administrateur,CN=Users,DC=CreativeFusion-Studios,DC=eu`
- **Test de liaison validé** : message *"Test réussi : Serveur principal AD - CreativeFusion"*
- **Authentification SSO validée** : connexion de l'utilisateur `John Doe` (importé depuis l'AD) sur l'interface Self-Service GLPI

### 4. Infrastructure réseau (VLANs & routage)
- Création de **6 VLANs** (10, 20, 30, 40, 50, 60) sur SW-Coeur
- Lien **Trunk** Gigabit entre le switch et le routeur
- Sous-interfaces virtuelles avec encapsulation **dot1Q** sur R-Principal
- Passerelles en `.254` sur chaque sous-réseau
- Validation par ping inter-VLAN et consultation de la **table ARP**

### 5. Sécurité & automatisation
- Serveur **FTP (IIS)** sur CFS-ADSRV-01 avec utilisateur `backup_admin` (droits RWDNL)
- **SVI VLAN60** configurée sur le switch (`10.0.60.253`) pour les sauvegardes
- Sauvegarde validée : `copy running-config ftp:` → `[OK - 1522 bytes]`
- Script **PowerShell** `ActiveDHCP.ps1` : passage automatique en DHCP de toutes les interfaces actives
- Déploiement via **GPO Startup** liée à la racine du domaine (via SYSVOL)

---

## 📁 Contenu du repo

```
├── README.md
├── scripts/
│   └── ActiveDHCP.ps1     
├── cisco/
│   └── vlan-config.md     
└── debian/
    └── glpi-install.md    
```

---

## 💡 Points techniques notables

- **Choix de la dernière adresse disponible comme gateway** (ex: `10.0.10.254`) : convention respectée sur l'ensemble des étendues DHCP et sous-interfaces.
- **SVI dédiée sur VLAN 60** pour permettre au switch de communiquer avec le serveur FTP sans passer par un poste client.
- **Bind LDAP via compte de service** : en environnement de production, un compte dédié en lecture seule remplacerait le compte Administrateur utilisé ici.
- **FTP non chiffré** : protocole retenu pour la simulation Packet Tracer. En production, SFTP ou SCP serait privilégié.

---

## 👤 Auteur

**Jean-Paul DIJEONT**  
Support N2 en poste | En formation TSSR (cours du soir)  
Objectif : Administrateur Systèmes & Réseaux  

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Jean--Paul_DIJEONT-blue?logo=linkedin)](www.linkedin.com/in/jean-paul-dijeont)
