# Kubernetes ConfigMap 가이드

## 📌 개요
**ConfigMap**은 Kubernetes에서 **구성 데이터를 키-값 쌍** 형태로 저장하고 Pod에 전달하는 데 사용됩니다. ConfigMap을 사용하면 **애플리케이션 설정을 코드와 분리**하여 더 유연하게 구성할 수 있습니다.

---

## 🛠 ConfigMap 생성 방법

### ✅ 1) 명령형 접근법 (Imperative Approach)

#### 🔹 **리터럴(Literal) 값 사용**
```bash
kubectl create configmap app-config \
  --from-literal=APP_COLOR=blue \
  --from-literal=APP_MODE=production
```
- `--from-literal` 플래그를 통해 키-값 쌍을 직접 지정할 수 있습니다.

#### 🔹 **파일에서 생성**
```bash
kubectl create configmap app-config --from-file=app.properties
```
- `--from-file` 플래그를 사용하여 파일의 내용을 읽어 ConfigMap을 생성합니다.

---

### ✅ 2) 선언형 접근법 (Declarative Approach)

#### 🔹 **ConfigMap YAML 예제**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_COLOR: blue
  APP_MODE: production
```

#### 🔹 **ConfigMap 적용**
```bash
kubectl apply -f app-config.yaml
```
- YAML 파일을 사용하여 **선언적으로** ConfigMap을 정의하고 생성합니다.

---

## 🚀 Pod에 ConfigMap 주입 방법

### 🔹 **1) 환경 변수로 주입 (envFrom 사용)**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app
spec:
  containers:
  - name: web-container
    image: nginx
    envFrom:
    - configMapRef:
        name: app-config
```
- ConfigMap의 **모든 키-값 쌍을 환경 변수**로 주입합니다.

---

### 🔹 **2) 특정 환경 변수로 주입 (env 사용)**
```yaml
env:
- name: APP_COLOR
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: APP_COLOR
```
- 특정 키만 Pod의 환경 변수로 주입할 수 있습니다.

---

### 🔹 **3) 볼륨으로 주입 (파일 형태)**
```yaml
volumes:
- name: config-volume
  configMap:
    name: app-config

volumeMounts:
- name: config-volume
  mountPath: /etc/config
```
- ConfigMap 데이터를 파일 형태로 Pod의 **볼륨에 마운트**합니다.

---

## 🔍 ConfigMap 확인 및 관리

### 🔹 **ConfigMap 목록 확인**
```bash
kubectl get configmaps
```

### 🔹 **ConfigMap 상세 정보 확인**
```bash
kubectl describe configmap app-config
```

---

## 🎯 핵심 요약

| 🔑 **주제**              | 💡 **설명**                                   |
|--------------------------|---------------------------------------------|
| **ConfigMap 용도**        | 설정 데이터를 Pod와 분리하여 전달              |
| **생성 방법**            | 명령형(`kubectl create`) 또는 선언형(YAML) 방식|
| **Pod에 주입 방법**       | 환경 변수(`envFrom`, `env`), 볼륨 마운트        |
| **관리 명령어**          | `kubectl get`, `kubectl describe`, `kubectl apply` |

---

## 💬 요점 정리
- **ConfigMap**은 여러 Pod에서 동일한 구성을 **중앙 집중식**으로 관리할 수 있도록 도와줍니다.
- 환경 변수, 파일, 볼륨 등 다양한 방법으로 **유연하게 주입**할 수 있습니다.
- Pod 정의 파일을 간소화하고, **애플리케이션 설정을 외부화**할 수 있는 중요한 Kubernetes 기능입니다.

---

## 📚 추가 학습 제안
- **Secrets**와 **ConfigMap**의 차이점 이해하기
- **Deployment**에서 ConfigMap 동적 업데이트 적용하기
- **Helm** 차트에서 ConfigMap 사용 사례 실습

---

이 가이드를 통해 **Kubernetes ConfigMap**의 핵심 개념과 사용 방법을 익히고, 실무에 효과적으로 적용할 수 있기를 바랍니다. 🚀

