FROM rust:1.71

# Use the [Option] comment to specify true/false arguments that should appear in VS Code UX
#
# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"
# Reference: https://github.com/microsoft/vscode-dev-containers/tree/main/container-templates/docker-compose
# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
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
