# Debian 12 — Installation GLPI + Stack LAMP (Lab TSSR CreativeFusion Studios)

> Environnement : **Debian 12 (Bookworm) en mode console — sans interface graphique**  
> Serveur : **GLPI-SRV** — IP statique `10.0.60.2/24`  
> Objectif : Déployer GLPI et le connecter à l'Active Directory via LDAP

---

## 1. Mise à jour du système

```bash
apt update && apt upgrade -y
```

---

## 2. Configuration IP statique

> Fichier : `/etc/network/interfaces`

```bash
nano /etc/network/interfaces
```

Contenu à renseigner :

```
auto ens33
iface ens33 inet static
    address 10.0.60.2
    netmask 255.255.255.0
    gateway 10.0.60.254
    dns-nameservers 10.0.60.1
```

Appliquer la configuration :

```bash
systemctl restart networking
```

Vérifier :

```bash
ip a
ping 10.0.60.1
```

> ✅ Le ping vers le contrôleur de domaine `10.0.60.1` confirme la connectivité avec l'AD.

---

## 3. Installation de la stack LAMP

### Apache

```bash
apt install apache2 -y
systemctl enable apache2
systemctl start apache2
```

### MariaDB

```bash
apt install mariadb-server -y
systemctl enable mariadb
systemctl start mariadb

# Sécurisation de l'installation
mysql_secure_installation
```

### PHP et extensions requises par GLPI

```bash
apt install php php-mysql php-xml php-curl php-gd php-mbstring \
php-intl php-ldap php-zip php-bz2 php-imap php-apcu -y
```

> 💡 L'extension **`php-ldap`** est indispensable pour la connexion GLPI ↔ Active Directory.

---

## 4. Création de la base de données MariaDB pour GLPI

```bash
mysql -u root -p
```

Dans le shell MariaDB :

```sql
CREATE DATABASE glpidb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'glpiuser'@'localhost' IDENTIFIED BY 'MotDePasseSecurise';
GRANT ALL PRIVILEGES ON glpidb.* TO 'glpiuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

## 5. Téléchargement et installation de GLPI

```bash
# Téléchargement de l'archive GLPI (exemple avec la version 10.x)
cd /tmp
wget https://github.com/glpi-project/glpi/releases/download/10.0.x/glpi-10.0.x.tgz

# Extraction dans le répertoire web Apache
tar -xzf glpi-10.0.x.tgz -C /var/www/html/

# Droits corrects pour Apache
chown -R www-data:www-data /var/www/html/glpi
chmod -R 755 /var/www/html/glpi
```

---

## 6. Configuration Apache pour GLPI

```bash
nano /etc/apache2/sites-available/glpi.conf
```

Contenu :

```apache
<VirtualHost *:80>
    ServerName glpi.creativefusion-studios.eu
    DocumentRoot /var/www/html/glpi/public

    <Directory /var/www/html/glpi/public>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

Activer le site et le module rewrite :

```bash
a2ensite glpi.conf
a2enmod rewrite
systemctl restart apache2
```

---

## 7. Finalisation de l'installation via navigateur

> Depuis un poste client, accéder à : `http://10.0.60.2/glpi`  
> Suivre l'assistant d'installation en renseignant les paramètres MariaDB :
> - Serveur : `localhost`
> - Base : `glpidb`
> - Utilisateur : `glpiuser`

---

## 8. Configuration du connecteur LDAP dans GLPI

> Menu : **Configuration → Authentification → Annuaires LDAP → Ajouter**

| Paramètre | Valeur |
|---|---|
| Nom | Ad CreativeFusion |
| Serveur | 10.0.60.1 |
| Port | 389 |
| DN de base | DC=CreativeFusion-Studios,DC=eu |
| Compte de bind | CN=Administrateur,CN=Users,DC=CreativeFusion-Studios,DC=eu |
| Champ identifiant | samaccountname |

Tester la liaison → message attendu : **"Test réussi : Serveur principal AD - CreativeFusion"**

---

## 9. Commandes de vérification utiles

```bash
# Vérifier les services actifs
systemctl status apache2
systemctl status mariadb

# Vérifier l'IP de l'interface ens33
ip a show ens33

# Tester la résolution DNS vers le domaine AD
ping creativefusion-studios.eu

# Vérifier les logs Apache en cas d'erreur
tail -f /var/log/apache2/error.log
```

---

> 💡 **Note :** Les commandes ont été reconstituées à partir du rapport de TP.  
> Les numéros de version GLPI et certains détails (mot de passe MariaDB, nom VirtualHost)  
> sont à adapter à votre environnement réel.
