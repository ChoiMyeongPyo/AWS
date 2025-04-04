## 🌐 EKS에서 Application Load Balancer와 프리픽스 기능을 활용한 트래픽 처리

### 📌 **Ingress (ALB) 생성 모드**

EKS에서 ALB를 통한 트래픽 처리 시 **두 가지 `target-type` 모드**를 사용할 수 있습니다:

---

### 1️⃣ **인스턴스 모드 (`target-type: instance`)**
- **트래픽 흐름**:  
  `Client ➔ ALB ➔ EC2 노드(NodePort) ➔ Pod`

- **작동 방식**:
  - ALB는 각 노드의 ENI(Elastic Network Interface)와 연결된 **NodePort**를 타겟으로 설정.
  - 트래픽이 노드의 NodePort를 통해 전달되며, **kube-proxy**가 이를 적절한 Pod로 라우팅.
  - Pod가 재배치되어도 노드가 유지되면 타겟 그룹 갱신이 불필요.

- **특징**:
  - 설정이 간단하지만 **노드를 경유**하여 **네트워크 홉**으로 인한 지연 발생.
  - **보안 그룹**이 노드 수준에서 적용되어 관리가 단순함.

---

### 2️⃣ **IP 모드 (`target-type: ip`)**
- **트래픽 흐름**:  
  `Client ➔ ALB ➔ Pod (노드 경유 없음)`

- **작동 방식**:
  - ALB가 **Pod의 IP 주소를 직접 타겟**으로 지정하여 트래픽 전달.
  - Kubernetes **Service**(`ClusterIP`)가 Pod의 **selector**를 통해 특정 Pod를 선택.
  - **Ingress Controller**가 API 서버를 **watch**하여 Pod의 변경사항을 감지하고 ALB 타겟 그룹을 **자동 갱신**.

- **특징**:
  - 노드 경유 없이 **직접 연결**하여 **지연 시간 최소화**.
  - Pod 스케일 업/다운 시 **ALB 타겟 그룹이 실시간으로 업데이트**됨.
  - Pod IP가 직접 타겟이므로 **세밀한 보안 그룹 관리** 필요.

---

### ⚡ **Pod 변경사항 감지 프로세스**

```
Pod 상태 변경
   ↓
API 서버가 상태 업데이트
   ↓
Ingress Controller가 API 서버 감시 (watch)
   ↓
ALB 타겟 그룹 자동 갱신 (Pod IP 추가/삭제)
```

- **Ingress**: 라우팅 규칙만 정의 (변경사항 감지 기능 없음).
- **Ingress Controller**: API 서버의 상태 변경을 감지하고 ALB 설정을 동적으로 관리.
- **API 서버**: 클러스터의 모든 상태 변경을 중앙에서 관리.

---

### 🚀 **프리픽스(Prefix Delegation) 기능을 통한 노드당 Pod 수 증가**

### 🔍 **프리픽스 기능의 필요성**

EKS에서는 각 노드당 생성할 수 있는 Pod 수가 **ENI와 ENI당 IP 할당 수**에 따라 제한됩니다. 기본적으로 `m5.large` 인스턴스는 약 **29개의 Pod**만 지원합니다.

그러나 **프리픽스 기능(Prefix Delegation)**을 사용하면 **하나의 ENI에 다수의 IP 범위(/28, /27 등)**를 할당하여 **노드당 더 많은 Pod**를 실행할 수 있습니다.

---

### 🌟 **프리픽스 기능의 작동 원리**

| 항목                  | 기본 ENI 방식               | 프리픽스 할당 방식           |
|---------------------|------------------------|----------------------|
| IP 할당 방식            | 개별 IP 주소 할당             | IP 주소 블록(/28, /27 등) 할당 |
| Pod 수용 능력          | 제한적 (예: 29개)            | 대폭 증가 (예: 110개 이상)   |
| 네트워크 구성 복잡성      | 단순                      | 다소 복잡하지만 확장성 제공    |
| 리소스 활용 효율성        | 낮음                      | 높음                   |

---

### 🔧 **프리픽스 기능 활성화 방법 (EKS)**

#### 1. **`aws-node` ConfigMap 수정**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-node
  namespace: kube-system
data:
  ENABLE_PREFIX_DELEGATION: "true"  # 프리픽스 기능 활성화
  WARM_PREFIX_TARGET: "1"           # 유지할 프리픽스 수 설정
```

#### 2. **IAM 역할에 필요한 권한 추가**

AWS Load Balancer Controller가 Pod IP를 관리할 수 있도록 **IAM 정책**을 업데이트:

```json
{
  "Effect": "Allow",
  "Action": [
    "ec2:AssignPrivateIpAddresses",
    "ec2:UnassignPrivateIpAddresses"
  ],
  "Resource": "*"
}
```

#### 3. **노드 그룹 업데이트**

```bash
aws eks update-nodegroup-config \
  --cluster-name <your-cluster-name> \
  --nodegroup-name <your-nodegroup-name> \
  --scaling-config minSize=1,maxSize=10,desiredSize=3
```

---

### ⚡ **프리픽스 기능 적용 후 기대 효과**

- **노드당 Pod 수 증가**: `m5.large` 인스턴스에서 최대 110개 이상의 Pod 실행 가능.
- **비용 절감**: 더 적은 수의 노드로 동일한 워크로드 실행.
- **확장성 향상**: 대규모 마이크로서비스 환경에서도 효율적인 리소스 사용.

---

### 📈 **프리픽스 기능 적용 예시**

#### ✅ **Pod 스케일링 전**:

```bash
kubectl get pods -o wide
```

출력 결과:
```
NAME            READY   STATUS    IP           NODE        
app-1           1/1     Running   192.168.1.10 ip-10-0-0-1
app-2           1/1     Running   192.168.1.11 ip-10-0-0-1
...
```

#### ✅ **Pod 스케일링 후 (프리픽스 적용)**:

```bash
kubectl scale deployment app --replicas=100
kubectl get pods -o wide
```

출력 결과:
```
NAME            READY   STATUS    IP              NODE        
app-1           1/1     Running   192.168.1.10    ip-10-0-0-1
app-100         1/1     Running   192.168.1.110   ip-10-0-0-1
```

💡 **프리픽스 기능 적용 후에도 단일 노드에서 100개 이상의 Pod가 정상적으로 실행**됨을 확인할 수 있습니다.

---

### 🌐 **Ingress Group 기능을 통한 ALB 통합 관리**

#### 🔍 **Ingress Group이란?**

`alb.ingress.kubernetes.io/group.name` 어노테이션을 사용하면 **여러 Ingress 리소스를 단일 ALB로 통합**할 수 있습니다. 이는 **마이크로서비스 아키텍처**에서 ALB 비용 절감과 **라우팅 효율성**을 향상시킵니다.

#### 💡 **Ingress Group 사용 시 장점**:
- **ALB 수 감소**: 여러 서비스가 동일한 ALB를 공유하여 비용 절감.
- **중앙화된 라우팅 관리**: 하나의 ALB에서 다양한 서비스에 대한 라우팅 규칙 적용.
- **빠른 배포 및 롤백**: ALB 재생성 없이 Ingress 리소스만 업데이트.

#### 🔧 **Ingress Group 적용 예시**

**Ingress A (서비스 A용):**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: service-a-ingress
  annotations:
    alb.ingress.kubernetes.io/group.name: my-app-group
spec:
  ingressClassName: alb
  rules:
    - host: service-a.example.com
      http:
        paths:
          - path: /a
            pathType: Prefix
            backend:
              service:
                name: service-a
                port:
                  number: 80
```

**Ingress B (서비스 B용):**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: service-b-ingress
  annotations:
    alb.ingress.kubernetes.io/group.name: my-app-group
spec:
  ingressClassName: alb
  rules:
    - host: service-b.example.com
      http:
        paths:
          - path: /b
            pathType: Prefix
            backend:
              service:
                name: service-b
                port:
                  number: 80
```

#### ✅ **결과:**
- `my-app-group`이라는 동일한 그룹 이름을 지정했기 때문에 **하나의 ALB**가 생성되어 `/a`와 `/b` 경로에 대해 각각 다른 서비스로 트래픽을 라우팅합니다.
- Pod 스케일링, 서비스 추가 시 **ALB 재생성 없이 즉각 반영**됩니다.

---

### 📝 **최종 요약**

1️⃣ **Ingress 모드:**
- **인스턴스 모드**: ALB ➔ 노드(NodePort) ➔ Pod (간단하지만 지연 발생)
- **IP 모드**: ALB ➔ Pod (노드 경유 없음, 실시간 타겟 그룹 업데이트)

2️⃣ **Pod 변경사항 감지:**
- **API 서버**가 상태 변경 감지 ➔ **Ingress Controller**가 watch하여 ALB 타겟 그룹 자동 업데이트

3️⃣ **프리픽스 기능:**
- ENI당 **IP 할당량 확장**으로 노드당 **Pod 수 증가**
- **비용 효율성** 및 **리소스 활용 최적화**

4️⃣ **Ingress Group 기능:**
- **`group.name` 어노테이션**을 통해 **여러 Ingress 리소스를 단일 ALB로 통합**
- **비용 절감**, **중앙화된 라우팅 관리**, **빠른 배포 및 롤백** 지원

---

💡 **EKS 환경에서 프리픽스 기능, `target-type: ip` 모드, Ingress Group 기능을 함께 사용하면 고성능, 확장성, 비용 효율성을 모두 만족하는 최적의 클러스터 운영이 가능합니다.** 🚀✨

