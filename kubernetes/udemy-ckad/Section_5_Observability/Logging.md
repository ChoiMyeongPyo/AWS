# CKAD 실습: 응용 프로그램 로그 관리 및 분석

---

## 📌 1. 개요

이 실습에서는 **쿠버네티스에서 응용 프로그램 로그를 관리하고 분석하는 방법**을 배웁니다.  
애플리케이션이 실행되는 **포드(Pod)의 로그를 확인**하고, **사용자 문제를 진단하는 방법**을 실습합니다.

[쿠버네티스 공식 문서 - 로그 관리](https://kubernetes.io/docs/concepts/cluster-administration/logging/)

---

## 🏗 2. 로그 분석 실습 개요

### ✅ 시나리오 1: 사용자 로그인 실패 로그 확인
- **사용자 5가 로그인 실패** 문제를 보고함
- 로그에서 **계정 잠금 메시지**를 확인하여 원인 파악

### ✅ 시나리오 2: 아이템 구매 실패 로그 확인
- **사용자 30이 아이템 구매 실패** 문제를 보고함
- 로그에서 **재고 부족 오류**를 확인하여 원인 파악

---

## 🛠 3. 로그 확인 방법

### 📜 3.1 포드(Pod) 로그 확인 명령어
```bash
kubectl logs <pod-name>
```
- 특정 포드의 로그를 확인할 때 사용

```bash
kubectl logs <pod-name> -c <container-name>
```
- 포드에 **여러 개의 컨테이너**가 있을 경우 특정 컨테이너의 로그를 확인

### 📜 3.2 특정 포드의 최신 로그 출력
```bash
kubectl logs <pod-name> --tail=100
```
- 최근 **100줄**의 로그를 출력하여 빠르게 문제 분석 가능

### 📜 3.3 실시간 로그 스트리밍 확인
```bash
kubectl logs -f <pod-name>
```
- `-f` 옵션을 사용하여 **로그를 실시간으로 모니터링**

[쿠버네티스 공식 문서 - 로그 확인](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#interacting-with-pods)

---

## ⚡ 4. 실습: 사용자 문제 해결

### 🛠 4.1 사용자 로그인 실패 로그 분석
#### 🔹 문제: 사용자 5가 로그인 실패
#### 🔍 로그 확인
```bash
kubectl logs webapp-pod
```
#### 📝 로그 출력 예제
```
[ERROR] User 5 login failed - Account locked due to multiple failed attempts.
```
#### ✅ 원인 파악
- 사용자 **5번 계정이 여러 번 로그인 실패로 잠김** → 계정 복구 필요

---

### 🛠 4.2 아이템 구매 실패 로그 분석
#### 🔹 문제: 사용자 30이 아이템 구매 실패
#### 🔍 웹 애플리케이션 컨테이너 로그 확인
```bash
kubectl logs webapp-2 -c webapp
```
#### 📝 로그 출력 예제
```
[WARNING] User 30 order failed - Item out of stock.
```
#### ✅ 원인 파악
- 사용자 **30번 주문이 재고 부족으로 실패** → 재고 보충 필요

---

## 💡 5. 추가 팁 및 고려 사항

### 🛠 5.1 여러 개의 컨테이너가 있는 포드의 로그 확인
- `kubectl logs <pod-name>`만 실행하면 **첫 번째 컨테이너의 로그만 표시됨**
- 여러 개의 컨테이너가 있는 경우 `-c <container-name>` 옵션을 사용해야 함

### 🔍 5.2 포드가 삭제된 후 로그 확인 방법
```bash
kubectl logs --previous <pod-name>
```
- 포드가 재시작되었거나 삭제되었을 경우 **이전 로그 확인 가능**

### 🔄 5.3 로그 지속 저장 및 중앙 집중화
- 기본적으로 `kubectl logs`는 포드의 **stdout/stderr 로그만 확인 가능**
- 로그를 영구 저장하려면 **로깅 솔루션(EFK, Loki, Datadog 등)**을 도입하는 것이 필요

[쿠버네티스 공식 문서 - 로깅 아키텍처](https://kubernetes.io/docs/concepts/cluster-administration/logging/)

---

## 🎯 6. 핵심 요약

- `kubectl logs <pod-name>` 명령어를 사용하여 **실시간으로 포드 로그를 분석**
- 여러 개의 컨테이너가 있을 경우 `-c <container-name>` 옵션을 사용하여 특정 컨테이너 로그 확인
- `--previous` 옵션을 사용하여 **삭제된 포드의 로그를 확인 가능**
- 애플리케이션의 문제 해결을 위해 **로그 기반 분석**이 필수적

[쿠버네티스 공식 문서 - Pod Logs](https://kubernetes.io/docs/concepts/cluster-administration/logging/)

---

## 🎉 7. 강의 마무리

이 실습에서는 **포드의 로그를 확인하고 문제를 분석하는 방법**을 학습했습니다.  
💪 **다음 강의**에서는 중앙 집중식 로깅 솔루션을 활용하여 더 효율적인 로그 관리 방법을 다룰 예정입니다.

✨ **코딩 실습 환경에서 직접 로그를 확인하고 분석해 보세요!** 🚀

