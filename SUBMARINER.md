# Submariner in ACM
_Quick install of submariner on ACM._

- [Download the repo](#download-the-repo)
- [Apply the Manifest of submariner-addon](#apply-the-manifest-of-submariner-addon)
- [Setup Submariner on the Hub Cluster](#setup-submariner-on-the-hub-cluster)

## Download the Repo
Clone the repo and `cd` into the base
```
git clone https://github.com/open-cluster-management/submariner-addon
cd submariner-addon
```

## Apply the Manifest of submariner-addon
This is using Kustomize, so we apply with `-k`
```
kubectl create -k deploy/config/manifests
```

output
```
namespace/open-cluster-management configured
customresourcedefinition.apiextensions.k8s.io/submarinerconfigs.submarineraddon.open-cluster-management.io created
serviceaccount/submariner-addon created
clusterrole.rbac.authorization.k8s.io/submariner-addon created
clusterrolebinding.rbac.authorization.k8s.io/submariner-addon created
deployment.apps/submariner-addon created
```

## Setup Submariner on the Hub Cluster
Create a `ManagedClusterSet`. Make sure you are in the `Hub`.
```
kubectl apply -f -<<EOF
apiVersion: cluster.open-cluster-management.io/v1alpha1
kind: ManagedClusterSet
metadata:
  name: pro
EOF
```