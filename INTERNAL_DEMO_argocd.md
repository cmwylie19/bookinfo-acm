# Deploy Bookinfo in RHACM
- [Prereqs](#prereqs)
- [Create application Namespace](#create-application-namespace)
- [Add Managed Cluster](#add-managed-cluster)
- [Create Application Resources](#create-application-resources)
- [Apply the Placement Rule to Deploy Application](#apply-the-placement-rule-to-deploy-application)
- [Add Control through Policy](#add-control-through-policy)

## Prereqs
Prerequisites for this lab include the following:
- ACM Hub Cluster with OpenShift 4.4 or greater
- ACM Managed Cluster

Next, let's setup an alias for `kubectl`
```
alias k=kubectl
alias ACM=open-cluster-management
```

## Create application Namespace
This is in your **Hub** Cluster.
_This namespace is where the argocd application will be deployed._
```
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
```
## Add Managed Cluster
Add a manged cluster from the UI or from configuration. 

Label the managed cluster, this is an essential step to the `PlacementRules`
```
environment=dev
```

## Create Application Resources
_Apply the file containing the application, subscription, and channel on the hub cluster._
```
---
apiVersion: apps.open-cluster-management.io/v1
kind: Channel
metadata:
  name: argocd-app-latest
  namespace: argocd
spec:
  type: GitHub
  pathname: https://github.com/cmwylie19/bookinfo-acm.git
---
apiVersion: app.k8s.io/v1beta1
kind: Application
metadata:
  name: argocd-app
  namespace: argocd
spec:
  componentKinds:
  - group: apps.open-cluster-management.io
    kind: Subscription
  descriptor: {}
  selector:
    matchExpressions:
    - key: app
      operator: In
      values:
      - argocd-app
---
apiVersion: apps.open-cluster-management.io/v1
kind: Subscription
metadata:
  name: argocd-app
  namespace: argocd
  labels:
    app: argocd-app
  annotations:
    apps.open-cluster-management.io/github-path: resources/argocd
    apps.open-cluster-management.io/git-branch: main
spec:
  channel: argocd/argocd-app-latest
  placement:
    placementRef:
      kind: PlacementRule
      name: all-dev-clusters
```
**output**
```
channel.apps.open-cluster-management.io/cockroachdb-app-latest created
application.app.k8s.io/cockroachdb-app created
subscription.apps.open-cluster-management.io/cockroachdb-app created
```

## Apply the Placement Rule to Deploy Application
_You have the application and necessary components created at this point, you are ready to deploy to a target cluster. Apply a placement rule so that your subscription knows where to deploy the app._
```
apiVersion: apps.open-cluster-management.io/v1
kind: PlacementRule
metadata:
  name: all-dev-clusters
  namespace: argocd
spec:
  clusterConditions:
    - type: ManagedClusterConditionAvailable
      status: "True"
  clusterSelector:
    matchLabels:
      env: dev


```
**output**
```
placementrule.apps.open-cluster-management.io/dev-clusters created
```

```
k apply -f -<<EOF
apiVersion: agent.open-cluster-management.io/v1
kind: KlusterletAddonConfig
metadata:
  name: us-east-1 
  namespace: us-east-1 
spec:
  applicationManager:
    argocdCluster: true 
EOF
```

## Add Control through Policy
_You can further control your multi-cluster environment by building policies to alert and enforce on your managed clusters._

Create the policy namespace on the **Hub Cluster**
```
k create -f -<<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: rhacm-policies
EOF
```
**output**
```
namespace/rhacm-policies created
```
   
On the Hub Cluster, create a PlacementRule to enforce policy on the management cluster. (Really all clusters where env=dev)
```
k create -f -<<EOF
apiVersion: apps.open-cluster-management.io/v1
kind: PlacementRule
metadata:
  name: dev-clusters
  namespace: rhacm-policies
spec:
  clusterConditions:
  - type: ManagedClusterConditionAvailable
    status: "True"
  clusterSelector:
    matchExpressions:
      - key: environment
        operator: In
        values: 
        - "dev"
EOF
```
**output**
```
placementrule.apps.open-cluster-management.io/dev-clusters created
```

Next let's add a policy to enforce a `LimitRange` across selected namespaces
```
k create -f -<<EOF
apiVersion: policy.open-cluster-management.io/v1
kind: Policy
metadata:
  name: policy-limitmemory
  namespace: rhacm-policies
spec:
  remediationAction: enforce
  disabled: false
  policy-templates:
    - objectDefinition:
        apiVersion: policy.open-cluster-management.io/v1
        kind: ConfigurationPolicy
        metadata:
          name: policy-limitrange
        spec:
          severity: medium
          namespaceSelector:
            exclude:
            - kube-*
            - openshift-*
            - openshift
            - open-cluster*
       # Comment this line, we want to include the default   - default
            - multicluster-endpoint
            include:
            - '*'
          object-templates:
            - complianceType: musthave
              objectDefinition:
                apiVersion: v1
                kind: LimitRange
                metadata:
                  name: default-limit-range
                spec:
                  limits:
                  - type: Container
                    default:
                      cpu: 500m
                      memory: 512Mi
                    defaultRequest:
                      cpu: 50m
                      memory: 256Mi
                    max:
                      cpu: 2
                      memory: 8Gi
                  - type: Pod
                    max:
                      cpu: 4
                      memory: 12Gi
EOF
```
**output**
```
policy.policy.open-cluster-management.io/policy-limitmemory created
```

Finally, create a `PlacementBinding` that connects the `PlacementRule` to the `Policy`
```
k create -f -<<EOF
apiVersion: policy.open-cluster-management.io/v1
kind: PlacementBinding
metadata:
  name: binding-policy-limitmemory
  namespace: rhacm-policies
placementRef:
  name: dev-clusters
  kind: PlacementRule
  apiGroup: apps.open-cluster-management.io
subjects:
- name: policy-limitmemory
  kind: Policy
  apiGroup: policy.open-cluster-management.io
EOF
```
**output**
```
placementbinding.policy.open-cluster-management.io/binding-policy-limitmemory created
```
   
Let's check of the policy created was successful by looking at `LimitRanges` across all namespaces on the `managed cluster`
```
k get limitrange -A
```
   
**output**
```
NAMESPACE           NAME                  CREATED AT
default             default-limit-range   2021-09-27T14:15:50Z
managed-us-east-1   default-limit-range   2021-09-27T14:15:50Z
```


