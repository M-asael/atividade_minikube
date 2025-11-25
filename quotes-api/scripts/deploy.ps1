# Build & load image into Minikube, then apply manifests
param(
  [string]$Tag = "1.0.0"
)

Write-Host "Building image quotes-api:$Tag"
docker build -t quotes-api:$Tag ..

Write-Host "Loading image into Minikube"
minikube image load quotes-api:$Tag

Write-Host "Applying manifests"
kubectl apply -f ../k8s/deployment.yaml
kubectl apply -f ../k8s/service.yaml
kubectl apply -f ../k8s/ingress.yaml

kubectl get deploy,svc,ing
Write-Host "Start tunnel in another terminal: minikube tunnel"
