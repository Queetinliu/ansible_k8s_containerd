在1.22.6上部署成功，只是需要修改kube-scheduler.yaml.j2如下:
apiVersion: kubescheduler.config.k8s.io/v1beta2
kind: KubeSchedulerConfiguration
clientConnection:
  burst: 200
  kubeconfig: "{{ k8s_dir }}/cfg/kube-scheduler.kubeconfig"
  qps: 100
enableContentionProfiling: false
enableProfiling: true
healthzBindAddress: 127.0.0.1:10251
leaderElection:
  leaderElect: true
metricsBindAddress: {{ nodeip|default(ansible_host) }}:10251
