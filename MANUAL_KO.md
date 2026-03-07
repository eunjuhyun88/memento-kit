# Codex Context Kit Manual

이 문서는 `codex-context-kit`를 다른 사람에게 넘길 때 같이 주는 가장 짧은 사용 메뉴얼이다.

## 1. 이게 하는 일

이 kit는 저장소를 `AI가 읽기 쉬운 repo`로 바꾼다.

설치하면 다음이 생긴다.

- 짧은 진입점 문서: `README.md`, `AGENTS.md`, `ARCHITECTURE.md`
- canonical docs 구조: `docs/`
- generated context maps: route/store/API map
- semantic resume 도구: checkpoint / brief / handoff
- registry / retrieval / agent / tool catalog
- context value 보고서와 검증 스크립트

핵심 목적은 이것이다.

- AI가 어디부터 읽어야 하는지 알게 하기
- 전체 문서를 다 읽지 않고도 repo 구조를 파악하게 하기
- 작업 맥락을 세션 사이에 이어받게 하기
- 실제로 컨텍스트 비용이 줄었는지 보고서로 확인하게 하기

## 2. 설치 방법

기존 repo 또는 새 repo에서 아래처럼 실행한다.

```bash
bash /absolute/path/to/codex-context-kit/setup.sh \
  --target . \
  --project-name MyProject \
  --summary "한 줄 설명" \
  --stack "TypeScript / SvelteKit" \
  --surfaces core,admin,api
```

예시:

```bash
mkdir my-project
cd my-project
git init
bash /Users/ej/Downloads/codex-context-kit/setup.sh \
  --target . \
  --project-name MyProject \
  --summary "AI-friendly project"
```

## 3. 설치 직후 해야 할 것

```bash
npm run safe:hooks
npm run docs:refresh
npm run docs:check
```

그 다음 이 파일들을 먼저 채운다.

- `context-kit.json`
- `README.md`
- `AGENTS.md`
- `ARCHITECTURE.md`
- `docs/SYSTEM_INTENT.md`
- `docs/product-specs/*.md`

원칙은 간단하다.

- 큰 설명 하나를 쓰지 말고
- 짧은 진입점 + surface별 정본 문서로 나눈다

## 4. 실제 작업할 때 쓰는 순서

AI가 작업을 시작할 때 읽는 순서는 이렇다.

1. `README.md`
2. `AGENTS.md`
3. `ARCHITECTURE.md`
4. `docs/README.md`
5. 관련 `docs/product-specs/*.md`
6. 관련 generated map
7. 그 다음 코드

작업 시작 전에는 checkpoint를 남긴다.

```bash
npm run ctx:checkpoint -- \
  --work-id "W-$(date +%Y%m%d-%H%M)-myproject-codex" \
  --surface "core" \
  --objective "현재 작업 목표"
```

병렬 작업이면 claim을 먼저 잡는다.

```bash
npm run coord:claim -- \
  --work-id "W-$(date +%Y%m%d-%H%M)-myproject-codex" \
  --agent "codex-a" \
  --surface "core" \
  --summary "작업 범위 설명" \
  --path "src/routes/core"
```

## 5. 동작 확인 방법

가장 먼저:

```bash
npm run docs:check
```

찾기/조회:

```bash
npm run registry:query -- --q core
npm run registry:describe -- --kind tool --id context-retrieve
npm run retrieve:query -- --q "routing rules"
```

실제 체감 보고서:

```bash
npm run value:demo
```

생성되는 보고서:

- `docs/generated/context-value-demo.md`

이 보고서에서 봐야 하는 것은:

- small map가 전체 문서보다 얼마나 작은지
- 코드 스캔 전에 routes / stores / APIs가 보이는지
- spec alignment가 맞는지
- checkpoint / harness가 있는지

## 6. 시간이 실제로 아껴졌는지 보는 방법

telemetry 예시:

```bash
npm run agent:start -- --agent planner --surface core
npm run agent:event -- --type doc_open --path docs/PLANS.md
npm run agent:finish -- --status success --baseline-minutes 30
npm run agent:report
```

결과 파일:

- `docs/generated/agent-usage-report.md`
- `docs/generated/agent-usage-report.json`

비교 실험도 가능하다.

```bash
npm run eval:ab:record -- \
  --task-id "TASK-001" \
  --surface "core" \
  --routed-docs 4 \
  --baseline-docs 10 \
  --routed-minutes 2 \
  --baseline-minutes 6
npm run eval:ab:refresh
```

여기서 확인한다.

- `docs/generated/context-ab-report.md`

## 7. 누구에게 주면 되는 파일

보통은 아래 두 개만 주면 된다.

- 이 메뉴얼: `MANUAL_KO.md`
- 압축 파일: `codex-context-kit.zip`

압축을 푼 뒤 상대방은:

1. `setup.sh` 실행
2. `npm run docs:refresh`
3. `npm run docs:check`
4. `npm run value:demo`

이 4단계만 해도 kit가 실제로 동작하는지 확인할 수 있다.

## 8. 언제 의미가 큰가

특히 의미 있는 경우:

- repo가 커서 어디부터 읽어야 할지 자주 막힐 때
- AI가 여러 세션에 걸쳐 작업할 때
- 여러 agent가 동시에 작업할 때
- 문서가 많지만 정본이 불명확할 때

의미가 작은 경우:

- 아주 작은 개인 실험 repo
- 하루 이틀짜리 throwaway repo

## 9. 한 줄 요약

이 kit는 `문서를 많이 쓰게 하는 도구`가 아니라, `AI가 적은 문맥으로도 repo를 잘 읽고 작업하게 만드는 구조`를 설치하는 도구다.
