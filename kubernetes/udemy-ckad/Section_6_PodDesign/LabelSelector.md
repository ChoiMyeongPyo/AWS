# CKAD 실습: 라벨과 선택기(Label & Selector)

---

## 📌 1. 개요

이 실습에서는 **쿠버네티스 라벨(Label)과 선택기(Selector)**를 활용하여 **오브젝트를 그룹화하고 필터링하는 방법**을 학습합니다.  
라벨을 통해 쿠버네티스 개체를 효과적으로 관리하고, **선택기(Selector)**를 사용하여 특정 개체를 조회하는 방법을 실습합니다.

[쿠버네티스 공식 문서 - Labels & Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)

---

## 🏗 2. 라벨(Label)과 선택기(Selector) 개념

### ✅ 라벨(Label) 개념
- **라벨(Label)**은 쿠버네티스 개체에 부착되는 **키-값(Key-Value) 형식의 메타데이터**입니다.
- 개체를 특정 그룹으로 분류하는 데 사용됩니다.
- 예제:
  ```yaml
  labels:
    app: webapp
    tier: frontend
  ```

### ✅ 선택기(Selector) 개념
- **선택기(Selector)**는 특정 라벨이 있는 개체를 필터링하는 기능을 합니다.
- 특정 조건을 지정하여 원하는 개체만 조회할 수 있습니다.
- 예제:
  ```bash
  kubectl get pods --selector app=webapp
  ```

### ✅ 라벨과 선택기의 활용 사례
- **유튜브 비디오**에 태그를 붙이는 것과 유사 (예: #쿠버네티스 #DevOps)
- **온라인 스토어**에서 제품을 필터링하는 것과 유사 (예: 색상=빨강, 사이즈=M)
- **쿠버네티스 개체 관리** (포드, 서비스, 복제본 세트 등)

---

## 🛠 3. 라벨(Label) 적용 방법

### 📜 3.1 라벨 추가 및 관리

#### ✅ 포드(Pod)에 라벨 추가 (YAML 정의)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp-pod
  labels:
    app: webapp
    tier: frontend
spec:
  containers:
  - name: webapp
    image: nginx
```

#### ✅ 기존 개체에 라벨 추가 (kubectl 명령어)
```bash
kubectl label pod webapp-pod env=production
```

#### ✅ 라벨이 추가된 개체 조회
```bash
kubectl get pods --show-labels
```

[쿠버네티스 공식 문서 - Label 추가 및 조회](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)

---

## 🔍 4. 선택기(Selector) 활용 방법

### ✅ 4.1 특정 라벨이 있는 개체 조회
```bash
kubectl get pods --selector app=webapp
```
- `app=webapp` 라벨이 붙어 있는 모든 포드를 조회

### ✅ 4.2 여러 개의 조건을 지정하여 필터링
```bash
kubectl get pods --selector "app=webapp,tier=frontend"
```
- `app=webapp`이면서 `tier=frontend`인 포드만 조회

### ✅ 4.3 특정 라벨이 없는 개체 조회 (부정 연산)
```bash
kubectl get pods --selector 'env!=production'
```
- `env=production`이 **아닌** 개체를 조회

[쿠버네티스 공식 문서 - Label Selector](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors)

---

## 🚀 5. 라벨과 선택기를 활용한 오브젝트 관리

### ✅ 5.1 복제본 세트(ReplicaSet)에서 라벨과 선택기 활용
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: webapp-replicaset
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
        tier: frontend
    spec:
      containers:
      - name: webapp
        image: nginx
```

### ✅ 5.2 서비스(Service)에서 선택기를 활용한 트래픽 라우팅
```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  selector:
    app: webapp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

> ✅ **주의할 점:** 
> - `matchLabels`의 값이 포드의 `labels` 값과 **일치해야** 복제본 세트가 포드를 올바르게 관리할 수 있음.
> - 서비스(Service)도 **올바른 선택기**가 설정되어야 포드로 트래픽을 전달할 수 있음.

[쿠버네티스 공식 문서 - ReplicaSet & Service](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)

---

## 📝 6. 주석(Annotation)과 라벨의 차이점

| 속성 | 목적 | 활용 예 |
|------|------|--------|
| **라벨(Label)** | 개체를 그룹화하고 필터링 | `app=webapp`, `env=production` |
| **주석(Annotation)** | 메타데이터 저장 (검색 불가) | 빌드 정보, 연락처, 설명 |

- **라벨(Label)** → 검색 및 필터링 가능
- **주석(Annotation)** → 정보 저장용, 검색 불가능

[쿠버네티스 공식 문서 - Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)

---

## 🎯 7. 핵심 요약

- **라벨(Label)**: 개체를 그룹화하고 필터링하는 메타데이터
- **선택기(Selector)**: 특정 라벨이 있는 개체를 조회하는 필터링 기능
- **kubectl 명령어**를 사용하여 라벨을 추가/조회 가능
- **복제본 세트(ReplicaSet) 및 서비스(Service)**에서 라벨과 선택기를 활용하여 개체를 관리할 수 있음
- **주석(Annotation)**은 검색되지 않으며, 추가 정보 저장 용도로 사용됨

[쿠버네티스 공식 문서 - Labels & Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)

---

## 🎉 8. 강의 마무리

이 실습에서는 **라벨(Label)과 선택기(Selector)를 활용하여 쿠버네티스 개체를 효과적으로 관리하는 방법**을 배웠습니다.  
💪 **다음 강의**에서는 라벨과 선택기를 활용한 **고급 오브젝트 관리** 기법을 다룰 예정입니다.

✨ **코딩 실습 환경에서 직접 라벨과 선택기를 적용해 보세요!** 🚀

