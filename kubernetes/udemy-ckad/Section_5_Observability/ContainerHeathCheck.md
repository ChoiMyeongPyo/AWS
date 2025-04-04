# CKAD 실습: Liveness Probe 및 Readiness Probe 설정 및 동작 분석

---

## 📌 1. 개요

이 실습에서는 **livenessProbe**와 **readinessProbe**를 활용하여 컨테이너의 상태를 모니터링하고 **비정상적인 상태를 감지 후 자동 복구**하는 방법을 배웁니다.  

쿠버네티스에서 애플리케이션의 **헬스체크(Health Check) 기능**은 매우 중요합니다. 특히 **웜업(Warm-up) 시간**이 필요한 애플리케이션(예: 웹 서버, 데이터베이스, 캐시 서버 등)에서는 적절한 프로브 설정이 없으면 **정상적인 서비스 운영이 어려워질 수 있습니다.**

[쿠버네티스 공식 문서 - Liveness & Readiness Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

---

## 🏗 2. 요구사항

다음 조건을 만족하는 **livenessProbe**와 **readinessProbe**를 설정해야 합니다:
- **Liveness Probe**: 컨테이너가 살아 있는지 확인하여 비정상 상태 발생 시 자동 재시작
- **Readiness Probe**: 컨테이너가 트래픽을 받을 준비가 되었는지 확인하여 준비되지 않으면 트래픽 차단

### 설정 조건
- **HTTP GET 방식으로 `/live`, `/ready` 엔드포인트 검사**
- **HTTP 포트: 8080**
- **Liveness Probe**: `initialDelaySeconds: 80`, `periodSeconds: 1`
- **Readiness Probe**: `initialDelaySeconds: 5`, `periodSeconds: 2`

적용할 포드 목록:
- **Pod Name**: `simple-webapp-1`
- **Pod Name**: `simple-webapp-2`

---

## 🛠 3. YAML 설정 예제

다음과 같이 `livenessProbe` 및 `readinessProbe`를 구성합니다:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simple-webapp-1
spec:
  containers:
  - name: webapp
    image: kodekloud/webapp-delayed-start
    livenessProbe:
      httpGet:
        path: /live
        port: 8080
      initialDelaySeconds: 80
      periodSeconds: 1
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 2
---
apiVersion: v1
kind: Pod
metadata:
  name: simple-webapp-2
spec:
  containers:
  - name: webapp
    image: kodekloud/webapp-delayed-start
    livenessProbe:
      httpGet:
        path: /live
        port: 8080
      initialDelaySeconds: 80
      periodSeconds: 1
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 2
```

---

## ⚡ 4. 설정 적용 후 예상 동작

1. **포드 실행 후 80초 동안 livenessProbe 검사하지 않음**  
   - `initialDelaySeconds: 80` 설정으로 인해 **컨테이너가 안정적으로 실행될 시간 확보**
   - 애플리케이션이 웜업(Warm-up) 중인 동안 불필요한 재시작 방지

2. **80초 후부터 `/live` 엔드포인트를 1초 간격으로 검사**  
   - `/live` 엔드포인트가 200 OK 응답을 반환하면 정상 실행 유지
   - 응답이 없거나 500 에러 발생 시 컨테이너 재시작

3. **포드가 초기화 중이면 Readiness Probe가 트래픽을 차단**  
   - `/ready` 엔드포인트가 정상 응답할 때까지 서비스로 트래픽 전달 안 함
   - **애플리케이션이 DB 연결 등 필수 작업을 마칠 때까지 트래픽이 들어오지 않도록 방어**

4. **비정상 상태 발생 시 컨테이너 자동 복구**  
   - `/live` 엔드포인트가 비정상 상태가 되면, livenessProbe가 실패로 감지하고 **컨테이너를 자동 재시작**

---

## 💡 5. 추가 팁 및 고려 사항

### 🛠 5.1 livenessProbe vs. readinessProbe 차이점
| Probe 유형 | 목적 | 실패 시 동작 | 사용 사례 |
|------------|------|-------------|-----------|
| **Liveness Probe** | 컨테이너가 **살아 있는지** 확인 | 컨테이너 **재시작** | 컨테이너가 비정상적으로 동작할 때 자동 복구 |
| **Readiness Probe** | 컨테이너가 **트래픽을 받을 준비가 되었는지** 확인 | 트래픽 차단 (재시작 ❌) | 초기화 시간이 긴 애플리케이션, 일시적으로 트래픽을 차단할 때 |

### 🔄 5.2 Liveness & Readiness Probe를 함께 사용하는 이유
- Readiness Probe를 통해 **애플리케이션이 완전히 준비될 때까지 트래픽을 차단**
- Liveness Probe를 사용하여 **컨테이너가 충돌 또는 비정상 상태가 되면 자동 복구**
- 두 가지를 함께 설정하면 **장애 발생 시 빠른 복구** 및 **사용자 경험 보장** 가능

### 🔍 5.3 상태 확인 및 디버깅
```bash
kubectl describe pod simple-webapp-1
```
- `Events` 섹션에서 **Probe Failures** 로그 확인 가능

```bash
kubectl get pods
```
- 포드가 **Restarting** 상태라면 **livenessProbe 실패**로 인해 컨테이너가 재시작 중

```bash
kubectl logs simple-webapp-1
```
- 로그를 확인하여 **애플리케이션이 정상 실행 중인지 확인**

---

## 🎯 6. 핵심 요약

- `livenessProbe`는 **컨테이너가 살아있는지 확인하고 비정상 상태 시 자동 재시작**
- `readinessProbe`는 **컨테이너가 트래픽을 받을 준비가 되었는지 확인**하여 준비되지 않으면 트래픽 차단
- 애플리케이션이 웜업(Warm-up)이 필요한 경우, readinessProbe 설정이 필수적
- **둘 다 설정하는 것이 가장 효과적** (애플리케이션의 안정성과 가용성을 보장하기 위해)

[쿠버네티스 공식 문서 - Probes](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes)

---

## 🎉 7. 강의 마무리

이 실습에서는 **livenessProbe와 readinessProbe의 차이점**을 학습하고, 컨테이너 상태 감지 및 자동 복구 설정을 진행했습니다.  
💪 **다음 강의**에서는 `readinessProbe`와 `livenessProbe`를 함께 활용하는 방법을 다룰 예정입니다.

✨ **코딩 실습 환경에서 직접 적용해 보세요!** 🚀