# Kubernetes Init Containers (초기화 컨테이너)

## 1. 멀티 컨테이너 POD
- 일반적으로 POD 내의 컨테이너들은 POD의 라이프사이클 동안 계속 실행됨.
- 예: 웹 애플리케이션과 로그 에이전트가 함께 실행되는 경우, 둘 중 하나라도 종료되면 POD가 재시작됨.

## 2. Init Containers(초기화 컨테이너)의 필요성
- 어떤 작업은 POD 시작 전에 한 번만 실행되면 충분한 경우가 있음.
- 예:
  - 애플리케이션이 실행되기 전에 필요한 코드나 바이너리를 가져오기.
  - 외부 서비스(DB 등)가 준비될 때까지 대기하기.

## 3. Init Containers의 동작 방식
- 일반 컨테이너와 유사하게 `initContainers` 섹션에 정의됨.
- Init Container는 POD가 시작될 때 실행되며, 반드시 완료되어야 애플리케이션 컨테이너가 시작됨.
- 여러 개의 Init Container를 설정할 수 있으며, 순차적으로 하나씩 실행됨.
- 만약 Init Container가 실패하면 POD는 계속 재시작됨.

## 4. Init Container 예제

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox
    command: ['sh', '-c', 'git clone <some-repository-that-will-be-used-by-application> ;']
```

- 이 Init Container는 애플리케이션이 실행되기 전에 git에서 코드 또는 바이너리를 다운로드함.

## 5. 외부 서비스(DB, API 등)가 준비될 때까지 대기하는 예제

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox:1.28
    command: ['sh', '-c', 'until nslookup myservice; do echo waiting for myservice; sleep 2; done;']
  - name: init-mydb
    image: busybox:1.28
    command: ['sh', '-c', 'until nslookup mydb; do echo waiting for mydb; sleep 2; done;']
```

- `init-myservice`: `myservice`가 DNS에서 조회될 때까지 반복적으로 대기
- `init-mydb`: `mydb`가 DNS에서 조회될 때까지 반복적으로 대기
- 두 Init Container가 모두 성공적으로 완료된 후 애플리케이션 컨테이너가 실행됨.

## 정리
- Init Container는 POD 실행 전에 필요한 사전 작업을 수행하는 용도로 사용됨.
- 여러 개의 Init Container를 설정할 수 있으며, 순차적으로 실행됨.
- Init Container가 실패하면 POD는 계속 재시작됨.
- 주로 데이터 초기화, 외부 서비스 의존성 해결, 구성 파일 생성 등에 활용됨.

## 📖 추가적인 공식 문서
🔗 [Kubernetes Init Containers 공식 문서](https://kubernetes.io/docs/concepts/workloads/pods/init-containers)