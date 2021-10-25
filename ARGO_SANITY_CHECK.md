kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


Patch the `argocd-server` to be of type `LoadBalancer`:
```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: httpbin
spec:
  destination:
    name: ''
    namespace: default
    server: 'https://kubernetes.default.svc'
  source:
    path: apps/httpbin
    repoURL: 'https://github.com/cmwylie19/bookinfo-acm.git'
    targetRevision: HEAD
    directory:
      recurse: true
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```