FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm/onbuild
ENV WAIT_FOR_READY_TIMEOUT=900
ENV TESTER_TIMEOUT=900