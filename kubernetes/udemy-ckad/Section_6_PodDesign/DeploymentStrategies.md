# CKAD 실습: 롤링 업데이트(Rolling Updates), 롤백(Rollbacks) & 배포 전략(Deployment Strategies)

---

## 📌 1. 개요

이 실습에서는 **쿠버네티스의 롤링 업데이트(Rolling Updates)와 롤백(Rollbacks)** 방법을 학습하고, **다양한 배포 전략(Deployment Strategies)**을 비교합니다.  

쿠버네티스에서 **애플리케이션을 중단 없이 업데이트하는 방법**을 이해하고, **블루-그린 배포(Blue-Green Deployment)와 카나리아 배포(Canary Deployment)**를 실습합니다.

[쿠버네티스 공식 문서 - 배포 전략](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

---

## 🏗 2. 롤링 업데이트(Rolling Updates) & 롤백(Rollbacks)

### ✅ 롤링 업데이트란?
- 기존 애플리케이션을 **중단 없이 점진적으로 업데이트**하는 방법
- 한 번에 모든 파드를 교체하는 것이 아니라, **한 개씩 새 버전의 파드를 배포하고 기존 파드를 종료**
- 트래픽은 **항상 실행 중인 파드로 전달**되므로 **다운타임이 없음**

### ✅ 롤링 업데이트 실행하기
```bash
kubectl set image deployment/webapp webapp=webapp:v2
```
- 기존 `webapp` 배포를 새로운 이미지 `webapp:v2`로 업데이트

### ✅ 롤링 업데이트 상태 확인
```bash
kubectl rollout status deployment/webapp
```

### ✅ 롤백(Rollback) 수행하기
```bash
kubectl rollout undo deployment/webapp
```
- **업데이트된 애플리케이션에서 문제가 발생할 경우 롤백** 가능

[쿠버네티스 공식 문서 - 롤링 업데이트 및 롤백](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/)

---

## 🚀 3. 배포 전략(Deployment Strategies)

### ✅ 3.1 블루-그린 배포(Blue-Green Deployment)
- **두 개의 환경(Blue, Green)을 동시에 운영**
- 기존 버전(Blue)과 새 버전(Green)을 **분리된 환경에서 실행**
- 새 버전이 준비되면 **트래픽을 Green 환경으로 전환**
- **빠른 롤백 가능** (문제 발생 시 다시 Blue로 전환)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  selector:
    app: webapp-green  # 트래픽을 green 버전으로 변경 가능
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

[블루-그린 배포 전략 자세히 보기](https://martinfowler.com/bliki/BlueGreenDeployment.html)

---

### ✅ 3.2 카나리아 배포(Canary Deployment)
- **새 버전의 애플리케이션을 일부 사용자에게만 배포**
- A/B 테스트, 새로운 기능 테스트에 활용됨
- 안정성이 확인되면 점진적으로 전체 트래픽을 새 버전으로 전환

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-canary
spec:
  replicas: 1  # 카나리아 버전은 일부 사용자만 이용 가능하도록 설정
  selector:
    matchLabels:
      app: webapp
      version: canary
  template:
    metadata:
      labels:
        app: webapp
        version: canary
    spec:
      containers:
      - name: webapp
        image: webapp:v2
```

[카나리아 배포 전략 자세히 보기](https://medium.com/@copyconstruct/canary-releases-in-kubernetes-using-deployments-and-services-81e3fa87a45b)

---

## 🔄 4. 쿠버네티스 배포 업데이트 & 롤백 실습

### ✅ 4.1 배포 생성 및 확인
```bash
kubectl create deployment nginx --image=nginx:1.16
kubectl rollout status deployment nginx
kubectl rollout history deployment nginx
```

### ✅ 4.2 특정 버전의 배포 상태 확인
```bash
kubectl rollout history deployment nginx --revision=1
```

### ✅ 4.3 배포 변경 내역 저장하기 (`--record` 옵션 사용)
```bash
kubectl set image deployment nginx nginx=nginx:1.17 --record
kubectl rollout history deployment nginx
```

### ✅ 4.4 배포 수정 (`kubectl edit` 활용)
```bash
kubectl edit deployment nginx --record
kubectl rollout history deployment nginx
```

### ✅ 4.5 특정 버전으로 롤백
```bash
kubectl rollout undo deployment nginx --to-revision=1
```
- `--to-revision=1`을 사용하여 첫 번째 배포로 롤백 가능

[쿠버네티스 공식 문서 - 배포 롤백](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-back-a-deployment)

---

## 🎯 5. 핵심 요약

| 배포 전략 | 특징 | 장점 | 단점 |
|-----------|------|------|------|
| **롤링 업데이트** | 한 번에 하나씩 파드 교체 | 다운타임 없음 | 롤백이 상대적으로 느릴 수 있음 |
| **블루-그린 배포** | 두 개의 환경을 유지 | 빠른 롤백 가능 | 리소스 소모 증가 |
| **카나리아 배포** | 일부 사용자만 새 버전 이용 | 안정성 테스트 가능 | 설정이 복잡할 수 있음 |

[쿠버네티스 공식 문서 - 배포 전략](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

---

## 🎉 6. 강의 마무리

이 실습에서는 **쿠버네티스 롤링 업데이트 & 롤백 방법**을 학습하고, **다양한 배포 전략(Blue-Green, Canary)**을 비교했습니다.  
💪 **다음 강의**에서는 Istio를 활용한 **고급 트래픽 관리 및 배포 전략**을 다룰 예정입니다.

✨ **실습 환경에서 직접 롤링 업데이트 및 배포 전략을 실행해 보세요!** 🚀