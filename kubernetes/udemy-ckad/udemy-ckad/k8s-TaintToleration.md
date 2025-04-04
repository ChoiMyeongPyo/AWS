# CKAD 강의: 쿠버네티스 오점(Taint)과 관용(Toleration)

---

### 🎙 **강사**: 뭄샤드 마남베스  
### 📚 **주제**: 쿠버네티스 애플리케이션 개발자 코스 - 포드와 노드의 관계, 오점(Taint)과 관용(Toleration)

---

## 📌 1. 강의 개요

이번 강의에서는 **포드(Pod)**와 **노드(Node)** 간의 관계와,  
특정 노드에 특정 포드를 **배치**하기 위한 제약 방법인  
**오점(Taint)**과 **관용(Toleration)** 개념을 다룹니다.

[쿠버네티스 공식 문서 - Taints and Tolerations](https://kubernetes.io/ko/docs/concepts/scheduling-eviction/taint-and-toleration/)

---

## 🐞 2. 오점(Taint)과 관용(Toleration) 개념

- **비유적 설명**:  
  - 사람에게 벌레가 접근하는 것을 방지하기 위해 **방충 스프레이**를 뿌립니다.  
    - 🏃 사람 = **노드(Node)**  
    - 🐛 벌레 = **포드(Pod)**  
    - 🧴 방충 스프레이 = **오점(Taint)**  
  - 모든 벌레가 스프레이 냄새를 참을 수 있는 건 아닙니다.  
    - **내성을 가진 벌레**만 접근할 수 있습니다.  
    - 이 내성이 바로 **관용(Toleration)**입니다.

[쿠버네티스 스케줄링 개념](https://kubernetes.io/ko/docs/concepts/scheduling-eviction/scheduling-framework/)

---

## 🏗 3. 오점(Taint)와 관용(Toleration)의 적용

### 🖇 3.1 클러스터 구성 예시  
- **작업자 노드 3개**:  
  - 노드 이름: `node1`, `node2`, `node3`  
- **포드 세트**: `Pod A`, `Pod B`, `Pod C`, `Pod D`

### 🏷 3.2 노드 오점(Taint) 설정  
```bash
kubectl taint nodes node1 app=blue:NoSchedule
```
- **app=blue**: 오점 키-값 쌍  
- **NoSchedule**: 포드가 내성을 가지지 않으면 노드에 스케줄되지 않음

[쿠버네티스 공식 문서 - kubectl 명령어](https://kubernetes.io/ko/docs/reference/kubectl/overview/)

### 🛡 3.3 포드 관용(Toleration) 설정
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-d
spec:
  tolerations:
  - key: "app"
    operator: "Equal"
    value: "blue"
    effect: "NoSchedule"
```
- `tolerations` 설정을 통해 `pod-d`는 `node1`의 **app=blue** 오점을 견딜 수 있습니다.

---

## ⚡ 4. 오점 효과(Taint Effects) 유형

| 오점 효과          | 설명                                                       |
|--------------------|------------------------------------------------------------|
| **NoSchedule**     | 내성이 없는 포드는 노드에 절대 스케줄되지 않음               |
| **PreferNoSchedule** | 가능한 한 포드를 노드에 배치하지 않으려 하지만, 필요하면 배치할 수 있음 |
| **NoExecute**      | 기존 포드도 해당 노드에서 퇴거되며, 새로운 포드도 스케줄되지 않음 |

[오점 효과에 대한 공식 문서](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/#taint-effects)

---

## 📝 5. 오점과 관용의 동작 흐름

1. 노드에 **테인트(Taint)** 설정  
2. 특정 포드에 **관용(Toleration)** 설정  
3. **스케줄러(Scheduler)**가 포드의 관용 여부를 판단  
4. 내성이 있으면 노드에 포드를 스케줄링, 없으면 다른 노드로 이동

[쿠버네티스 스케줄러 이해](https://kubernetes.io/ko/docs/concepts/scheduling-eviction/kube-scheduler/)

---

## 🎯 6. 마스터 노드의 오점(Taint)

- 쿠버네티스는 기본적으로 마스터 노드에 다음과 같은 테인트를 추가합니다:
```bash
kubectl describe node <master-node-name>
```
- ✅ **모범 사례**: 마스터 노드에는 **애플리케이션 포드**를 배치하지 않음

[마스터 노드와 제어 플레인 이해](https://kubernetes.io/ko/docs/concepts/overview/components/#control-plane-components)

---

## 🎮 7. 실습 안내

- `kubectl taint nodes` 명령어로 **노드 오점 설정**  
- **포드 YAML 정의** 파일에서 `tolerations` 추가하여 **포드 관용 설정**  
- 오점 및 관용 설정 변경 시 **스케줄링 결과 확인**

[쿠버네티스 실습 가이드](https://kubernetes.io/docs/tasks/tools/)

---

## 💡 8. 핵심 요약

- **오점(Taint)**: 특정 노드에 포드가 스케줄되지 못하도록 제한  
- **관용(Toleration)**: 특정 포드가 노드의 오점을 견디고 스케줄될 수 있도록 허용  
- **포인트**: 오점과 관용은 **포드가 특정 노드에만 배치되도록 보장**하진 않음  
  - 특정 노드에만 포드를 배치하려면 👉 **노드 선호도(Node Affinity)** 설정 필요 (다음 강의에서 다룸)

[노드 선호도(Node Affinity) 공식 문서](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)

---

## 🎉 9. 강의 마무리

이번 강의에서는 쿠버네티스의 **오점과 관용**을 통해  
**노드와 포드 간의 스케줄링 제약**을 설정하는 방법을 배웠습니다.  
💪 **다음 강의**에서는 **노드 선호도(Node Affinity)**를 다룰 예정입니다.

✨ **코딩 연습실로 이동하여 오점과 관용 실습을 진행해 보세요!** 🚀