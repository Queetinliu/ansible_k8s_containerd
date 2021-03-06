#!/bin/bash
set -e
[ -z "$1" ] && { 
    KUBE_APISERVER=`kubectl config view  --output=jsonpath='{.clusters[].cluster.server}' | head -n1 `
} || KUBE_APISERVER=$1


set +e

kubectl get clusterrole | grep flanne ||  \
 cat << EOF | kubectl apply -f -
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: flannel
rules:
  - apiGroups: ['extensions']
    resources: ['podsecuritypolicies']
    verbs: ['use']
    resourceNames: ['psp.flannel.unprivileged']
  - apiGroups:
      - ""
    resources:
      - pods
    verbs:
      - get
  - apiGroups:
      - ""
    resources:
      - nodes
    verbs:
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - nodes/status
    verbs:
      - patch
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: flannel
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: flannel
subjects:
- kind: ServiceAccount
  name: flannel
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: flannel
  namespace: kube-system
EOF


CLUSTER_NAME=`kubectl config view -o jsonpath='{.clusters[0].name}'`

KUBE_CONFIG="flanneld.kubeconfig"

while [ -z "$SECRET" ];do
 SECRET=$(kubectl -n kube-system get sa/flannel   --output=jsonpath='{.secrets[0].name}')
  sleep 1
done
JWT_TOKEN=$(kubectl -n kube-system get secret/$SECRET  --output=jsonpath='{.data.token}' | base64 -d)

k8s_dir=$2

kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=${k8s_dir}/cert/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=${KUBE_CONFIG}

kubectl config set-context ${CLUSTER_NAME} \
  --cluster=${CLUSTER_NAME} \
  --user=${CLUSTER_NAME} \
  --kubeconfig=${KUBE_CONFIG}

kubectl config set-credentials ${CLUSTER_NAME} --token=${JWT_TOKEN} --kubeconfig=${KUBE_CONFIG}

kubectl config use-context ${CLUSTER_NAME} --kubeconfig=${KUBE_CONFIG}

kubectl config view --kubeconfig=${KUBE_CONFIG}

