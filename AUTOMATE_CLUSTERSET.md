# Automate Clusterset/ArgoCD (OpenShift Gitops)

Add `ManagedClusterSet` CR
```
kubectl apply -f -<<EOF
apiVersion: cluster.open-cluster-management.io/v1alpha1
kind: ManagedClusterSet
metadata:
  name: cockroach-clusters
  namespace: open-cluster-management
EOF
```

Add Clusters to `ManagedClusterSet` by adding labels to the `ManagedCluster` CRD

**Imperative**
```
kubectl label managedcluster us-east-1 -n $ACM cluster.open-cluster-management.io/clusterset=cockroach-clusters 
```

**Declarative** (Make sure you keep existing labels for placement)
```
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: us-east-1
  labels:
    env: dev
    region: us-east-1
    cluster.open-cluster-management.io/clusterset: cockroach-clusters # <- ADD THIS
spec:
  hubAcceptsClient: true
```

Create a `ManagedClusterSetBinding`, the name of the `ManagedClusterSetBinding` must be equal to the name of the `ManagedClusterSet`:
```
kubectl apply -f -<<EOF
apiVersion: cluster.open-cluster-management.io/v1alpha1
kind: ManagedClusterSetBinding
metadata:
  namespace: default
  name: cockroach-clusters
spec:
  clusterSet: cockroach-clusters
EOF
```

Create a Placement for the managed cluster set in the same namespace
```
kubectl apply -f -<<EOF
apiVersion: cluster.open-cluster-management.io/v1alpha1
kind: Placement
metadata:
  name: env-dev-placement
  namespace: default
spec:
  clusterSets:
    - cockroach-clusters
  predicates:
    - requiredClusterSelector:
        labelSelector:
          matchLabels:
            env: dev
EOF
```

Lookup placement decision
```
kubectl get placementdecision -n open-cluster-management
```

Bind a `Placement` to the cluster with a `GitOpsCluster` CR
```
kubectl apply -f -<<EOF
apiVersion: apps.open-cluster-management.io/v1alpha1
kind: GitOpsCluster
metadata:
  name: gitops-cluster-crdb
  namespace: default
spec:
  argoServer:
    cluster: local-cluster
    argoNamespace: openshift-gitops
  placementRef:
    kind: Placement
    apiVersion: cluster.open-cluster-management.io/v1alpha1
    name: env-dev-placement
EOF
```