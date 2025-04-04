# CKAD 실습: 쿠버네티스 클러스터 모니터링

---

## 📌 1. 개요

이 실습에서는 **쿠버네티스 클러스터 모니터링**을 위한 기본 개념과 **Metric Server를 활용한 성능 지표 수집 방법**을 배웁니다.  
쿠버네티스는 기본적으로 **완전한 모니터링 솔루션을 제공하지 않지만**, 다양한 오픈 소스 및 상용 솔루션을 활용하여 클러스터와 애플리케이션의 상태를 추적할 수 있습니다.

[쿠버네티스 공식 문서 - 모니터링 개념](https://kubernetes.io/docs/concepts/cluster-administration/monitoring/)

---

## 🏗 2. 모니터링 필요성 및 주요 지표

쿠버네티스를 운영할 때 가장 중요한 것은 **자원 소비를 지속적으로 추적하고 최적화하는 것**입니다.

### ✅ 노드(Node) 레벨 모니터링
- 클러스터 내 **노드 개수** 및 **정상 동작 여부**
- 성능 지표: **CPU, 메모리, 네트워크, 디스크 활용도**

### ✅ 포드(Pod) 레벨 모니터링
- 현재 실행 중인 **포드 개수** 및 상태
- 개별 포드의 **CPU 및 메모리 사용량**

이러한 메트릭을 수집하고 저장하여 **데이터 분석**을 수행할 수 있는 솔루션이 필요합니다.

---

## 🔍 3. 쿠버네티스 모니터링 솔루션

쿠버네티스는 자체적으로 **완전한 모니터링 솔루션을 포함하지 않음**

### ✅ 사용 가능한 모니터링 도구
| 모니터링 솔루션 | 설명 |
|---------------|------|
| **Metric Server** | 경량화된 기본 지표 수집 도구 (쿠버네티스 기본 제공) |
| **Prometheus** | 시계열 데이터 저장 및 분석 가능 (가장 많이 사용됨) |
| **Elastic Stack** | 로그 분석 및 시각화 지원 (ELK 스택) |
| **Datadog / Dynatrace** | SaaS 기반 클라우드 모니터링 솔루션 |

### ✅ 이 강의에서는 **Metric Server**를 다룸
- **Metric Server**는 클러스터 내 리소스 사용량을 실시간으로 수집
- CPU 및 메모리 사용량을 모니터링할 수 있음
- 그러나 **데이터를 영구 저장하지 않음** → 장기적인 분석을 위해서는 Prometheus 등의 솔루션 필요

[Metric Server 공식 문서](https://github.com/kubernetes-sigs/metrics-server)

---

## ⚙️ 4. Metric Server 개념 및 동작 원리

### ✅ Metric Server의 역할
- **클러스터당 하나의 Metric Server** 배포
- **노드 및 포드의 성능 메트릭을 수집하여 API를 통해 제공**
- 데이터를 **메모리에만 저장** → 과거 데이터 조회 불가능

### ✅ 성능 지표 수집 과정
1. 각 노드에서 **Kubelet(쿠벨렛)**이 실행됨
2. Kubelet은 내부에 **cAdvisor(컨테이너 어드바이저)** 포함
3. cAdvisor가 각 포드에서 CPU, 메모리 사용량을 수집
4. Kubelet이 API를 통해 Metric Server에 데이터를 제공
5. Metric Server가 이를 수집하여 **kubectl top** 명령어를 통해 확인 가능

[쿠버네티스 API와 Metric Server 연동](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/)

---

## 🚀 5. Metric Server 설치 및 실행

### ✅ Minikube 환경에서 실행하는 경우
```bash
minikube addons enable metrics-server
```

### ✅ 일반적인 쿠버네티스 클러스터에서 실행하는 경우
```bash
git clone https://github.com/kubernetes-sigs/metrics-server.git
kubectl apply -f metrics-server/deploy/kubernetes/
```

### ✅ 배포된 Metric Server 확인
```bash
kubectl get deployment -n kube-system | grep metrics-server
```

Metric Server가 실행 중이라면, 노드 및 포드 성능 메트릭을 수집할 수 있습니다.

---

## 📊 6. 클러스터 성능 지표 조회

### ✅ 노드(Node) 성능 지표 확인
```bash
kubectl top nodes
```
출력 예제:
```
NAME        CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
node-1      166m         8%     2048Mi          65%
node-2      200m         10%    3072Mi          70%
```

### ✅ 포드(Pod) 성능 지표 확인
```bash
kubectl top pods
```
출력 예제:
```
NAME            CPU(cores)   MEMORY(bytes)
webapp-1        50m          256Mi
webapp-2        75m          512Mi
```

- CPU 사용량: **밀리코어(m)** 단위 (ex: 166m = 0.166 core)
- 메모리 사용량: **MiB(Mebibytes)** 단위

[쿠버네티스 공식 문서 - kubectl top](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/)

---

## 🔄 7. 추가 고려 사항

### ✅ Metric Server의 한계
- **과거 데이터 저장 불가** → Prometheus 등의 저장 솔루션 필요
- **디스크 I/O, 네트워크 트래픽 모니터링 불가능**
- **클러스터 규모가 커질수록 성능 이슈 발생 가능** → 리소스 조정 필요

### ✅ 고급 모니터링을 위한 솔루션 비교
| 솔루션 | 장점 | 단점 |
|--------|------|------|
| **Metric Server** | 기본 내장, 간단한 설치 | 과거 데이터 저장 불가 |
| **Prometheus** | 강력한 시계열 데이터 수집 | 복잡한 설정 필요 |
| **Datadog** | 클라우드 기반 SaaS, 쉬운 UI | 비용 발생 |
| **Elastic Stack** | 로그와 메트릭 통합 관리 | 설정이 다소 복잡 |

[쿠버네티스 공식 문서 - 모니터링 아키텍처](https://kubernetes.io/docs/concepts/cluster-administration/logging/)

---

## 🎯 8. 핵심 요약

- **Metric Server**는 쿠버네티스의 기본적인 성능 지표를 제공하는 경량화된 솔루션
- **kubectl top nodes / pods** 명령어를 사용해 CPU 및 메모리 사용량 확인 가능
- **장기적인 모니터링과 분석을 위해 Prometheus 등의 솔루션과 함께 사용 권장**

[Metric Server 공식 문서](https://github.com/kubernetes-sigs/metrics-server)

---

## 🎉 9. 강의 마무리

이 실습에서는 **Metric Server를 활용한 쿠버네티스 클러스터 모니터링 방법**을 학습했습니다.  
💪 **다음 강의**에서는 Prometheus, Grafana 등의 고급 모니터링 도구를 다룰 예정입니다.

✨ **실습 환경에서 직접 Metric Server를 설치하고 모니터링 명령어를 실행해 보세요!** 🚀

