CERT_MANAGER_VER=1.7.0

deploy:
	kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v$(CERT_MANAGER_VER)/cert-manager.yaml
	sleep 90 # Gotta give cert-manager time to deploy for the webhooks to fire
	kubectl apply -f cert-manager-acme.yaml
	kubectl apply -f traefik-rbac.yaml
	kubectl apply -f traefik-daemonset.yaml

delete:
	kubectl delete -f traefik-daemonset.yaml
	kubectl delete -f traefik-rbac.yaml
	kubectl delete -f cert-manager-acme.yaml
	kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v$(CERT_MANAGER_VER)/cert-manager.yaml
