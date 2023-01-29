#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list

apt update
# docker pre-install setting
apt install -yqq --no-install-recommends golang ca-certificates curl gnupg lsb-release apt-transport-https sysvbanner gettext-base
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null
apt update

# k8s pre-install setting
curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt update

# install docker and k8s
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
apt install -y kubectl # kubelet kubeadm
# apt-mark hold kubelet kubeadm kubectl

# docker post-install step
systemctl start docker
systemctl enable docker.service
systemctl enable containerd.service
systemctl restart docker
chmod 666 /var/run/docker.sock

isRun=$(ps -ef | grep dockerd | wc -l)
if [ $isRun == 1 ]; then
    dockerd & # WSL에서는 systemctl이 동작 안할떄가 있음
fi

# install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

# create cluster using kind.
kind create cluster
# kind cluster node 설정

# docker image build
docker compose build
kind load docker-image rank-service wordle-web score-service user-service

# using kind
kubectl config use-context kind-kind

# set strict ARP config
ARPDIFF=$(kubectl get configmap kube-proxy -n kube-system -o yaml |
    sed -e "s/strictARP: false/strictARP: true/g" |
    kubectl diff -f - -n kube-system)
if [ $(echo $ARPDIFF | tr -d '\n' | wc -l) ]; then
    kubectl apply -f - -n kube-system
fi

# install MetalLB (load balancer)
kubectl apply -f ./metallb/metallb-native.yaml
echo "Wait for Metal LB"
kubectl wait --namespace metallb-system \
    --for=condition=ready pod \
    --selector=app=metallb \
    --timeout=90s

# set metallb config
KIND_NET_CIDR=$(docker network inspect kind -f '{{(index .IPAM.Config 0).Subnet}}')
METALLB_IP_START=$(echo ${KIND_NET_CIDR} | sed "s@0.0/16@255.200@")
METALLB_IP_END=$(echo ${KIND_NET_CIDR} | sed "s@0.0/16@255.250@")
METALLB_IP_RANGE="${METALLB_IP_START}-${METALLB_IP_END}"
sed -i "s/172.19.255.200-172.19.255.250/$METALLB_IP_RANGE/" ./metallb/metallb-config.yaml
kubectl apply -f ./metallb/metallb-config.yaml

# delete previous download files
if [ -d istio-1.16.1 ]; then
    rm -Rf istio-1.16.1
fi

# install istio
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.16.1 TARGET_ARCH=x86_64 sh -
export PATH=$PWD/istio-1.16.1/bin:$PATH
chmod 777 -R ./istio-1.16.1
# istioctl install -y --set profile=demo
istioctl install -y # 성능이 낮은 머신에서 동작 안함

# istio 자동 인젝션
kubectl label namespace default istio-injection=enabled

# run my app
kubectl apply -f kube.yaml

# check my app
export SERVICE_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')

pushd traefik
envsubst <dynamic.yml.template >dynamic.yml
docker compose up -d
popd

if [ $(echo $SERVICE_IP | wc -l) ]; then
    banner FINISHED
    echo "Now... my service can access ==> http://localhost:5173"
fi
