# Summer 2026 CLO835 (Portable Technologies in Cloud) Assignment 2

Setup commands and all steps executed in the assignment can be found in [`docs/commands.md`](docs/commands.md).

---

> [!NOTE]
> Below are instructions from forking the repo: https://github.com/sojoudian/CLO835_summer2026_assignment2

# CLO835 — Assignment 2 starter

Starter applications for **CLO835 Assignment 2: Automate the build with GitHub Actions and deploy a versioned application to Kubernetes.**

This builds on **Assignment 1** → https://github.com/sojoudian/CLO835_summer2026_assignment1

> ⭐ **Star + Watch this repo** — that's how you'll get fixes to the starter and the solution walkthrough after the due date.

---

## What you are building

A simple web service that returns one text message on **port 8080**, deployed to your **kind** Kubernetes cluster through an automated pipeline. You ship **two versions**:

| Version | The app returns                                   |
| ------- | ------------------------------------------------- |
| **0.2** | `Hello world from the CLO835 class!`              |
| **0.3** | `Hello world from the CLO835 class and 10112233!` |

`10112233` must be **your own Seneca student ID**. Everyone's running app is unique.

## Pick ONE language

Programming is **not** the focus of this course — you may use AI tools to help. Choose any **one** of these (a ready starter for each is in [`apps/`](apps/)):

| Language        | Folder                       | Run locally      |
| --------------- | ---------------------------- | ---------------- |
| Python 3.14     | [`apps/python`](apps/python) | `python3 app.py` |
| Go 1.26         | [`apps/go`](apps/go)         | `go run main.go` |
| Rust 1.96       | [`apps/rust`](apps/rust)     | `cargo run`      |
| Java 26         | [`apps/java`](apps/java)     | `java Main.java` |
| C# 14 (.NET 10) | [`apps/csharp`](apps/csharp) | `dotnet run`     |
| Node.js v26     | [`apps/nodejs`](apps/nodejs) | `node server.js` |

Then check it: `curl http://localhost:8080` → `Hello world from the CLO835 class!`

Each starter has a clearly-marked `MESSAGE`/`message` constant. **To release version 0.3, edit that one line** to include your student ID, commit, and let the pipeline build the new image.

## What YOU must complete (this is the graded work)

Skeleton **placeholder** files are provided — fill in the `TODO`s. They intentionally do **not** contain the answers:

1. **`Dockerfile`** — build your chosen app into an image that serves on port 8080.
2. **`.github/workflows/docker.yml`** — on merge to `master`, log in to Docker Hub and build + push the image tagged with the version (`0.2`) and the commit SHA.
3. **`k8s/deployment.yaml`** and **`k8s/service.yaml`** — a 3-replica Deployment (`apps/v1`) and a NodePort Service for your kind cluster.

See the assignment handout for the full requirements, recommended flow, and grade breakdown.

## Rules

- **Never commit Docker Hub passwords or tokens.** Store them as GitHub Actions **secrets** (e.g. `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`).
- All commits must be dated **before** the due date.
- The **report** of challenges faced is **mandatory**.
- Your **student ID must appear** in the version 0.3 output.

## Deploy / update / rollback (quick reference)

```bash
# deploy v0.2
kubectl apply -f deployment.yaml -f service.yaml
kubectl get deploy,rs,pods,svc

# release v0.3 (after the pipeline pushed <user>/<repo>:0.3)
kubectl set image deployment/<name> <container>=<user>/<repo>:0.3
kubectl rollout status deployment/<name>
kubectl rollout history deployment/<name>

# roll back to v0.2
kubectl rollout undo deployment/<name>
```
