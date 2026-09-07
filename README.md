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

## Python 포팅 (진행 중)

MATLAB Runtime 없이 실행되는 Python(PySide6 + matplotlib) 버전으로 옮기는 작업을 진행 중입니다.
계산 코드(`geomech/core/`)와 화면 코드(`geomech/gui/`)를 분리하고, 모듈마다 MATLAB 원본 출력값과
대조하는 회귀 테스트(`tests/`)를 둡니다.

| 모듈 | 계산 코드 | GUI | MATLAB 대조 테스트 |
|---|---|---|---|
| Hydrofracturing Estimation | `geomech/core/hydrofrac.py` | `geomech/gui/hydrofrac_panel.py` | `tests/test_hydrofrac.py` (5 케이스, 상대오차 1e-8) |
| Temperature Prediction | `geomech/core/thermal.py`, `thermal_project.py` | `geomech/gui/thermal_panel.py` | `tests/test_thermal.py` (5 케이스; Bodvarsson 1e-8, Talbot 역변환 모델 2e-3 °C) |
| 3D Mohr Circle | `geomech/core/mohr.py` | `geomech/gui/mohr_panel.py` | `tests/test_mohr_aniso.py` (6 케이스, 1e-10; 방향코사인 해석해와도 일치) |
| Strength Anisotropy | `geomech/core/anisotropy.py` | `geomech/gui/anisotropy_panel.py` | `tests/test_mohr_aniso.py` (4 케이스, 1e-10; Jaeger 식과 일치) |
| Borehole Stability | 예정 | | |
| Stereographic Projection | 예정 | | |
| Units | `geomech/core/units.py` (일부) | | |
| 3D DFN Generation | 예정 | | |

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
```

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

## 버전 이력

- v1.0 (2017) — 초기 GUIDE 기반 툴박스
- v1.2 (2021-10-12) — 매뉴얼 배포판 (`docs/manual/`)
- 2024-08 개정 — App Designer 런처(`Simulator_int`), 시추공 안정성 모듈 개편 (이창무, 성하경)
- 2025-04 — 표준 실행 파일 재빌드 (MATLAB R2024a)
