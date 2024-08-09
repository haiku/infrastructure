FROM ghcr.io/haiku/general-worker:latest
ADD runner /runner
ENV _BUILDAH_STARTED_IN_USERNS="" BUILDAH_ISOLATION=chroot
RUN chmod 755 /runner
ENTRYPOINT /runner
