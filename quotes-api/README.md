# Quotes API on Minikube (Windows)

Exemplo didático: API FastAPI containerizada e publicada no **Minikube**.
Inclui manifests Kubernetes, Helm chart mínimo e CI básico (GitHub Actions).

## 1) Pré-requisitos (Windows)
- Windows 10/11 com WSL2 recomendado
- Docker Desktop (backend WSL2 habilitado)
- kubectl, minikube e helm
  - PowerShell (Admin):
    ```powershell
    winget install -e --id Docker.DockerDesktop
    winget install -e --id Kubernetes.kubectl
    winget install -e --id Kubernetes.minikube
    winget install -e --id Helm.Helm
    ```

## 2) Subir o cluster
```powershell
minikube start --driver=docker --cpus=4 --memory=6144 --kubernetes-version=v1.30.0
minikube addons enable ingress
kubectl -n ingress-nginx get pods
```

## 3) Build & Test local (opcional)
```powershell
cd quotes-api
docker build -t quotes-api:1.0.0 .
docker run -d -p 8000:8000 --name quotes quotes-api:1.0.0
curl http://localhost:8000/healthz
docker rm -f quotes
```

## 4) Publicar no Minikube (manifests)
```powershell
# Dentro da pasta quotes-api
minikube image load quotes-api:1.0.0
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
kubectl get deploy,svc,ing
```

Abra um terminal separado e execute:
```powershell
minikube tunnel
```

**Mapeie o host** no Windows (Notepad como Admin):  
Edite `C:\Windows\System32\drivers\etc\hosts` e adicione:  
`127.0.0.1  quotes.local`

Teste:
```powershell
curl http://quotes.local/healthz
curl http://quotes.local/quotes/random
```

## 5) Helm (opcional)
```powershell
cd quotes-api
helm install quotes charts/quotes
helm upgrade quotes charts/quotes --set image.tag=1.0.1
helm uninstall quotes
```

## 6) CI (opcional)
- Workflow em `.github/workflows/ci.yml` roda testes e build (sem push).

## 7) Troubleshooting
- Pods pendentes: `kubectl describe pod -l app=quotes-api`
- Ingress 404: addon habilitado e `ingressClassName: nginx`
- Sem tunnel: use `kubectl port-forward svc/quotes-svc 8080:80`
- Imagem não encontrada: `minikube image load` e reimplante

## 8) Scripts
- `scripts/deploy.ps1` — build, load e apply (manifests)
- `scripts/cleanup.ps1` — remove recursos

## 9) Limpeza
```powershell
helm uninstall quotes  # se tiver instalado via Helm
kubectl delete -f k8s/ingress.yaml -f k8s/service.yaml -f k8s/deployment.yaml
minikube stop
minikube delete
```
