CERT_MANAGER_VER=1.20.5
CERT_MANAGER_REPO=https://github.com/cert-manager/cert-manager

deploy:
	kubectl apply -f $(CERT_MANAGER_REPO)/releases/download/v$(CERT_MANAGER_VER)/cert-manager.yaml
	sleep 90 # Gotta give cert-manager time to deploy for the webhooks to fire
	kubectl apply -f cert-manager-acme.yaml
	kubectl apply -f kubernetes-crd-definition-v1.yaml
	kubectl apply -f kubernetes-crd-rbac.yaml
	kubectl apply -f traefik-daemonset.yaml

deploy-certmanager:
	kubectl apply -f $(CERT_MANAGER_REPO)/releases/download/v$(CERT_MANAGER_VER)/cert-manager.yaml

deploy-traefik:
	kubectl apply -f kubernetes-crd-definition-v1.yaml
	kubectl apply -f kubernetes-crd-rbac.yaml
	kubectl apply -f traefik-daemonset.yaml

delete:
	kubectl delete -f traefik-daemonset.yaml
	kubectl delete -f traefik-rbac.yaml
	kubectl delete -f cert-manager-acme.yaml
	kubectl delete -f $(CERT_MANAGER_REPO)/releases/download/v$(CERT_MANAGER_VER)/cert-manager.yaml
