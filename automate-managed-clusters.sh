#!/bin/bash

HUB=<hub_context>
MANAGED=<managed_context>
MANAGED_CLUSTER=<name_of_managed_cluster>

# Create the namespace 
kubectl apply -f --context $HUB -<<EOF
apiVersion: v1
kind: Namespace
metadata:
  labels:
    cluster.open-cluster-management.io/managedCluster: $MANAGED_CLUSTER
  name: $MANAGED_CLUSTER
EOF


# Change the labels in your managed cluster for the placement rules

# Create the ManagedCluster in the HUB
kubectl apply -f --context $HUB -<<EOF
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: $MANAGED_CLUSTER
  labels: 
    region: us-east-1
    cloud: aws
spec:
  hubAcceptsClient: true
EOF

# Create Klusterlet addon config file
kubectl apply -f --context $HUB -<<EOF
apiVersion: agent.open-cluster-management.io/v1
kind: KlusterletAddonConfig
metadata:
  name: $MANAGED_CLUSTER
  namespace: $MANAGED_CLUSTER
spec:
  clusterName: $MANAGED_CLUSTER
  clusterNamespace: $MANAGED_CLUSTER
  applicationManager:
    enabled: true
  certPolicyController:
    enabled: true
  clusterLabels:
    cloud: auto-detect
    vendor: auto-detect
  iamPolicyController:
    enabled: true
  policyController:
    enabled: true
  searchCollector:
    enabled: true
  version: 2.2.0
EOF

# Obtain the `klusterlet-crd.yaml` generated by managed cluster
```
kubectl get secret us-east-1-import -n us-east-1 -o jsonpath={.data.crds\\.yaml} | base64 --decode > klusterlet-crd.yaml
```

# Obtain the `import.yaml` that was generated by the managed cluster 
```
oc get secret ${CLUSTER_NAME}-import -n ${CLUSTER_NAME} -o jsonpath={.data.import\\.yaml} | base64 --decode > import.yaml
```

# Apply klusterlet-crd in the managed cluster
```
kubectl apply -f --context $MANAGED klusterlet-crd.yaml
```

# Apply the import.yaml in the managed cluster
```
kubectl apply -f --context $MANAGED import.yaml
```