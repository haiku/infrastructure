VERSION = 23.0.5-3
REGISTRY = ghcr.io/haiku

FEATURES = docker

default:
	docker build --security-opt seccomp=unconfined --no-cache --tag ${REGISTRY}/keycloak:${VERSION} .
enter:
	docker run -it --security-opt seccomp=unconfined --entrypoint /bin/sh ${REGISTRY}/keycloak:${VERSION} -l
test:
	docker run -it --name keycloak-test -p8080:8080 -p8443:8443 \
		-e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=testtest -e KC_SPI_THEME_WELCOME_THEME=haiku \
		--security-opt seccomp=unconfined ${REGISTRY}/keycloak:${VERSION} \
			start-dev --features=${FEATURES} --import-realm
clean:
	docker stop keycloak-test
	docker rm keycloak-test
push:
	docker push ${REGISTRY}/keycloak:${VERSION}
