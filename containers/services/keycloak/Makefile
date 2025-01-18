VERSION = $(shell cat VERSION | grep -Ev "^#" | tail -1)-development
REGISTRY = ghcr.io/haiku
FEATURES = docker

default:
	podman build --security-opt seccomp=unconfined --no-cache --tag ${REGISTRY}/keycloak:${VERSION} .
enter:
	podman run -it --security-opt seccomp=unconfined --entrypoint /bin/sh ${REGISTRY}/keycloak:${VERSION} -l
test:
	podman run -it --name keycloak-test -p8080:8080 -p8443:8443 --replace \
		-e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=testtest -e KC_SPI_THEME_WELCOME_THEME=haiku \
		--security-opt seccomp=unconfined ${REGISTRY}/keycloak:${VERSION} \
			start-dev --features=${FEATURES} --import-realm
clean:
	podman stop keycloak-test
	podman rm keycloak-test
push:
	podman push ${REGISTRY}/keycloak:${VERSION}
