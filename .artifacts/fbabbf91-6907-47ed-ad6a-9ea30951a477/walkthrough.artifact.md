# Walkthrough - Étape 1 : Backend Django

J'ai mis en place la structure complète du backend pour votre projet d'assistant médical. L'architecture est conçue pour être modulaire, explicable et facile à défendre lors de votre soutenance.

## Ce qui a été réalisé

### 1. Architecture Modulaire
- **`core/models.py`** : Définit les entités clés (Utilisateur, Symptôme, Règle de décision, Consultation).
- **`core/engine.py`** : Contient la logique du moteur de règles. Il calcule un score basé sur les poids des symptômes sélectionnés. C'est ici que réside "l'intelligence" explicable de l'application.
- **Authentification JWT** : Sécurisation des endpoints avec SimpleJWT pour permettre une connexion fluide depuis Flutter.

### 2. Moteur de Règles (Engine)
Le moteur fonctionne par agrégation de poids :
- Chaque règle (`DecisionRule`) a un seuil (`min_weight_score`).
- Chaque symptôme lié à une règle a un poids spécifique (`SymptomWeight`).
- Si la somme des poids des symptômes de l'utilisateur dépasse le seuil, la règle est activée.

### 3. API REST
Les endpoints suivants sont prêts à être consommés par Flutter :
- `POST /api/auth/register/` : Inscription
- `POST /api/auth/login/` : Connexion (retourne un token JWT)
- `GET /api/symptoms/` : Liste des symptômes disponibles
- `POST /api/consult/` : Soumission des symptômes et obtention d'une recommandation
- `GET /api/history/` : Historique des consultations de l'utilisateur

## Instructions pour finaliser l'installation

Comme je ne peux pas exécuter de base de données PostgreSQL ou de serveur Python directement, vous devez effectuer les étapes suivantes sur votre machine :

1.  **Créer la base de données** :
    ```sql
    CREATE DATABASE medical_ia_db;
    ```
    *(Assurez-vous que les identifiants dans `backend/medical_backend/settings.py` correspondent à votre configuration PostgreSQL).*

2.  **Installer les dépendances** :
    ```bash
    cd backend
    pip install -r requirements.txt
    ```

3.  **Appliquer les migrations** :
    ```bash
    python manage.py makemigrations core
    python manage.py migrate
    ```

4.  **Initialiser les données de test** :
    J'ai créé un script `seed.py` pour vous aider à commencer avec quelques symptômes et règles.
    ```bash
    python seed.py
    ```

5.  **Lancer le serveur** :
    ```bash
    python manage.py runserver
    ```

## Prochaines étapes
Une fois que le backend est fonctionnel sur votre machine, nous passerons à l'**Étape 2 : Frontend Flutter**, où nous intégrerons les appels API et créerons les écrans de diagnostic.

> [!TIP]
> Pour votre soutenance, n'oubliez pas de mentionner que le moteur de règles permet d'ajuster la sensibilité du diagnostic sans changer le code, simplement en modifiant les poids en base de données via l'interface d'administration Django (`/admin`).
