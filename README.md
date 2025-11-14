# Bibliothèque & Réservations - Application Flutter 2 en 1

Une application Flutter complète qui combine deux fonctionnalités principales :
1. **Gestion de Bibliothèque** - Gérer une base de données de livres avec recherche ISBN
2. **Gestion de Réservations** - Gérer des réservations de créneaux horaires

## 📋 Fonctionnalités

### 🏛️ Gestion de Bibliothèque
- ✅ **Recherche de livres par ISBN** - Récupération automatique des informations via Google Books API et Open Library
- ✅ Ajouter des livres avec titre, auteur, thématique, numéro et description
- ✅ Rechercher des livres par :
  - Auteur
  - Thématique
  - Titre
  - Numéro
  - Recherche globale (tous les critères)
- ✅ Visualiser les détails d'un livre
- ✅ Modifier un livre existant
- ✅ Supprimer un livre
- ✅ Persistance des données (SQLite sur mobile, localStorage sur web)

### 📅 Gestion de Réservations
- ✅ Créer des réservations de créneaux avec :
  - Titre
  - Date et heure de début
  - Date et heure de fin
  - Nom du réservant (optionnel)
  - Catégorie (optionnel)
  - Description (optionnel)
- ✅ Visualiser toutes les réservations
- ✅ Filtrer les réservations par période :
  - Toutes
  - Aujourd'hui
  - Cette semaine
  - Ce mois
- ✅ Détection automatique des conflits de créneaux
- ✅ Statut visuel (Terminée, En cours, À venir)
- ✅ Modifier ou supprimer une réservation
- ✅ Persistance des données (SQLite sur mobile, localStorage sur web)

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

## 🚀 Installation

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
- **path** : Gestion des chemins de fichiers
- **intl** : Formatage des dates et heures
- **provider** : Gestion d'état
- **http** : Requêtes API pour la recherche ISBN

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

## 🏗️ Structure du projet

```
lib/
├── main.dart                           # Point d'entrée de l'application
├── models/                             # Modèles de données
│   ├── livre.dart                      # Modèle Livre
│   └── reservation.dart                # Modèle Réservation
├── services/                           # Services
│   ├── database_helper.dart            # Service base de données (SQLite)
│   ├── web_storage_helper.dart         # Service stockage web (localStorage)
│   ├── reservation_service.dart        # Service pour les réservations
│   └── isbn_service.dart               # Service API ISBN
└── screens/                            # Écrans de l'application
    ├── bibliotheque_screen.dart        # Liste des livres
    ├── add_livre_screen.dart           # Ajouter/Modifier un livre avec recherche ISBN
    ├── livre_detail_screen.dart        # Détails d'un livre
    ├── reservations_screen.dart        # Liste des réservations
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
   - Les champs se remplissent automatiquement
4. **Option 2** : Remplissez manuellement les informations
5. Utilisez la barre de recherche et le filtre pour retrouver vos livres
6. Touchez un livre pour voir ses détails complets
7. Modifiez ou supprimez des livres selon vos besoins

### Réservations
1. Basculez vers l'onglet "Réservations"
2. Appuyez sur le bouton **+** pour créer une réservation
3. Définissez le titre, les dates/heures de début et fin
4. Ajoutez optionnellement un nom de réservant et une catégorie
5. Le système détecte automatiquement les conflits de créneaux
6. Utilisez les filtres pour afficher les réservations par période
7. Les réservations sont colorées selon leur statut (Terminée, En cours, À venir)

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
- ✅ **API ISBN** : Double source (Google Books + Open Library) pour meilleure fiabilité
- ✅ **Description ISBN** : Nettoyage des balises HTML et gestion des descriptions vides
- ✅ **Gestion d'erreurs** : Ajout de try-catch et messages utilisateur appropriés

### Améliorations techniques
- Detection automatique de la plateforme (web vs mobile)
- Messages de débogage pour faciliter le diagnostic
- Confirmation visuelle des opérations réussies/échouées
- Actualisation automatique des listes après modifications

## 🔄 Évolutions possibles

- Export des données en CSV/PDF
- Notifications pour les réservations à venir
- Système de catégories prédéfinies
- Statistiques et tableaux de bord
- Synchronisation cloud
- Mode sombre
- Recherche avancée avec filtres combinés
- Scanner de code-barres pour l'ISBN
- Import de données depuis fichiers

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
