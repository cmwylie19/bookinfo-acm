# Deploy Bookinfo in RHACM
- [Prereqs](#prereqs)
- [Create application Namespace](#create-application-namespace)
- [Create Application Resources](#create-application-resources)
- [Apply the Placement Rule to Deploy Application](#apply-the-placement-rule-to-deploy-application)

## Prereqs
Prerequisites for this lab include the following:
- ACM Hub Cluster with OpenShift 4.4 or greater
- ACM Managed Cluster

Next, let's setup an alias for `kubectl`
```
alias k=kubectl
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

## Create Application Resources
_Apply the file containing the applicat, subscription, and channel on the hub cluster._
```
k create -f apps/bookinfo/application.yaml
```
**sample output**
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