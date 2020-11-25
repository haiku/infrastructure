default:
	# container used to build discourse
	docker build -t local/discuss_builder .

	# do the build inside our container
	docker rm --force discuss || true
	docker rmi --force local_discourse/discuss || true
	docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock:z -w /var/discourse/docker \
	  local/discuss_builder ./launcher bootstrap discuss \
	  --docker-args "--network infrastructure_default -v $(shell pwd)/images:/images"
	# produces tagged image: local_discourse/discuss
	docker image tag local_discourse/discuss docker.io/haiku/discuss:latest
	
	# clean up the builder
	docker rmi --force local/discuss_builder

push:
	docker push docker.io/haiku/discuss:latest
