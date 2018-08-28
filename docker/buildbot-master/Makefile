DATACTX=$(shell realpath ../../data/buildbot/)

default:
	docker build --no-cache --tag docker.io/haiku/buildbot-master:latest .
push:
	docker push docker.io/haiku/buildbot-master:latest
buildah:
	buildah bud -t docker.io/haiku/buildbot-master:latest .
test:
	docker stop infrastructure_buildbot_1 || true
	docker rm infrastructure_buildbot_1 || true
	docker run -p 80:80 \
		-v $(DATACTX)/master.cfg:/var/lib/buildbot/master.cfg \
		-v $(DATACTX)/demo-secrets:/var/lib/buildbot/secrets \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--name infrastructure_buildbot_1 \
		docker.io/haiku/buildbot-master:latest
