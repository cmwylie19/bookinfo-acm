# Steps to delete managed clusters

Delete the managed cluster set
```
kubectl delete managedclusterset -A 
```

Delete managedcluster CRD from Hub
```
k delete managedcluster us-central-1
k delete managedcluster us-central-2
```

Delete Operator Group, Subscription, and MultiClusterHub

