TEMPLATE=layout/template.tmpl
CODELABS_DIR=tutorial
OUTPUT_DIR=public

all: build-tutorials build-landing

build-landing:
	go run cmd/claat-landing/main.go -template $(TEMPLATE) -codelabs-dir $(CODELABS_DIR) -output-dir $(OUTPUT_DIR)

build-tutorials-staging:
	claat export -prefix https://storage.googleapis.com/grafana-tutorials-staging -o tutorial tutorial/*.md

build-tutorials-prod:
	claat export -prefix https://storage.googleapis.com/grafana-tutorials-prod -o tutorial tutorial/*.md

publish-staging:
	gsutil -m rsync -r public/ gs://grafana-tutorials-staging

publish-prod:
	gsutil -m rsync -r public/ gs://grafana-tutorials-prod

clean:
	rm -rf $(OUTPUT_DIR)
