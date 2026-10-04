# vllm_qwen38 — vLLM v0.30.0 (TurboQuant 내장) 을 CUDA 12.9 빌드로 재구성
#
# 배경: fg1 드라이버 525(CUDA 12.0)는 CUDA 13 을 실행 불가.
#   공식 v0.30.0-cu129 이미지조차 내부 torch 가 cu130 이라 기동 실패
#   → torch·vLLM 을 cu129 wheel 로 교체 + GeForce 미지원 compat libcuda 제거
#   (CUDA 12.x minor version compatibility 로 525 드라이버에서 실행)
ARG BASE_IMAGE=vllm/vllm-openai:v0.30.0-cu129
FROM ${BASE_IMAGE}

ARG VLLM_VERSION=0.30.0
ARG TORCH_VERSION=2.13.0
ARG TORCHVISION_VERSION=0.28.0
ARG TORCHAUDIO_VERSION=2.11.0
ARG TORCH_INDEX=https://download.pytorch.org/whl/cu129

# 1) torch cu129 빌드로 교체
RUN pip install --no-cache-dir --break-system-packages --force-reinstall --no-deps \
      torch==${TORCH_VERSION} torchvision==${TORCHVISION_VERSION} torchaudio==${TORCHAUDIO_VERSION} \
      --index-url ${TORCH_INDEX} \
 && pip install --no-cache-dir --break-system-packages \
      torch==${TORCH_VERSION} --index-url ${TORCH_INDEX}

# 2) vLLM cu129 wheel 로 교체 (의존성은 베이스 이미지 것 유지)
RUN pip install --no-cache-dir --break-system-packages --force-reinstall --no-deps \
      https://github.com/vllm-project/vllm/releases/download/v${VLLM_VERSION}/vllm-${VLLM_VERSION}+cu129-cp38-abi3-manylinux_2_28_x86_64.whl

# 3) forward-compat libcuda 제거 → 호스트 드라이버 libcuda 사용 (GeForce 에서 error 803 방지)
RUN rm -rf /usr/local/cuda*/compat && ldconfig

# 4) vLLM GGUF 플러그인 (v0.30 부터 GGUF 는 out-of-tree) — 3bit GGUF 로 GPU 단독 적재용
#    CUDA 확장을 위 cu129 torch 기준으로 빌드. 대상 아키텍처는 fg1(Ada) 만
#    v0.0.5 릴리스에는 Qwen3.5 계열(qwen3_5) 어댑터가 없어 main 커밋으로 고정
ARG GGUF_PLUGIN_REF=e2b8ad532b8b5ea175100202c30430c1d2b5e6a8
ARG GGUF_CUDA_ARCH=8.9
RUN pip install --no-cache-dir --break-system-packages "gguf>=0.17.0" \
 && curl -sL https://github.com/vllm-project/vllm-gguf-plugin/archive/${GGUF_PLUGIN_REF}.tar.gz | tar xz -C /tmp \
 && cd /tmp/vllm-gguf-plugin-${GGUF_PLUGIN_REF} \
 && TORCH_CUDA_ARCH_LIST=${GGUF_CUDA_ARCH} MAX_JOBS=4 \
    pip install --no-cache-dir --break-system-packages --no-build-isolation --no-deps . \
 && rm -rf /tmp/vllm-gguf-plugin-${GGUF_PLUGIN_REF}

# 빌드 결과 점검 (GPU 없이 가능한 범위)
RUN python3 -c "import torch, vllm, vllm_gguf_plugin; print('torch', torch.__version__, 'cuda', torch.version.cuda, 'vllm', vllm.__version__); assert torch.version.cuda.startswith('12.')"
