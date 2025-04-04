# Kubernetes Secret 가이드

## 📌 개요
**Secret**은 Kubernetes에서 **민감한 정보를 안전하게 저장하고 관리**하는 데 사용됩니다. 예를 들어, **비밀번호**, **OAuth 토큰**, **SSH 키** 등의 민감한 데이터를 저장할 수 있습니다. Secret은 기본적으로 **base64 인코딩**되어 저장되며, Pod에서 필요할 때 안전하게 참조할 수 있습니다.

---

## 🛠 Secret 생성 방법

### ✅ 1) 명령형 접근법 (Imperative Approach)

#### 🔹 **리터럴(Literal) 값 사용**
```bash
kubectl create secret generic app-secret \\
  --from-literal=DB_HOST=mysql \\
  --from-literal=DB_USER=root \\
  --from-literal=DB_PASSWORD=passwrd
```
- `--from-literal` 플래그를 통해 키-값 쌍을 직접 지정할 수 있습니다.

#### 🔹 **파일에서 생성**
```bash
kubectl create secret generic app-secret --from-file=./credentials.txt
```
- `--from-file` 플래그를 사용하여 파일의 내용을 읽어 Secret으로 생성합니다.

---

### ✅ 2) 선언형 접근법 (Declarative Approach)

#### 🔹 **Secret YAML 예제**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
data:
  DB_HOST: bXlzcWw=   # mysql (base64 인코딩된 값)
  DB_USER: cm9vdA==    # root
  DB_PASSWORD: cGFzd3Jk # paswrd
```

#### 🔹 **base64 인코딩 명령어**
```bash
echo -n 'mysql' | base64   # bXlzcWw=
echo -n 'root' | base64    # cm9vdA==
echo -n 'paswrd' | base64  # cGFzd3Jk
```

#### 🔹 **Secret 적용**
```bash
kubectl apply -f app-secret.yaml
```

---

## 🚀 Pod에 Secret 주입 방법

### 🔹 **1) 환경 변수로 주입 (envFrom 사용)**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app
spec:
  containers:
  - name: web-container
    image: python:3.8
    envFrom:
    - secretRef:
        name: app-secret
```
- Secret의 **모든 키-값 쌍을 환경 변수**로 주입합니다.

---

### 🔹 **2) 특정 환경 변수로 주입 (env 사용)**
```yaml
env:
- name: DB_HOST
  valueFrom:
    secretKeyRef:
      name: app-secret
      key: DB_HOST
```
- 특정 키만 Pod의 환경 변수로 주입할 수 있습니다.

---

### 🔹 **3) 볼륨으로 주입 (파일 형태)**
```yaml
volumes:
- name: secret-volume
  secret:
    secretName: app-secret

volumeMounts:
- name: secret-volume
  mountPath: "/etc/secrets"
```
- Secret 데이터를 **파일 형태로 Pod의 볼륨에 마운트**합니다.

---

## 🔍 Secret 확인 및 관리

### 🔹 **Secret 목록 확인**
```bash
kubectl get secrets
```

### 🔹 **Secret 상세 정보 확인**
```bash
kubectl describe secret app-secret
```

### 🔹 **Secret 값 디코딩**
```bash
kubectl get secret app-secret -o jsonpath="{.data.DB_HOST}" | base64 --decode
```
- 저장된 base64 값을 디코딩하여 원래의 값을 확인할 수 있습니다.

---

## ⚠️ Secret 사용 시 주의사항

1. **Secret은 기본적으로 암호화되지 않고 base64로 인코딩**됩니다. 따라서 추가적인 저장소 암호화를 고려해야 합니다.
2. **GitHub** 같은 버전 관리 시스템에 **Secret 정의 파일을 업로드하지 마세요**.
3. **RBAC(Role-Based Access Control)**을 설정하여 Secret에 대한 **액세스를 제한**하세요.
4. **클라우드 공급자의 Secret 관리 서비스** 사용도 고려해 보세요 (예: AWS Secrets Manager, Azure Key Vault, HashiCorp Vault).

---

## 🎯 핵심 요약

| 🔑 **주제**              | 💡 **설명**                                   |
|--------------------------|---------------------------------------------|
| **Secret 용도**           | 민감한 데이터를 안전하게 저장 및 전달          |
| **생성 방법**            | 명령형(`kubectl create secret`) 또는 선언형(YAML)|
| **Pod에 주입 방법**       | 환경 변수(`envFrom`, `env`), 볼륨 마운트        |
| **보안 고려사항**        | base64 인코딩 확인, RBAC 설정, GitHub 업로드 금지 |

---

## 📚 추가 학습 제안
- **Kubernetes Secret 암호화 설정**
- **RBAC를 활용한 Secret 접근 제어**
- **클라우드 Secret 관리 서비스와 Kubernetes 통합**

---

**💡 사용법:**
1. 위 내용을 복사합니다.
2. 텍스트 편집기에서 `.md` 파일을 생성합니다 (예: `secret-guide.md`).
3. 복사한 내용을 `.md` 파일에 붙여넣기 합니다.
4. 저장 후 필요에 따라 GitHub, GitLab 또는 다른 문서 저장소에 업로드할 수 있습니다.

이 가이드를 통해 **Kubernetes Secret**의 핵심 개념과 사용 방법을 익히고, 실무에 안전하게 적용할 수 있기를 바랍니다. 🔐✨

---

## 🔐  HashiCorp Vault
	•	동적 비밀 관리, 액세스 제어, 자동 키 순환 등의 기능 제공.
	•	Kubernetes와 통합하여 런타임 시 안전하게 비밀을 주입할 수 있습니다.