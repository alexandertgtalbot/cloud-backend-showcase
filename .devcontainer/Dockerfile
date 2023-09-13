FROM rust:1.71

ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="false"
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

COPY library-scripts/*.sh library-scripts/*.env /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && apt-get -y install --no-install-recommends build-essential \
    apt-transport-https \
    curl \
    ca-certificates \
    apt-utils \
    dialog \
    git \
    vim \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

WORKDIR /app
ARG TF_VERSION="1.5.7"
ARG TFSWITCH_VERSION="0.13.1308"
RUN curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh -o ./install.sh && \
    chmod 755 ./install.sh && \
    ./install.sh $TFSWITCH_VERSION && \
    rm -f ./install.sh
RUN tfswitch ${TF_VERSION}

ARG TG_VERSION="0.50.14"
ARG TGSWITCH_VERSION="0.6.0"
RUN curl -L https://raw.githubusercontent.com/warrensbox/tgswitch/release/install.sh -o ./install.sh && \
    chmod 755 ./install.sh && \
    ./install.sh $TGSWITCH_VERSION && \
    rm -f ./install.sh
RUN tgswitch ${TG_VERSION}

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    rm -rf ./aws awscliv2.zip

RUN curl -L https://dl.k8s.io/release/v1.28.1/bin/linux/amd64/kubectl -o ./kubectl && \
    mv ./kubectl /usr/local/bin && \
    chmod 755 /usr/local/bin/kubectl

RUN OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    KREW="krew-${OS}_${ARCH}" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
    tar zxvf "${KREW}.tar.gz" && \
    ./"${KREW}" install krew

ENV PATH="${KREW_ROOT:-$HOME/.krew}/bin:/usr/local/bin/kubectl:$PATH"
