# Kubernetes 리소스 요구 사항 및 제한 정리

## 📌 **1. 리소스 요구 사항 개요**
- Kubernetes 클러스터는 각 **노드**별로 사용 가능한 **CPU**와 **메모리 리소스**를 제공합니다.
- **Kubernetes 스케줄러**는 다음 조건을 고려하여 포드를 배치합니다:
  - 포드가 요구하는 리소스 양
  - 노드의 사용 가능한 리소스

📖 **참고:** [Kubernetes 공식 문서 - Scheduling](https://kubernetes.io/docs/concepts/scheduling-eviction/)

---

## 🔑 **2. 리소스 요청(Request)과 제한(Limit)**

### ⚡ **리소스 요청 (Request)**
- **정의**: 포드나 컨테이너가 실행될 때 보장되는 최소한의 리소스 양.
- **목적**: 스케줄러가 포드를 배치할 때 참고하여 노드를 선택.
- **예제:**
  ```yaml
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
  ```

### ⚡ **리소스 제한 (Limit)**
- **정의**: 컨테이너가 사용할 수 있는 최대 리소스 양.
- **목적**: 컨테이너가 지정된 리소스를 초과하지 않도록 제한.
- **예제:**
  ```yaml
  resources:
    limits:
      memory: "2Gi"
      cpu: "1"
  ```

📖 **참고:** [Managing Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

---

## 🛡 **3. CPU 및 메모리 단위**

### ✅ **CPU 단위**
- `1 CPU` = `1 vCPU` (AWS), 또는 하이퍼스레드 1개.
- `1000m` = 1 CPU (m은 밀리 단위를 의미).

### ✅ **메모리 단위**
- `Gi` = Gibibyte (1Gi = 1024Mi).
- `G` = Gigabyte (1G = 1000Mi).

📖 **참고:** [Resource Units in Kubernetes](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#meaning-of-cpu)

---

## 🚀 **4. 리소스 초과 시 동작**

### ✅ **CPU 초과 시**
- CPU 초과 시 **스로틀링(Throttling)** 발생 (CPU 사용량 제한).

### ✅ **메모리 초과 시**
- 메모리 초과 시 **OOMKilled(Out of Memory)** 에러 발생.
- 포드가 강제로 종료됨.

📖 **참고:** [OOMKilled Troubleshooting](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pod-replication-controller/)

---

## 🎯 **5. 제한 범위 (LimitRange) 설정**

- **LimitRange**를 사용하여 네임스페이스 내 모든 포드 및 컨테이너에 기본 리소스 제한과 요청 설정 가능.
- **예제:**
  ```yaml
  apiVersion: v1
  kind: LimitRange
  metadata:
    name: resource-limits
  spec:
    limits:
    - default:
        cpu: 500m
        memory: 512Mi
      defaultRequest:
        cpu: 200m
        memory: 256Mi
      type: Container
  ```

📖 **참고:** [LimitRange 공식 문서](https://kubernetes.io/docs/concepts/policy/limit-range/)

---

## 🌐 **6. 리소스 쿼터 (ResourceQuota) 설정**

- **ResourceQuota**를 통해 네임스페이스 단위로 리소스 사용량 제한.
- **예제:**
  ```yaml
  apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: compute-resources
  spec:
    hard:
      requests.cpu: "4"
      requests.memory: 8Gi
      limits.cpu: "10"
      limits.memory: 16Gi
  ```

📖 **참고:** [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)

---

## 💡 **7. 포드 리소스 설정 시나리오**

| 시나리오                | CPU 요청 | CPU 제한 | 메모리 요청 | 메모리 제한 | 결과                   |
|----------------------|---------|---------|------------|-------------|----------------------|
| **요청 및 제한 없음**    | 없음      | 없음      | 없음         | 없음          | 자원 무제한 사용 가능     |
| **요청만 설정**        | 1 vCPU  | 없음      | 1Gi         | 없음          | 최소 1 vCPU 보장, 초과 사용 가능 |
| **제한만 설정**        | 없음      | 1 vCPU   | 없음         | 1Gi           | 최대 1 vCPU 사용 제한   |
| **요청 및 제한 설정**   | 1 vCPU  | 2 vCPU   | 1Gi         | 2Gi           | 1 vCPU 보장, 2 vCPU 최대 사용 |

📖 **참고:** [CPU 및 메모리 관리 가이드](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

---

## 🔍 **8. 실습 시 주의사항**
- **요청(Request)**과 **제한(Limit)**을 적절히 설정하여 클러스터 안정성을 확보하세요.
- 클러스터 전체의 자원 사용량을 통제하기 위해 **ResourceQuota**와 **LimitRange**를 활용하세요.
- **Pod가 메모리 한계를 초과하면 강제 종료**되므로, 충분한 메모리를 요청하세요.

---

이 문서를 통해 Kubernetes에서 **리소스 관리**의 중요성과 **요청(Request) 및 제한(Limit)** 설정 방법을 익히고, 클러스터의 자원 효율성을 높일 수 있습니다. 🚀✨

