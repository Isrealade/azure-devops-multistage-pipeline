# azure-devops-multistage-pipeline

An end-to-end sample showing a modern Azure DevOps YAML multi-stage CI/CD pipeline for a simple Blazor application.

This repository demonstrates how to build, containerize, scan, and deploy a .NET Blazor app to AKS using Azure DevOps pipelines, with environment overlays (dev/test/prod) and SonarQube analysis.

**Key Highlights**
- **Application:** `BlazorSample` — a .NET 9 server-rendered Blazor app
- **Container image:** Multi-stage Dockerfile (build + runtime) targeting port `8080`
- **CI/CD:** `azure-pipelines.yml` uses templates in `templates/` to orchestrate build and release stages
- **Kubernetes:** Manifests in `manifests/`, with environment-specific deploy overlays in `manifests/dev`, `manifests/test`, `manifests/prod`
- **Quality:** `sonar-project.properties` present for SonarQube scanning

**Repository Layout**
- `BlazorSample/` — application source and project file
- `Dockerfile` — multi-stage image build (dotnet 9 preview SDK/runtime)
- `azure-pipelines.yml` — entrypoint pipeline referencing templates in `templates/`
- `templates/` — pipeline templates for build and environment releases
- `manifests/` — Kubernetes manifests and `namespace.yaml`
- `sonar-project.properties` — Sonar project configuration

**Quick Links**
- Pipeline: [azure-pipelines.yml](azure-pipelines.yml)
- App project: [BlazorSample/BlazorSample.csproj](BlazorSample/BlazorSample.csproj)
- Dockerfile: [Dockerfile](Dockerfile)
- Dev release template: [templates/release-dev.yaml](templates/release-dev.yaml)
- Dev manifests: [manifests/dev/deploy.yaml](manifests/dev/deploy.yaml)

**Requirements**
- .NET SDK 9.0 (preview) — project targets `net9.0`
- Docker (for local image build and run)
- kubectl (to apply Kubernetes manifests)
- An Azure DevOps organization (if using Azure Pipelines)

Getting Started (Local)
-----------------------
1. Restore and run the Blazor app locally:

```bash
cd BlazorSample
dotnet restore
dotnet run --urls "http://localhost:8080"
# Open http://localhost:8080
```

2. Build and run the Docker image locally:

```bash
# from repo root
docker build -t blazorapp:local .
docker run -p 8080:8080 blazorapp:local
```

Container & Kubernetes
----------------------
- The `Dockerfile` is multi-stage: it restores, builds and publishes the app, then copies the published output into an ASP.NET runtime image.
- The runtime exposes port `8080` and the Kubernetes `Deployment` uses `containerPort: 8080`.
- `manifests/namespace.yaml` contains `dev`, `test`, and `prod` namespaces.
- `manifests/dev/deploy.yaml` is a sample deployment used by the `Dev` release pipeline template.

Example: push image and deploy to a cluster (CI normally handles image tagging):

```bash
# Build and tag
docker build -t <ACR_NAME>.azurecr.io/blazor:mytag .
docker push <ACR_NAME>.azurecr.io/blazor:mytag

# Apply namespaces and deployment
kubectl apply -f manifests/namespace.yaml
kubectl apply -f manifests/dev/deploy.yaml -n dev
```

CI / Azure DevOps Pipeline
--------------------------
- `azure-pipelines.yml` triggers builds for `main`, `develop`, and `release/*` branches. It references `templates/build-stage.yaml` and environment release templates (`templates/release-dev.yaml`, `templates/release-test.yaml`, `templates/release-prod.yaml`).
- Pipelines use a variable group `blazor-vars` for ACR/AKS credentials and generate an `IMAGE_TAG` using branch name + build id.
- The `Dev` deploy template replaces the image tag in the manifest then runs a `Kubernetes@1` task to apply manifests to AKS.

SonarQube
---------
- `sonar-project.properties` is configured with `sonar.projectKey` and `sonar.sources=.` for scanning the repo. The pipeline can invoke Sonar tasks to push analysis to your Sonar organization.

Notes & Tips
------------
- The project currently targets .NET 9.0 (preview). If you prefer a stable SDK, change `TargetFramework` in [BlazorSample/BlazorSample.csproj](BlazorSample/BlazorSample.csproj) and update the `Dockerfile` base images accordingly.
- The pipeline templates use `sed` to replace image tags in manifests; ensure the agent OS supports `sed` and has permissions to edit files.
- Image names in manifests use `blazorappacr.azurecr.io/blazor` as an example — replace with your ACR name and repository.

Contributing
------------
- Please open issues or PRs for fixes and enhancements.
- If you update the app framework version or Docker base images, update the README and pipeline templates accordingly.

License
-------
This project is provided under the repository license. See `LICENSE` at the repository root.