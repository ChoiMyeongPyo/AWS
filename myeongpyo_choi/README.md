# 최명표_경력기술서

## About Me

> 클라우드 전환과 자동화를 주도하며, 안정적인 서비스 운영과 비용 최적화를 이끌어낸 DevOps 엔지니어입니다.  
> KT Cloud, NCP, AWS 등 다양한 환경에서 인프라 설계와 보안을 최적화하며,  
> **Terraform 기반 IaC**, **ECS/Fargate 운영**, **Datadog 고도화**, **GitOps 기반 배포 자동화** 등의 경험을 보유하고 있습니다.  
> 기술의 깊이와 넓이를 바탕으로, 팀과 함께 성장하고 문제를 해결하는 것을 즐깁니다.

---

## 🛠 Tech Stack

### Cloud & Infra
- AWS (ECS, EKS, Lambda, RDS, S3, ALB, IAM)
- KT Cloud, Naver Cloud Platform (NCP)
- IDC 및 하이브리드/멀티 클라우드 네트워크 설계 및 운영 경험

### DevOps & Automation
- Docker, AWS Fargate, ECS Anywhere, AWS EKS
- Kubernetes, Argo CD, Helm (PoC)
- Terraform (IaC), config.yaml 기반 자동화 스크립트 작성
- **CI/CD 환경 구축 및 운영**: Bitbucket + Bamboo 파이프라인을 활용한 AWS 리소스 배포 자동화 경험 보유
- GitOps 환경 구성 및 배포 흐름 최적화

### Monitoring & Logging
- Datadog (Infra, APM, DBM 통합 모니터링)
- AWS CloudWatch
- Slack 연동 알림 자동화, 로그 기반 장애 감지 및 대응 시스템 구축

---

## 경력 사항

## 🏢  팀프레시 | DevOps 엔지니어
**재직기간**: 2024.08 ~ (재직중)  
**담당업무**: 클라우드 인프라 설계 및 운영, 보안/비용 최적화, 모니터링 자동화, Terraform 기반 IaC 고도화

---

### ✅ 주요 프로젝트 및 성과


---

### 2024.08 Terraform 관리 고도화

- 전사 공통 Terraform 모듈 구조 정의 및 모듈화
- ECS Anywhere, Fargate, ALB, ACM 등 다양한 리소스 유형 지원
- config.yaml 자동화 구성 도입으로 CLI 없이 인프라 설정 가능
- 신규 서비스 시 3-tier 아키텍처 신속 배포 및 문서화 체계 마련
- **작업 시간 455시간 절감 / 연간 $18,200 비용 절감**

---

### 2024.09 Datadog APM 고도화 및 시각화

- APM Span Trace 필터링으로 중요 트랜잭션만 수집
- 스쿼드별 대시보드 구성: 전일·금일 리소스 사용량 실시간 시각화
- 팀 간 협업을 위한 커뮤니케이션용 Datadog 보드 활용
- **520시간/연간 절감 → $20,800 → $2,600으로 비용 최적화**

---

### 2024.10 신규 서비스 구축 및 아키텍처 설계

- TimfMatch, 맘스터치, ROS 일본 서비스 인프라 설계 및 배포
- ECS Fargate + ALB 기반 3-Tier 고가용성 아키텍처 구축
- 일본 리전 대비 Latency 분석 기반 리전 선택
- **중복 리소스 제거로 인한 운영 비용 절감 및 재활용 구조 수립**

---

### 2024.11 CloudWatch & Datadog 비용 최적화

- 불필요한 메트릭 제거 및 MetricMonitorUsage 최적화
- **Datadog 비용 월 $1,250 절감 → 연 $15,000 절감**
- **로그 파싱 시간 절감: 연간 180시간 → $7,206 절감**
- **테스트 인프라 자동화로 50시간/연, $2,000 절감**

---

### 2024.12 DevLake 기반 DORA 지표 도입

- DevOps 성숙도 향상을 위한 오픈소스 DevLake POC 수행
- Grafana + DevLake 대시보드 구성
- RDS 보안 설정 강화 및 DataTransfer 최적화
- **매년 1,629만 건 SQL 공격 차단 / 연간 $7,200 비용 절감**

---

### 2025.01~02 보안 아키텍처 고도화 및 Slack 자동화

- Slack Webhook 연동으로 보안 리포트 자동 전달
- ECS Anywhere 재부팅 시 ALB 타겟 자동 제거 → 트래픽 장애 예방
- Slack 봇으로 ECS 부팅 상태 실시간 모니터링 자동화

---

### 2025.02 SLO 정의 및 Redis 보안 강화

- 주요 서비스별 SLO 지표 수립 (가용성, 오류율, 응답속도 등)
- Redis ElastiCache TLS 활성화 및 AUTH 기반 보안 도입
- 데이터 무결성 검증 및 인증 체계 구축

---

### 2025.03 SSL 무중단 전환 및 ARM 빌드 PoC

- Sectigo Wildcard SSL → AWS ACM 전환, Terraform으로 자동화
- 무중단 인증서 배포 및 연간 약 80만원 절감
- docker buildx 기반 ARM 이미지 빌드
- Graviton 기반 서버 도입 시 연간 $11,280 절감 기대 (x86 → ARM)

---

### 2025.01~03 1분기 비용 최적화 프로젝트

- RDS, ALB, ECS 등 자원 통합으로 리소스 정리
- ALB 통합 (dev, stage, prod) → 연간 $7,800 절감
- 서비스별 인스턴스 스펙 조정 → TimfMatch, RDMS 등 월 수십만원 절감

---

## 💡 누적 성과 요약

| 항목                      | 절감 수치               |
|--------------------------|-------------------------|
| 작업 시간 절감           | 총 1,111시간/연         |
| 비용 절감 합계           | 약 $66,500 이상/연      |
| 리소스 정리              | ALB, ECR, S3, RDS 통합 최적화 |
| 보안 강화                | IAM, Redis, TLS, Audit Log |
| DevOps 문화 성숙도 개선  | DORA 기반 지표 운영 정착 |

---

---

### 🔧 핵심 기술 및 도구
- **AWS**: ECS, EKS, ALB, S3, RDS, CloudWatch, ACM, Route53, IAM, Parameter Store, SSM
- **IaC**: Terraform, config.yaml 기반 자동화
- **CI/CD**: Bamboo, ArgoCD, GitHub Actions
- **Observability**: Datadog (Infra, APM, DBM), SLO 대시보드, Slack 알림 연동
- **Security**: ACM, IAM Policy, SSM SecureString with KMS

---
## 🏢 디딤365 | 클라우드 엔지니어
**근무기간**: 2022.04 ~ 2024.08  
**담당업무**: 공공기관 클라우드 이전 및 통합 구축, AWS, NCP 및 KT Cloud 운영, 네트워크 및 보안 설계

### 수행 프로젝트

#### 1. 행정·공공기관 정보시스템 클라우드 전환·통합 사업 2차
- **기간**: 2022.04.25 ~ 2022.04.30  
- **역할**: 시스템 구축 및 운영, 클라우드 통합 환경 구성

#### 2. 도시숲 리빙랩 플랫폼 구축
- **기간**: 2022.04.25 ~ 2022.11.30  
- **역할**: 플랫폼 인프라 환경 구축 및 클라우드 이전

#### 3. 핵심산업클라우드 플래그십 프로젝트 - 환경에너지·디지털헬스
- **기간**: 2022.05.01 ~ 2022.12.31  
- **역할**: 프로젝트 운영 및 시스템 관리

#### 4. 청주시 온라인 도매시장 클라우드 서비스 도입
- **기간**: 2022.07.01 ~ 2023.05.30  
- **역할**: 온라인 시장 플랫폼 이전 및 운영환경 안정화

#### 5~6. 이동통신설비 구축지원센터 클라우드 연장 (1,2차)
- **기간**: 2023.01.01 ~ 2023.12.31  
- **역할**: 지속적인 클라우드 자원 유지보수 및 보안 강화

#### 7. 과제관리시스템 클라우드 운영
- **기간**: 2023.01.01 ~ 2023.12.31  
- **역할**: 과제관리시스템 운영 및 접근 제어 설계

#### 8. 공공자전거 이용사업 클라우드 서비스 임대
- **기간**: 2023.08.01 ~ 2023.12.31  
- **역할**: 클라우드 임대 운영 환경 안정화 및 SLA 유지

#### 9. 경기도일자리재단 클라우드 인프라 통합 운영
- **기간**: 2024.01.01 ~ 2024.02.07  
- **역할**: 클라우드 인프라 전환 및 통합 운영 담당

---

## 🎯 강점 요약

- **클라우드 플랫폼**: AWS, NCP, KT Cloud 운영 경험
- **모니터링**: Datadog APM/Infra/DBM 고도화 및 운영
- **보안 관리**: IAM, KMS, SSL 등 보안 체계 구축
- **공공 프로젝트 경험**: 정부·지자체 대상 클라우드 전환 및 운영 경험
---

## 🌱 교육 이수

- 📘 구트아카데미학원 / 2023.04.24 - 2023.04.27
> 쿠버네티스(Kubernetes) 고급 활용을 통한 컨테이너 오케스트레이션 구현

- 📘 한국정보교육원 / 2021.09.15 - 2022.03.07
> 클라우드컴퓨팅과 보안솔루션을 활용한 DC 엔지니어 양성


---

## 📜 Certifications

| 자격증명                                | 등급/레벨     | 취득일       | 자격번호            | 발급기관                            |
|----------------------------------------|---------------|--------------|---------------------|-------------------------------------|
| Certified Kubernetes Administrator     | admin         | 2024.03.16   | LF-iq7bbt4mqa       | Linux Foundation                    |
| AWS Solutions Architect                | Professional  | 2023.03.24   | Q529PJN2ZJQ414C7    | Amazon Web Services                 |
| Azure Virtual Desktop                  | Specialty     | 2023.08.31   | 491432BB3DE13078    | Microsoft Azure                     |
| Naver Cloud Platform Certified         | Professional  | 2022.12.28   | NCP_20224661        | NAVER Cloud Platform               |
| 리눅스마스터                            | 2급            | 2021.12.31   | LMS-2104-003214     | 한국정보통신진흥협회                 |
| 무선설비산업기사                        | 산업기사       | 2018.08.31   | 182210050           | 한국방송통신전파진흥원               |
| 정보통신산업기사                        | 산업기사       | 2018.05.25   | 187210038           | 한국방송통신전파진흥원               |
| 네트워크관리사                          | 2급            | 2017.12.12   | NT2040532           | 한국정보통신자격협회                 |
| ITQ (OA Master)                        | A등급          | 2016.10.27   | -                   | 한국생산성본부 등                   |

## 📬 Contact

- 📱 Mobile: 010-9756-3389  
- 📧 Email: zld3598@naver.com  
- 🌐 Blog: [pyowiki.com](https://pyowiki.com)  
- 💼 LinkedIn: [Link](https://www.linkedin.com/in/myeongpyochoi/)