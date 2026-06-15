FROM node:24-bookworm

ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl ca-certificates bash vim git less netcat-openbsd gosu tzdata sudo && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Claude Code 전역 설치 (모든 유저에서 실행 가능)
RUN npm install -g @anthropic-ai/claude-code

# node:24 이미지의 기본 node 유저(UID 1000) 제거 후 ubuntu 유저 생성
RUN if id -u node >/dev/null 2>&1; then userdel -r node 2>/dev/null || true; fi && \
    if getent group ubuntu >/dev/null 2>&1; then \
        groupmod -g ${USER_GID} ubuntu; \
    else \
        groupadd -g ${USER_GID} ubuntu; \
    fi && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && \
    chmod 0440 /etc/sudoers.d/ubuntu

# 소스 마운트 지점
RUN mkdir -p /home/users/df && chown -R ubuntu:ubuntu /home/users

RUN echo "alias cc='claude --dangerously-skip-permissions'" >> /home/ubuntu/.bashrc && \
    chown -R ubuntu:ubuntu /home/ubuntu

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 기본 유저 ubuntu — docker exec 도 entrypoint 우회하므로 이미지 USER 로 고정
USER ubuntu
WORKDIR /home/users/df

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
