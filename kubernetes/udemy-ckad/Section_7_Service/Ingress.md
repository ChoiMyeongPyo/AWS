# CKAD 실습: Kubernetes Ingress 개념 및 AWS 환경 설정

---

## 📌 1. 개요

이 실습에서는 **Kubernetes의 Ingress 개념과 역할**을 학습하고, AWS 환경에서 **Application Load Balancer(ALB) 또는 NGINX Ingress Controller**를 활용하여 **트래픽을 클러스터 내부 서비스로 라우팅하는 방법**을 실습합니다.

Kubernetes Ingress는 **외부 요청을 하나의 진입점으로 통합하고, URL 기반 라우팅, SSL/TLS 인증서 관리, 로드 밸런싱 등을 제공하는 계층 7 네트워크 엔드포인트**입니다.

[쿠버네티스 공식 문서 - Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)

---

## 🏗 2. Kubernetes에서 외부 접근 방식

### ✅ Kubernetes에서 외부 트래픽을 처리하는 방법
| 방법 | 설명 |
|-------------|------|
| **NodePort** | 특정 노드의 포트를 개방하여 외부 접근 허용 (고정 포트 사용) |
| **LoadBalancer (AWS ALB)** | 클라우드 제공자의 로드 밸런서를 사용하여 외부 접근 허용 |
| **Ingress** | 단일 진입점(Load Balancer)으로 여러 서비스에 트래픽을 라우팅 |

### ✅ NodePort 방식의 한계
- 서비스가 **30,000 ~ 32,767 범위 내의 포트**를 사용해야 함
- 클러스터 내부의 모든 노드에서 동일한 포트를 사용해야 하므로, **유연성이 떨어짐**
- DNS를 설정해도 **트래픽을 서비스별로 나누기 어렵고 SSL/TLS 적용이 번거로움**

### ✅ LoadBalancer 방식 (AWS ALB)
- AWS 환경에서는 `LoadBalancer` 타입의 서비스가 **자동으로 AWS Application Load Balancer(ALB)를 프로비저닝**
- **트래픽을 여러 노드로 분산**할 수 있음
- 하지만 **서비스마다 새로운 로드 밸런서를 생성해야 하므로 비용이 증가**

👉 **Ingress를 사용하면 하나의 로드 밸런서로 여러 서비스에 대한 트래픽을 라우팅할 수 있음!**

---

## 🚀 3. Ingress Controller와 Ingress 리소스 개념

### ✅ Ingress Controller란?
- Ingress는 **Kubernetes에서 기본적으로 제공되지 않음** → 직접 **Ingress Controller를 배포**해야 함
- Ingress Controller는 **Ingress 리소스의 설정을 감지하고 로드 밸런서 또는 프록시 서버를 자동으로 구성**함
- 대표적인 Ingress Controller:
  - **AWS ALB Ingress Controller** (EKS에서 ALB를 자동 생성하여 사용)
  - **NGINX Ingress Controller** (오픈소스, Kubernetes 내에서 실행되는 리버스 프록시)
  - **Traefik, HAProxy, Contour, Istio 등**

👉 **AWS 환경에서는 ALB Ingress Controller를 추천, 자체 관리가 필요한 경우 NGINX Ingress Controller 사용 가능**

### ✅ Ingress 리소스란?
- Ingress는 **도메인 또는 URL 경로 기반으로 트래픽을 서비스로 전달하는 Kubernetes 리소스**
- 일반적인 Ingress 설정 예제:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
  - host: my-online-store.com
    http:
      paths:
      - path: /watch
        pathType: Prefix
        backend:
          service:
            name: video-service
            port:
              number: 8080
      - path: /wear
        pathType: Prefix
        backend:
          service:
            name: wear-service
            port:
              number: 8081
```

---

## 🔄 4. 다양한 Ingress 트래픽 분산 방식

### ✅ Host 기반 트래픽 분산
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: host-based-ingress
spec:
  rules:
  - host: app1.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
  - host: app2.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
```
👉 **도메인(app1.example.com, app2.example.com)에 따라 다른 서비스로 트래픽 분산**

### ✅ 경로 기반 트래픽 분산
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-based-ingress
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
      - path: /web
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```
👉 **같은 도메인(myapp.example.com)에서 URL 경로(/api, /web)에 따라 서비스로 트래픽 분산**

---

## 🎯 5. 핵심 요약

| 개념 | 설명 |
|------|------|
| **Ingress** | 단일 진입점(Load Balancer)으로 여러 서비스에 트래픽을 라우팅 |
| **Ingress Controller** | Ingress 리소스를 감지하고 자동으로 로드 밸런서를 구성하는 컴포넌트 |
| **ALB Ingress Controller** | AWS ALB를 활용하여 Ingress 트래픽을 자동 라우팅 |
| **NGINX Ingress Controller** | Kubernetes 내부에서 실행되는 오픈소스 리버스 프록시 |
| **Ingress 리소스** | URL 경로 또는 도메인 기반으로 트래픽을 특정 서비스로 전달 |
| **Host 기반 라우팅** | 특정 도메인에 따라 다른 서비스로 트래픽을 분산 |
| **경로 기반 라우팅** | 같은 도메인 내에서 URL 경로에 따라 트래픽을 분산 |

[쿠버네티스 공식 문서 - Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)

---

## 🎉 6. 강의 마무리

이 실습에서는 **Ingress의 개념과 역할, AWS 환경에서의 Ingress Controller 배포 및 설정 방법, Host 및 경로 기반 트래픽 분산 방식**을 학습했습니다.  
💪 **다음 강의**에서는 **SSL/TLS 적용 및 Ingress 인증서 관리**를 다룰 예정입니다.

✨ **AWS 환경에서 Ingress를 직접 생성하고 테스트해 보세요!** 🚀

