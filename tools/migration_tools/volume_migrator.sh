#!/bin/bash

if [[ $# -ne 2 ]]; then
	echo "This tool migrates data from a remote server over ssh to pod pv accessed"
	echo "through a local kubectl installation"
	echo ""
	echo "Requirements: ReadWriteMany PVCs, Service being deployed"
	echo ""
	echo "Warning: Ensure kubectl is configured for the correct environment before running!"
	echo ""
	echo "Usage: $0 <source scp path> <destination k8s volume claim>"
	echo "       (assumes ssh port 2222 for source system)"
	echo ""
	echo "ex: ./volume_migrator.sh limerick.ams3.haiku-os.org:/var/lib/docker/volumes/support_redis_data/_data/. redis-data-pvc"
	exit 1
fi

SOURCE=$1
VOLUME=$2

echo "Beginning rsync of $SOURCE..."
mkdir -p /tmp/$VOLUME
rsync --exclude 'tmp' -avz --delete -e "ssh -p 2222" $1 /tmp/$VOLUME

echo "Rsync complete"

echo "Beginning of rsync to $VOLUME in kubernetes..."

IMAGE="docker.io/alpine:latest"
COMMAND="/bin/sh"
VOL_MOUNTS="${VOL_MOUNTS}${COMMA}{\"name\": \"${VOLUME}\",\"mountPath\": \"/pvcs/${VOLUME}\"}"
VOLS="${VOLS}${COMMA}{\"name\": \"${VOLUME}\",\"persistentVolumeClaim\": {\"claimName\": \"${VOLUME}\"}}"

# Stand up a pod bound to the specified volume claim
kubectl run --restart=Never --image=${IMAGE} pvc-$VOLUME --overrides "
{
  \"spec\": {
    \"hostNetwork\": true,
    \"containers\":[
      {
        \"args\": [\"${COMMAND}\"],
        \"stdin\": true,
        \"tty\": true,
        \"name\": \"pvc\",
        \"image\": \"${IMAGE}\",
        \"volumeMounts\": [
          ${VOL_MOUNTS}
        ]
      }
    ],
    \"volumes\": [
      ${VOLS}
    ]
  }
}
" -- ${COMMAND}

echo "Waiting on migration pod..."
kubectl wait --for=condition=Ready pod/pvc-$VOLUME

echo "Installing rsync..."
kubectl exec pod/pvc-$VOLUME -- apk add rsync

echo "Beginning rsync to pod..."
rsync -za0v --delete --blocking-io --rsync-path="/pvcs/${VOLUME}" --rsh="kubectl exec pvc-${VOLUME} -i -- " /tmp/$VOLUME/. rsync:/pvcs/${VOLUME}

echo "Cleaning up migration pod..."
kubectl delete pod/pvc-$VOLUME

echo "Done!"
echo "You may want to erase the data in /tmp/$VOLUME once you go live!"
