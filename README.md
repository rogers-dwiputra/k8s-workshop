# 🐳 Kubernetes Workshop – Minikube Demo

Workshop ini memperkenalkan konsep dasar deployment dan scaling aplikasi di Kubernetes dengan pendekatan **single service** dan **multi-service (microservices)** menggunakan Minikube secara lokal.

## 📁 Struktur Direktori

```
k8s-workshop/
├── demo-single-service/         # Aplikasi Node.js tunggal + Service
└── demo-microservice/           # 3 microservices: auth, core, notification
    ├── service-auth/
    ├── service-core/
    ├── service-notification/
    └── ingress.yaml
```

---

## 🚀 Prasyarat

- [x] Docker
- [x] Minikube
- [x] kubectl

> Pastikan Minikube aktif:  
```bash
minikube start
```

---

## 🧪 Demo 1: Single Service Deployment

### 📍 Jalankan langkah berikut:

```bash
cd k8s-workshop/demo-single-service
eval $(minikube docker-env)           # Gunakan Docker di Minikube VM
docker build -t demo-pod-local .
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
minikube service demo-service         # Akan membuka URL di browser
```

---

## 🧩 Demo 2: Microservices + Ingress

### 🧱 Build image untuk setiap service

```bash
cd k8s-workshop/demo-microservice
eval $(minikube docker-env)

docker build -t auth-service ./service-auth
docker build -t core-service ./service-core
docker build -t notification-service ./service-notification
```

### 🗂️ Deploy tiap service ke Kubernetes

```bash
kubectl apply -f service-auth/deployment.yaml
kubectl apply -f service-auth/service.yaml

kubectl apply -f service-core/deployment.yaml
kubectl apply -f service-core/service.yaml

kubectl apply -f service-notification/deployment.yaml
kubectl apply -f service-notification/service.yaml
```

### 🌐 Setup Ingress

```bash
minikube addons enable ingress
kubectl apply -f ingress.yaml
```

> Ingress dikonfigurasi untuk mengakses masing-masing service lewat path:

* [http://127.0.0.1.nip.io/auth](http://127.0.0.1.nip.io/auth)
* [http://127.0.0.1.nip.io/core](http://127.0.0.1.nip.io/core)
* [http://127.0.0.1.nip.io/notification](http://127.0.0.1.nip.io/notification)

> **Kamu tidak perlu mengedit `/etc/hosts` karena menggunakan [nip.io](https://nip.io)**.

### 🚪 Jalankan Minikube Tunnel (wajib untuk Ingress)

```bash
minikube tunnel
```

> Biarkan jendela terminal ini tetap terbuka selama proses berjalan.

---

## 🛠️ Perintah `kubectl` Dasar untuk Belajar

| Kategori          | Perintah                                                                                 |
| ----------------- | ---------------------------------------------------------------------------------------- |
| 🔍 Lihat objek    | `kubectl get pods`<br>`kubectl get svc`<br>`kubectl get deploy`<br>`kubectl get ingress` |
| 📖 Detail         | `kubectl describe pod <nama-pod>`<br>`kubectl describe svc <nama-service>`               |
| 🔁 Scaling        | `kubectl scale deployment <nama-deployment> --replicas=3`                                |
| 💥 Simulasi gagal | `kubectl delete pod <nama-pod>` (pod akan otomatis restart oleh deployment)              |
| 📊 Dashboard      | `minikube dashboard` (akan membuka UI visual di browser)                                 |

---

## ✅ Tips Tambahan

* Untuk melihat respons dari berbagai pod (load balancing), coba:

  ```bash
  watch -n 0.5 curl http://127.0.0.1.nip.io/core
  ```

  → hostname dari pod yang berbeda akan muncul.

* Untuk membersihkan semua resource:

  ```bash
  kubectl delete -f .
  ```

---

## 🎯 Tujuan Belajar

* Menjalankan aplikasi di pod Kubernetes
* Mengenal deployment, service, dan ingress
* Memahami konsep scaling dan high availability
* Mengetahui dasar interaksi antar microservices

---

## 🔧 Troubleshooting

### Ingress tidak bisa diakses?

1. **Pastikan ingress addon aktif:**
   ```bash
   minikube addons enable ingress
   ```

2. **Jalankan minikube tunnel:**
   ```bash
   minikube tunnel
   ```

3. **Alternatif: gunakan Minikube IP:**
   ```bash
   MINIKUBE_IP=$(minikube ip)
   curl http://$MINIKUBE_IP/auth
   ```

### Pod tidak bisa pull image?

Pastikan menggunakan Docker environment Minikube:
```bash
eval $(minikube docker-env)
```

### Service tidak merespons?

Cek status pod dan service:
```bash
kubectl get pods
kubectl get svc
kubectl logs <nama-pod>
```

---

Selamat mencoba! 🚀  
Jika kamu mengalami kendala, gunakan `kubectl describe` atau `kubectl logs` untuk investigasi.

## 🚀 Demo 3: Deploy ke Amazon EKS dengan Spot Instances
### IAM Role
- IAM User dengan akses: eks:*, ec2:*, iam:*
- VPC yang bisa dibuat otomatis oleh eksctl, atau sudah ada sebelumnya.

### 🧰 Instalasi CLI (opsional jika belum)
#AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install
aws --version

#EKSCTL
# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

sudo mv /tmp/eksctl /usr/local/bin
eksctl version

#KUBECTL
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
### 🗂️ Buat Cluster

eksctl create cluster -f cluster.yaml
Butuh ~15–20 menit. Cluster akan menggunakan EC2 Spot Instances untuk efisiensi biaya.

### 🔗 Konfigurasi kubectl ke cluster

aws eks --region ap-south-1 update-kubeconfig --name nginx-cluster
### 🚀 Deploy Aplikasi

kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
### 🌐 Akses Aplikasi

kubectl describe service nginx-service
Cari bagian:

LoadBalancer Ingress: <dns-name>
Lalu akses di browser:

http://<dns-name>

### Delete Resource After Workshop
# Hapus deployment dan service
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml

# Hapus cluster EKS sepenuhnya
eksctl delete cluster --name nginx-cluster --region ap-south-1

Pastikan tidak ada resource kubectl get all yang tertinggal setelah delete.

Gunakan kubectl config get-contexts untuk memastikan kamu berada di context yang tepat saat menjalankan perintah delete.