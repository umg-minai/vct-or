GUIX:=/usr/local/bin/guix
GUIXTM:=${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest.scm
DATA:=data/agc.csv
RAWDATA:=raw-data
MANUSCRIPT:=manuscript
SECTIONDIR:=sections
OUTPUTDIR:=output
DISTDIR:=distribute
RMD=$(wildcard $(SECTIONDIR)/*.Rmd)
CSV=$(wildcard $(RAWDATA)/draeger-connect/*/*.csv) $(wildcard $(RAWDATA)/*/*.csv) $(wildcard $(RAWDATA)/*.csv)
SCRIPTS=$(wildcard $(RAWDATA)/scripts/*.R)
BIB=bibliography/bibliography.bib

DATE=$(shell date +'%Y%m%d')
GITHEAD=$(shell git rev-parse --short HEAD)
GITHEADL=$(shell git rev-parse HEAD)

.DELETE_ON_ERROR:

.PHONEY: \
	clean clean-dist clean-output \
	dist gh-pages guix-pin-channels \
	validate validate-raw-data

all: manuscript

manuscript: $(OUTPUTDIR)/$(MANUSCRIPT).html

$(OUTPUTDIR):
	@mkdir -p $(OUTPUTDIR)

$(OUTPUTDIR)/%.html: %.Rmd $(RMD) $(BIB) $(DATA) guix/manifest.scm | $(OUTPUTDIR)
	${GUIXTM} -- \
		Rscript -e "rmarkdown::render('$<', output_dir = '$(OUTPUTDIR)')"

$(OUTPUTDIR)/%.docx: %.Rmd $(RMD) $(BIB) $(DATA) guix/manifest.scm | $(OUTPUTDIR)
	${GUIXTM} -- \
		Rscript -e "rmarkdown::render('$<', output_format = 'bookdown::word_document2', output_dir = '$(OUTPUTDIR)')"

$(DISTDIR):
	@mkdir -p $(DISTDIR)

dist: $(OUTPUTDIR)/$(MANUSCRIPT).docx | $(DISTDIR)
	@cp $< $(DISTDIR)/"$(DATE)_$(GITHEAD)_$(MANUSCRIPT).docx"

gh-pages: manuscript
	git checkout gh-pages
	sed 's#</h4>#</h4> \
<div style="background-color: \#ffc107; padding: 10px; text-align: center;"> \
<strong>This study is work-in-progress!</strong><br /> \
Please find details at <a href="https://github.com/umg-minai/vct-or">https://github.com/umg-minai/vct-or</a>.<br /> \
Manuscript date: $(shell date +"%Y-%m-%d %H:%M"); Version: <a href="https://github.com/umg-minai/vct-or/commit/$(GITHEADL)">$(GITHEAD)</a> \
</div>#' $(OUTPUTDIR)/$(MANUSCRIPT).html > index.html
	git add index.html
	git commit -m "chore: update index.html"
	git checkout main

.PHONEY:
shell:
	${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest.scm

## pinning guix channels to latest commits
guix-pin-channels: guix/channels.pinned.scm

guix/channels.pinned.scm: guix/channels.scm FORCE
	${GUIX} time-machine --channels=guix/channels.scm -- \
		describe -f channels > guix/channels.pinned.scm

FORCE:

$(DATA): ${CSV} ${SCRIPTS} guix/manifest-data-preparation.scm
	${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest-data-preparation.scm -- \
		Rscript raw-data/scripts/00-setup.R

validate: validate-raw-data

validate-raw-data:
	${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest-data-preparation.scm -- \
		Rscript validation/validate.R

clean: clean-dist clean-output

clean-dist:
	@rm -rf $(DISTDIR)

clean-output:
	@rm -rf $(OUTPUTDIR)
