ARG BASE_IMAGE=us-east4-docker.pkg.dev/clearvision-edge-dev/docker-cve-dev/i7e-app:4.0.3
FROM ${BASE_IMAGE}

ENV GST_PLUGIN_SYSTEM_PATH=/usr/lib/x86_64-linux-gnu/gstreamer-1.0/:/opt/generic
ENV GST_PLUGIN_PATH=/opt/vmbsrc:/usr/local/lib/x86_64-linux-gnu/gstreamer-1.0

ADD src/plugins/ /opt/generic/python/
ADD models/ /opt/generic/models/
ADD config/ /opt/generic/config/
ADD images/ /opt/generic/images/
