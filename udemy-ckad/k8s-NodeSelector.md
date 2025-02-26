# CKAD 강의: 쿠버네티스 노드 셀렉터(Node Selector)

---

### 🎙 **강사**: 뭄샤드 마남베스  
### 📚 **주제**: 쿠버네티스 노드 셀렉터(Node Selector) 이해 및 활용

---

## 📌 1. 강의 개요

이번 강의에서는 **쿠버네티스 노드 셀렉터(Node Selector)**에 대해 배웁니다.  
특정 **노드(Node)**에서만 **포드(Pod)**가 실행되도록 제한하는 방법과  
**노드 레이블(Node Label)**을 통해 어떻게 스케줄링 제약을 설정할 수 있는지 알아봅니다.

[쿠버네티스 공식 문서 - Assigning Pods to Nodes](https://kubernetes.io/ko/docs/concepts/scheduling-eviction/assign-pod-node/)

---

## 🏗 2. 클러스터 구성 및 문제 정의

### 🖇 클러스터 예시
- **3개 노드 클러스터**
  - `node1`: 큰 노드 (**리소스 충분**)
  - `node2`: 작은 노드 (**리소스 제한적**)
  - `node3`: 작은 노드 (**리소스 제한적**)

### ⚡ 문제 상황
- 데이터 프로세싱 작업은 **높은 리소스**가 필요합니다.
- **기본 설정**상 모든 포드는 어떤 노드로든 갈 수 있습니다.
- 결과적으로 **포드 C**가 **2번이나 3번 노드**에 잘못 스케줄될 수 있습니다.

---

## 🛠 3. 노드 셀렉터(Node Selector) 적용 방법

### 🏷 3.1 노드에 레이블 추가

먼저 **노드에 레이블**을 추가해야 합니다.

```bash
kubectl label nodes node1 size=large
```
- **size=large**: 노드를 식별하는 키-값 쌍입니다.

[쿠버네티스 공식 문서 - kubectl 명령어](https://kubernetes.io/ko/docs/reference/kubectl/overview/)

### 📜 3.2 포드에 Node Selector 설정

포드 정의 파일에 `nodeSelector`를 추가합니다.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-processing-pod
spec:
  containers:
  - name: data-container
    image: data-processing:latest
  nodeSelector:
    size: large
```
- `nodeSelector`: 포드를 **size=large** 레이블이 있는 노드에만 스케줄링합니다.

[Node Selector에 대한 공식 문서](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector)

---

## ⚡ 4. 노드 셀렉터의 한계

| 한계점 | 설명 |
|--------|------|
| **단일 레이블** | 하나의 레이블과 값으로만 스케줄링 제약 설정 가능 |
| **복잡한 조건 불가** | `nodeSelector`는 "큰 노드 또는 중간 노드"와 같은 복잡한 조건 지원 불가 |

---

## 🌐 5. 더 복잡한 요구사항은?

- **노드 친화성(Node Affinity)** 및 **반 친화성(Anti-Affinity)**를 사용하여 다음을 구현할 수 있습니다:
  - "포드를 **큰 노드** 또는 **중간 노드**에만 배치"
  - "포드를 **작지 않은 모든 노드**에 배치"

[노드 친화성과 반 친화성 공식 문서](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity)

---

## 🎯 6. 핵심 요약

- **Node Selector**는 특정 **노드에만 포드**를 배치하기 위한 간단한 방법입니다.
- **레이블(Label)**은 노드 식별을 위해 사용되며, **`kubectl label`** 명령어로 추가할 수 있습니다.
- **한계**: `nodeSelector`는 단순한 조건만 지원합니다.
- **복잡한 요구사항**은 👉 **노드 친화성(Node Affinity)** 기능을 사용하세요.

---

## 🎉 7. 강의 마무리

이번 강의에서는 **노드 셀렉터(Node Selector)**를 통해  
특정 노드에서 포드를 실행하도록 스케줄링하는 방법을 배웠습니다.  
💪 **다음 강의**에서는 더 복잡한 요구사항을 처리하는 **노드 친화성(Node Affinity)**를 다룰 예정입니다.

✨ **코딩 연습실로 이동하여 Node Selector 실습을 진행해 보세요!** 🚀

