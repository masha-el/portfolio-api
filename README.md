# Portfolio API

A live portfolio site backed by a real API running in Kubernetes on GCP.

The frontend fetches CV data dynamically from a FastAPI backend — no static JSON, no mock data. The entire stack is deployed and managed with Helm, exposed via Cloudflare, and automatically redeployed on every push via GitHub Actions.

**Live frontend:** https://masha-el.github.io/portfolio-api  
**Live API:** https://api.elgart.tech/cv

> ⚠️ The GKE cluster is not always running. To manage GCP costs, it is spun up for demos and interviews and torn down afterward. If the API is unreachable, the frontend will show an error message.

---

## Architecture

```
Browser
  │
  ├── GitHub Pages (frontend) ─────────────────────────────────────┐
  │                                                                 │
  └── Cloudflare (TLS · api.elgart.tech) ──► GKE LoadBalancer      │
                                                    │               │
                                             ┌──────▼──────┐       │
                                             │  FastAPI pod │◄──────┘
                                             │  (cv.json)   │   fetches /cv
                                             └─────────────┘
                                                    ▲
                                             Helm chart deploy
                                                    ▲
                                             GitHub Actions CI/CD
                                                    ▲
                                             Artifact Registry (Docker image)
```

| Layer | Technology |
|---|---|
| Frontend | GitHub Pages (static HTML/JS) |
| DNS + TLS | Cloudflare (Flexible SSL) |
| Backend | FastAPI (Python) |
| Container registry | GCP Artifact Registry |
| Orchestration | GKE (Google Kubernetes Engine) |
| Deployment | Helm |
| CI/CD | GitHub Actions |
| Region | `me-west1` (Tel Aviv) |

---

## Project Structure

```
portfolio-api/
├── main.py                  # FastAPI app
├── cv.json                  # CV data served by the API
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
│   └── index.html
└── .github/
    └── workflows/
        └── deploy.yml       # CI/CD pipeline
```

---

## API Endpoints

| Endpoint | Description |
|---|---|
| `GET /cv` | Returns full CV as JSON |
| `GET /health` | Health check (used by K8s liveness/readiness probes) |

---

## CI/CD Pipeline

Every push to `main` triggers the GitHub Actions workflow which:

1. Builds a `linux/amd64` Docker image
2. Tags it with the commit SHA
3. Pushes it to GCP Artifact Registry
4. Authenticates to GKE
5. Runs `helm upgrade` with the new image tag

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

- **`linux/amd64` build target** — GKE runs on amd64; local Mac builds arm64 by default. `docker buildx` with `--platform linux/amd64` is required.
- **Rolling update strategy `maxSurge: 0`** — single-node cluster has limited CPU. Killing the old pod before starting the new one prevents scheduling failures.
- **Commit SHA as image tag** — guarantees K8s always pulls the updated image. Mutable tags like `latest` can cause stale deployments.
- **Cloudflare Flexible SSL** — handles TLS termination without requiring an ingress controller or cert-manager inside the cluster, keeping resource usage low on a single e2-medium node.

---

## Author

Maria Elgart — Platform / DevOps Engineer  
[masha.elgart@gmail.com](mailto:masha.elgart@gmail.com) · Haifa, Israel  
[LinkedIn](https://linkedin.com/in/maria-elgart) · [GitHub](https://github.com/masha-el)