FROM alpine/helm:3.11.1

# renovate: datasource=github-releases depName=mozilla/sops
ARG SOPS_VERSION=v3.7.3
# renovate: datasource=github-releases depName=jkroepke/helm-secrets
ARG HELM_SECRETS_VERSION=v4.4.0

RUN \
    curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux && \
    chmod +x /usr/local/bin/sops && \
    apk add jq yq && \
    mkdir -p /home/argocd/cmp-server/config && \
    mkdir -p /home/argocd/.local/share/helm/plugins && \
    chown -R 999 /home/argocd

# Add argocd plugin config
ADD plugin.yaml /home/argocd/cmp-server/config

# Switch back to non-root user
USER 999
ENV HOME=/home/argocd
WORKDIR /home/argocd

# Install Helm-Secrets plugin
ENV HELM_PLUGINS="/home/argocd/.local/share/helm/plugins/"
RUN helm plugin install https://github.com/jkroepke/helm-secrets --version ${HELM_SECRETS_VERSION}

ENTRYPOINT [ "/var/run/argocd/argocd-cmp-server" ]