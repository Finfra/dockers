FROM debian:bookworm-slim

ARG USER_UID=1000
ARG USER_GID=1000

# 범용 Claude Code 이미지 — 특정 백엔드에 하드코딩하지 않음.
#   런타임 환경변수로 백엔드 지정:
#     ANTHROPIC_BASE_URL   : LLM 백엔드 (예: http://ollama:11434, http://lms:1234)
#                            미지정 시 Anthropic 공식 API 사용 (claude 로그인 필요)
#     ANTHROPIC_AUTH_TOKEN : 백엔드 인증 토큰 (로컬 백엔드는 임의 문자열)
#     ANTHROPIC_MODEL      : 사용할 모델명
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# Node.js 22 + tzdata(TZ 적용) + curl(헬스체크)
RUN apt-get update && \
    apt-get install -y curl git ca-certificates tzdata && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Claude Code 설치
RUN npm install -g @anthropic-ai/claude-code

# ubuntu 유저 생성 (UID/GID 가변, 기본 1000 — 호스트 사용자와 일치 권장)
RUN groupadd -g ${USER_GID} ubuntu && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ubuntu

RUN mkdir -p /home/ubuntu/.claude

# alias 설정 (시스템 전체)
RUN echo "alias cc='claude --dangerously-skip-permissions'" >> /etc/bash.bashrc

RUN chown -R ubuntu:ubuntu /home/ubuntu

# 백엔드 대기 + settings.json 생성 스크립트
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER ubuntu
WORKDIR /home/ubuntu

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
