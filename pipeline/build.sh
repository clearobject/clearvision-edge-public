#!/usr/bin/env bash
set -e

####### Variables ###########

CLOUD_PROVIDER="GCP" # (e.g. GCP or Azure)  
ONNX_MODEL_URI="" # (e.g. gs://knauf-model-weights/illsf/illsf-230906-256_b16_enb3-float32.onnx)       
ENGINE_MODEL_URI="" # (e.g. gs://knauf-model-weights/illsf/illsf-230906-256_b16_enb3-float32.engine)

# DOCKER BUILD VARIABLES
# PUSH_TAG = CONTAINER_URI/PIPELINE_NAME  (e.g. europe-docker.pkg.dev/knauf-vision-dev/knauf-docker/knauf-infer/illsf-pipeline)
# CONTAINER_URI="europe-docker.pkg.dev/knauf-vision-dev/knauf-docker/knauf-infer" # (e.g. europe-docker.pkg.dev/knauf-vision-dev/knauf-docker/knauf-infer)  
CONTAINER_URI="us-east4-docker.pkg.dev/clearvision-edge-prod/docker-cve-prod" # (e.g. europe-docker.pkg.dev/knauf-vision-dev/knauf-docker/knauf-infer)  

PIPELINE_NAME="generic-pipeline" # (e.g. illsf-pipeline)    

############################        

[ -z "$ONNX_MODEL_URI" ] && ONNX_MODEL_URI=""
[ -z "$ENGINE_MODEL_URI" ] && ENGINE_MODEL_URI=""

validate_gcp() {
    if [[ $1 != gs://* ]]; then
        echo "Invalid GCP . Should start with gs://"
        exit 1
    fi
}
validate_azure() {
    ## Add this once have azure access
    echo "Azure Validation not available rkjfhekgjherg"
}

validate_onnx() {
    if [[ $1 != *.onnx ]]; then
        echo "Invalid ONNX model. Should end with .onnx"
        exit 1
    fi
}

validate_engine() {
    if [[ $1 != *.engine ]]; then
        echo "Invalid engine model. Should end with .engine"
        exit 1
    fi
}

############################################

if [ ! -e libs ]
then
  mkdir libs
fi

if [ -n "$ONNX_MODEL_URI" ]; then
    validate_onnx $ONNX_MODEL_URI
    # Rest of the code using ONNX_MODEL_URI
fi

if [ -n "$ENGINE_MODEL_URI" ]; then
    validate_engine $ENGINE_MODEL_URI
    # Rest of the code using ENGINE_MODEL_URI
fi

case $CLOUD_PROVIDER in
    "GCP")        
        if [ -n "$ONNX_MODEL_URI" ]; then
            validate_gcp $ONNX_MODEL_URI
            if [ ! -e libs/infer.onnx ]; then
                gsutil cp "$ONNX_MODEL_URI" models/infer.onnx
            fi
        fi

        if [ -n "$ENGINE_MODEL_URI" ]; then
            validate_gcp $ENGINE_MODEL_URI
            if [ ! -e libs/infer.engine ]; then
                gsutil cp "$ENGINE_MODEL_URI" models/infer.engine
            fi
        fi
        
        SECRET_PATH="${HOME}/.config/gcloud/application_default_credentials.json"
        ;;
esac

export DOCKER_BUILDKIT=1
docker build \
        --secret id=cloud_json,src=$SECRET_PATH \
        -t $PIPELINE_NAME . "$@"

if [ "$TAG" != "" ]; then
    PUSH_TAG="$CONTAINER_URI/$PIPELINE_NAME:$TAG"
    docker tag $PIPELINE_NAME $PUSH_TAG
    echo "tagged $PUSH_TAG"
    docker push $PUSH_TAG
    echo "pushed $PUSH_TAG"
fi


