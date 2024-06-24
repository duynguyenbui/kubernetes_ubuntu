#!/usr/bin/env bash

# init kubernetes 
kubeadm init --token 123456.1234567890123456 --token-ttl 0 \
             --pod-network-cidr=172.16.0.0/16 --apiserver-advertise-address=$1 \
             --cri-socket=unix:///run/containerd/containerd.sock

# config for control-plane node only 
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# CNI raw address & config for kubernetes's network 
kubectl apply -f /helpers/172.16_net_calico_v3.26.0.yaml

# kubectl completion on bash-completion dir
kubectl completion bash >/etc/bash_completion.d/kubectl

# alias kubectl to k 
echo 'alias k=kubectl'               >> ~/.bashrc
echo "alias ka='kubectl apply -f'"   >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc

# extended k8s certifications all
cp -r /helpers/update-kube-cert /tmp/update-kube-cert
chmod 755 /tmp/update-kube-cert/update-kubeadm-cert.sh
/tmp/update-kube-cert/update-kubeadm-cert.sh all --cri containerd
rm -rf /tmp/update-kube-cert
echo "Wait 30 seconds for restarting the Control-Plane Node..." ; sleep 30