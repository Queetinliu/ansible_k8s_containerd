#!/bin/bash
k8s_dir=$1
ip=$2
rolename=$3
cn=$4 
 kubectl config set-cluster kubernetes --certificate-authority=$k8s_dir/cert/ca.pem --embed-certs=true --server="https://$ip:6443" --kubeconfig=$rolename.kubeconfig
 kubectl config set-credentials $cn --client-certificate=$k8s_dir/cert/$rolename.pem --client-key=$k8s_dir/cert/$rolename-key.pem --embed-certs=true --kubeconfig=$rolename.kubeconfig
 kubectl config set-context $cn --cluster=kubernetes --user=$cn --kubeconfig=$rolename.kubeconfig
 kubectl config use-context $cn --kubeconfig=$rolename.kubeconfig
 touch  has-$rolename
