# Submariner in OpenShift
_Install submariner in OpenShift._

- [Download `subctl` cli](#download-subctl-cli)
- [Create ManagedClusterSet](#create-managedclusterset)
- [VPC Peering on Managed Clusters](#vpc-peering-on-managed-clusters)

## Download subctl cli
Clone the repo and `cd` into the base
```
curl -Ls https://get.submariner.io | bash
export PATH=$PATH:~/.local/bin
echo export PATH=\$PATH:~/.local/bin >> ~/.profile
```

## Create ManagedClusterSet
From the Hub cluster, create a `ManagedClusterSet` called dev-managed-clusters:
```
apiVersion: cluster.open-cluster-management.io/v1alpha1
kind: ManagedClusterSet
metadata:
  name: dev-managed-clusters
```

Now that we have created a `ManagedClusterSet`, we need to add clusters to it.

Take a look at your managed clusters.
```
k get managedclusters 
```

Add a label that specifies the name of the `ManagedClusterSet` in the format `cluster.open-cluster-management.io/clusterset: dev-managed-clusters`

My clusters both have the label `env=dev`, so this is an example of how to add them to the `dev-managed-clusters` `ManageClusterSet`:
```
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  labels:
    cloud: Amazon
    cluster.open-cluster-management.io/clusterset: dev-managed-clusters
    clusterID: 5662d595-9d1a-4575-9365-dda538ca11c6
    env: dev
    name: us-east-1
    openshiftVersion: 4.4.29
    region: us-east-1
    vendor: OpenShift
  name: us-east-1
spec:
  hubAcceptsClient: true
  leaseDurationSeconds: 60
```



## VPC Peering on Managed Clusters
_Peer the VPCs between both managed clusters._

ACCEPTER is the VPC that you are reaching out to   
REQUESTER is the VPC that you are coming from 


After the peering connection gets created, modify the public route tables to point to the CIDR block of the opposite VPC that we are tryig to connect to.

On the Peering connection, enable DNS rendering for both sides. _This has to be done on both sides._


## Debugging
In one of the managed clusters.

```
SUB=submariner-operator   
k logs daemonset/submariner-gateway -n submariner-operator

k logs daemonset/submariner-routeagent -n $SUB

```

## Issues
Submariner requires coreDNS deployment to forward request for the domain `clusterset.local` to the lighthouse CoreDNS server in the cluster making the registry.
   
First we check if CoreDNS is configured to forward requests for domain clusterset.local to Lighthouse CoreDNS Server in the cluster making the query.   

```
kubectl -n kube-system describe configmap coredns
```

```
apiVersion: multicluster.x-k8s.io/v1alpha1
kind: ServiceExport
metadata:
  name: nginx
  namespace: default
```