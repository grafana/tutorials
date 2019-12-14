package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"text/template"
	"time"
)

type codelab struct {
	Environment string    `json:"environment"`
	Format      string    `json:"format"`
	Prefix      string    `json:"prefix"`
	MainGA      string    `json:"mainga"`
	Updated     time.Time `json:"updated"`
	ID          string    `json:"id"`
	Duration    int       `json:"duration"`
	Title       string    `json:"title"`
	Authors     string    `json:"authors"`
	Summary     string    `json:"summary"`
	Source      string    `json:"source"`
	Theme       string    `json:"theme"`
	Status      []string  `json:"status"`
	Category    []string  `json:"category"`
	Tags        []string  `json:"tags"`
	Feedback    string    `json:"feedback"`
	URL         string    `json:"url"`
}

func main() {
	var (
		codelabsDir   = flag.String("codelabs-dir", "tutorials", "Directory where the codelabs are located")
		htmlTemplate  = flag.String("template", "layout/template.tmpl", "Template to use when building landing page")
		landingStyles = flag.String("asset-dir", "layout/assets", "Assets for landing page")
		outputDir     = flag.String("output-dir", "public", "Directory where to put the generated site")
	)

	flag.Parse()

	// Each exported codelab contains a codelab.json file that contains the
	// metadata.
	var paths []string
	err := filepath.Walk(*codelabsDir, func(path string, info os.FileInfo, err error) error {
		if filepath.Base(path) == "codelab.json" {
			paths = append(paths, path)
		}
		return nil
	})
	if err != nil {
		log.Fatal(err)
	}

	// Parse each codelab.json.
	var labs []codelab
	for _, l := range paths {
		b, err := ioutil.ReadFile(l)
		if err != nil {
			log.Fatal(err)
		}

		var lab codelab
		if err := json.Unmarshal(b, &lab); err != nil {
			log.Fatal(err)
		}

		labs = append(labs, lab)
	}

	tmpl, err := template.ParseFiles(*htmlTemplate)
	if err != nil {
		log.Fatal(err)
	}

	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, struct{ Codelabs []codelab }{labs}); err != nil {
		log.Fatal(err)
	}

	// Write all files to the output directory.
	if err := os.MkdirAll(*outputDir, os.ModePerm); err != nil {
		log.Fatal(err)
	}
	err = exec.Command("cp", "-a", *codelabsDir, *outputDir).Run()
	if err != nil {
		log.Fatal(err)
	}
	err = exec.Command("cp", "-a", *landingStyles, *outputDir).Run()
	if err != nil {
		log.Fatal(err)
	}
	err = ioutil.WriteFile(filepath.Join(*outputDir, "index.html"), buf.Bytes(), os.ModePerm)
	if err != nil {
		log.Fatal(err)
	}
}
