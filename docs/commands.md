## Commands

Commands that will be ran throughout the assignment's demo. The setup script is only a reference to the user data setup for the EC2 template used to launch the instance.

## K8 Setup Script for EC2 user data template

```bash
#!/bin/bash
set -euxo pipefail

USER_NAME="ubuntu"
CLUSTER_NAME="clo835"
NODE_PORT="30080" # Port should match mapping service.yaml

# Install Docker
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

systemctl enable --now docker
usermod -aG docker "$USER_NAME"

# Install kind v0.31.0
curl -sLo /tmp/kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64
install -o root -g root -m 0755 /tmp/kind /usr/local/bin/kind

# Install kubectl v1.35.0
curl -Lo /tmp/kubectl https://dl.k8s.io/release/v1.35.0/bin/linux/amd64/kubectl
install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl

# Create kind cluster with NodePort exposed on the EC2 host
cat > /tmp/kind-config.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: ${NODE_PORT}
        hostPort: ${NODE_PORT}
        listenAddress: "0.0.0.0"
        protocol: TCP
EOF

kind create cluster --name "$CLUSTER_NAME" --config /tmp/kind-config.yaml

# Export kubeconfig for the ubuntu SSH user
mkdir -p "/home/${USER_NAME}/.kube"
kind export kubeconfig --name "$CLUSTER_NAME" --kubeconfig "/home/${USER_NAME}/.kube/config"
chown -R "${USER_NAME}:${USER_NAME}" "/home/${USER_NAME}/.kube"

# Verify setup
docker version
kind version
kubectl version --client
KUBECONFIG="/home/${USER_NAME}/.kube/config" kubectl get nodes
```

## Verify EC2 kind cluster

```bash
kind get clusters
kubectl config current-context
kubectl get nodes
kubectl get pods -A
```

## Deploy v0.2.1 with 3 replicas

Before applying, make sure the raw GitHub Deployment manifest uses this image:

```bash
curl -s https://raw.githubusercontent.com/zhuojuelee/S26-CLO835-Assignment2/master/k8s/deployment.yaml | grep "image:"
```

Apply the Deployment and Service manifests from GitHub:

```bash
kubectl apply -f https://raw.githubusercontent.com/zhuojuelee/S26-CLO835-Assignment2/master/k8s/deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/zhuojuelee/S26-CLO835-Assignment2/master/k8s/service.yaml
```

Verify the Deployment has 3 ready replicas:

```bash
kubectl rollout status deployment/clo835-assignment2
kubectl get deployment clo835-assignment2
kubectl get rs,pods -l app=clo835-assignment2 -o wide
```

Verify the NodePort Service is exposing the app:

```bash
kubectl get service clo835-assignment2
kubectl describe service clo835-assignment2
curl http://<your-ec2-public-ip>:30080
```

## Rolling update to v0.3.0

After the v0.3.0 PR is merged and GitHub Actions has pushed the Docker image, update the running Deployment:

```bash
kubectl set image deployment/clo835-assignment2 \
  nodejs-app=zjlianlee/clo835-assignment2:0.3.0
```

Watch the rolling update complete:

```bash
kubectl rollout status deployment/clo835-assignment2
kubectl rollout history deployment/clo835-assignment2
kubectl get rs,pods -l app=clo835-assignment2 -o wide
curl http://<your-ec2-public-ip>:30080
```

## Roll back

```bash
kubectl rollout undo deployment/clo835-assignment2
kubectl rollout status deployment/clo835-assignment2
kubectl get rs,pods -l app=clo835-assignment2 -o wide
curl http://<your-ec2-public-ip>:30080
```
