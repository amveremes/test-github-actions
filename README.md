# test-github-actions
test github actions

# test docker build
```bash
docker build -t amveremes/test-github-actions .
```

# create release with goreleaser

Example :
```bash
git tag v0.1.22
git push origin v0.1.22
```

Start container :
```bash
docker run -d -p 5000:5000 ghcr.io/amveremes/test-github-actions:latest
```

# Architecture de l'infrastructure AWS

## Vue d'ensemble

Voici l'architecture de notre infrastructure gérée par Terraform/Terramate :

```mermaid
architecture-beta
    group dns(logos:aws-route53)[DNS Zone]
    group delivery(logos:aws-cloudfront)[Content Delivery]
    group compute(logos:aws-ec2)[Compute Layer]
    
    service route53(logos:aws-route53)[Route 53] in dns
    service cloudfront(logos:aws-cloudfront)[CloudFront] in delivery
    service alb(logos:aws-ec2)[Load Balancer] in compute
    service ui(logos:nextjs)[UI Application] in compute
    
    route53:R --> L:cloudfront
    cloudfront:R --> L:alb
    alb:B --> T:ui
```

```mermaid
architecture-beta
    group api(logos:aws-api-gateway)[API Layer]
    group backend(logos:aws-lambda)[Backend Services]
    group data(logos:aws-dynamodb)[Data Layer]
    
    service gateway(logos:aws-api-gateway)[API Gateway] in api
    service auth(logos:aws-lambda)[Auth Service] in backend
    service blog(logos:aws-lambda)[Blog Service] in backend
    service analytics(logos:aws-lambda)[Analytics Service] in backend
    service auth_db(logos:aws-dynamodb)[Auth DB] in data
    service blog_db(logos:aws-dynamodb)[Blog DB] in data
    service search(logos:aws-open-search)[OpenSearch] in data
    
    gateway:R --> L:auth
    gateway:R --> L:blog
    gateway:R --> L:analytics
    
    auth:R --> L:auth_db
    blog:R --> L:blog_db
    analytics:R --> L:search
```

```mermaid
flowchart TD
    User[Utilisateur] --> DNS[Route 53]
    DNS --> CF[CloudFront]
    CF --> LB[Load Balancer]
    LB --> UI[Next.js UI]
    CF --> GW[API Gateway]
    
    GW --> Auth[Auth Service]
    GW --> Blog[Blog Service]
    GW --> Analytics[Analytics Service]
    
    Auth --> AuthDB[(Auth DB)]
    Blog --> BlogDB[(Blog DB)]
    Analytics --> Search[(OpenSearch)]
    
    style User fill:#f9f,stroke:#333,color:#000,stroke-width:2px
    style Auth fill:#bbf,stroke:#333,color:#000
    style Blog fill:#bbf,stroke:#333,color:#000
    style Analytics fill:#bbf,stroke:#333,color:#000
```

```mermaid
quadrantChart
    title Criticité des services
    x-axis Basse criticité --> Haute criticité
    y-axis Faible trafic --> Fort trafic
    
    Analytics Service: [0.3, 0.7]
    Blog Service: [0.7, 0.6]
    Auth Service: [0.9, 0.8]
    UI Application: [0.8, 0.9]
    Batch Jobs: [0.2, 0.3]
```

```mermaid
erDiagram
    authors {
        uuid id PK
        varchar name
        varchar email UK
        timestamp created_at
    }
    
    posts {
        uuid id PK
        uuid author_id FK
        varchar title
        text content
        timestamp published_at
    }
    
    tags {
        uuid id PK
        varchar name UK
        varchar slug
    }
    
    categories {
        uuid id PK
        varchar name
        uuid parent_id FK "self-reference"
    }
    
    post_tags {
        uuid post_id FK
        uuid tag_id FK
        timestamp linked_at
    }
    
    post_categories {
        uuid post_id FK
        uuid category_id FK
        boolean is_primary
    }
    
    %% Relations many-to-many via tables de jointure
    authors ||--o{ posts : "écrit"
    posts ||--o{ post_tags : "a"
    tags ||--o{ post_tags : "a"
    
    posts ||--o{ post_categories : "a"
    categories ||--o{ post_categories : "a"
    
    %% Self-reference many-to-one
    categories ||--o{ categories : "parent"
```

```mermaid
erDiagram
    users {
        uuid id PK
        varchar email
        varchar username
    }
    
    posts {
        uuid id PK
        uuid author_id FK
        varchar title
        text content
    }
    
    comments {
        uuid id PK
        uuid post_id FK
        uuid user_id FK
        text content
    }
    
    profiles {
        uuid user_id PK,FK
        text bio
        varchar avatar_url
    }
    
    %% Relations avec cardinalités explicites dans le texte
    users ||--o{ posts : "1 → *"
    posts ||--o{ comments : "1 → *"
    comments }o--|| users : "* → 1"
    users ||--o| profiles : "1 → 0..1"
```

```mermaid
gantt
    title Lancement produit — Q3 2026
    dateFormat  YYYY-MM-DD
    axisFormat  %Y-%m-%d

    section Planification
    Analyse marché           :a1, 2026-07-01, 14d
    Cahier des charges       :a2, after a1, 10d

    section Développement
    Prototype                :b1, 2026-07-25, 20d
    Tests internes           :b2, after b1, 10d
    Ajustements              :b3, after b2, 7d

    section Pré-lancement
    Marketing & contenu      :c1, 2026-08-30, 14d
    Formation équipe vente   :c2, after c1, 5d

    section Lancement
    Déploiement production   :d1, 2026-09-20, 2d
    Revue post-lancement     :d2, after d1, 7d
```
