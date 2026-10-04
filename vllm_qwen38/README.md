# vllm_qwen38

**vLLM v0.30.0** 으로 **Qwen3.8-27B** 를 OpenAI 호환 API 로 서빙하는 단일 컨테이너 구성입니다.
KV cache 는 vLLM upstream 내장 **TurboQuant**(`--kv-cache-dtype turboquant_*`)로 압축합니다.
호스트 `~/df` 폴더를 컨테이너 `/df` 로 공유합니다.

## 요구사항
- Docker / Docker Compose + NVIDIA Container Toolkit
- NVIDIA GPU 16GB (fg1, Ada sm_89) · 호스트 RAM 24GB 이상
- NVIDIA 드라이버: 525(CUDA 12.0)에서 동작 확인 — 아래 "구형 드라이버 우회" 참조

## 구형 드라이버 우회 (fg1: 525.105, CUDA 12.0)
공식 `vllm/vllm-openai:v0.30.0-cu129` 이미지는 내부 torch 가 **cu130** 이라 525 드라이버에서 실행 불가.
[Dockerfile](Dockerfile) 로 재빌드하여 해결:

| 문제                                   | 대응                                                   | 위치            |
| -------------------------------------- | ------------------------------------------------------ | --------------- |
| torch cu130 → CUDA 13 실행 불가        | torch 2.13.0 cu129 + vLLM 0.30.0+cu129 wheel 로 교체   | Dockerfile      |
| `cuda>=12.9` 요구 검사로 기동 거부     | `NVIDIA_DISABLE_REQUIRE=1`                             | compose env     |
| compat libcuda 로드 시 error 803       | `/usr/local/cuda*/compat` 제거                         | Dockerfile      |
| `named symbol not found`               | `CUDA_MODULE_LOADING=LAZY`                             | compose env     |
| FlashInfer sampler `kernel image is invalid` | `VLLM_USE_FLASHINFER_SAMPLER=0`                  | compose env     |

> 드라이버를 575+ 로 올리면 env 우회는 불필요 (Dockerfile 재빌드는 무해하게 유지 가능)

## 양자화 구성 (기본: GPU 단독)
| 대상      | 방식                                                  | 설정              |
| --------- | ----------------------------------------------------- | ----------------- |
| 가중치    | GGUF 3bit (`unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S`, 12GB) | `VLLM_MODEL`      |
| GGUF 로더 | `vllm-gguf-plugin` (main 커밋 고정 — Qwen3.5 어댑터)  | Dockerfile        |
| KV cache  | TurboQuant (WHT 회전 + Lloyd-Max 양자화)              | `KV_CACHE_DTYPE`  |
| vision    | 미로드 (`--language-model-only`)                      | `VLLM_EXTRA_ARGS` |

- 대안: AWQ INT4 + CPU offload 9GB — `cp .env.awq.sample .env` (0.65 tok/s, 품질↑)

TurboQuant 프리셋 (`KV_CACHE_DTYPE`):

| 프리셋                | K      | V     | 비고          |
| --------------------- | ------ | ----- | ------------- |
| `turboquant_k8v4`     | FP8    | 4bit  | 품질 우선     |
| `turboquant_4bit_nc`  | 4bit   | 4bit  | **기본값**    |
| `turboquant_k3v4_nc`  | 3bit   | 4bit  |               |
| `turboquant_3bit_nc`  | 3bit   | 3bit  | 최대 압축     |

> ⚠️ TurboQuant 는 **KV cache 만** 압축합니다. Qwen3.8 은 hybrid(linear + full attention) 구조라 KV cache 비중이
> 원래 작으므로, 16GB 의 주 병목은 가중치(INT4 약 15GB+)입니다. TurboQuant 의 이득은 주로 **긴 context 확보**입니다.
> hybrid 모델에서는 full-attention 경계 레이어가 자동으로 압축 제외됩니다.

## 빌드 및 실행
```bash
cp .env.sample .env   # 모델·KV 프리셋·메모리 값 수정 가능
./start.sh            # 이미지 빌드(최초 ~15분) + 기동. 첫 기동 시 모델(~20GB) 다운로드
docker logs -f vllm-qwen38
```

## 실측 (fg1, 2026-10-04)
| 항목                  | GGUF UD-IQ3_S (기본)            | AWQ INT4 + offload 9GB           |
| --------------------- | ------------------------------- | -------------------------------- |
| GPU 가중치            | 11.86 GiB (offload 0)           | 9.15 GiB (+ CPU 9GB)             |
| KV cache (TurboQuant) | **63,608 tokens** (32K × 1.94)  | 117,579 tokens (32K × 3.59)      |
| 기동 시간             | 약 7분                          | 약 15~20분                       |
| 생성 속도             | **16.3 tok/s**                  | 0.65 tok/s (PCIe 병목)           |

- AWQ 는 offload 6GB 이하에서 KV 가용 음수로 기동 실패 — GPU 단독은 3bit GGUF 만 가능

OOM 발생 시 조정 순서: `MAX_MODEL_LEN` 축소 → `KV_CACHE_DTYPE=turboquant_3bit_nc` → `CPU_OFFLOAD_GB` 증가(속도 저하)

## 공유 볼륨
| 호스트                   | 컨테이너                    | 용도               |
| ------------------------ | --------------------------- | ------------------ |
| `~/df` (`DF_DIR`)        | `/df`                       | 공유 작업 폴더     |
| `~/.cache/huggingface`   | `/root/.cache/huggingface`  | 모델 캐시 (보존)   |
| `~/.cache/vllm`          | `/root/.cache/vllm`         | torch.compile 캐시 |

## 포트 정보
| 컨테이너    | 포트        | 용도                     |
| ----------- | ----------- | ------------------------ |
| vllm-qwen38 | 8000 → 8000 | OpenAI 호환 API (`/v1`)  |

## 테스트
```bash
./test.sh                  # health → /v1/models → chat completion → /df 마운트 확인
./chat.sh "질문"           # 스트리밍 채팅 + tok/s 표시 (THINK=1: 사고 과정, MAX_TOKENS=N)
BASE_URL=http://100.120.197.22:8000 ./chat.sh "질문"   # 원격(Tailscale)
```
- 컨테이너 안에서 쓰려면 `cp chat.sh ~/df/` → 컨테이너 `/df/chat.sh`
- reasoning parser `qwen3` → 사고 과정은 `reasoning_content` 로 분리
- tool call: `--enable-auto-tool-choice --tool-call-parser qwen3_coder`

## 정리
```bash
./clear.sh   # 컨테이너만 제거 (모델 캐시·df 보존)
```
