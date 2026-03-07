# Memento Kit 설치 후 체크리스트

이 문서는 `설치 후 정상 상태가 무엇인지` 아주 짧게 확인하기 위한 체크리스트다.

## 1. 설치 직후

아래 명령이 끝까지 통과해야 한다.

```bash
npm run safe:hooks
npm run safe:git-config
npm run adopt:bootstrap
npm run docs:refresh
npm run docs:check
```

## 2. 바로 생겨 있어야 하는 것

- `docs/generated/project-truth-bootstrap.md`
- `docs/generated/context-value-demo.md`
- `docs/generated/route-map.md`
- `docs/generated/store-authority-map.md`
- `docs/generated/api-group-map.md`

## 3. 기대 상태

- 에이전트가 `README -> AGENTS -> docs/README` 순서로 시작할 수 있다
- `context-kit.json`에 surface별 `routes/stores/apis`가 최소한 자동 seed 되어 있다
- `docs/product-specs/*.md`의 Context Contracts가 비어 있지 않다
- `docs/ENGINEERING.md`에 inventory snapshot이 들어가 있다
- `docs/GIT_WORKFLOW.md`가 있고 git 규칙이 보인다
- repo-local git config가 적용돼 있다

## 4. 보고서에서 봐야 하는 것

`docs/generated/project-truth-bootstrap.md`

- 무엇이 자동으로 채워졌는지
- 어떤 문서가 아직 비어 있는지
- 다음에 무엇을 채워야 하는지

`docs/generated/context-value-demo.md`

- small map가 충분히 작은지
- 코드 스캔 전 routes/stores/apis가 보이는지
- 아직 시간 절감 telemetry가 비어 있는지 아닌지

## 5. git 쪽 정상 상태

아래 값이 잡혀 있어야 한다.

```bash
git config --local --get core.hooksPath
git config --local --get pull.ff
git config --local --get merge.conflictstyle
git config --local --get rerere.enabled
```

기대값:

- `.githooks`
- `only`
- `zdiff3`
- `true`

## 6. 실제로 체감돼야 하는 것

- 예전처럼 `src/`를 먼저 다 뒤지지 않는다
- route/store/api를 generated docs에서 먼저 본다
- 다음 세션이 와도 checkpoint/brief로 재개한다
- 브랜치/worktree/sync 규칙이 명확하다

## 7. 아직 덜 된 상태의 신호

이런 상태면 설치는 됐지만 `진짜 프로젝트 진실`은 아직 덜 들어간 것이다.

- `docs/ENGINEERING.md`가 placeholder 위주다
- `docs/product-specs/*.md`가 한두 문장뿐이다
- `context-kit.json`의 매핑이 아직 부정확하다
- telemetry run이 0건이다

## 8. 한 줄 기준

정상 상태는 `문서가 늘어난 상태`가 아니라, `에이전트가 덜 헤매고 더 빨리 재개할 수 있는 상태`다.
