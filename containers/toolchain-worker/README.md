# Haiku toolchain-worker containers

This Dockerfile pre-compiles all of our toolchains into a Docker container ready to be used to
compile Haiku (or whatever) from source *without* needing to build the toolchains.

> This is a big container.  Any help to shrink it further (while still retaining compatibility)
> is apprecerated.

## Building

> The build of this container will automatically detect the number of cores available on your
> host and use all of them.

**Building the latest sources**
```docker build -t haiku/toolchain-worker:latest .```

**Building a branch**
```docker build --build-arg HAIKU_CHECKOUT=r1beta1 --build-arg BUILDTOOLS_CHECKOUT=r1beta1 -t haiku/toolchain-worker:r1beta1 .```

**Building a buildtools commit**
```docker build --build-arg BUILDTOOLS_CHECKOUT=f420f1565f730384cb669545608c65a36adfdcad -t haiku/toolchain-worker:f420f1565f730384cb669545608c65a36adfdcad .```
