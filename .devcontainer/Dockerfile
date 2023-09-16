FROM rust:1.71

ARG INSTALL_ZSH="true"
ARG TF_VERSION="1.5.7"
ARG TFSWITCH_VERSION="0.13.1308"
ARG TG_VERSION="0.50.14"
ARG TGSWITCH_VERSION="0.6.0"
ARG UPGRADE_PACKAGES="false"
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

COPY library-scripts/*.sh library-scripts/*.env /tmp/library-scripts/

RUN rm -rf /var/lib/apt/lists/partial && \
    apt-get update -o Acquire::CompressionTypes::Order::=gz && \
    apt-get upgrade -y && \
    export DEBIAN_FRONTEND=noninteractive \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && apt-get -y install --no-install-recommends build-essential \
    apt-transport-https \
    apt-utils \
    curl \
    ca-certificates \
    dialog \
    git \
    gnupg \
    lsb-release \
    vim

RUN mkdir -p /etc/apt/keyrings

# Azure: `az` CLI.
RUN curl -sLS https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/keyrings/microsoft.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/microsoft.gpg
RUN AZ_REPO=$(lsb_release -cs) && echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    tee /etc/apt/sources.list.d/azure-cli.list

# GCP: `gcloud` CLI.
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - 
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

RUN apt-get update -o Acquire::CompressionTypes::Order::=g && \
    apt-get -y install \
    azure-cli \
    google-cloud-cli

RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

WORKDIR /app

RUN curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh -o ./install.sh && \
    chmod 755 ./install.sh && \
    ./install.sh $TFSWITCH_VERSION && \
    rm -f ./install.sh
RUN tfswitch ${TF_VERSION}

RUN curl -L https://raw.githubusercontent.com/warrensbox/tgswitch/release/install.sh -o ./install.sh && \
    chmod 755 ./install.sh && \
    ./install.sh $TGSWITCH_VERSION && \
    rm -f ./install.sh
RUN tgswitch ${TG_VERSION}

RUN curl -L https://dl.k8s.io/release/v1.28.1/bin/linux/amd64/kubectl -o ./kubectl && \
    mv ./kubectl /usr/local/bin && \
    chmod 755 /usr/local/bin/kubectl

RUN OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    KREW="krew-${OS}_${ARCH}" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
    tar zxvf "${KREW}.tar.gz" && \
    ./"${KREW}" install krew

# AWS: `aws` CLI.
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf ./aws awscliv2.zip

ENV PATH="${KREW_ROOT:-$HOME/.krew}/bin:/usr/local/bin/kubectl:$PATH"