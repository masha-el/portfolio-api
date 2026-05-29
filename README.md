# Portfolio API

A portfolio site with a free production path and an on-demand DevOps demo path.

The production site is hosted on GitHub Pages and reads CV data from a static JSON file. This keeps the public portfolio always available without running paid GCP infrastructure.

The FastAPI, Docker, Helm, GKE, Artifact Registry, Cloudflare, and GitHub Actions setup is kept as a DevOps demo environment. It can be deployed manually when needed for interviews or practice, then shut down to control GCP costs.

**Live frontend:** https://masha-el.github.io/portfolio-api  
**Production data source:** `docs/cv.json`  
**Demo API:** https://api.elgart.tech/cv

> The demo API is not expected to be always running. The GKE cluster should be started only for demos or practice and torn down afterward.

---

## Architecture

### Production

```
Browser
  │
  └── GitHub Pages
        ├── docs/index.html
        └── docs/cv.json
```

The production page fetches `./cv.json` from the same GitHub Pages site. No GKE cluster, public LoadBalancer, Cloud NAT, or backend service is required for the live portfolio.

### DevOps Demo

```
Browser
  │
  └── Cloudflare (TLS · api.elgart.tech)
        │
        ▼
      GKE LoadBalancer
        │
        ▼
      FastAPI pod
        │
        └── serves /cv and /health
        ▲
        │
      Helm chart deploy
        ▲
        │
      Manual GitHub Actions workflow
        ▲
        │
      Artifact Registry Docker image
```

| Layer | Technology |
|---|---|
| Production hosting | GitHub Pages |
| Production data | Static `docs/cv.json` |
| Demo DNS + TLS | Cloudflare |
| Demo backend | FastAPI (Python) |
| Demo container registry | GCP Artifact Registry |
| Demo orchestration | GKE (Google Kubernetes Engine) |
| Demo deployment | Helm |
| Demo CI/CD | GitHub Actions manual workflow |
| Region | `me-west1` (Tel Aviv) |

---

## Project Structure

```
portfolio-api/
├── main.py                  # FastAPI app
├── requirements.txt
├── Dockerfile
├── helm/
│   └── portfolio-api/       # Helm chart
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           └── service.yaml
├── docs/                    # GitHub Pages frontend
│   ├── index.html
│   └── cv.json              # Production CV data
└── .github/
    └── workflows/
        └── deploy.yml       # Manual DevOps demo deployment
```

---

## API Endpoints

| Endpoint | Description |
|---|---|
| `GET /cv` | Returns full CV as JSON |
| `GET /health` | Health check (used by K8s liveness/readiness probes) |

---

## CI/CD Pipeline

The GKE deployment workflow is manual. It is triggered from GitHub Actions with `workflow_dispatch`:

```yaml
on:
  workflow_dispatch:
```

When run manually, the workflow:

1. Builds a `linux/amd64` Docker image
2. Tags it with the commit SHA
3. Pushes it to GCP Artifact Registry
4. Authenticates to GKE
5. Runs `helm upgrade` with the new image tag

This keeps the DevOps demo deployable while preventing every push to `main` from starting or updating paid GCP infrastructure.

---

## Local Development

```bash
# Install dependencies
pip install -r requirements.txt

# Run locally
python3 -m uvicorn main:app --reload

# Visit
http://localhost:8000/cv
http://localhost:8000/health
```

---

## Helm Deployment

```bash
# Install
helm install portfolio-api helm/portfolio-api

# Upgrade
helm upgrade portfolio-api helm/portfolio-api

# Uninstall
helm uninstall portfolio-api
```

---

## Key Design Decisions

- **Separate production and demo paths** — the live portfolio is static and free to host, while the Kubernetes setup remains available for hands-on DevOps practice.
- **Manual GitHub Actions deployment** — `workflow_dispatch` prevents automatic GKE deployments on every push.
- **`linux/amd64` build target** — GKE runs on amd64; local Mac builds arm64 by default. `docker buildx` with `--platform linux/amd64` is required.
- **Rolling update strategy `maxSurge: 0`** — single-node cluster has limited CPU. Killing the old pod before starting the new one prevents scheduling failures.
- **Commit SHA as image tag** — guarantees K8s always pulls the updated image. Mutable tags like `latest` can cause stale deployments.
- **Cloudflare Flexible SSL** — handles TLS termination without requiring an ingress controller or cert-manager inside the cluster, keeping resource usage low on a single e2-medium node.

---

## Author

Maria Elgart — Platform / DevOps Engineer  
[masha.elgart@gmail.com](mailto:masha.elgart@gmail.com) · Haifa, Israel  
[LinkedIn](https://linkedin.com/in/maria-elgart) · [GitHub](https://github.com/masha-el)
