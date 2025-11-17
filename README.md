# Bibliothèque & Réservations - Application Flutter 2 en 1

Une application Flutter complète qui combine deux fonctionnalités principales :
1. **Gestion de Bibliothèque** - Gérer une base de données de livres avec recherche ISBN
2. **Gestion de Réservations** - Gérer des réservations de créneaux horaires

## 📋 Fonctionnalités

### 🏛️ Gestion de Bibliothèque
- ✅ **Recherche de livres par ISBN** - Récupération automatique des informations via Google Books API et Open Library
- ✅ **Affichage des couvertures** - Images de livres récupérées automatiquement
- ✅ **Statut de disponibilité** - Affichage si un livre est disponible ou réservé
- ✅ Ajouter des livres avec titre, auteur, thématique, numéro et description
- ✅ Rechercher des livres par :
  - Auteur
  - Thématique
  - Titre
  - Numéro
  - Recherche globale (tous les critères)
- ✅ Visualiser les détails d'un livre avec :
  - Couverture du livre
  - Informations complètes
  - Statut de disponibilité en temps réel
  - Date de prochaine disponibilité si réservé
- ✅ **Réserver directement depuis la bibliothèque**
- ✅ Modifier un livre existant
- ✅ Supprimer un livre
- ✅ **Import/Export des livres** au format JSON
- ✅ Persistance des données (SQLite sur mobile/desktop, localStorage sur web)

### 📅 Gestion de Réservations
- ✅ Créer des réservations de créneaux avec :
  - Titre
  - Date et heure de début
  - Date et heure de fin
  - Nom du réservant (optionnel)
  - Catégorie (optionnel)
  - Description (optionnel)
- ✅ **Réservation pré-remplie** depuis la page d'un livre
- ✅ Visualiser toutes les réservations
- ✅ Filtrer les réservations par période :
  - Toutes
  - Aujourd'hui
  - Cette semaine
  - Ce mois
- ✅ Détection automatique des conflits de créneaux
- ✅ Statut visuel (Terminée, En cours, À venir)
- ✅ Modifier ou supprimer une réservation
- ✅ **Import/Export des réservations** au format JSON
- ✅ **Export complet** (livres + réservations)
- ✅ Persistance des données (SQLite sur mobile/desktop, localStorage sur web)

## 🌐 Support Multi-plateforme

Cette application fonctionne sur :
- **Web** (Chrome, Firefox, Edge, Safari)
- **Android**
- **iOS**
- **Windows** (avec Visual Studio installé)
- **macOS**
- **Linux**

### 🔑 Particularités Web
L'application utilise un système de stockage adaptatif :
- **Sur web** : Les données sont stockées dans le localStorage du navigateur
- **Sur mobile/desktop** : Les données utilisent SQLite

## 📥 Installation depuis le package Debian (Linux)

Pour les utilisateurs Linux, un package `.deb` pré-compilé est disponible :

```bash
# Télécharger le package (version 1.0.3)
# Disponible dans les releases GitHub

# Installer le package
sudo dpkg -i bibliotheque-app_1.0.3_amd64.deb

# Lancer l'application
/usr/local/bin/bibliotheque_app
# Ou cherchez "Bibliothèque App" dans votre menu d'applications
```

### Dépendances système requises
- libgtk-3-0
- libblkid1
- liblzma5
- libsqlite3-0

Ces dépendances sont automatiquement installées avec le package.

---

## 🚀 Installation depuis les sources

### Prérequis
- Flutter SDK (>=2.19.0 <3.0.0)
- Dart SDK
- Pour le web : Un navigateur moderne (Chrome recommandé)
- Pour Windows : Visual Studio avec les outils de développement C++
- Pour mobile : Un émulateur Android/iOS ou un appareil physique

### Étapes d'installation

1. **Cloner ou naviguer dans le dossier du projet** :
   ```bash
   cd C:\flutter_bibliotheque_app
   ```

2. **Installer les dépendances** :
   ```bash
   flutter pub get
   ```

3. **Vérifier que Flutter est correctement configuré** :
   ```bash
   flutter doctor
   ```

4. **Lancer l'application** :
   
   - **Sur le web** :
     ```bash
     flutter run -d chrome
     ```
   
   - **Sur mobile** :
     ```bash
     flutter run
     ```
   
   - **Sur Windows** :
     ```bash
     flutter run -d windows
     ```

## 📦 Dépendances

- **sqflite** : Base de données SQLite locale (mobile/desktop)
- **sqflite_common_ffi** : Support FFI pour SQLite sur desktop
- **path** : Gestion des chemins de fichiers
- **path_provider** : Accès aux répertoires système
- **intl** : Formatage des dates et heures
- **provider** : Gestion d'état
- **http** : Requêtes API pour la recherche ISBN
- **file_picker** : Sélection de fichiers pour import/export

## 🔍 Fonctionnalité Recherche ISBN

La recherche par ISBN permet de remplir automatiquement les informations d'un livre :

1. Dans l'écran d'ajout de livre, entrez un ISBN (ex: `9782253006329`)
2. Cliquez sur le bouton "Rechercher"
3. Les informations sont récupérées depuis :
   - **Google Books API** (prioritaire) - meilleure couverture
   - **Open Library API** (alternative) - si Google Books ne trouve pas

Les données récupérées incluent :
- Titre du livre
- Auteur(s)
- Thématique/Catégories
- Description (nettoyée des balises HTML)
- **Image de couverture** (affichée dans la liste et les détails)

## 📤 Import/Export de données

L'application permet d'importer et exporter vos données au format JSON :

### Export
- **Depuis la bibliothèque** (menu ⋮) :
  - Exporter tous les livres
- **Depuis les réservations** (menu ⋮) :
  - Exporter toutes les réservations
  - **Export complet** : livres + réservations dans un seul fichier

Les fichiers sont sauvegardés dans le dossier Téléchargements avec un nom horodaté.

### Import
- **Importer des livres** : Sélectionnez un fichier JSON d'export de livres
- **Importer des réservations** : Sélectionnez un fichier JSON d'export de réservations
- **Import complet** : Restaurez livres et réservations depuis un export complet

L'import ajoute les données sans écraser l'existant.

## 🏗️ Structure du projet

```
lib/
├── main.dart                           # Point d'entrée de l'application
├── models/                             # Modèles de données
│   ├── livre.dart                      # Modèle Livre (avec coverUrl)
│   └── reservation.dart                # Modèle Réservation
├── services/                           # Services
│   ├── database_helper.dart            # Service base de données (SQLite)
│   ├── web_storage_helper_web.dart     # Service stockage web (localStorage)
│   ├── web_storage_helper_stub.dart    # Stub pour plateformes non-web
│   ├── sqflite_init_desktop.dart       # Initialisation SQLite FFI (desktop)
│   ├── sqflite_init_mobile.dart        # Initialisation SQLite (mobile)
│   ├── reservation_service.dart        # Service pour les réservations
│   ├── isbn_service.dart               # Service API ISBN
│   └── import_export_service.dart      # Service import/export JSON
└── screens/                            # Écrans de l'application
    ├── bibliotheque_screen.dart        # Liste des livres avec import/export
    ├── add_livre_screen.dart           # Ajouter/Modifier un livre avec recherche ISBN
    ├── livre_detail_screen.dart        # Détails d'un livre avec statut disponibilité
    ├── reservations_screen.dart        # Liste des réservations avec import/export
    ├── add_reservation_screen.dart     # Ajouter/Modifier une réservation
    └── reservation_detail_screen.dart  # Détails d'une réservation
```

## 💡 Utilisation

### Bibliothèque
1. Lancez l'application et restez sur l'onglet "Bibliothèque"
2. Appuyez sur le bouton **+** pour ajouter un livre
3. **Option 1** : Recherchez par ISBN pour remplissage automatique
   - Entrez un code ISBN dans le champ dédié
   - Cliquez sur "Rechercher"
   - Les champs se remplissent automatiquement avec la couverture
4. **Option 2** : Remplissez manuellement les informations
5. Utilisez la barre de recherche et le filtre pour retrouver vos livres
6. Touchez un livre pour voir ses détails complets :
   - Couverture du livre
   - Informations bibliographiques
   - **Statut de disponibilité** (Disponible/Indisponible)
   - Si indisponible : qui l'a réservé et jusqu'à quand
   - Date de prochaine disponibilité
7. Depuis la liste, utilisez le menu (⋮) sur chaque livre pour :
   - **Réserver le livre** directement
   - Supprimer le livre
8. Menu général (⋮) en haut :
   - **Exporter les livres** en JSON
   - **Importer des livres** depuis JSON

### Réservations
1. Basculez vers l'onglet "Réservations"
2. **Option 1** : Créer une réservation depuis un livre
   - Allez dans la bibliothèque
   - Ouvrez les détails d'un livre
   - Cliquez sur "Réserver ce livre"
   - Le formulaire est pré-rempli avec les infos du livre
3. **Option 2** : Créer une réservation manuelle
   - Appuyez sur le bouton **+**
   - Remplissez les informations
4. Définissez le titre, les dates/heures de début et fin
5. Ajoutez optionnellement un nom de réservant et une catégorie
6. Le système détecte automatiquement les conflits de créneaux
7. Utilisez les filtres pour afficher les réservations par période
8. Les réservations sont colorées selon leur statut (Terminée, En cours, À venir)
9. Menu général (⋮) en haut :
   - **Exporter les réservations** en JSON
   - **Importer des réservations** depuis JSON
   - **Exporter tout** (livres + réservations)
   - **Importer tout**

## 🎨 Personnalisation

L'application utilise un thème cohérent avec :
- **Bleu** pour la section Bibliothèque
- **Vert** pour la section Réservations
- Interface Material Design moderne
- Navigation par onglets en bas de l'écran
- Interface responsive adaptée au web et mobile

## 📝 Stockage des données

### Sur Web
- Les données sont stockées dans le **localStorage** du navigateur
- Persistance automatique des livres et réservations
- Pas de limite de stockage significative pour ce type d'application
- Les données restent même après fermeture du navigateur

### Sur Mobile/Desktop
- Utilisation de **SQLite** pour un stockage local robuste
- Tables `livres` et `reservations`
- Les données persistent même après la fermeture de l'application
- Performances optimales pour de grandes quantités de données

## 🔧 Corrections et Améliorations

### Problèmes résolus
- ✅ **Erreur CardTheme** : Remplacé `CardTheme` par `CardThemeData` pour compatibilité
- ✅ **Support Web SQLite** : Implémentation d'un système de stockage adaptatif (localStorage pour web)
- ✅ **Support Desktop SQLite** : Utilisation de sqflite_common_ffi avec initialisation conditionnelle
- ✅ **API ISBN** : Double source (Google Books + Open Library) pour meilleure fiabilité
- ✅ **Description ISBN** : Nettoyage des balises HTML et gestion des descriptions vides
- ✅ **Images de couverture** : Récupération et affichage automatique des couvertures de livres
- ✅ **Migration base de données** : Ajout de la colonne coverUrl (version 2)
- ✅ **Contexte asynchrone** : Ajout de vérifications `context.mounted` pour éviter les crashes
- ✅ **Gestion d'erreurs** : Ajout de try-catch et messages utilisateur appropriés

### Améliorations techniques
- Detection automatique de la plateforme (web vs mobile vs desktop)
- Compilation conditionnelle pour éviter les imports incompatibles
- Initialisation SQLite FFI sur Linux/Windows/macOS
- Messages de débogage pour faciliter le diagnostic
- Confirmation visuelle des opérations réussies/échouées
- Actualisation automatique des listes après modifications
- Système d'import/export avec format JSON structuré
- Vérification de disponibilité en temps réel basée sur les réservations actives

### Nouvelles fonctionnalités (v1.0.3)
- 📸 **Affichage des couvertures de livres**
- 🔄 **Statut de disponibilité des livres** en temps réel
- 📅 **Date de prochaine disponibilité** pour les livres réservés
- 🔗 **Réservation directe** depuis la page d'un livre
- 📤📥 **Import/Export complet** des données au format JSON
- 🖥️ **Support desktop** amélioré (Linux, Windows, macOS)

## 🔄 Évolutions possibles

- Gestion des emprunts et retours de livres
- Notifications pour les réservations à venir
- Système de catégories prédéfinies
- Statistiques et tableaux de bord
- Synchronisation cloud
- Mode sombre
- Recherche avancée avec filtres combinés
- Scanner de code-barres pour l'ISBN
- Historique des réservations par livre
- Système de notes et commentaires sur les livres
- Rappels automatiques avant la fin d'une réservation

## 🐛 Débogage

En cas de problème :

1. **Sur Web** : Ouvrez la console développeur (F12) pour voir les logs
2. **Vérifiez les données** : 
   - Sur Web : Inspectez le localStorage dans les DevTools
   - Sur Mobile : Utilisez les outils de débogage Flutter
3. **Effacer les données** :
   - Web : Vider le cache du navigateur
   - Mobile : Désinstaller et réinstaller l'application

## 📄 Licence

Ce projet est un exemple d'application Flutter et peut être librement utilisé et modifié.

---

Développé avec ❤️ en Flutter
