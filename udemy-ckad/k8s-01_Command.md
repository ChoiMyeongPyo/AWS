# 쿠버네티스 자주 사용하는 명령어

## 📜 클러스터 정보 확인
- **클러스터 정보 조회**
  ```bash
  kubectl cluster-info
  ```
- **현재 컨텍스트 확인**
  ```bash
  kubectl config current-context
  ```
- **컨텍스트 목록 확인**
  ```bash
  kubectl config get-contexts
  ```
- **컨텍스트 변경**
  ```bash
  kubectl config use-context <context-name>
  ```

---


## 📦 파드(Pod) 관련 명령어
- **파드 목록 조회**
  ```bash
  kubectl get pods
  kubectl get pods -n <namespace>
  ```
- **파드 상세 정보 조회**
  ```bash
  kubectl describe pod <pod-name>
  ```
- **파드 로그 확인**
  ```bash
  kubectl logs <pod-name>
  kubectl logs -f <pod-name> # 실시간 로그
  ```
- **파드 접속 (쉘 실행)**
  ```bash
  kubectl exec -it <pod-name> -- /bin/bash
  ```
- **파드 삭제**
  ```bash
  kubectl delete pod <pod-name>
  ```

---

## 📂 디플로이먼트(Deployment) 관련 명령어
- **디플로이먼트 목록 조회**
  ```bash
  kubectl get deployments
  ```
- **디플로이먼트 생성**
  ```bash
  kubectl create deployment <deployment-name> --image=<image-name>
  ```
- **디플로이먼트 업데이트**
  ```bash
  kubectl set image deployment/<deployment-name> <container-name>=<new-image>
  ```
- **디플로이먼트 롤아웃 상태 확인**
  ```bash
  kubectl rollout status deployment/<deployment-name>
  ```
- **디플로이먼트 롤백**
  ```bash
  kubectl rollout undo deployment/<deployment-name>
  ```

---

## 🏗 서비스(Service) 관련 명령어
- **서비스 목록 조회**
  ```bash
  kubectl get services
  ```
- **서비스 생성 (예: NodePort)**
  ```bash
  kubectl expose deployment <deployment-name> --type=NodePort --port=<port>
  ```
- **서비스 상세 정보 조회**
  ```bash
  kubectl describe service <service-name>
  ```
- **서비스 삭제**
  ```bash
  kubectl delete service <service-name>
  ```

---

## 🗃 네임스페이스(Namespace) 관련 명령어
- **네임스페이스 목록 확인**
  ```bash
  kubectl get namespaces
  ```
- **네임스페이스 생성**
  ```bash
  kubectl create namespace <namespace-name>
  ```
- **네임스페이스 삭제**
  ```bash
  kubectl delete namespace <namespace-name>
  ```

---

## ⚡ 기타 유용한 명령어
- **리소스 종류별 전체 조회**
  ```bash
  kubectl get all
  ```
- **리소스를 YAML 형식으로 확인**
  ```bash
  kubectl get <resource> <resource-name> -o yaml
  ```
- **YAML 파일을 통한 리소스 생성/적용**
  ```bash
  kubectl apply -f <file.yaml>
  ```
- **리소스 삭제 (YAML 기준)**
  ```bash
  kubectl delete -f <file.yaml>
  ```
- **kubectl 자동완성 설정 (bash 기준)**
  ```bash
  source <(kubectl completion bash)
  ```

---

## 🌐 네트워크 및 디버깅
- **파드 내 네트워크 연결 확인**
  ```bash
  kubectl exec -it <pod-name> -- curl <service-name>:<port>
  ```
- **트러블슈팅 시 유용한 명령어**
  ```bash
  kubectl describe node <node-name>
  kubectl get events --sort-by='.metadata.creationTimestamp'
  ```

---

## 📝 참고 사항
- `<namespace>`, `<pod-name>`, `<deployment-name>`, `<service-name>`, `<node-name>`, `<context-name>`, `<image-name>`, `<port>`, `<file.yaml>` 등은 실제 환경에 맞게 변경하여 사용합니다.
- 자주 사용하는 옵션:
  - `-n <namespace>`: 특정 네임스페이스 지정
  - `-o yaml|json`: 출력 형식 지정
  - `-f <file>`: 파일 지정
  
이 문서는 쿠버네티스 환경에서 자주 수행하는 작업을 보다 효율적으로 처리할 수 있도록 도움을 주기 위한 기본 명령어 모음을 제공합니다.

