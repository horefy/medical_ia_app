# Assistant Médical Mobile avec IA (Projet L3 Informatique)

Ce document résume l'architecture technique, les choix effectués et les limites du projet pour aider à la rédaction du rapport de soutenance.

## 1. Architecture Générale

L'application suit une architecture client-serveur classique :
- **Frontend** : Flutter (Dart) avec gestion d'état via **Riverpod**.
- **Backend** : Django REST Framework (Python) avec base de données **PostgreSQL**.
- **Communication** : REST API avec authentification **JWT (JSON Web Tokens)**.

## 2. Le Moteur de Règles (Explicabilité)

Contrairement à un modèle "boîte noire", le diagnostic textuel repose sur un moteur de règles pondérées (`backend/core/engine.py`).

### Fonctionnement :
- Chaque symptôme a un poids associé pour une maladie donnée.
- Une règle de décision est déclenchée si la somme des poids dépasse un seuil (`min_weight_score`).
- **Avantage pour la soutenance** : Le système est transparent. On peut expliquer exactement pourquoi l'app recommande d'aller aux urgences (ex: cumul de "Difficulté respiratoire" et "Douleur thoracique").

## 3. Analyse Visuelle (IA Caméra)

L'analyse visuelle utilise le package `tflite_flutter` pour exécuter un modèle **TensorFlow Lite** localement sur le smartphone.

- **Modèle** : Basé sur du Transfer Learning (ex: MobileNetV2 entraîné sur des datasets dermatologiques).
- **Confidentialité** : L'image est traitée en local, elle n'est pas envoyée sur le serveur pour analyse, ce qui garantit la protection des données de santé.
- **Limitation** : L'IA détecte uniquement des signes visuels simples et ne remplace pas l'avis d'un dermatologue.

## 4. Sécurité et Éthique

- **Disclaimer** : Un message clair "Ne remplace pas une consultation médicale" est affiché sur chaque écran de résultat.
- **Authentification** : Les données de consultation sont liées à l'utilisateur via JWT.
- **Stockage** : Les tokens sont stockés de manière sécurisée via `flutter_secure_storage`.

## 5. Comment lancer le projet complet

### Backend
1. Créer la DB PostgreSQL `medical_ia_db`.
2. `cd backend && pip install -r requirements.txt`
3. `python manage.py migrate`
4. `python seed.py` (pour les données de base)
5. `python manage.py runserver`

### Frontend
1. `flutter pub get`
2. Pour l'IA, placer votre fichier `model.tflite` dans `assets/models/`.
3. `flutter run`

---
*Projet développé dans le cadre d'un cursus académique en Informatique.*
