# Guide de déploiement Sanity Studio sur VPS via Dokploy

Ce guide vous accompagne pas à pas pour déployer votre Sanity Studio sur votre VPS en utilisant Dokploy.

## Prérequis

- Un VPS avec Dokploy installé
- Un compte Sanity.io avec un projet créé
- Git installé sur votre machine locale
- Un dépôt Git (GitHub, GitLab, Bitbucket, etc.)

## Configuration du projet

### 1. Variables d'environnement nécessaires

Votre Sanity Studio nécessite les variables d'environnement suivantes :

- `SANITY_STUDIO_PROJECT_ID` : L'ID de votre projet Sanity (trouvable dans votre dashboard Sanity)
- `SANITY_STUDIO_DATASET` : Le nom de votre dataset (par défaut : `portfolio`)

Pour obtenir votre Project ID :
1. Connectez-vous à [sanity.io/manage](https://sanity.io/manage)
2. Sélectionnez votre projet
3. Copiez le Project ID visible dans l'URL ou dans les paramètres du projet

### 2. Structure des fichiers de déploiement

Le projet contient maintenant :
- `Dockerfile` : Configuration Docker pour le build et l'exécution
- `.dockerignore` : Fichiers à exclure du build Docker
- `.env.example` : Template des variables d'environnement

## Déploiement sur Dokploy

### Étape 1 : Préparer votre dépôt Git

1. Committez tous les nouveaux fichiers créés :
```bash
git add Dockerfile .dockerignore DEPLOYMENT.md
git commit -m "feat: add Docker configuration for Dokploy deployment"
git push origin main
```

### Étape 2 : Créer l'application dans Dokploy

1. Connectez-vous à votre interface Dokploy (généralement `https://votre-domaine.com:3000`)

2. Créez un nouveau projet ou sélectionnez un projet existant

3. Cliquez sur "Create Application"

4. Configurez l'application :
   - **Name** : `sanity-studio` (ou le nom de votre choix)
   - **Source** : Sélectionnez "Git"
   - **Repository** : Connectez et sélectionnez votre dépôt Git
   - **Branch** : `main` (ou votre branche principale)
   - **Build Type** : Sélectionnez "Dockerfile"

### Étape 3 : Configuration des variables d'environnement

Dans l'onglet "Environment" de votre application Dokploy :

1. Ajoutez les variables suivantes :
```
SANITY_STUDIO_PROJECT_ID=votre_project_id
SANITY_STUDIO_DATASET=portfolio
```

2. Remplacez `votre_project_id` par votre véritable Project ID Sanity

### Étape 4 : Configuration du domaine et du port

1. Dans l'onglet "Domains" :
   - Ajoutez votre domaine (ex: `studio.votre-domaine.com`)
   - Dokploy configurera automatiquement SSL via Let's Encrypt

2. Dans l'onglet "Settings" :
   - Port : `3333` (port par défaut de Sanity Studio)

### Étape 5 : Déployer l'application

1. Cliquez sur "Deploy" dans l'interface Dokploy

2. Suivez les logs de build en temps réel

3. Une fois le déploiement terminé, votre Sanity Studio sera accessible via votre domaine

## Vérification du déploiement

1. Accédez à votre domaine (ex: `https://studio.votre-domaine.com`)

2. Vous devriez voir l'interface de connexion Sanity Studio

3. Connectez-vous avec vos identifiants Sanity.io

## Configuration CORS dans Sanity

Pour que votre Studio fonctionne correctement, vous devez autoriser votre domaine dans les paramètres CORS de Sanity :

1. Allez sur [sanity.io/manage](https://sanity.io/manage)

2. Sélectionnez votre projet

3. Dans "API" → "CORS Origins"

4. Ajoutez votre domaine :
   - Origin : `https://studio.votre-domaine.com`
   - Cochez "Allow credentials"

## Mises à jour automatiques

Dokploy peut être configuré pour déployer automatiquement à chaque push :

1. Dans les paramètres de votre application Dokploy

2. Activez "Auto Deploy" pour la branche `main`

3. À chaque push sur main, Dokploy reconstruira et redéploiera automatiquement

## Commandes utiles

### Redémarrer l'application
Via l'interface Dokploy : Bouton "Restart"

### Voir les logs
Via l'interface Dokploy : Onglet "Logs"

### Rebuild complet
Via l'interface Dokploy : Bouton "Rebuild"

## Dépannage

### Erreur "npm ci" - Lockfile désynchronisé

**Symptôme** : Le build Docker échoue avec des erreurs comme :
```
npm error Invalid: lock file's @sanity/cli-core@X.X.X does not satisfy @sanity/cli-core@Y.Y.Y
npm error Missing: [package]@X.X.X from lock file
```

**Cause** : Le `package-lock.json` n'est pas synchronisé avec `package.json`

**Solution** :
1. Supprimez et régénérez le lockfile :
```bash
rm package-lock.json
npm install
```

2. Committez le nouveau lockfile :
```bash
git add package-lock.json
git commit -m "fix: regenerate package-lock.json"
git push
```

3. Relancez le déploiement dans Dokploy

**Note** : Le Dockerfile inclut maintenant un fallback qui utilise `npm install` si `npm ci` échoue, mais il est préférable d'avoir un lockfile propre.

### Le Studio ne se charge pas
- Vérifiez que les variables d'environnement sont correctement définies
- Vérifiez les logs dans Dokploy pour les erreurs
- Assurez-vous que le port 3333 est correctement exposé

### Erreur CORS
- Vérifiez que votre domaine est ajouté dans les CORS Origins de Sanity
- Assurez-vous d'utiliser HTTPS

### Build échoue
- Vérifiez que tous les fichiers nécessaires sont bien committés
- Vérifiez les logs de build dans Dokploy
- Assurez-vous que le Dockerfile est valide
- Vérifiez que le package-lock.json est synchronisé (voir ci-dessus)

## Architecture du déploiement

Le Dockerfile utilise une stratégie de build multi-étapes :

1. **Build stage** : Installation des dépendances et build du Studio
2. **Production stage** : Installation des dépendances et copie des fichiers nécessaires

**Note** : Contrairement à d'autres applications, Sanity Studio nécessite toutes ses dépendances (y compris TypeScript) au runtime, car il lit les fichiers de configuration TypeScript lors du démarrage. L'image de production contient donc :
- Toutes les dépendances npm
- Le build (`dist/`)
- Les fichiers de configuration (`sanity.config.ts`, `sanity.cli.ts`)
- Les schémas (`schemaTypes/`)
- Les fichiers statiques (`static/`)

## Sécurité

- Les variables d'environnement contenant des secrets doivent être configurées dans Dokploy (pas dans le code)
- Utilisez toujours HTTPS pour votre Studio en production
- Configurez les CORS Origins de manière restrictive
- Mettez à jour régulièrement vos dépendances

## Support

Pour plus d'informations :
- Documentation Sanity : [sanity.io/docs](https://www.sanity.io/docs)
- Documentation Dokploy : [dokploy.com/docs](https://dokploy.com/docs)
- Communauté Sanity : [slack.sanity.io](https://slack.sanity.io)
