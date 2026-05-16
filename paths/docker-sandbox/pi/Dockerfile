FROM docker/sandbox-templates:shell-docker
USER root
RUN apt-get update && apt-get install -y nodejs npm fd-find && \
    npm install -g @earendil-works/pi-coding-agent && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
USER agent
