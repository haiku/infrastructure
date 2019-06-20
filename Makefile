DOMAIN=haiku-test.org
default:
	@echo "Usage: make (deploy|upgrade)"
	exit 1
deploy:
	DOMAIN=$(DOMAIN) docker stack deploy -c ingress.yaml ingress
	sleep 5
	DOMAIN=$(DOMAIN) docker stack deploy -c ci.yaml ci
	DOMAIN=$(DOMAIN) docker stack deploy -c cdn.yaml cdn
	#DOMAIN=$(DOMAIN) docker stack deploy -c core.yaml core
clean:
	#docker stack rm core
	docker stack rm cdn
	docker stack rm ci
	sleep 5
	docker stack rm ingress
