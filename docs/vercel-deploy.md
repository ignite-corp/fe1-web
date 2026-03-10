# Vercel 배포

## 개요
- Next.js 16 (App Router) 프로젝트를 Vercel에 배포
- 배포 환경: Production 단일 환경
- 커스텀 도메인: 없음 (Vercel 기본 도메인 사용)

## 환경변수

| 변수명 | 설명 |
|--------|------|
| `IGNITE_JIRA_EMAIL` | Ignite Jira 계정 이메일 |
| `IGNITE_JIRA_API_TOKEN` | Ignite Jira API 토큰 |
| `HMG_JIRA_EMAIL` | HMG Jira 계정 이메일 |
| `HMG_JIRA_API_TOKEN` | HMG Jira API 토큰 |
| `BLACKDUCK_BASE_URL` | Blackduck 서버 URL |
| `BLACKDUCK_HB_GROUPWARE_TOKEN` | Blackduck HB Groupware 토큰 |
| `BLACKDUCK_CPO_TOKEN` | Blackduck CPO 토큰 |
| `SONALQUBE_TOKEN` | SonarQube API 토큰 |
| `SONARQUBE_URL` | SonarQube 서버 URL |

## 작업 항목
- [x] 로컬 빌드 테스트 (`npm run build`) — 성공
- [x] `curl.md` 히스토리 제거 (git filter-repo) — GitHub Push Protection 대응
- [x] 개인 레포(ignite-seongju/fe1-web) remote 추가 및 push — 조직 관리자 권한 없이 배포하기 위함
- [ ] **Vercel 프로젝트 생성 및 GitHub 연결** ← 현재 여기
- [ ] 환경변수 설정 (9개)
- [ ] 배포 확인

## 현재 진행 상황 (이어서 작업 시 참고)

### 완료된 작업
1. `.gitignore`에 `.taskmaster/`, `curl.md` 추가
2. `git filter-repo`로 `curl.md` 전체 히스토리에서 제거
3. remote 구성: `origin`(ignite-corp), `personal`(ignite-seongju) 양쪽 force push 완료
4. 로컬 빌드 정상 확인

### 다음 단계: Vercel 프로젝트 연결
1. Vercel → New Project → **"Import Git Repository"** 에서 `ignite-seongju/fe1-web` 선택
   - ⚠️ "Clone from GitHub"가 아닌 **Import** 로 진행해야 함
2. Framework Preset: Next.js (자동 감지)
3. 환경변수 9개 입력 (`.env.local` 참고)
4. Deploy 클릭

### Git Remote 구성
```
origin   → https://github.com/ignite-corp/fe1-web.git (조직 레포)
personal → https://github.com/ignite-seongju/fe1-web.git (개인 레포, Vercel 배포용)
```

## 빌드 설정
- Framework: Next.js
- Build Command: `next build` (기본값)
- Output Directory: `.next` (기본값)
- Install Command: `npm install` (기본값)

## 참고사항
- `.env.example`의 AI 서비스 API 키들은 Task Master 전용이므로 Vercel 환경변수에 불필요
- `SONALQUBE_TOKEN` 오타 여부 확인 필요 (SONARQUBE vs SONALQUBE)
