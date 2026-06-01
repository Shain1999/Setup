# ==========================================
# Devshell image — VS Code Dev Containers entry point.
# Editor/build/test shell only; no runtime services.
# ==========================================
ARG BASE_IMAGE=ubuntu:22.04
ARG UV_IMAGE=ghcr.io/astral-sh/uv:0.9.26
FROM ${UV_IMAGE} AS uv
FROM ${BASE_IMAGE} AS base
COPY --from=uv /uv /uvx /bin/

WORKDIR /app

# ==========================================
# DEVELOPMENT (ZSH, mise, uv, claude-code)
# ==========================================
FROM base AS development

ENV TZ=Asia/Jerusalem DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo git zsh curl wget ca-certificates locales tzdata make nodejs npm && \
    ln -fs /usr/share/zoneinfo/Asia/Jerusalem /etc/localtime && \
    echo "Asia/Jerusalem" > /etc/timezone && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ARG USER=vscode
RUN useradd -m -s /usr/bin/zsh ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER} && \
    chown -R ${USER}:${USER} /app

RUN curl -fsSL https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh

USER ${USER}
ARG HOME=/home/${USER}
ARG ZSH=${HOME}/.oh-my-zsh
ARG ZSH_CUSTOM=${ZSH}/custom
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
ENV MISE_DATA_DIR=/home/vscode/.local/share/mise
ENV PATH="/home/vscode/.local/share/mise/shims:${PATH}"

RUN mkdir -p ${HOME}/.local/share/uv ${HOME}/.local/state ${HOME}/commandhistory ${HOME}/.cache/uv

# oh-my-zsh + spaceship prompt + autosuggestions/syntax-highlighting
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    mkdir -p ${ZSH_CUSTOM}/plugins && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git ${ZSH_CUSTOM}/themes/spaceship-prompt --depth=1 && \
    ln -s ${ZSH_CUSTOM}/themes/spaceship-prompt/spaceship.zsh-theme ${ZSH_CUSTOM}/themes/spaceship.zsh-theme && \
    sed -i.bak 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc && \
    sed -i 's|ZSH_THEME="robbyrussell"|ZSH_THEME="spaceship"|g' ~/.zshrc && \
    echo '\nexport TERM=xterm-256color\nZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"\nZSH_AUTOSUGGEST_STRATEGY=(history completion)' >> ~/.zshrc && \
    echo '\neval "$(uv generate-shell-completion zsh)"\neval "$(uvx --generate-shell-completion zsh)"' >> ~/.zshrc && \
    echo '\neval "$(mise activate zsh)"' >> ~/.zshrc && \
    echo '\n# Persist ZSH History\nexport HISTFILE=/home/vscode/commandhistory/.zsh_history\nexport HISTSIZE=10000\nexport SAVEHIST=10000' >> ~/.zshrc

# Install the pinned toolchain (python + uv) from .mise.toml, plus claude-code.
COPY --chown=${USER}:${USER} .mise.toml ./
RUN mise trust .mise.toml && mise install && npm install -g @anthropic-ai/claude-code

ENV PATH="/home/vscode/.local/bin:/app/.venv/bin:$PATH"
