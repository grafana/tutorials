TEMPLATE=layout/template.tmpl
CODELABS_DIR=tutorial
OUTPUT_DIR=public

all: build-tutorials build-landing

build-landing:
	go run cmd/claat-landing/main.go -template $(TEMPLATE) -codelabs-dir $(CODELABS_DIR) -output-dir $(OUTPUT_DIR)

build-tutorials:
	pushd layout/assets; sass google-codelab.scss google-codelab.css; popd
	pushd tutorial; claat export -f ../layout/template.html -o ../tutorial *.md; popd

publish-staging:
	gsutil -m rsync -d -r public/ gs://grafana-tutorials-staging

publish-prod:
	gsutil -m rsync -d -r public/ gs://grafana-tutorials-prod

clean:
	rm -rf $(OUTPUT_DIR)
