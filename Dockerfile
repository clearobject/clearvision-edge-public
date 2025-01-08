FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm/onbuild
LABEL com.googleapis.cloudmarketplace.product.service.name="com.clearobject.clearvision"
ENV WAIT_FOR_READY_TIMEOUT=900
ENV TESTER_TIMEOUT=900
RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-server
