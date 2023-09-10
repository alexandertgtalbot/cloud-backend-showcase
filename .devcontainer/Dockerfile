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
