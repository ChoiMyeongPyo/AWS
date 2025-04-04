# CKAD 강의: 쿠버네티스 준비성과 라이브니스 프로브

---

### 🎙 **강사**: 뭄샤드 마남베스  
### 📚 **주제**: 쿠버네티스 준비성과 라이브니스 프로브, 로깅 및 모니터링 개념 이해

---

## 📌 1. 강의 개요

이번 강의에서는 **쿠버네티스의 관측력(Observability)** 개념을 학습합니다.  
특히 **준비성(Readiness) 프로브**와 **라이브니스(Liveness) 프로브**, 그리고 **로깅과 모니터링**을 다룹니다.

[쿠버네티스 공식 문서 - Probe 개념](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes)

---

## 🏗 2. 포드(Pod)의 수명 주기 및 상태

### 🖇 포드의 수명 주기 단계
1. **Pending(보류 중)**: 포드가 생성되었지만 아직 스케줄링되지 않음.
2. **ContainerCreating(컨테이너 생성 중)**: 컨테이너가 이미지 가져오고 실행 준비 중.
3. **Running(실행 중)**: 모든 컨테이너가 정상 실행됨.
4. **Succeeded/Failed(성공/실패)**: 포드가 종료됨.

```bash
kubectl describe pod <pod-name>
```
- 포드 상태 및 이벤트 확인 가능.

[쿠버네티스 포드 라이프사이클 공식 문서](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)

---

## 🛠 3. 준비성 프로브(Readiness Probe) 설정

### 🏷 3.1 준비성 프로브 필요성
- **포드가 시작되었지만 애플리케이션이 준비되지 않은 경우**
- **초기화 시간이 긴 서비스 (예: Jenkins, DB 서버 등)**
- **서비스가 정상적으로 사용자 요청을 처리할 수 있을 때만 트래픽을 전달**

### 📜 3.2 준비성 프로브 예제
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example-pod
spec:
  containers:
  - name: example-container
    image: example-app:latest
    readinessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 5
```
- `httpGet`: 지정된 HTTP 경로로 응답 확인.
- `initialDelaySeconds`: 컨테이너 시작 후 10초 대기 후 프로브 실행.
- `periodSeconds`: 5초마다 상태 확인.

[쿠버네티스 공식 문서 - Readiness Probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

---

## ⚡ 4. 라이브니스 프로브(Liveness Probe) 설정

| 프로브 유형 | 설명 |
|------------|------|
| **Readiness Probe** | 포드가 준비 상태인지 확인하여 트래픽 전달 여부 결정 |
| **Liveness Probe** | 컨테이너가 살아있는지 확인하여 비정상 상태일 경우 재시작 |

### 📜 4.1 라이브니스 프로브 예제
```yaml
livenessProbe:
  tcpSocket:
    port: 3306
  initialDelaySeconds: 15
  periodSeconds: 10
```
- `tcpSocket`: 포트 3306이 열려 있는지 확인.
- `initialDelaySeconds`: 15초 대기 후 시작.
- `periodSeconds`: 10초마다 확인 후 실패 시 컨테이너 재시작.

[쿠버네티스 공식 문서 - Liveness Probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

---

## 🌐 5. 준비성과 라이브니스 프로브의 필요성

### 🧩 실전 예제: 다중 포드 환경
- **잘못된 프로브 설정**: 새 포드가 준비되지 않았는데 트래픽이 전달됨 → 사용자 장애 발생.
- **올바른 프로브 설정**: 기존 포드가 유지되며, 새 포드가 준비될 때까지 트래픽을 전달하지 않음.

```yaml
readinessProbe:
  exec:
    command:
    - cat
    - /tmp/ready
```
- 실행 명령어를 사용하여 파일 존재 여부 확인.

[쿠버네티스 공식 문서 - Exec Probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

---

## 📝 6. 추가 프로브 옵션 및 튜닝

| 옵션 | 설명 |
|------|------|
| `initialDelaySeconds` | 컨테이너 시작 후 프로브 실행까지 대기 시간 |
| `timeoutSeconds` | 응답 대기 시간 (기본: 1초) |
| `failureThreshold` | 몇 번 연속 실패하면 포드를 재시작할지 설정 |
| `successThreshold` | 몇 번 연속 성공하면 준비 상태로 판단 |

[쿠버네티스 공식 문서 - Probe 튜닝](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)

---

## 🎯 7. 핵심 요약

- **준비성 프로브(Readiness Probe)**: 포드가 요청을 받을 준비가 되었는지 확인.
- **라이브니스 프로브(Liveness Probe)**: 포드가 정상적으로 실행 중인지 확인하여 비정상 상태 시 재시작.
- **적절한 설정을 통해 가용성과 안정성을 극대화할 수 있음.**

[쿠버네티스 공식 문서 - 컨테이너 프로브](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes)

---

## 🎉 8. 강의 마무리

이번 강의에서는 **쿠버네티스 준비성과 라이브니스 프로브**를 학습하여  
**애플리케이션의 상태를 모니터링하고 자동 복구를 수행하는 방법**을 배웠습니다.  
💪 **다음 강의**에서는 **변조(Taint) 및 관용(Toleration)**, **노드 친밀성(Node Affinity)**과 비교하여 활용하는 방법을 다룰 예정입니다.

✨ **코딩 연습실로 이동하여 프로브 설정을 실습해 보세요!** 🚀

