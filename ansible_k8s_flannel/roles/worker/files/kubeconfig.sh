#!/bin/bash
kubectl config set-cluster kubernetes --certificate-authority=$1/cert/ca.pem --embed-certs=true  --server=$2   --kubeconfig=kube-proxy.kubeconfig
kubectl config set-credentials kube-proxy  --client-certificate=$1/kube-proxy/cert/kube-proxy.pem --client-key=$1/kube-proxy/cert/kube-proxy-key.pem --embed-certs=true --kubeconfig=kube-proxy.kubeconfig
kubectl config set-context kube-proxy --cluster=kubernetes --user=kube-proxy --kubeconfig=kube-proxy.kubeconfig
kubectl config use-context kube-proxy --kubeconfig=kube-proxy.kubeconfig

