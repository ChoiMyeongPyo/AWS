
# Amazon EKS + Argo CD + GitOps 구축 일지

## 📌 목표
- EKS 클러스터 생성
- ALB Controller 설치 및 외부 노출 구성
- Argo CD 설치 및 외부에서 UI 접근
- GitHub 레포지토리와 연동하여 GitOps 기반 배포 자동화

---

## 1️⃣ EKS 클러스터 생성

### 📁 eks-cluster.yaml

```yaml
cat eks-cluster.yaml
# 수정 후 eks-cluster.yaml (vpc 블록 제거)
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: sa-eks-cluster
  region: ap-northeast-2

managedNodeGroups:
  - name: spot-nodes
    instanceType: t3.medium
    desiredCapacity: 2
    minSize: 2
    maxSize: 4
    spot: true
    volumeSize: 20
    privateNetworking: true
    iam:
      withAddonPolicies:
        albIngress: true
        externalDNS: true
        autoScaler: true
    labels:
      lifecycle: Ec2Spot
    tags:
      lifecycle: Ec2Spot
      "k8s.io/cluster-autoscaler/enabled": "true"
      "k8s.io/cluster-autoscaler/sa-eks-cluster": "owned"
```

```bash
# eksctl create cluster -f eks-cluster.yaml
```

---

## 2️⃣ ALB Controller 설치

### ✅ IAM Policy 생성

```bash
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.2/docs/install/iam_policy.json

aws iam create-policy   --policy-name AWSLoadBalancerControllerIAMPolicy-Fix   --policy-document file://iam_policy.json
```

이미 있으면 `create-policy`는 생략하고 아래 `attach`만 진행

### ✅ IAM Role 연결 (IRSA)

```bash
eksctl create iamserviceaccount   --cluster sa-eks-cluster   --region ap-northeast-2   --namespace kube-system   --name aws-load-balancer-controller   --attach-policy-arn arn:aws:iam::{AWS 계정}:policy/AWSLoadBalancerControllerIAMPolicy-Fix   --approve   --override-existing-serviceaccounts
```

### ✅ Helm 설치

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller   -n kube-system   --set clusterName=sa-eks-cluster   --set serviceAccount.create=false   --set serviceAccount.name=aws-load-balancer-controller   --set image.repository=602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller   --set region=ap-northeast-2   --set vpcId=vpc-xxxxxxxxxxxxxxxxx   --set enableShield=false   --set enableWaf=false   --set enableWafv2=false
```

`enableWaf` 등을 꺼주는 게 권한 오류 피하는 데 유리

⚠️ 권한 오류 발생 시  
`elasticloadbalancing:DescribeListenerAttributes` 권한이 없다는 오류 → 정책에 권한 추가하고 파드 재생성

---

## 3️⃣ Argo CD 설치 및 외부 노출

### ✅ Helm 설치

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

kubectl create namespace argocd

helm install argocd argo/argo-cd   -n argocd   --set server.service.type=LoadBalancer   --set server.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internet-facing"   --set server.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-nlb-target-type"="ip"
```

LoadBalancer 생성 지연 시 IAM/ALB 권한 확인 필요  
이후 EXTERNAL-IP 값이 할당되면 웹 UI 접근 가능

### ✅ 초기 패스워드 확인

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

---

## 4️⃣ GitHub와 연동해 GitOps 구성

### ✅ GitHub 레포지토리 주소

```bash
https://github.com/ChoiMyeongPyo/DevOps.git
```

경로: `aws/aws_eks_poc/argocd`

### ✅ 디렉토리 구조

```bash
argocd/
├── hello-nginx-deployment.yaml
├── hello-nginx-service.yaml
├── hello-nginx-ingress.yaml
└── kustomization.yaml
```

### 📁 kustomization.yaml

```yaml
resources:
  - hello-nginx-deployment.yaml
  - hello-nginx-service.yaml
  - hello-nginx-ingress.yaml
```

### ✅ Argo CD UI에서 Application 등록

- Repository URL: `https://github.com/ChoiMyeongPyo/DevOps.git`
- Path: `aws/aws_eks_poc/argocd`
- Cluster: `in-cluster`
- Namespace: `default` (또는 원하는 네임스페이스)
- Sync Policy: 수동/자동 선택 가능

등록 후 Sync 하면 Git의 YAML이 EKS 클러스터에 적용됨

### ✅ 확인

```bash
kubectl get all -n default
```

배포된 nginx 리소스들 확인 가능  
→ `kubectl port-forward` 또는 Ingress를 통해 접근 확인

---

## ✅ 다음 학습/작업 계획

| 단계 | 내용 |
|------|------|
| ✅ 1 | ALB Controller 및 Argo CD 설치 및 외부 접근 설정 완료 |
| ✅ 2 | GitHub 연동 및 GitOps 기반 배포 파이프라인 구성 완료 |
| 🔜 3 | Helm chart로 관리되는 애플리케이션 GitOps 구성 |
| 🔜 4 | Argo CD ApplicationSet 구성 연습 |
| 🔜 5 | Argo CD RBAC, 인증 연동 (OIDC) 구성 |
| 🔜 6 | Argo Rollouts와 연동한 Canary 배포 구성 |

---

## 📌 회고

- ALB Controller는 권한 부족 시 오류가 잘 드러나지 않고 EXTERNAL-IP pending으로만 표시되어 디버깅이 필요함
- Argo CD는 UI 및 Git 연동이 직관적이어서 배포 환경 표준화에 매우 적합함
- IRSA 기반 IAM 정책 연결 이후에도 기존 파드에는 적용되지 않으므로 재생성 필요
