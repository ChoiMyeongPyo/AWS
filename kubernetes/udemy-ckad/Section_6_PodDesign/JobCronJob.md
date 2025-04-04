# CKAD 실습: 쿠버네티스 Job (Batch Processing) & CronJob (Scheduled Jobs)

---

## 📌 1. 개요

이 실습에서는 **쿠버네티스 Job과 CronJob**을 활용하여 **배치 처리(Batch Processing) 작업과 정기 실행(Scheduled Jobs) 작업을 수행하는 방법**을 학습합니다.  
Job을 사용하면 **특정 작업을 수행한 후 종료되는 컨테이너**를 관리할 수 있으며, **병렬 실행과 오류 처리**도 가능합니다.  
CronJob을 사용하면 **Linux Crontab과 같은 방식으로 주기적으로 실행되는 작업을 스케줄링**할 수 있습니다.

[쿠버네티스 공식 문서 - Job](https://kubernetes.io/docs/concepts/workloads/controllers/job/)  
[쿠버네티스 공식 문서 - CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

---

## 🏗 2. 배치 작업(Batch Processing) 개념

### ✅ 쿠버네티스에서 수행할 수 있는 작업 유형
- **웹 애플리케이션** (지속적인 실행)
- **데이터베이스 서버** (지속적인 실행)
- **배치 처리 작업 (Batch Processing)**
  - **연산 수행 (예: 수학 계산, 데이터 처리)**
  - **이미지 처리**
  - **데이터 분석 및 리포트 생성**
  - **이메일 발송**
  - **대량 데이터 변환**
- **정기적으로 실행되는 작업 (Scheduled Jobs)**
  - **매일 새벽 데이터 백업**
  - **매주 월요일 보고서 생성**
  - **매시간 특정 데이터베이스 정리 작업 수행**

이러한 배치 작업은 **짧은 시간 동안 실행된 후 종료**되는 것이 특징입니다.

---

## 🔄 3. Job과 포드(Pod)의 차이점

- **일반 포드(Pod)**: 기본적으로 종료된 후에도 **다시 시작(restart)** 됨
- **Job을 사용한 포드**: **한 번 실행된 후 종료**되고, 필요하면 다시 실행 가능

### ✅ 포드의 기본 재시작 정책
```yaml
restartPolicy: Always  # 기본값, 실패해도 자동 재시작 (웹 서버 등 지속 실행 목적)
restartPolicy: Never   # 한 번 실행 후 종료 (배치 작업에 적합)
restartPolicy: OnFailure  # 실패한 경우에만 다시 시작
```

[쿠버네티스 공식 문서 - Restart Policy](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy)

---

## 🚀 4. Job 생성 및 실행

### ✅ 4.1 간단한 Job 정의 (수학 연산)
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: math-add-job
spec:
  template:
    spec:
      containers:
      - name: calculator
        image: busybox
        command: ["expr", "3", "+", "5"]
      restartPolicy: Never
```

### ✅ 4.2 Job 생성 및 확인
```bash
kubectl apply -f math-add-job.yaml
kubectl get jobs
kubectl get pods
```

### ✅ 4.3 Job 로그 확인
```bash
kubectl logs <pod-name>
```
출력 예제:
```
8  # 3 + 5 연산 결과
```

### ✅ 4.4 Job 삭제
```bash
kubectl delete job math-add-job
```
- Job을 삭제하면 해당 Job이 생성한 모든 포드도 삭제됨

---

## ⏰ 5. CronJob을 활용한 정기 작업 실행

### ✅ 5.1 CronJob 개념
- **Linux의 Crontab과 동일한 방식으로 특정 시간 간격마다 실행되는 Job**
- 데이터 백업, 로그 정리, 정기 리포트 생성 등에 사용
- `schedule` 필드에 **크론 표현식(Cron Syntax)**을 사용하여 실행 주기를 설정

### ✅ 5.2 CronJob 정의 예제 (매일 자정 실행)
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: report-cronjob
spec:
  schedule: "0 0 * * *"  # 매일 자정 실행
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: report-generator
            image: busybox
            command: ["sh", "-c", "echo 'Generating report...' && sleep 10"]
          restartPolicy: Never
```

### ✅ 5.3 CronJob 생성 및 확인
```bash
kubectl apply -f report-cronjob.yaml
kubectl get cronjob
kubectl get jobs
kubectl get pods
```

### ✅ 5.4 CronJob의 실행 내역 확인
```bash
kubectl get jobs --selector=job-name=report-cronjob
```

### ✅ 5.5 CronJob 로그 확인
```bash
kubectl logs -f <pod-name>
```
출력 예제:
```
Generating report...
```

### ✅ 5.6 CronJob 삭제
```bash
kubectl delete cronjob report-cronjob
```

[쿠버네티스 공식 문서 - CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

---

## 🎯 6. 핵심 요약

| 개념 | 설명 |
|------|------|
| **Job** | 특정 작업을 수행하고 완료된 후 종료되는 쿠버네티스 리소스 |
| **CronJob** | 지정된 일정에 따라 자동 실행되는 Job |
| **Restart Policy** | Job은 `Never` 또는 `OnFailure`로 설정해야 함 |
| **Completions** | 성공적으로 완료해야 하는 작업 개수 |
| **Parallelism** | 한 번에 병렬로 실행할 작업 개수 |
| **BackoffLimit** | 실패 시 몇 번까지 재시도할지 설정 |
| **schedule** | Cron 표현식을 사용하여 실행 주기 지정 |

[쿠버네티스 공식 문서 - Job](https://kubernetes.io/docs/concepts/workloads/controllers/job/)  
[쿠버네티스 공식 문서 - CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

---

## 🎉 7. 강의 마무리

이 실습에서는 **쿠버네티스 Job을 활용한 배치 처리 작업과 CronJob을 활용한 정기 작업 실행 방법**을 학습했습니다.  
💪 **다음 강의**에서는 **고급 배치 작업 관리 및 모니터링 방법**을 다룰 예정입니다.

✨ **실습 환경에서 직접 Job과 CronJob을 생성하고 실행해 보세요!** 🚀

