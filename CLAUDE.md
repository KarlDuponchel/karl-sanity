# Spécifications du projet - Karl Duponchel Portfolio CMS

> Document de référence pour Claude Code. Contient toutes les informations essentielles sur le projet pour une prise en main rapide.

## Vue d'ensemble

**Type** : Sanity Studio (CMS headless)
**Objectif** : Backend de gestion de contenu pour le portfolio Karl Duponchel
**Dataset** : `portfolio`
**Version Sanity** : 5.6.0
**Langage** : TypeScript
**Framework UI** : React 19

Ce projet est une instance Sanity Studio configurée pour gérer le contenu d'un blog/portfolio. Il s'agit d'un CMS headless qui expose une API pour être consommée par un frontend (à développer séparément).

## Technologies utilisées

### Core
- **Sanity Studio** v5.6.0 - Interface de gestion de contenu
- **React** v19.1 - Framework UI
- **TypeScript** v5.8 - Langage de développement
- **Node.js** v22 - Runtime (pour production)

### Outils Sanity
- `@sanity/vision` - Outil de requêtage GROQ intégré au Studio
- `structureTool` - Outil de navigation dans la structure de contenu

### Styling
- **styled-components** v6.1.18 - CSS-in-JS

### Dev Tools
- **ESLint** v9.28 - Linter
- **Prettier** v3.5 - Formatage de code

## Structure du projet

```
karl-sanity/
├── schemaTypes/           # Définitions des types de contenu
│   ├── blog/
│   │   ├── post.ts       # Schema des articles de blog
│   │   ├── author.ts     # Schema des auteurs
│   │   └── category.ts   # Schema des catégories
│   └── index.ts          # Export des schemas
├── static/               # Fichiers statiques
├── sanity.config.ts      # Configuration principale du Studio
├── sanity.cli.ts         # Configuration CLI
├── Dockerfile            # Configuration Docker pour déploiement
├── .dockerignore         # Exclusions Docker
├── .env.example          # Template variables d'environnement
├── package.json          # Dépendances et scripts
└── tsconfig.json         # Configuration TypeScript
```

## Modèles de contenu (Schemas)

### 1. Post (Article de blog)
**Type** : `post`
**Champs** :
- `title` (string, requis) - Titre de l'article
- `slug` (slug, requis) - URL-friendly identifier (auto-généré depuis title)
- `author` (reference → author) - Référence à un auteur
- `coverImage` (image avec hotspot) - Image de couverture avec texte alternatif
- `category` (reference → category) - Référence à une catégorie
- `publishedAt` (datetime) - Date de publication (auto-initialisée)
- `excerpt` (text, max 200 chars) - Résumé de l'article
- `body` (array) - Contenu riche (blocs de texte + images)
- `tags` (array of strings) - Tags libres
- `featured` (boolean) - Marqueur "à la une"

**Preview** : Affiche le titre, l'auteur et l'image de couverture

### 2. Author (Auteur)
**Type** : `author`
À documenter (lire le fichier si besoin de détails)

### 3. Category (Catégorie)
**Type** : `category`
À documenter (lire le fichier si besoin de détails)

### Évolutions prévues
- Schémas e-commerce (commentaire dans [schemaTypes/index.ts](schemaTypes/index.ts:10))

## Variables d'environnement

### Requises
```bash
SANITY_STUDIO_PROJECT_ID=your_project_id    # ID du projet Sanity
SANITY_STUDIO_DATASET=portfolio             # Nom du dataset (défaut: portfolio)
```

### Où les trouver
- **Project ID** : [sanity.io/manage](https://sanity.io/manage) → Sélectionner le projet → visible dans l'URL ou les paramètres

### Fichiers
- `.env.example` - Template à copier en `.env` pour le développement local
- En production (Dokploy) : définir dans l'interface de configuration

## Scripts npm disponibles

```bash
npm run dev              # Lance le Studio en mode développement (port 3333)
npm run start            # Lance le Studio en mode production
npm run build            # Build le Studio pour production
npm run deploy           # Déploie le Studio sur Sanity Cloud
npm run deploy-graphql   # Déploie l'API GraphQL sur Sanity
```

## Configuration

### sanity.config.ts
Configuration principale du Studio :
- Project ID et dataset lus depuis les variables d'environnement
- Plugins activés : `structureTool`, `visionTool`
- Schemas importés depuis [schemaTypes/index.ts](schemaTypes/index.ts)

### sanity.cli.ts
Configuration CLI :
- Auto-updates activé pour le Studio
- Configuration API (project ID, dataset)

### Prettier
```json
{
  "semi": false,
  "printWidth": 100,
  "bracketSpacing": false,
  "singleQuote": true
}
```

## Déploiement

### Environnement cible
- **Plateforme** : Dokploy (sur VPS)
- **Port** : 3333 (port par défaut Sanity Studio)
- **Build** : Docker multi-stage

### Fichiers de déploiement
- [Dockerfile](Dockerfile) - Build multi-stage avec toutes les dépendances (Sanity nécessite TypeScript au runtime)
- [.dockerignore](.dockerignore) - Exclusions (node_modules, .git, etc.)
- [DEPLOYMENT.md](DEPLOYMENT.md) - Guide complet de déploiement

### Configuration CORS
**Important** : Après déploiement, ajouter le domaine de production dans Sanity.io :
- [sanity.io/manage](https://sanity.io/manage) → API → CORS Origins
- Ajouter `https://studio.votre-domaine.com` avec "Allow credentials"

## Points d'attention

### 1. Package-lock.json
Le fichier `package-lock.json` doit rester synchronisé avec `package.json`. Si des erreurs `npm ci` surviennent lors du build Docker :
```bash
rm package-lock.json && npm install
git add package-lock.json
git commit -m "fix: regenerate package-lock.json"
```

Le Dockerfile inclut un fallback (`npm ci || npm install`) mais un lockfile propre est préférable.

### 2. Version de Node
- Développement : version installée localement
- Production Docker : Node 22 Alpine (voir [Dockerfile](Dockerfile:2))

### 3. Auto-updates
Le Studio est configuré avec auto-updates activé ([sanity.cli.ts](sanity.cli.ts:13)). Sanity peut mettre à jour automatiquement certaines dépendances.

### 4. Dataset
Le dataset par défaut est `portfolio`. Si vous créez des environnements multiples (staging, prod), utilisez des datasets différents.

## Workflows de développement

### Développement local
```bash
# Première installation
npm install

# Configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec votre PROJECT_ID

# Lancer le Studio
npm run dev

# Accéder au Studio
# http://localhost:3333
```

### Ajouter un nouveau type de contenu
1. Créer un nouveau fichier dans [schemaTypes/](schemaTypes/) (ou sous-dossier)
2. Définir le schema avec `defineType()` et `defineField()`
3. Importer et ajouter dans [schemaTypes/index.ts](schemaTypes/index.ts)
4. Le Studio se rechargera automatiquement

### Déployer
Voir le guide complet : [DEPLOYMENT.md](DEPLOYMENT.md)

## Intégration API

### Consommer le contenu (frontend)
Le Studio expose les données via l'API Sanity. Pour les consommer depuis un frontend :

```typescript
// Exemple de requête GROQ
const query = `*[_type == "post" && featured == true]{
  title,
  slug,
  excerpt,
  coverImage,
  author->{name},
  category->{title}
}`;
```

### Outils disponibles
- **Vision Tool** : Intégré au Studio pour tester les requêtes GROQ
- **GraphQL API** : Peut être déployé avec `npm run deploy-graphql`
- **Client Sanity** : Utiliser `@sanity/client` dans le frontend

## Liens utiles

### Documentation
- [Sanity Studio Docs](https://www.sanity.io/docs)
- [GROQ Query Language](https://www.sanity.io/docs/groq)
- [Schema Types Reference](https://www.sanity.io/docs/schema-types)
- [Content Modeling](https://www.sanity.io/docs/content-modeling)

### Communauté
- [Sanity Community Slack](https://slack.sanity.io)
- [Sanity Exchange](https://www.sanity.io/exchange) - Plugins et starters

### Dashboards
- [Sanity Manage](https://sanity.io/manage) - Dashboard du projet
- [Sanity Vision](http://localhost:3333/vision) - Query tool (local)

## Historique des modifications importantes

### 2026-02-04
- Ajout Dockerfile multi-stage optimisé
- Ajout .dockerignore
- Régénération package-lock.json
- Création DEPLOYMENT.md
- Création CLAUDE.md (ce fichier)

### Avant
- Setup initial Sanity Studio
- Configuration des schemas blog (post, author, category)
- Configuration prettier et eslint

## TODO / Évolutions futures

- [ ] Ajouter schemas e-commerce (mentionné dans index.ts)
- [ ] Configurer prévisualisation temps réel avec le frontend
- [ ] Ajouter des custom components pour l'éditeur de contenu
- [ ] Configurer la validation avancée des champs
- [ ] Documenter les schemas author et category
- [ ] Ajouter tests (si nécessaire)
