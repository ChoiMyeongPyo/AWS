# 🌐 EKS에서 IRSA와 OIDC 쉽게 이해하기

## 1. ✅ IRSA란?

**IRSA (IAM Roles for Service Accounts)**는 AWS EKS에서 Pod 단위로 IAM 권한을 부여할 수 있는 기능이야.

기존에는:
- EKS 노드(EC2)에 IAM Role을 붙이고,
- 그 노드에 올라가는 모든 Pod가 같은 IAM 권한을 공유했어.

하지만 이런 것은 권한 분류가 ì \xec96b음. 그래서 **Pod별로 필요한 권한만 주기 위해 IRSA를 사용**하는 거야.

---

## 2. 🔐 OIDC는 왜 필요할까?

IRSA는 "이 ServiceAccount가 이 IAM Role을 사용할 수 있다"는 것을 증명해야 해.
그러면서 AWS는 EKS 클러스터에 **OIDC Provider**를 설정해줘.

OIDC는 OpenID Connect의 약자로, **신용 증명용 토큰을 주고받는 표준 인증 방식**이야.

EKS 클러스터는 Pod에게 OIDC 토큰을 발금하고, IAM은 그 토큰을 검증해서 권한을 주는 구조야.

---

## 3. 📦 전체 구조 요약

```
[Pod]
  ↓ (uses)
[ServiceAccount]
  ↓ (annotated with IAM Role ARN)
[IAM Role]
  ↑ (trusts)
[OIDC Provider (EKS)]
```

- Pod는 ServiceAccount를 사용하고,
- ServiceAccount는 IAM Role과 연결되어 있으며,
- IAM Role은 특정 OIDC Provider를 신뢰하고,
- 이 구조로 Pod가 IAM Role을 안전하게 Assume할 수 있음.

---

## 4. ⚙️ 실제 설정 환경

### 4.1 OIDC Provider 연결
```bash
eksctl utils associate-iam-oidc-provider \
  --cluster my-cluster \
  --region ap-northeast-2 \
  --approve
```

### 4.2 IAM Role 생성 및 정책 연결 (S3ReadOnly, SecretsManager 등)

### 4.3 IRSA(ServiceAccount + IAM Role) 생성
```bash
eksctl create iamserviceaccount \
  --name my-service-account \
  --namespace default \
  --cluster my-cluster \
  --attach-policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/MyPolicy \
  --approve
```

- 생성된 ServiceAccount는 IAM Role과 연결되어 있음
- Pod에서 해당 ServiceAccount를 사용하면, IAM Role을 Assume할 수 있음

---

## 5. 🔎 IRSA가 좋은 이유

| 항목 | 내용 |
|------|------|
| 보안성 향상 | 최소 권한 원칙 (Least Privilege) 적용 가능 |
| IAM 관리 편리 | 서비스 단위로 IAM 정책 분리 가능 |
| 감싸 가능 | 어느 Pod가 어느 IAM Role을 쓰였는지 CloudTrail로 추적 가능 |

---

## 6. 파드 아이덴티티 (EKS 파드 아이덴티티)

**EKS 파드 아이덴티티**는 IRSA의 조합 개선 복잡성을 가소하고, 더 쉽게 IAM 권한을 Pod에 부여할 수 있게 해줍니다.

### 특징
- IRSA 같이 OIDC Provider가 필요하지 않음
- IAM Role과 Pod를 EKS에서 직접 바추는 구조
- 구성이 간단하고 복장성 없음

### 비교 (IRSA vs Pod Identity)

| 구단 | IRSA | EKS 파드 아이덴티티 |
|--------|------|-----------------|
| OIDC 필요 | 필요 | 모두 제거함 |
| 매니저리 | ServiceAccount에 관련 | IAM Role을 클러스터가 관리 |
| 구성 여부 | 일반기 필요 | 구성 없음 (eksctl 필요 없음) |
| 복장성 | 복장적 | 가능성 복지 |

### 가장 큰 차이
- **IRSA**는 업글된 설정이 필요
- **Pod Identity**는 구성 간단 + 클러스터 범위가 관리

---

## 7. 😎 자주 나오는 질문

### Q. OIDC Provider는 어떻게 등록되나요?
- IAM 카페 → 신뢰할 수 있는 IdP 항목에 등록됨

### Q. OIDC 토큰은 어느 경로에 저장되나요?
- Pod 내부의 `/var/run/secrets/eks.amazonaws.com/serviceaccount/token`

### Q. OIDC가 없으면 IRSA는 안 되나요?
- 마지막으로 그렇다. **OIDC Provider가 무엇보다 먼저 등록되어야 IRSA 설정 가능**

---

## 8. 🔗 참고 자리

- [AWS 공식 IRSA 문서](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [eksctl IRSA 예제](https://eksctl.io/usage/iamserviceaccounts/)
- [OIDC OpenID Connect 개요](https://openid.net/connect/)
- [EKS Pod Identity 공식](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)

---

## 9. 포장 정리

- IRSA는 **Pod별 IAM 권한 부여 방식**
- OIDC는 **ServiceAccount의 신뢰성 보장을 위한 인증 구조**
- Pod Identity는 이것을 간단하고 더 쉽게 변경
- IRSA 또는 Pod Identity는 현재 권한 관리의 기준이며, 안전과 관리성이 자리재가 된다

