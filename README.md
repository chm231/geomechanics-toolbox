# Geomechanics Toolbox

암반역학·지열/저류층 지질역학 해석용 MATLAB 툴박스입니다.
App Designer 기반의 메인 런처(`Simulator_int.mlapp`)에서 아래 모듈을 호출하며,
MATLAB Compiler로 독립 실행 파일(`Geomechanics_Toolbox.exe`)로도 배포합니다.

> DFN(Discrete Fracture Network) 역해석·재구성 연구는 별도 저장소
> [chm231/DFN](https://github.com/chm231/DFN) 에서 진행합니다.
> 이 저장소는 툴박스 애플리케이션(GUI·계산 모듈·배포) 전용입니다.

## 모듈 구성

| 메인 메뉴 | 진입 파일 | 내용 |
|---|---|---|
| Borehole Stability | `BSA210831_v2.m` (`calUCS.m`, `calOBB.m`) | 시추공 안정성 해석 — 요구 UCS, 브레이크아웃 방향, 열응력 포함 |
| Hydrofracturing Estimation | `HFsim.m` / `HFsim.fig` | 수압파쇄 균열 성장 추정 — PKN, KGD, Radial 모델 (`PKN3D.m`, `KGD3D.m`, `radial3D.m`) |
| Hydroshearing Estimation | `HSsim.m` / `HSsim.fig` | 수압전단(hydroshearing) 추정 |
| Temperature Prediction | `TherCal.m` / `TherCal.fig` | 저류층·암반 온도 예측 (`rockTemp_*.m`, `talbot_inversion.m`) |
| Stereographic Projection | `stereoProjection.m` / `.fig` | 스테레오 투영, 슈미트/울프 네트, 로즈 다이어그램, FCM 클러스터링 |
| 3D DFN Generation | `threeddfngui.m` / `.fig` | 간단한 3차원 DFN 생성 GUI (툴박스 내장 기능) |
| 3D Mohr Circle | `Mohr_Circle.mlapp`, `Mohr_Sub.mlapp` | 3차원 모어원 |
| Strength Anisotropy | `anisotropy.mlapp` | 강도 이방성 |
| (공통) | `Units.m` / `Units.fig`, `descriptions.m` | 단위 변환, 도움말 화면 |

## Python 포팅

MATLAB Runtime 없이 실행되는 Python(PySide6 + matplotlib) 버전입니다. 8개 모듈 전부 이식됐습니다.
계산 코드(`geomech/core/`)와 화면 코드(`geomech/gui/`)를 분리하고, 모듈마다 MATLAB 원본 출력값과
대조하는 회귀 테스트(`tests/`)를 둡니다.

| 모듈 | 계산 코드 | GUI | MATLAB 대조 테스트 |
|---|---|---|---|
| Hydrofracturing Estimation | `geomech/core/hydrofrac.py` | `geomech/gui/hydrofrac_panel.py` | `tests/test_hydrofrac.py` (5 케이스, 상대오차 1e-8) |
| Temperature Prediction | `geomech/core/thermal.py`, `thermal_project.py` | `geomech/gui/thermal_panel.py` | `tests/test_thermal.py` (5 케이스; Bodvarsson 1e-8, Talbot 역변환 모델 2e-3 °C) |
| 3D Mohr Circle | `geomech/core/mohr.py` | `geomech/gui/mohr_panel.py` | `tests/test_mohr_aniso.py` (6 케이스, 1e-10; 방향코사인 해석해와도 일치) |
| Strength Anisotropy | `geomech/core/anisotropy.py` | `geomech/gui/anisotropy_panel.py` | `tests/test_mohr_aniso.py` (4 케이스, 1e-10; Jaeger 식과 일치) |
| Borehole Stability | `geomech/core/borehole.py` | `geomech/gui/borehole_panel.py` | `tests/test_borehole.py` (해석해 5, FEM 1, 전방위 3 케이스) |
| Hydroshearing Estimation | `geomech/core/hydroshear.py` | `geomech/gui/hydroshear_panel.py` | `tests/test_hydroshear.py` (4 케이스; Pcm/Pco/Pc/최적방향 1e‑10, 응력다각형·스테레오넷 1e‑10) |
| Stereographic Projection | `geomech/core/stereonet.py` | `geomech/gui/stereonet_panel.py` | `tests/test_stereonet.py` (투영·밀도등고선·평균방향·FCM·로즈 1e‑9) |
| 3D DFN Generation — 툴박스 모드 | `geomech/core/dfn.py` | `geomech/gui/dfn_panel.py` | `tests/test_dfn.py` (같은 시드로 MATLAB 실현과 1e‑12 일치) |
| 3D DFN Generation — 암반 모드 | `geomech/core/dfn_rockmass.py` | `geomech/gui/dfn_rockmass_panel.py` | `tests/test_dfn_rockmass.py` (DFN 프로젝트 원본 스크립트와 같은 시드로 완전 일치) |
| Units | `geomech/core/units.py` | `geomech/gui/units_dialog.py` (Hydrofracturing 창의 Units… 버튼) | `tests/test_units.py` (Units.m 환산계수 전부 대조) |

```bash
pip install -e .[dev]          # numpy, scipy, matplotlib, PySide6, pytest
geomech                        # 런처 실행 (또는 python -m geomech.gui.app)
pytest                         # MATLAB 대조 테스트
```

MATLAB 기준값 재생성(MATLAB 설치 필요):

```bash
matlab -batch "run('tools/gen_reference_hydrofrac.m')"
matlab -batch "run('tools/gen_reference_thermal.m')"
matlab -batch "run('tools/gen_reference_mohr_aniso.m')"   # .mlapp 콜백의 계산부를 함수로 복사해 실행
python tools/make_reference_borehole_m.py                  # BSA210831_v2.m 계산 블록을 그대로 잘라 함수로 감싼 .m 생성
matlab -batch "run('tools/gen_reference_borehole.m')"
python tools/make_reference_hydroshear_m.py && matlab -batch "run('tools/gen_reference_hydroshear.m')"
python tools/make_reference_stereonet_m.py  && matlab -batch "run('tools/gen_reference_stereonet.m')"
python tools/make_reference_dfn_m.py        && matlab -batch "run('tools/gen_reference_dfn.m')"
```

3D DFN은 MATLAB `rng(seed,'twister')`와 numpy `RandomState(seed)`의 균일난수 스트림이 동일하다는 점을 이용해
같은 시드의 실현(realisation) 전체를 비교합니다. Python에서 seed를 주면 MATLAB과 같은 DFN이 나옵니다.

### 3D DFN Generation의 두 가지 모드

| | 툴박스 모드 | 암반(rock-mass) 모드 |
|---|---|---|
| 출처 | `threeddfngui.m` (툴박스 원본) | DFN 프로젝트 `dfn generator v1/python/generate_dfn.py` (`tests/oracle/`에 원본 사본) |
| 절리군 | 1개 | 여러 개(표에서 편집, Forsmark/Laxemar 프리셋, JSON config 불러오기) |
| 개수 | 직접 입력 또는 멱법칙 밀도 | 절리군별 P32 × 상자 부피 / 평균 원판 면적 (r0 → rmin 재척도) |
| 크기 | 지름: 음지수 / 멱법칙 | 반지름: 멱법칙(kr, 생존지수) / 지수 / 로그정규 / 균일, rmin~rmax 절단 |
| 방향 | dip/dip direction + Fisher K | 극점 trend/plunge + Fisher κ |
| 좌표계 | x, y, z(아래 방향 depth) | x = 동, y = 북, z = 위 |
| 중심 | 상자 안 균일 | 상자 안 균일 + 원판 위 면적균일 점으로 이동(원판 표면이 공간에 균일) |
| 출력 | 검증 히스토그램, 샘플링 창 트레이스, 시추공 교차, 텍스트 저장 | 크롭박스 클리핑 3D, 터널 폴리곤 교차, X/Y/Z=0 트레이스 맵(P21), 크기분포·스테레오넷 검증, HDF5(DFN 프로젝트 형식)/CSV |

이식 중 확인된 MATLAB 원본의 문제와 Python에서의 처리:

- Radial 수압파쇄 모델은 누출계수 C = 0 이면 원본도 계산이 깨집니다. Python은 명시적으로 오류를 냅니다.
- Temperature Prediction의 단일 균열(N = 1) 암반 온도장은 원본이 Gringarten에서 전부 NaN,
  Radial에서 −5×10⁶ °C 같은 값을 냅니다(무한 간격을 Talbot 역변환에 넣기 때문). Python은
  해당 극한의 닫힌 해(erfc)를 사용합니다.
- Talbot 역변환(M = 64)은 항 크기가 e²⁵ 수준이라 라이브러리마다 1e‑6 정도 차이가 납니다.
  표시 정밀도(0.01 °C)보다 훨씬 작습니다.
- Strength Anisotropy의 각도 β는 σ₁과 약면 **법선** 사이 각입니다(Jaeger 식의 β와 여각 관계).
  원본은 축 라벨이 'Deg'만 있어 Python 화면에 명시했습니다. 원본은 c = 0, σ₃ = 0 일 때
  β = 90° − φ 에서 0/0 = NaN 이 되지만 Python은 극한값 0을 씁니다.
- 3D Mohr Circle은 원본과 같은 작도법(보조원 교점)으로 (σn, τn)을 구하며, 방향코사인 해석해와
  1e‑9 이내로 일치함을 테스트로 확인했습니다. 원본의 `vars.mat` 파일 교환은 없어졌습니다.
- Borehole Stability(Ong 1994 해석해)는 원본의 다음 특성을 그대로 재현합니다(README와 코드 주석에 명시):
  원거리 전단응력을 변환행렬에 (xz, yz, xy) 순서로 넣는 점(행렬은 yz, xz, xy 순서를 기대),
  변위 퍼텐셜에서 (Tyz − i·Sz)를 쓰는 점, 중근 분리를 위해 μ에 1.0001~1.0003을 곱하는 점
  (등방성 Kirsch 해와 3e‑4 상대 차이의 원인). "3D Elastic Modulus Matrix" 입력은 원본이 강성행렬을
  컴플라이언스로 그대로 사용하지만 Python은 역행렬을 취해 올바르게 처리합니다.
- FEM은 원본이 7,320×7,320 밀집행렬을 `pinv`로 풀고 5000×5000 격자로 보간하던 것을, 희소행렬 +
  강체운동 구속(최소노름 해와 동일)과 400×400 보간으로 바꿔 기본 격자(60×56)에서 1초 안에 끝납니다.
  요소 중심 응력은 MATLAB과 1e‑6 이내로 일치합니다.
- Breakout 기하(Rbbo, θbbo) 계산은 원본이 각도 인덱스가 배열 밖으로 나가면 오류가 나지만 Python은
  둘레 방향으로 순환 처리합니다.
- Hydroshearing: 원본 `stereonetGroup.m`은 `zeros(no)`로 91×91 행렬을 만들어 첫 열만 쓰고, 확률 곡선도
  91개 선을 겹쳐 그립니다(나머지는 0). Python은 91개 벡터만 씁니다. 원본의 "bbl"은 42 gal 석유 배럴이
  아니라 31.5 gal 액체 배럴(0.11924 m³)이며 그대로 두었습니다.
- Stereographic Projection: 원본 `dist3.m`은 `for i=1:size(data)`(비스칼라 콜론 피연산자) 때문에 최신
  MATLAB(R2023 이후)에서 실행되지 않습니다. Python은 일반 유클리드 거리로 대체했습니다. 상반구 도법에서
  클릭한 극점의 dip direction이 180° 어긋나던 문제(투영은 좌표를 반전하지만 역변환은 하지 않음)를
  수정했고, 대원(great circle)은 원본이 등면적 도법에서도 등각 반지름을 쓰던 것을 도법에 맞게 그립니다.
  FCM 군집은 원본처럼 난수 초기화이므로 실행마다 결과가 달라질 수 있습니다(seed 인자로 고정 가능).
- 3D DFN: 원본의 'Square' 분기는 3×3 행렬과 1×3 행벡터를 곱해 실행 자체가 안 되고, 꼭짓점 z 오프셋이
  균열 크기와 무관하게 고정돼 있습니다. Python은 원판과 같은 방식으로 한 변이 l인 정사각형을 만듭니다.
  로그정규 개구폭은 원본이 평균 대신 균열 길이 l을 쓰는 오타가 있어 평균으로 고쳤습니다. 원본의
  'Normal'/'Log normal' 개구폭은 Statistics Toolbox가 없으면 실행되지 않습니다. 시추공 교차 판정은 원본처럼
  심도 범위를 검사하지 않습니다.
- Units: `Units.m`의 lbf/ft² 입력 환산계수 4.788은 10배 작은 값(1 lbf/ft² = 47.88 Pa, 출력 계수 0.02089는
  정상)이라 Python은 47.88을 씁니다. 단위 이름과 순서는 MATLAB 팝업 메뉴와 같아 `HFsim_units/*.txt`
  단위 세트 파일을 그대로 읽고 씁니다.

### 계산 성능

2026-09-08 프로파일링 뒤 아래 항목을 벡터화했습니다. 결과값은 MATLAB·원본 스크립트 대조 테스트로
그대로임을 확인했습니다(Python 3.13, numpy 2.4, 노트북 기준).

| 항목 | 이전 | 이후 | 방법 |
|---|---|---|---|
| 암반 DFN 크롭박스 클리핑 (균열 80만 개, half=15 m, 폴리곤 24,108개) | 22.0 s | 0.41 s | 패딩 배열에 Sutherland–Hodgman 6단계를 배치로 적용, 면적 합 벡터화, 박스 안에 완전히 든 원판은 통과 |
| 2D 트레이스 맵 3장 | 3 × 0.54 s | 0.08 s | 크롭박스 클리핑 결과를 캐시해 3D 뷰와 트레이스 맵이 공유 |
| 3D 뷰 렌더링 (회전 시 매 프레임) | 0.94 s | 0.17 s | 면적 큰 폴리곤 5,000개까지 표시(`Max polygons shown`), 2,000개 초과 시 테두리 생략 |
| 스테레오넷 극점 밀도 (극점 20,000개) | 4.05 s | 0.39 s | (격자 × 2n × 3) 거리 배열 대신 내적 조건 g·v ≥ cos θ의 행렬곱 (임시 메모리 GB → MB) |
| 보어홀 All orientation + 열응력 | 1.80 s | 0.06 s | (delta, phi, theta) 전체를 한 번에 계산; 각도별 6×6 solve 8만 회 → 역행렬 201회 |
| 보어홀 FEM 60×64 | 1.28 s | 0.33 s | 요소 강성·응력 복원 배치 계산, Delaunay 삼각분할 1회 공유 |
| 보어홀 해석해 181×1441 | 0.28 s | 0.24 s | 제곱근 분기 추적(stsign/detsign) 순차 루프를 누적합으로 대체 |

GUI에서 암반 DFN 생성·클리핑과 보어홀 계산은 `geomech/gui/worker.py`의 QThreadPool 작업으로 실행되어
계산 중에도 창이 멈추지 않습니다(관련 버튼 비활성화, 대기 커서, 오류는 메시지 상자).
`tools/screenshot_gui.py`처럼 동기 실행이 필요하면 `worker.SYNC = True`로 둡니다.

같이 고친 Python 쪽 버그: Hydrofracturing에서 누출계수 C > 0이고 spurt loss Sp = 0이면 근 탐색 구간이
L = 0에서 시작해 폭 0으로 0×∞(NaN)가 되어 실패하던 문제를 구간 하한 1e-12 m로 고쳤습니다.

## 폴더 구조

```
.
├── geomech/                  # Python 패키지
│   ├── core/                 #   계산 모듈 (SI 단위, GUI 의존성 없음)
│   └── gui/                  #   PySide6 화면 (app.py = 런처)
├── tests/                    # pytest + MATLAB 기준값(tests/reference/*.json)
├── tools/                    # MATLAB 기준값 생성 스크립트, GUI 스크린샷 스크립트
├── src/                      # MATLAB 툴박스 소스 (Application Compiler 프로젝트가 참조하는 파일 전체)
│   ├── Simulator_int.mlapp   # 메인 런처
│   ├── Geomechanics Toolbox.prj   # 앱 패키징 프로젝트 (${PROJECT_ROOT} 상대경로)
│   ├── *.m / *.fig / *.mlapp / *.jpg
│   ├── DFNs/, HFsim_projects/, HFsim_units/, reservTemp_projects/, stereo_exmapledata/   # 예제 데이터
│   └── legacy/               # 이전 버전·실험용 스크립트 (BSA_181116, HSsim_2, TherCal_2, BSA_App_v1~4 등)
├── docs/manual/              # 사용자 매뉴얼 (PDF)
├── Geomechanics_Toolbox/     # 2025-04 표준 실행 파일 빌드 (exe·설치파일은 git 제외)
├── 240905/                   # 2024-09 빌드 (exe 제외)
└── 새 폴더/                  # 2024-09 시점 mlapp 스냅샷
```

## 개발 환경

- MATLAB R2024a 이상 (App Designer, GUIDE 호환 `.fig` 사용)
- 배포: MATLAB Compiler → MATLAB Runtime R2024a 필요
- 일부 `.m` 파일의 한글 주석은 CP949(EUC-KR) 인코딩입니다. MATLAB에서는 정상 표시되지만
  git diff/GitHub 웹에서는 깨져 보일 수 있습니다. 새로 작성하는 파일은 UTF-8을 권장합니다.

## 실행 방법

```matlab
cd src
addpath(genpath(pwd))
Simulator_int        % 메인 런처 실행
```

## 빌드(배포 파일 생성)

1. MATLAB에서 `src/Geomechanics Toolbox.prj` 를 엽니다 (Application Compiler).
2. 메인 파일이 `Simulator_int.mlapp` 인지 확인하고 **Package** 를 누릅니다.
3. 산출물(`for_redistribution*`, `for_testing`)은 `.gitignore` 로 git 추적에서 제외됩니다.
   배포 파일은 GitHub Releases 에 첨부하는 방식을 권장합니다.

### Python 실행 파일 (PyInstaller)

MATLAB Runtime 없이 실행되는 단일 exe입니다.

```bash
pip install pyinstaller
pyinstaller --noconfirm GeomechanicsToolbox.spec      # -> dist/GeomechanicsToolbox.exe (단일 파일, 콘솔 창 없음)
dist/GeomechanicsToolbox.exe --smoke-test             # 모든 모듈 창을 열어 기본 계산을 실행하고 종료 (종료코드 0 = 정상)
```

- 빌드 설정은 `GeomechanicsToolbox.spec`, 진입 스크립트는 `tools/launch.py`입니다. GUI는 파일 대화상자로만
  데이터를 읽으므로 데이터 파일은 넣지 않습니다.
- 단일 파일 exe는 실행할 때마다 임시 폴더에 압축을 풀기 때문에 첫 창이 뜨기까지 몇 초 걸립니다.
- 서명되지 않은 PyInstaller 실행 파일은 Windows SmartScreen이나 백신이 경고할 수 있습니다.
- `--smoke-test`는 현재 폴더의 `geomech_smoke.log`에 결과를 남깁니다. 같은 절차가
  `python tools/screenshot_gui.py out_dir`로 스크린샷을 저장합니다(`geomech/gui/smoke.py`).
- `dist/`, `build/`, `*.exe`는 git에서 제외됩니다. 배포는 GitHub Releases에 첨부하는 방식을 권합니다.

## 버전 이력

- v1.0 (2017) — 초기 GUIDE 기반 툴박스
- v1.2 (2021-10-12) — 매뉴얼 배포판 (`docs/manual/`)
- 2024-08 개정 — App Designer 런처(`Simulator_int`), 시추공 안정성 모듈 개편 (이창무, 성하경)
- 2025-04 — 표준 실행 파일 재빌드 (MATLAB R2024a)
