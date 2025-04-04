# 📘 EKS에서 ALB Ingress Controller 기반 NGINX 애플리케이션 배포 실작 문서

## 1. 🎯 목표

- EKS 클러스터에서 ALB Ingress Controller를 활용해 nginx 애플리케이션 배포
- ALB의 TargetGroup을 IP 방식으로 구성
- ConfigMap을 통해 nginx의 index.html 정의
- 한글 및 이모지 출력 시 인코딩 문제 해결
- 불필요한 ReplicaSet 정리 및 리소스 삭제

## 2. 🔧 사전 조건

- AWS Load Balancer Controller가 설치된 EKS 클러스터
- 퍼블릭 서비스에 ELB 생성 가능한 태그 설정
- kubectl, AWS CLI 사용 가능 환경
- ALB Ingress Controller가 IngressClassName `alb`로 등록되어 있어야 함

## 3. 📦 리소스 정의 및 배포

### 3.1 Deployment + ConfigMap (hello-nginx-deployment.yaml)

```yaml
<... trimmed for readability ...>
```

### 3.2 Service (hello-nginx-service.yaml)

```yaml
<... trimmed for readability ...>
```

### 3.3 Ingress (hello-nginx-ingress.yaml)

```yaml
<... trimmed for readability ...>
```

## 4. 🧪 배포 및 테스트

```bash
kubectl apply -f hello-nginx-deployment.yaml
kubectl apply -f hello-nginx-service.yaml
kubectl apply -f hello-nginx-ingress.yaml
```

### ALB DNS 확인

```bash
kubectl get ingress hello-nginx-ing -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
curl http://<ALB-DNS>
```

## 5. 💠 ConfigMap 수정 및 반영

```bash
kubectl rollout restart deployment hello-nginx
```

## 6. ⚙️ ReplicaSet 정리

```bash
kubectl get rs -n kube-system
kubectl delete rs <replicaSetName> -n kube-system
```

## 7. 🧹 리소스 삭제

```bash
kubectl delete -f hello-nginx-deployment.yaml
kubectl delete -f hello-nginx-service.yaml
kubectl delete -f hello-nginx-ingress.yaml
```

또는:

```bash
kubectl delete -f hello-nginx-*
```

## 8. 📝 트러브슈트팅 요조

| 문제 | 원인 | 해결 방법 |
|------|------|-----------|
| ALB DNS 접근 불가 | DNS 전파 지역 | 수 분 대기 후 재시도 or `nslookup` 확인 |
| 한글 깨짓 | HTML에 charset 설정 없음 | `<meta charset="UTF-8">` 추가 |
| ConfigMap 반영 안 되음 | nginx는 파일 변환 감지 못함 | Deployment 재시작 필요 |
| RS 삭제 안 되음 | 네임스페이스 미지정 or 이미 삭제 | `-n` 옵션으로 재확인 |

