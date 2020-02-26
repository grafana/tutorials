.PHONY: tutorials tutorials-no-pull tutorials-test

tutorials:
	docker pull grafana/docs-base:latest
	docker run -v $(PWD)/content:/hugo/content -p 3002:3002 --rm -it grafana/docs-base:latest /bin/bash -c 'mkdir -p content/docs/grafana/latest/ && touch content/docs/grafana/latest/menu.yaml && make docs-menu && hugo server -p 3002 -D --ignoreCache --baseUrl http://localhost:3002 --bind 0.0.0.0'

tutorials-no-pull:
	docker run -v $(PWD)/content:/hugo/content -p 3002:3002 --rm -it grafana/docs-base:latest /bin/bash -c 'mkdir -p content/docs/grafana/latest/ && touch content/docs/grafana/latest/menu.yaml && make docs-menu && hugo server -p 3002 -D --ignoreCache --baseUrl http://localhost:3002 --bind 0.0.0.0'

tutorials-test:
	docker pull grafana/docs-base:latest
	docker run -v $(PWD)/content:/hugo/content --rm -it grafana/docs-base:latest /bin/bash -c 'npm i && make prod'
