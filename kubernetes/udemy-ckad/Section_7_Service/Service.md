# CKAD 실습: 쿠버네티스 서비스(Service) 개념 및 NodePort

---

## 📌 1. 개요

이 실습에서는 **쿠버네티스 서비스(Service)의 개념과 역할**을 학습하고, 특히 **NodePort** 타입을 활용하여 외부에서 클러스터 내부의 포드(Pod)에 접근하는 방법을 실습합니다.

쿠버네티스에서 서비스는 **애플리케이션 내부 및 외부의 다양한 구성 요소 간의 통신을 가능하게 하는 중요한 리소스**입니다.

[쿠버네티스 공식 문서 - Service](https://kubernetes.io/docs/concepts/services-networking/service/)

---

## 🏗 2. 쿠버네티스 서비스 개념

### ✅ 서비스(Service)란?
- **포드(Pod)는 동적으로 생성되고 삭제되기 때문에, 직접 접근할 수 있는 고정 IP가 없음**
- 서비스는 **포드의 라이프사이클과 무관하게 트래픽을 안정적으로 전달하는 네트워크 엔드포인트** 역할 수행
- **라벨(Label)과 선택기(Selector)를 활용하여 특정 포드 그룹에 트래픽을 분배**

### ✅ 주요 서비스 유형
| 서비스 유형 | 설명 |
|-------------|------|
| **ClusterIP (기본값)** | 내부 클러스터 내에서만 접근 가능 |
| **NodePort** | 클러스터 외부에서 접근 가능 (노드의 포트를 통해) |
| **LoadBalancer** | 클라우드 제공자의 로드 밸런서를 통해 접근 가능 (AWS, GCP 등) |
| **ExternalName** | DNS 이름을 사용하여 외부 서비스와 연결 |

---

## 🚀 3. NodePort 서비스 설정 및 이해

### ✅ NodePort란?
- **클러스터 외부에서 특정 노드의 IP와 포트를 통해 포드에 접근 가능**
- **포트 범위: 30000 ~ 32767** (기본적으로 이 범위 내에서 자동 할당 가능)
- 모든 클러스터 노드에서 동일한 포트로 서비스 접근 가능

```
노트북 (192.168.1.10) 
     │
     │  (접속) http://<노드IP>:<NodePort>
     ▼
쿠버네티스 노드 (192.168.1.2)
     │
     │  (서비스 포트 80 -> 포드의 80포트로 전달)
     ▼
포드 (10.244.0.2:80)
```

### ✅ NodePort 서비스 YAML 예제
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  type: NodePort
  ports:
    - targetPort: 80  # 포드가 실행 중인 포트
      port: 80        # 서비스가 내부에서 사용하는 포트
      nodePort: 30008 # 노드에서 외부 접근을 위한 포트
  selector:
    app: myapp
```

### ✅ NodePort 서비스 생성
```bash
kubectl apply -f myapp-service.yaml
kubectl get services
```

출력 예제:
```
NAME             TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
myapp-service   NodePort   10.106.1.112     <none>        80:30008/TCP   10s
```

### ✅ 서비스 확인 및 접근
```bash
kubectl get svc myapp-service -o wide
```

웹 브라우저 또는 `curl`을 이용해 외부에서 접근:
```bash
curl http://<노드IP>:30008
```

---

## 🔄 4. 서비스의 부하 분산 및 다중 노드 구성

### ✅ 서비스와 여러 포드 간의 연결
- 서비스는 **라벨 셀렉터(Label Selector)를 사용하여 여러 포드에 트래픽을 분산**
- `selector`를 이용해 동일한 라벨이 적용된 모든 포드와 연결 가능

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  type: NodePort
  ports:
    - targetPort: 80
      port: 80
      nodePort: 30008
  selector:
    app: myapp
```

위 설정을 적용하면 **`app: myapp` 라벨이 설정된 모든 포드로 트래픽이 전달됨**.

### ✅ 부하 분산 동작 방식
- 서비스는 클러스터 내부에서 **포드 엔드포인트(Endpoints) 목록을 자동으로 관리**
- 기본적으로 **라운드 로빈 방식**으로 부하를 분산함

```bash
kubectl get endpoints myapp-service
```
출력 예제:
```
NAME             ENDPOINTS                       AGE
myapp-service   10.244.0.2:80,10.244.0.3:80    5m
```

즉, 서비스가 여러 개의 포드를 가리키고 있으면 **자동으로 부하를 분산하여 요청을 처리**.

---

## 🎯 5. 핵심 요약

| 개념 | 설명 |
|------|------|
| **Service** | 클러스터 내부 및 외부에서 포드로 접근할 수 있도록 하는 네트워크 리소스 |
| **ClusterIP** | 클러스터 내부에서만 접근 가능 (기본값) |
| **NodePort** | 클러스터 외부에서 특정 노드의 포트를 통해 접근 가능 |
| **LoadBalancer** | 클라우드 로드밸런서를 통해 외부 접근 가능 (AWS ELB 등) |
| **ExternalName** | DNS 이름을 사용하여 외부 서비스와 연결 |
| **Selector** | 특정 라벨이 적용된 포드와 연결 |
| **Endpoints** | 서비스가 연결된 포드 목록 |

[쿠버네티스 공식 문서 - Service](https://kubernetes.io/docs/concepts/services-networking/service/)

---

## 🎉 6. 강의 마무리

이 실습에서는 **쿠버네티스 서비스의 개념과 역할, NodePort를 활용한 외부 접근 방법**을 학습했습니다.  
💪 **다음 강의**에서는 **ClusterIP 및 LoadBalancer를 활용한 다양한 네트워크 접근 방식**을 다룰 예정입니다.

✨ **실습 환경에서 직접 NodePort 서비스를 생성하고 테스트해 보세요!** 🚀

