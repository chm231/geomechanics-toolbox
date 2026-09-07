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

## 폴더 구조

```
.
├── src/                      # 툴박스 소스 (Application Compiler 프로젝트가 참조하는 파일 전체)
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
