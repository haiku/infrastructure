VERSION ?= 0.1.0
IMAGE ?= ghcr.io/haiku/importantadminportal
ENGINE ?= podman

default: build

build:
	$(ENGINE) build -t $(IMAGE):$(VERSION) -t $(IMAGE):latest .

push:
	$(ENGINE) push $(IMAGE):$(VERSION)
	$(ENGINE) push $(IMAGE):latest

run:
	$(ENGINE) run --rm -p 8080:8080 -v $(CURDIR)/data:/data $(IMAGE):$(VERSION)

test:
	cargo test

fmt:
	cargo fmt

lint:
	cargo clippy --all-targets -- -D warnings
