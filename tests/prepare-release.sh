set -e

docker buildx build --push --platform linux/arm64,linux/amd64 -t cunneen/meteor ./image
docker buildx build --push --platform linux/arm64,linux/amd64 -t cunneen/meteor:root ./root-image

semantic-release --debug
