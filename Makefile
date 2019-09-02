DOMAIN=haiku-os.org
default:
	@echo "Usage: make (bootstrap|deploy|upgrade|clean)"
	@echo "       bootstrap: Setup required services in a new environment"
	@echo "       deploy: Apply the current infrastructure to the current environment"
	@echo "       clean: Remove all of the haiku infrastructure from this host (persistant volumes remain)"
	@echo "       upgrade: Roll-out updates as safely as possible. (Services with replicas of >1 shouldn't see an outage)"
	@exit 1
#Not needed until we do a multi-traefik deployment.
#bootstrap:
#	# Seed our etcd with the initial Traefik kv's
#	docker stack deploy -c support.yaml support
#	sleep 15
#	docker run --rm --network support_default -v $(PWD)/data/traefik/traefik.toml:/traefik.toml -v infrastructure_traefik_acme:/acme traefik:latest storeconfig
#	sleep 15
#	docker stack rm support
deploy:
	DOMAIN=$(DOMAIN) docker stack deploy -c support.yaml support
	sleep 5
	DOMAIN=$(DOMAIN) docker stack deploy -c ingress.yaml ingress
	sleep 5
	DOMAIN=$(DOMAIN) docker stack deploy -c sysadmin.yaml sysadmin
	DOMAIN=$(DOMAIN) docker stack deploy -c ci.yaml ci
	DOMAIN=$(DOMAIN) docker stack deploy -c cdn.yaml cdn
	DOMAIN=$(DOMAIN) docker stack deploy -c dev.yaml dev
	DOMAIN=$(DOMAIN) docker stack deploy -c community.yaml community
clean:
	docker stack rm community
	docker stack rm dev
	docker stack rm cdn
	docker stack rm ci
	docker stack rm sysadmin
	sleep 5
	docker stack rm ingress
	docker stack rm support
