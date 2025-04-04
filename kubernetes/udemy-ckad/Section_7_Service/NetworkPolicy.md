# 쿠버네티스 네트워크 정책 심화 학습

## 1. 네트워크 정책 개요
쿠버네티스에서 네트워크 정책(Network Policy)은 **Pod 간의 네트워크 트래픽을 제어**하는 기능을 제공합니다. 기본적으로 쿠버네티스는 모든 Pod 간의 통신을 허용하지만, 보안을 강화하려면 특정 트래픽만 허용하도록 제한해야 합니다.

네트워크 정책을 정의할 때 **입력(Ingress)과 출력(Egress) 트래픽**을 분리하여 설정할 수 있습니다.

---

## 2. 데이터베이스 보호를 위한 네트워크 정책

### **요구 사항**
- 데이터베이스(DB) Pod은 **오직 API Pod에서 오는 트래픽만 허용**해야 함.
- 외부의 모든 트래픽을 차단해야 함.
- API Pod에서 DB의 **3306 포트**로만 접속 가능해야 함.

### **네트워크 정책 적용 과정**
1. **DB Pod을 보호하기 위해 기본적으로 모든 트래픽 차단**
2. **API Pod에서 오는 트래픽만 허용**
3. **네임스페이스를 기반으로 트래픽 제어 가능**
4. **클러스터 외부 IP를 기반으로 트래픽 제어 가능**

### **네트워크 정책 예제: API Pod에서만 DB Pod 접근 허용**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: database  # DB Pod 선택
  policyTypes:
  - Ingress  # 입력 트래픽 제한
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: api  # API Pod에서 오는 트래픽만 허용
    ports:
    - protocol: TCP
      port: 3306  # MySQL 포트
```

✅ **결과:**
- API Pod에서 오는 3306 포트의 요청만 허용됨.
- 웹 서버 등 다른 Pod에서 DB에 접근하려 하면 차단됨.

---

## 3. 네임스페이스 기반 트래픽 제어

EKS 환경에서는 **네임스페이스(Namespace) 기반으로 트래픽을 제어할 수도 있습니다.**

### **사용 사례**
- API Pod이 `development`, `test`, `production` 등 다양한 네임스페이스에서 실행될 수 있음.
- 특정 네임스페이스의 API Pod에서만 DB Pod 접근을 허용해야 함.

### **네임스페이스 기반 네트워크 정책 예제**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: api  # API Pod에서 오는 트래픽만 허용
      namespaceSelector:
        matchLabels:
          environment: production  # 특정 네임스페이스의 API Pod만 허용
    ports:
    - protocol: TCP
      port: 3306
```

✅ **결과:**
- `production` 네임스페이스의 API Pod만 DB Pod에 접근 가능.
- `development`, `test` 등의 네임스페이스에서는 DB 접근 불가.

📌 **네임스페이스 사용 시 주의할 점**
- 네임스페이스에 **라벨(Label)을 추가**해야 함.
  ```sh
  kubectl label namespace production environment=production
  ```

---

## 4. 외부 IP 기반 트래픽 제어

쿠버네티스 클러스터 외부에서 오는 특정 IP 트래픽을 허용할 수도 있습니다.

### **사용 사례**
- 쿠버네티스 외부의 **백업 서버가 DB와 통신해야 하는 경우**.
- 특정 **신뢰할 수 있는 IP 범위만 허용**해야 하는 경우.

### **IP 기반 네트워크 정책 예제**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy-external
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - ipBlock:
        cidr: 192.168.5.10/32  # 특정 외부 백업 서버 IP 허용
    ports:
    - protocol: TCP
      port: 3306
```

✅ **결과:**
- 외부 **192.168.5.10** IP에서 오는 DB 요청만 허용.
- 그 외의 모든 외부 IP 트래픽 차단.

📌 **주의할 점**
- `ipBlock` 규칙은 쿠버네티스 **클러스터 내부 Pod에는 적용되지 않음.**
- 즉, 내부 Pod 트래픽을 제어하려면 `podSelector`나 `namespaceSelector`를 사용해야 함.

---

## 5. Egress(출력 트래픽) 정책 적용

기본적으로 네트워크 정책은 **Ingress(입력 트래픽)만 제한**하지만, **Egress(출력 트래픽)도 제한 가능**합니다.

### **사용 사례**
- DB Pod이 외부 백업 서버로 데이터를 전송할 수 있도록 허용.

### **출력 트래픽(Egress) 정책 예제**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-egress-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: database
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 192.168.5.10/32  # 외부 백업 서버 IP
    ports:
    - protocol: TCP
      port: 80  # HTTP 포트로 백업 전송 허용
```

✅ **결과:**
- DB Pod에서 **192.168.5.10** 백업 서버로 **80번 포트 트래픽 전송 허용**.
- 다른 모든 출력 트래픽은 차단됨.

---

## 6. 결론
- 쿠버네티스 네트워크 정책은 **입력(Ingress)과 출력(Egress) 트래픽을 각각 제어할 수 있음**.
- **네임스페이스 기반**으로 특정 네임스페이스의 Pod만 접근 가능하도록 설정 가능.
- **IP 기반 제어**를 사용해 클러스터 외부와의 통신을 관리할 수 있음.
- EKS 환경에서는 **SG(Security Group)와 함께 네트워크 정책을 병행 사용**하여 보안을 강화해야 함.

🚀 **네트워크 정책을 활용하면 EKS 환경에서 더욱 정교한 보안 정책을 적용할 수 있습니다!**