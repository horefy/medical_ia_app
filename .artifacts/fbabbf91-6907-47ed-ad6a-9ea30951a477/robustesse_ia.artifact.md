# Robustesse de l'Application (Gestion de l'IA)

L'application a été mise à jour pour fonctionner correctement même si les dépendances natives de TensorFlow Lite (comme `tensorflowlite.dll` sur Windows) sont manquantes.

## Modifications apportées

### 1. Détection de disponibilité (`AIService`)
Le service d'IA tente maintenant de charger le modèle dans un bloc `try-catch`. Si le chargement échoue (DLL manquante, plateforme non supportée), le service passe en mode `isAvailable = false`. L'application ne plante plus au démarrage ou lors de l'accès à la caméra.

### 2. Retour d'information utilisateur (`CameraScreen`)
Si l'utilisateur tente de prendre une photo pour analyse alors que l'IA n'est pas disponible :
- Une barre de notification (SnackBar) orange apparaît pour expliquer que le moteur d'IA est manquant.
- L'application reste stable et permet de revenir en arrière.

### 3. Intégration transparente (`SymptomFormScreen`)
L'analyse visuelle est traitée comme une option bonus. Si elle échoue ou est indisponible, l'utilisateur peut toujours soumettre ses symptômes textuels et obtenir son diagnostic basé sur le moteur de règles Django.

## Pourquoi ce choix pour votre soutenance ?
C'est un excellent point à mentionner : **la conception résiliente**. Vous pouvez expliquer que l'application est conçue pour dégrader ses fonctionnalités gracieusement (*graceful degradation*) :
- Sur un smartphone (Android/iOS), l'IA fonctionnera car les bibliothèques sont incluses dans l'APK/IPA.
- Sur Windows (environnement de dev), si la DLL manque, la partie "cœur" (symptômes) reste 100% fonctionnelle.
