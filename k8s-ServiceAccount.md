# Kubernetes 서비스 계정 및 토큰 변경 사항 정리

## 📌 **1. 서비스 계정 개요**
- Kubernetes의 계정 유형:
  - **사용자 계정 (User Account)**: 사람이 클러스터에 접근할 때 사용.
  - **서비스 계정 (Service Account)**: 응용 프로그램이나 프로세스가 Kubernetes API와 상호작용할 때 사용.

- **서비스 계정의 주요 용도**:
  - Prometheus와 같은 모니터링 앱이 Kubernetes API에서 메트릭 수집.
  - Jenkins 같은 빌드 도구가 Kubernetes 클러스터에 애플리케이션 배포.

📖 **참고:** [Kubernetes 공식 문서 - 서비스 계정](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)

---

## 🔑 **2. Kubernetes 서비스 계정 토큰의 기본 동작**
- **서비스 계정 생성 시 기본 동작:**
  - 서비스 계정 생성 시, Kubernetes는 **비밀 객체(Secret)**를 자동 생성하고 토큰을 저장.
  - 토큰은 Pod 생성 시 `/var/run/secrets/kubernetes.io/serviceaccount` 경로에 **자동 마운트**됨.
  - **Pod 내 프로세스**는 이 토큰을 통해 Kubernetes API에 접근.

- **기본 서비스 계정 특징:**
  - 각 네임스페이스는 기본 서비스 계정을 가짐.
  - 기본 토큰은 만료일 없이 영구적임.

📖 **참고:** [Kubernetes 인증](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)

---

## 🚨 **3. Kubernetes 버전 업그레이드에 따른 변경 사항**

### ⚡ **버전 1.22 변경사항**
- **TokenRequest API 도입:**
  - Kubernetes 개선안 [KEP-1205](https://github.com/kubernetes/enhancements/issues/1205) 일부로 소개.
  - 토큰은 이제 **시간 제한(expiry)**과 **대상(audience)**을 기반으로 생성됨.
  - Pod가 생성될 때 **TokenRequest API**가 자동 호출되어 **프로젝션된 토큰(volume projected token)**을 생성.

- **보안 강화:**
  - 기존의 비밀 기반 토큰은 **만료일이 없고** 무제한 유효했지만, **TokenRequest API**를 통해 생성된 토큰은 기본적으로 **1시간** 유효.
  - 명령어를 통해 유효 기간 연장 가능:
    ```bash
    kubectl create token <service-account-name> --duration=2h
    ```

📖 **참고:** [TokenRequest API 공식 문서](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/)

---

### ⚡ **버전 1.24 변경사항**
- **서비스 계정 토큰의 자동 생성 중단:**
  - Kubernetes 개선안 [KEP-2799](https://github.com/kubernetes/enhancements/issues/2799) 일부.
  - `kubectl create token` 명령어를 사용하여 **수동 생성** 필요:
    ```bash
    kubectl create token <service-account-name>
    ```
  - 생성된 토큰은 기본적으로 **만료일(expiry)**이 포함됨.

- **보안 향상:**
  - 서비스 계정 생성 시, 더 이상 비밀 객체(secret)를 자동 생성하지 않음.
  - **TokenRequest API**를 통한 **온디맨드 토큰 생성** 권장.

📖 **참고:** [서비스 계정 및 토큰 관리](https://kubernetes.io/docs/concepts/configuration/secret/)

---

## 🛡 **4. 토큰 생성 및 관리 방법**

### ✅ **1. 토큰 생성 명령어**
```bash
kubectl create token <service-account-name> --duration=1h
```

### ✅ **2. Pod 정의에서 서비스 계정 연결**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example-pod
spec:
  serviceAccountName: custom-sa
  containers:
  - name: example-container
    image: nginx
```

### ✅ **3. 자동 마운팅 비활성화**
```yaml
spec:
  automountServiceAccountToken: false
```

📖 **참고:** [Pod에 서비스 계정 연결](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-specifying-a-service-account)

---

## 🎯 **5. 핵심 요약**

| Kubernetes 버전 | 주요 변경 사항                                      |
|------------------|---------------------------------------------------|
| **v1.22**        | - TokenRequest API 도입<br>- 시간 제한 토큰 도입      |
| **v1.24**        | - 서비스 계정 생성 시 토큰 자동 생성 중단<br>- 수동 토큰 생성 필요 |

📖 **참고:** [Kubernetes 공식 변경 로그](https://kubernetes.io/docs/setup/release/notes/)

---

## 💬 **6. 추가 참고 자료**
- [Kubernetes 인증 개념](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)
- [서비스 계정 및 RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Kubernetes API 인증 흐름](https://kubernetes.io/docs/concepts/overview/kubernetes-api/)

---

이 문서를 통해 Kubernetes 서비스 계정과 토큰의 변경 사항을 이해하고, **최신 버전의 Kubernetes 클러스터에서 보안성을 유지하는 방법**을 학습할 수 있습니다. 🚀✨

