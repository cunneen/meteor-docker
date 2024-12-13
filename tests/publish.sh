set -e
VERSION="$1"

# Normal image
docker tag cunneen/meteor cunneen/meteor:latest
docker tag cunneen/meteor cunneen/meteor:$VERSION

docker push cunneen/meteor:latest
docker push cunneen/meteor:$VERSION

# root image
docker tag cunneen/meteor:root cunneen/meteor:$VERSION-root

docker push cunneen/meteor:root
docker push cunneen/meteor:$VERSION-root
