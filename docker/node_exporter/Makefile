default:
	docker build --no-cache --tag docker.io/haiku/node_exporter:latest .
test:
	docker run -d --name download-test docker.io/haiku/node_exporter:latest
clean:
	docker stop node_exporter-test
	docker rm node_exporter-test
push:
	docker push docker.io/haiku/node_exporter:latest
