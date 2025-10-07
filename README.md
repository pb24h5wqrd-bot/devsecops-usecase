# devsecops-usecase

Secure DevSecOps Pipeline — Proof of Concept

This repo shows how I’d design a secure and automated DevSecOps workflow for a small web app — from build to deployment — keeping speed, security, and auditability in balance.
---------------------------------------------------------------------------------------------------------------------------------------------------

 Pipeline Flow (what happens step by step)
	1.	Developer commits code → GitHub triggers the pipeline.
	2.	Docker image builds for the app using a lean base image and non-root user.
	3.	Trivy scan runs on the image to catch vulnerabilities early.
	•	Pipeline stops automatically if it finds high or critical issues.
	4.	Syft SBOM generates a full list of components and dependencies — stored as an artifact for traceability.
	5.	Cosign signing happens next — the image is signed with a key to prove it came from our trusted build pipeline.
	6.	Push to registry (example: GHCR or ECR).
	7.	Kubernetes deployment applies only if all security gates pass (scans clean, image signed).
	8.	Kyverno / Admission control (optional) verifies signature at cluster side.

This makes sure no unscanned or unsigned image ever reaches production.

---------------------------------------------------------------------------------------------------------------------------------------------------
Tools Used
Tool	Purpose
Terraform	Infra-as-code — spins up namespaces, config maps, or cluster objects declaratively
Docker	Packages the app in a reproducible, immutable image
GitHub Actions	Automates CI/CD pipeline, triggers builds and tests
Trivy	Image vulnerability scanning (stops deployment on high/critical issues)
Syft	SBOM generator (Software Bill of Materials)
Cosign	Cryptographically signs and verifies container images
Kubernetes	Deployment and service orchestration
Kyverno (optional)	Admission controller that ensures only signed, non-root images deploy

---------------------------------------------------------------------------------------------------------------------------------------------------
 Security Layers Added
	1.	Runs as non-root user in Dockerfile and K8s manifest.
	2.	Image scanning is automated before deployment.
	3.	SBOM stored for every build — compliance ready.
	4.	Image signing ensures supply-chain integrity.
	5.	Admission policy (Kyverno) enforces signed images only.
	6.	Resource limits defined in manifests to prevent abuse.

Each of these removes a human dependency and builds trust into the pipeline itself.

---------------------------------------------------------------------------------------------------------------------------------------------------
File Overview
File	Description
app/server.js	Simple Express app that returns “Hello from secure DevSecOps pipeline!”
Dockerfile	Builds secure, lightweight image (node:18-alpine, non-root)
.github/workflows/ci.yml	CI/CD pipeline — build → scan → SBOM → sign → deploy
k8s/deployment.yaml	K8s deployment with resource limits and non-root security context
k8s/service.yaml	Exposes the app on port 80 (ClusterIP)
terraform/main.tf	Creates a namespace + ConfigMap in cluster
README.md	This explanation of the full workflow

---------------------------------------------------------------------------------------------------------------------------------------------------
Why This Is Secure
	•	Shift-left security: scans run early in CI.
	•	No manual deploys: everything is automated and auditable.
	•	Immutable artifacts: all builds traceable by tag and signature.
	•	Separation of duties: build and deploy stages are distinct.
	•	Zero trust principles: nothing runs unless verified.

---------------------------------------------------------------------------------------------------------------------------------------------------
Design Choice: Simplicity over Modularity
This proof of concept uses a single Terraform configuration (main.tf) instead of splitting infrastructure and workloads into separate modules or workspaces.
The goal here is clarity — to demonstrate core DevSecOps automation principles end-to-end without adding abstraction layers that hide what’s actually happening.
In a production environment, I would separate:
	•	Infra layer (networking, IAM, AKS/EKS cluster, backend state)
	•	Workload layer (namespaces, configmaps, policies, deployments)
That approach provides better isolation, faster plans, and clearer blast-radius control.
For this test, however, a unified configuration makes it easier to review, audit, and understand the full workflow in one place — while still following Terraform’s declarative and idempotent model.

---------------------------------------------------------------------------------------------------------------------------------------------------
How to Run Locally
# Build image
docker build -t secure-app:latest .

# Run scan
trivy image secure-app:latest

# Generate SBOM
syft secure-app:latest -o table

# Sign image
cosign generate-key-pair
cosign sign --key cosign.key secure-app:latest

# Deploy to local kind cluster
kubectl apply -f k8s/

---------------------------------------------------------------------------------------------------------------------------------------------------
 Future Enhancements
	•	Integrate Vault / External Secrets for runtime secrets.
	•	Use IRSA (OIDC) for workload identity in AWS.
	•	Add Prometheus + Grafana for observability and SLO tracking.
	•	Add Velero backups and chaos drills for DR testing.

---------------------------------------------------------------------------------------------------------------------------------------------------
 TL;DR Summary

This project demonstrates how to secure every stage of a CI/CD pipeline — build, scan, sign, and deploy — using open-source tooling and clean automation principles.
It’s production-lean, but enterprise-ready in concept.


I built a secure CI/CD workflow that automatically builds, scans, signs, and deploys a containerized app. Every artifact is traceable — from SBOM to signature — and policies ensure that only trusted images reach Kubernetes.
The value relies in “Speed with security — no separate audit step, no manual gates. Everything is automated, logged, and auditable.



