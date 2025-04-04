# CKAD 강의: 쿠버네티스 노드 선호도(Node Affinity)

---

### 🎙 **강사**: 뭄샤드 마남베스  
### 📚 **주제**: 쿠버네티스 노드 선호도(Node Affinity) 이해 및 활용

---

## 📌 1. 강의 개요

이번 강의에서는 **쿠버네티스 노드 선호도(Node Affinity)** 기능을 학습합니다.  
**노드 선호도**는 **포드(Pod)**가 특정 **노드(Node)**에서 호스팅되도록 제어하는 고급 기능입니다.

[쿠버네티스 공식 문서 - Node Affinity](https://kubernetes.io/ko/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity)

---

## 🏗 2. 노드 선호도(Node Affinity)의 필요성

### 🖇 클러스터 예시
- **3개 노드 클러스터**
  - `node1`: 큰 노드 (**대규모 데이터 처리용**)
  - `node2`: 작은 노드 (**리소스 제한적**)
  - `node3`: 작은 노드 (**리소스 제한적**)

### ⚡ 문제 상황
- **큰 데이터 처리 포드**는 **node1**에 스케줄되어야 합니다.
- **기본 설정**상 모든 포드는 어떤 노드로든 갈 수 있어 비효율적인 스케줄링 발생.

---

## 🛠 3. 노드 선호도(Node Affinity) 설정 방법

### 🏷 3.1 노드에 레이블 추가

```bash
kubectl label nodes node1 size=large
```
- **size=large**: 노드를 식별하는 키-값 쌍입니다.

[쿠버네티스 공식 문서 - kubectl 명령어](https://kubernetes.io/ko/docs/reference/kubectl/overview/)

### 📜 3.2 포드에 노드 선호도 설정

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-processing-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: size
            operator: In
            values:
            - large
  containers:
  - name: data-container
    image: data-processing:latest
```
- `requiredDuringSchedulingIgnoredDuringExecution`: **필수 선호도 규칙**으로 일치하는 노드가 없으면 포드는 스케줄되지 않습니다.

[Node Affinity에 대한 공식 문서](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#required-during-scheduling-ignored-during-execution)

---

## ⚡ 4. 노드 선호도 유형

| 유형 | 설명 |
|------|------|
| **requiredDuringSchedulingIgnoredDuringExecution** | 포드 스케줄 시 필수 조건. 일치하는 노드 없으면 스케줄 실패. |
| **preferredDuringSchedulingIgnoredDuringExecution** | 조건 만족 시 선호하지만, 불만족 시에도 스케줄 가능. |

---

## 🌐 5. 고급 설정 및 사용 사례

### 🧩 다중 조건 선호도 설정
```yaml
nodeAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 1
    preference:
      matchExpressions:
      - key: size
        operator: In
        values:
        - large
        - medium
```
- **weight**: 선호도 우선 순위. 값이 클수록 우선.

### 💡 **Tip**: `preferredDuringSchedulingIgnoredDuringExecution`는 **유연한 배치**에 유용합니다.

[고급 Node Affinity 설정 문서](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity)

---

## 📝 6. 실행 중 노드 선호도의 동작

- 노드 레이블이 변경되면 **실행 중인 포드**는 영향을 받지 않습니다.
- 향후 새로운 유형으로 **실행 중 선호도 조건**이 추가될 수 있습니다.

### ⚡ 예제: 레이블 제거 시 동작
- 노드에서 `size=large` 레이블이 제거되어도 포드는 계속 실행됩니다.

---

## 🎯 7. 핵심 요약

- **노드 선호도(Node Affinity)**는 **복잡한 스케줄링 조건**을 설정할 수 있는 고급 기능입니다.
- **`requiredDuringSchedulingIgnoredDuringExecution`**와 **`preferredDuringSchedulingIgnoredDuringExecution`**의 차이를 이해하는 것이 중요합니다.
- 복잡한 요구 사항은 노드 선호도와 **반 친화성(Anti-Affinity)**를 결합하여 해결할 수 있습니다.

[반 친화성(Anti-Affinity) 공식 문서](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity)

---

## 🎉 8. 강의 마무리

이번 강의에서는 **노드 선호도(Node Affinity)**를 활용하여  
**포드가 특정 노드에서 실행되도록 스케줄링**하는 방법을 학습했습니다.  
💪 **다음 강의**에서는 **변조(Taint)와 관용(Toleration)**, **노드 친밀성(Node Affinity)**의 비교를 진행할 예정입니다.

✨ **코딩 연습실로 이동하여 노드 선호도 실습을 진행해 보세요!** 🚀

