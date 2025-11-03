# Structure du Pipeline CI/CD

Ce dossier contient tous les fichiers de configuration et les scripts nécessaires au pipeline CI/CD du projet Agenda.

## Structure des dossiers

```
pipeline/
├── config/               # Fichiers de configuration Kubernetes
│   ├── namespace-dev.yaml  # Configuration du namespace de développement
│   ├── namespace-prod.yaml # Configuration du namespace de production
│   └── ingress.yaml       # Configuration des entrées (routage HTTP/S)
├── scripts/              # Scripts de déploiement et d'utilitaires
│   └── deploy-k8s.sh     # Script principal de déploiement
├── .gitlab-ci.yml        # Configuration du pipeline GitLab CI/CD
└── README.md             # Ce fichier
```

## Fichiers de configuration

### `config/`
- `namespace-*.yaml` : Définition des namespaces Kubernetes pour chaque environnement
- `ingress.yaml` : Configuration du routage HTTP/S et des règles d'accès

### `scripts/`
- `deploy-k8s.sh` : Script principal pour le déploiement sur Kubernetes
  - Gère le déploiement dans différents environnements (dev/prod)
  - Configure les ressources nécessaires
  - Gère les mises à jour et les rollbacks

## Utilisation

### Pour déployer manuellement

```bash
# Pour l'environnement de développement
./scripts/deploy-k8s.sh agenda-dev v1.0.0 dev

# Pour l'environnement de production
./scripts/deploy-k8s.sh agenda-prod v1.0.0 prod
```

### Pour exécuter le pipeline CI/CD

1. Pousser les modifications sur la branche `develop` pour un déploiement en développement
2. Créer une merge request vers `main` pour un déploiement en production
3. Le déploiement en production nécessite une validation manuelle

## Configuration requise

- Accès à un cluster Kubernetes
- `kubectl` configuré avec les droits nécessaires
- Un registre d'images Docker (comme GitLab Container Registry)
- Les variables d'environnement nécessaires configurées dans GitLab CI/CD
