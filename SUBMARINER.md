# Submariner in OpenShift
_Install submariner in OpenShift._

- [Download `subctl` cli](#download-subctl-cli)
- [Deploy Broker on Managed Cluster](#deploy-broker-on-managed-cluster)
- [Join Hub and Managed Cluster](#join-hub-and-managed-cluster)

## Download subctl cli
Clone the repo and `cd` into the base
```
curl -Ls https://get.submariner.io | bash
export PATH=$PATH:~/.local/bin
echo export PATH=\$PATH:~/.local/bin >> ~/.profile
```

## Deploy Broker on Managed Cluster
This is done from the Hub Cluster.
```
subctl deploy-broker ~/.kube/config --service-discovery
```

output
```
 ✓ Setting up broker RBAC 
 ✓ Deploying the Submariner operator 
 ✓ Created operator CRDs
 ✓ Created operator namespace: submariner-operator
 ✓ Created operator service account and role
 ✓ Updated the privileged SCC
 ✓ Created lighthouse service account and role
 ✓ Updated the privileged SCC
 ✓ Created Lighthouse service accounts and roles
 ✓ Deployed the operator successfully
 ✓ Deploying the broker
 ✓ The broker has been deployed
 ✓ Creating broker-info.subm file
 ✓ A new IPsec PSK will be generated for broker-info.subm
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

## Join Hub and Managed Cluster
In the `Hub`. In this command `--kubeconfig` references the `~/.kube/config` on the `HUB`. The ClusterID can be whatever identifier you want.
```
subctl join --kubeconfig ~/.kube/config broker-info.subm --clusterid hub
```

output
```
* broker-info.subm says broker is at: https://api.cluster-3cb8.3cb8.sandbox426.opentlc.com:6443
? Which node should be used as the gateway? ip-10-0-159-62.us-east-2.compute.internal
        Network plugin:  OpenshiftSDN
        Service CIDRs:   [172.30.0.0/16]
        Cluster CIDRs:   [10.128.0.0/14]
 ✓ Discovering network details
 ✓ Validating Globalnet configurations
 ✓ Discovering multi cluster details
 ✓ Deploying the Submariner operator 
 ✓ Created Lighthouse service accounts and roles
 ✓ Creating SA for cluster 
 ✓ Deploying Submariner
 ✓ Submariner is up and running
```

In the `Managed`. You will need to copy the `~/.kube/config` from the `managed` to the `Hub` cluster giving it a unique name, I called mine `managed-kube-config`.
 In this command `--kubeconfig` references the `managed-kube-config`, which is the `~/.kube/config` from the `managed` cluster.
```
subctl join --kubeconfig managed-kube-config broker-info.subm --clusterid managed
```

output
```
* broker-info.subm says broker is at: https://api.cluster-3cb8.3cb8.sandbox426.opentlc.com:6443
? Which node should be used as the gateway? ip-10-0-131-161.us-east-2.compute.internal
        Network plugin:  OpenshiftSDN
        Service CIDRs:   [172.30.0.0/16]
        Cluster CIDRs:   [10.128.0.0/14]
 ✓ Discovering network details
 ✓ Validating Globalnet configurations
 ✓ Discovering multi cluster details
 ✓ Deploying the Submariner operator 
 ✓ Created operator CRDs
 ✓ Created operator namespace: submariner-operator
 ✓ Created operator service account and role
 ✓ Updated the privileged SCC
 ✓ Created lighthouse service account and role
 ✓ Updated the privileged SCC
 ✓ Created Lighthouse service accounts and roles
 ✓ Deployed the operator successfully
 ✓ Creating SA for cluster
 ✓ Deploying Submariner
 ✓ Submariner is up and running
```