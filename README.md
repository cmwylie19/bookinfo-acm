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
_This namespace is where the bookinfo application will be deployed._
```
k apply -f apps/bookinfo/namespace.yaml
```
**sample output**
```
namespace/bookinfo created
```
## Add Managed Cluster
Add a manged cluster from the UI or from configuration. 

Label the managed cluster, this is an essential step to the `PlacementRules`
```
environment=dev
```



## Create Application Resources
_Apply the file containing the applicat, subscription, and channel on the hub cluster._
```
k create -f apps/bookinfo/application.yaml
```
**output**
```
channel.apps.open-cluster-management.io/bookinfo-app-latest created
application.app.k8s.io/bookinfo-app created
subscription.apps.open-cluster-management.io/bookinfo-app created
```

## Apply the Placement Rule to Deploy Application
_You have the application and necessary components created at this point, you are ready to deploy to a target cluster. Apply a placement rule so that your subscription knows where to deploy the app._
```
k apply -f apps/bookinfo/placement-rule-dev-clusters.yaml
```
**output**
```
placementrule.apps.open-cluster-management.io/dev-clusters created
```

## Add Control through Policy
_You can further control your multi-cluster environment by building policies to alert and enforce on your managed clusters._

Create the policy namespace on the Hub Cluster
```
k apply -f resources/policies/namespace.yaml
```
**output**
```
namespace/rhacm-policies created
```
   
On the Hub Cluster, create a PlacementRule to enforce policy on the management cluster.
```
k create -f resources/policies/config_placement_rule.yaml
```
**output**
```
placementrule.apps.open-cluster-management.io/dev-clusters created
```

Next let's add a policy to enforce a `LimitRange` across selected namespaces
```
k create -f resources/policies/config_limitrange.yaml
```
**output**
```
policy.policy.open-cluster-management.io/policy-limitmemory created
```

Finally, create a `PlacementBinding` that connects the `PlacementRule` to the `Policy`
```
k create -f resources/policies/config_placement_binding.yaml
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
bookinfo            default-limit-range   2021-09-15T21:37:28Z
us-east-1-managed   default-limit-range   2021-09-15T16:49:34Z
```

