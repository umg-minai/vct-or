GUIX:=/usr/local/bin/guix
GUIXTM:=${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest.scm
DATA:=data/agc.csv
RAWDATA:=raw-data
MANUSCRIPT:=manuscript
SECTIONDIR:=sections
OUTPUTDIR:=output
DISTDIR:=distribute
CACHEDIR:=cache
RMD=$(wildcard $(SECTIONDIR)/*.Rmd)
CSV=$(wildcard $(RAWDATA)/*/*.csv) $(wildcard $(RAWDATA)/*.csv)
SCRIPTS=$(wildcard $(RAWDATA)/scripts/*.R)

DATE=$(shell date +'%Y%m%d')
GITHEAD=$(shell git rev-parse --short HEAD)

.DELETE_ON_ERROR:

.PHONEY: \
	clean clean-dist clean-output \
	dist gh-pages env guix-pin-channels

all: manuscript

manuscript: $(OUTPUTDIR)/$(MANUSCRIPT).html

$(OUTPUTDIR):
	@mkdir -p $(OUTPUTDIR)

$(OUTPUTDIR)/%.html: %.Rmd $(RMD) $(DATA) guix/manifest.scm | $(OUTPUTDIR)
	${GUIXTM} -- \
		Rscript -e "rmarkdown::render('$<', output_dir = '$(OUTPUTDIR)')"

$(OUTPUTDIR)/%.docx: %.Rmd $(RMD) $(DATA) guix/manifest.scm | $(OUTPUTDIR)
	${GUIXTM} -- \
		Rscript -e "rmarkdown::render('$<', output_format = 'bookdown::word_document2', output_dir = '$(OUTPUTDIR)')"

$(DISTDIR):
	@mkdir -p $(DISTDIR)

dist: $(OUTPUTDIR)/$(MANUSCRIPT).docx | $(DISTDIR)
	@cp $< $(DISTDIR)/"$(DATE)_$(GITHEAD)_$(MANUSCRIPT).docx"

gh-pages: manuscript
	git checkout gh-pages
	cp $(OUTPUTDIR)/$(MANUSCRIPT).html index.html
	git add index.html
	git commit -m "chore: update index.html"
	git checkout main

## start guix development environment
env: guix/manifest.scm
	${GUIXTM}

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

clean: clean-cache clean-dist clean-output

clean-cache:
	@rm -rf $(CACHEDIR)

clean-dist:
	@rm -rf $(DISTDIR)

clean-output:
	@rm -rf $(OUTPUTDIR)
