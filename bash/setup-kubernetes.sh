#!/usr/bin/env bash

sudo swapoff -a

suod kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml

kubectl taint nodes --all node-role.kubernetes.io/master-
