# How to get the setup.py script to work
- [Change LoadBalancer](#change-loadbalancer)
- [Use Python2 to run the script](#use-python2)
- [Add kubeconfigs to one cluster](#add-kubeconfigs-to-one-cluster)
- [Add Cluster Admin Role to User](#add-cluster-admin-role-to-user)
- [Add contexts to setup script](#add-contexts-to-setup-script)

## Change LoadBalancer
Add annotation to the `dns-lb.yaml` service to change the loadBalancer to an `NLB`
```
service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
```

## Use Python2
```
sudo dnf install python2
```

## Add kubeconfigs to one cluster
Signin to the clusters through the console and then `COPY LOGIN COMMAND`. Execute the logins from the `HUB` Cluster.

Make sure you have the contexts
```
k config get-contexts
```

## Add Cluster Admin Role to User
```
oc adm policy add-cluster-role-to-user cluster-admin $(oc whoami)
```

## Add Contexts to setup script
```
$ k config get-contexts
CURRENT   NAME                                                               CLUSTER                                               AUTHINFO   NAMESPACE
          /api-cluster-qbx5l-qbx5l-sandbox368-opentlc-com:6443/user1         api-cluster-qbx5l-qbx5l-sandbox368-opentlc-com:6443   user1      
          default/api-cluster-7a63-7a63-sandbox1544-opentlc-com:6443/admin   api-cluster-7a63-7a63-sandbox1544-opentlc-com:6443    admin      default
*         hub                                                                cluster-1e30                                          admin   
```

`setup.py`
```
contexts = {
    'us-east-1': '/api-cluster-qbx5l-qbx5l-sandbox368-opentlc-com:6443/user1',
    'us-east-2':'default/api-cluster-7a63-7a63-sandbox1544-opentlc-com:6443/admin'
}
```



```
contexts = {
 'us-east-1':'admin',
  'us-east-2':'default/api-cluster-k7hh4-k7hh4-sandbox1508-opentlc-com:6443/admin'
}
```