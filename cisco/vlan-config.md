# Cisco — Commandes utilisées (Lab TSSR CreativeFusion Studios)

> Environnement : **Cisco Packet Tracer**  
> Équipements : Switch **SW-Coeur** + Routeur **R-Principal**  
> Plan d'adressage : 6 VLANs sur le réseau `10.0.x.0/24`

---

## Plan d'adressage

| VLAN | Service       | Réseau          | Passerelle    | Ports SW (ex.) |
|------|---------------|-----------------|---------------|----------------|
| 10   | RH            | 10.0.10.0/24    | 10.0.10.254   | Fa0/5          |
| 20   | Comptabilité  | 10.0.20.0/24    | 10.0.20.254   | Fa0/x          |
| 30   | Informatique  | 10.0.30.0/24    | 10.0.30.254   | Fa0/x          |
| 40   | Direction     | 10.0.40.0/24    | 10.0.40.254   | Fa0/x          |
| 50   | Commercial    | 10.0.50.0/24    | 10.0.50.254   | Fa0/x          |
| 60   | Serveurs      | 10.0.60.0/24    | 10.0.60.254   | Fa0/2          |

---

## 1. Switch SW-Coeur — Création des VLANs

```
SW-Coeur> enable
SW-Coeur# configure terminal

! Création des 6 VLANs
SW-Coeur(config)# vlan 10
SW-Coeur(config-vlan)# name RH
SW-Coeur(config-vlan)# exit

SW-Coeur(config)# vlan 20
SW-Coeur(config-vlan)# name Comptabilite
SW-Coeur(config-vlan)# exit

SW-Coeur(config)# vlan 30
SW-Coeur(config-vlan)# name Informatique
SW-Coeur(config-vlan)# exit

SW-Coeur(config)# vlan 40
SW-Coeur(config-vlan)# name Direction
SW-Coeur(config-vlan)# exit

SW-Coeur(config)# vlan 50
SW-Coeur(config-vlan)# name Commercial
SW-Coeur(config-vlan)# exit

SW-Coeur(config)# vlan 60
SW-Coeur(config-vlan)# name Serveurs
SW-Coeur(config-vlan)# exit
```

---

## 2. Switch SW-Coeur — Ports Access (un exemple par VLAN)

```
! Port Fa0/5 → VLAN 10 (RH)
SW-Coeur(config)# interface fastEthernet 0/5
SW-Coeur(config-if)# switchport mode access
SW-Coeur(config-if)# switchport access vlan 10
SW-Coeur(config-if)# exit

! Port Fa0/2 → VLAN 60 (Serveurs)
SW-Coeur(config)# interface fastEthernet 0/2
SW-Coeur(config-if)# switchport mode access
SW-Coeur(config-if)# switchport access vlan 60
SW-Coeur(config-if)# exit

! (Répéter pour chaque port selon le plan d'adressage)
```

---

## 3. Switch SW-Coeur — Lien Trunk vers le routeur

```
! Port GigabitEthernet 0/1 → Trunk vers R-Principal
SW-Coeur(config)# interface gigabitEthernet 0/1
SW-Coeur(config-if)# switchport mode trunk
SW-Coeur(config-if)# exit

SW-Coeur(config)# end
SW-Coeur# write memory
```

---

## 4. Switch SW-Coeur — SVI VLAN 60 (interface de gestion)

> Nécessaire pour que le switch puisse communiquer avec le serveur FTP `10.0.60.1` (sauvegardes).

```
SW-Coeur(config)# interface vlan 60
SW-Coeur(config-if)# ip address 10.0.60.253 255.255.255.0
SW-Coeur(config-if)# no shutdown
SW-Coeur(config-if)# exit

! Passerelle par défaut du switch
SW-Coeur(config)# ip default-gateway 10.0.60.254
SW-Coeur(config)# end
SW-Coeur# write memory
```

---

## 5. Routeur R-Principal — Sous-interfaces dot1Q (Router-on-a-Stick)

```
R-Principal> enable
R-Principal# configure terminal

! Activation de l'interface physique (sans IP sur l'interface mère)
R-Principal(config)# interface gigabitEthernet 0/0
R-Principal(config-if)# no shutdown
R-Principal(config-if)# exit

! Sous-interface VLAN 10 — RH
R-Principal(config)# interface gigabitEthernet 0/0.10
R-Principal(config-subif)# encapsulation dot1Q 10
R-Principal(config-subif)# ip address 10.0.10.254 255.255.255.0
R-Principal(config-subif)# exit

! Sous-interface VLAN 20 — Comptabilité
R-Principal(config)# interface gigabitEthernet 0/0.20
R-Principal(config-subif)# encapsulation dot1Q 20
R-Principal(config-subif)# ip address 10.0.20.254 255.255.255.0
R-Principal(config-subif)# exit

! Sous-interface VLAN 30 — Informatique
R-Principal(config)# interface gigabitEthernet 0/0.30
R-Principal(config-subif)# encapsulation dot1Q 30
R-Principal(config-subif)# ip address 10.0.30.254 255.255.255.0
R-Principal(config-subif)# exit

! Sous-interface VLAN 40 — Direction
R-Principal(config)# interface gigabitEthernet 0/0.40
R-Principal(config-subif)# encapsulation dot1Q 40
R-Principal(config-subif)# ip address 10.0.40.254 255.255.255.0
R-Principal(config-subif)# exit

! Sous-interface VLAN 50 — Commercial
R-Principal(config)# interface gigabitEthernet 0/0.50
R-Principal(config-subif)# encapsulation dot1Q 50
R-Principal(config-subif)# ip address 10.0.50.254 255.255.255.0
R-Principal(config-subif)# exit

! Sous-interface VLAN 60 — Serveurs
R-Principal(config)# interface gigabitEthernet 0/0.60
R-Principal(config-subif)# encapsulation dot1Q 60
R-Principal(config-subif)# ip address 10.0.60.254 255.255.255.0
R-Principal(config-subif)# exit

R-Principal(config)# end
R-Principal# write memory
```

---

## 6. Sauvegarde de la configuration vers le serveur FTP

```
! Depuis le routeur ou le switch
R-Principal# copy running-config ftp:

! Résultat attendu : [OK - 1522 bytes]
```

---

## 7. Commandes de vérification

```
! Vérifier les VLANs et l'assignation des ports
SW-Coeur# show vlan brief

! Vérifier le lien trunk
SW-Coeur# show interfaces trunk

! Vérifier les sous-interfaces du routeur
R-Principal# show ip interface brief

! Vérifier la table ARP (preuve du routage inter-VLAN)
R-Principal# show arp

! Tester la connectivité entre VLANs
PC-RH> ping 10.0.60.1
```

---

> 💡 **Note :** Ces commandes ont été reconstituées à partir du rapport de TP.
> Les numéros de ports exacts (Fa0/x) sont à adapter selon le schéma Packet Tracer de l'Annexe 1.
