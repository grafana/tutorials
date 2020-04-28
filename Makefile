.PHONY: tutorials tutorials-no-pull tutorials-test

IMAGE = grafana/docs-base:latest

tutorials:
	docker pull grafana/docs-base:latest
	docker run -v $(shell pwd)/sources:/hugo/content/docs/grafana/latest -p 3002:3002 --rm -it $(IMAGE) /bin/bash -c 'mkdir -p content/docs/grafana/latest/ && touch content/docs/grafana/latest/menu.yaml && make server'

tutorials-no-pull:
	docker run -v $(shell pwd)/sources:/hugo/content/docs/grafana/latest -p 3002:3002 --rm -it $(IMAGE) /bin/bash -c 'mkdir -p content/docs/grafana/latest/ && touch content/docs/grafana/latest/menu.yaml && make server'

tutorials-test:
	docker pull grafana/docs-base:latest
	docker run -v $(shell pwd)/sources:/hugo/content/docs/grafana/latest --rm -it $(IMAGE) /bin/bash -c 'make prod'

