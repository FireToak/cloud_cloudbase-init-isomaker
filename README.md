# CLOUD - Cloudbase-Init ISO Maker

## Contexte

Ce projet fournit une solution d'automatisation PowerShell permettant de générer dynamiquement des images ISO (`ConfigDrive`) destinées au provisionnement de machines virtuelles Windows via Cloudbase-Init. Il résout la problématique de configuration initiale en injectant à la volée l'identité (nom d'hôte) et les paramètres réseau (IP, masque, passerelle, DNS) au sein de l'image, facilitant ainsi les déploiements automatisés et l'Infrastructure as Code.

-----

## Structure du dépôt

L’organisation du dépôt suit la logique suivante :

```text
.
├── ConfigDrive/
│   └── openstack/
│       └── latest/
│           ├── meta_data.json
│           └── user_data
├── isomaker.ps1
└── README.md

```

* **`ConfigDrive/`** : Répertoire contenant l'arborescence standard OpenStack requise par le lecteur de configuration Cloudbase-Init.
* **`ConfigDrive/openstack/latest/meta_data.json`** : Modèle de données définissant le nom d'hôte (`hostname`) et le mot de passe administrateur.
* **`ConfigDrive/openstack/latest/user_data`** : Script PowerShell d'amorçage chargé de désactiver le DHCP et d'appliquer la configuration IP statique lors du premier démarrage.
* **`isomaker.ps1`** : Script principal automatisant la copie des modèles, le remplacement des valeurs cibles et la compilation de l'ISO finale.

---

## Utilisation de Cloudbase-Init ISO Maker

### 1. Cloner le dépôt localement

```bash
git clone https://github.com/FireToak/cloud-cloudbase-init-isomaker.git
cd cloud-cloudbase-init-isomaker
```

### 2. Installer les prérequis

L'utilitaire `oscdimg.exe` est strictement requis pour compiler l'image ISO. Vous devez installer le **Windows ADK (Assessment and Deployment Kit)** sur votre poste de travail. Le script s'attend à trouver l'exécutable au chemin par défaut :
`C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe`

### 3. Exécuter le script de génération

Le script `isomaker.ps1` doit être exécuté en ligne de commande. Il requiert cinq paramètres obligatoires (tous de type `[string]`) pour personnaliser l'image.

| Paramètre | Type | Description |
| --- | --- | --- |
| `-NomMachine` | `string` | Nom d'hôte de la machine virtuelle ciblée. |
| `-AdresseIP` | `string` | Adresse IPv4 statique à attribuer. |
| `-Masque` | `string` | Longueur du préfixe réseau (ex : "24"). |
| `-Passerelle` | `string` | Adresse IPv4 de la passerelle par défaut. |
| `-DNS` | `string` | Adresse IPv4 du serveur DNS. |

**Exemple de commande :**

```powershell
.\isomaker.ps1 -NomMachine "SRV-WEB-01" -AdresseIP "10.0.0.15" -Masque "24" -Passerelle "10.0.0.254" -DNS "1.1.1.1"
```

*Note : L'ISO générée sera automatiquement placée à la racine du projet sous le format de nommage `cloudbase-[NomMachine]-[UUID].iso`.*

---

## 👨‍💻 Mainteneurs

* **Louis MEDO** | [LinkedIn](https://www.linkedin.com/in/louismedo/) | [Portfolio](https://louis.loutik.fr/) | [GitHub](https://github.com/FireToak) | [louis.medo@loutik.fr](mailto:louis.medo@loutik.fr)

---

<div align="center">
<br>
<small><i>Dernière mise à jour : 28 mai 2026</i></small>
</div>