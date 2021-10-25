# Install ACM

Create the namespace
```
kubectl apply -f -<<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: open-cluster-management
EOF
```

Create the Operator Group, Subscription and Pull Secret
```
kubectl apply -f -<<EOF
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: acm-operator
spec:
  targetNamespaces:
  - open-cluster-management
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: acm-operator-subscription
  namespace: open-cluster-management
spec:
  sourceNamespace: openshift-marketplace
  source: redhat-operators
  channel: release-2.3
  installPlanApproval: Automatic
  name: advanced-cluster-management
---
apiVersion: v1
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64 encoded secret>
kind: Secret
metadata:
  name: pull-secret
  namespace: open-cluster-management
EOF
```

Create the MultiClusterHub once the CRD is present:
```
kubectl apply -f -<<EOF
apiVersion: operator.open-cluster-management.io/v1
kind: MultiClusterHub
metadata:
  name: multiclusterhub
  namespace: open-cluster-management
spec:
  imagePullSecret: pull-secret
EOF
```
