# terraform-raspberrypi-bootstrap

This repo is modified version of https://github.com/clayshek/terraform-raspberrypi-bootstrap

To run it on your cluster modify variables.tf accordingly.  Running `terraform apply` will setup machine, install Docker and install Kubernetes

  After this master and other nodes has to be setup manually. Following instructions given here https://gist.github.com/alexellis/fdbc90de7691a1b9edb545c17da2d975#gistcomment-2228114.  Everything is setup till setup master node

## Setup master node01
`ssh pi@$master_node_ip`

 ```
 sudo kubeadm init --token-ttl=0 --apiserver-advertise-address=$master_node_ip --kubernetes-version v1.13.1
 ```
 Save the join token and token hash, it will be needed in "Setup slave nodes02-05"

 Make local config for pi user, so login as pi on node01

 ```
 mkdir -p $HOME/.kube
 sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
 sudo chown $(id -u):$(id -g) $HOME/.kube/config
 ```
 Check it's working (except the dns pods wont be ready)

 ```
 kubectl get pods --all-namespaces
 ```
 Setup kubernetes ovverlay networking

 ```
 kubectl apply -f https://git.io/weave-kube-1.6
 kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
 ```
 ## Setup slave nodes02-05
 Join the cluster using the join token and token hash when you ran kubeadm on node01

 ```
 sudo kubeadm join $master_node_ip:6443 --token xxxxxxxxxxxxxxxxxxxxxxxx --discovery-token-ca-cert-hash sha256:yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
 ```
 Back on the master node01 check the nodes have joined the cluster and that pods are running:

 ```
 kubectl get nodes
 kubectl get pods --all-namespaces
 ```
 ## Deploy dashboard
 Deploy the tls disabled version of the dashboard.  Copy paste below yml into command line.  Hit enter.

 ```
 echo -n 'apiVersion: rbac.authorization.k8s.io/v1beta1
 kind: ClusterRoleBinding
 metadata:
   name: kubernetes-dashboard
   labels:
     k8s-app: kubernetes-dashboard
 roleRef:
   apiGroup: rbac.authorization.k8s.io
   kind: ClusterRole
   name: cluster-admin
 subjects:
 - kind: ServiceAccount
   name: kubernetes-dashboard
   namespace: kube-system' | kubectl apply -f -

 kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/alternative/kubernetes-dashboard-arm.yaml
 ```
 To access the dashboard start the proxy on node01:
 `kubectl proxy --address 0.0.0.0 --accept-hosts '.*' `

 Then from your pc point your browser at:
 `http://$master_node_ip:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/`



 ## License

This is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT).
