# Observational study of vapour capture technology in the OR (VCT-OR)

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

At the Department of Anaesthesiology and Intensive Care of the University Medicine Greifswald we investigate the recapture/recycling rate of [ZeoSys's CONTRAfluran](https://zeosys-medical.de/human/) carbon filter/vapture capture technology at two Draeger Perseus A500 anaesthesia machines.

This repository contains the (raw) data and analysis of this investigation.

## Directory structure

### Data

- `data`: cleaned and summarized data for each anaesthetic gas canister, see [data/README.md](data/README.md) for details.
- `raw-data`: raw Draeger connect, CONTRAfluran and Sevoflurane weight measurements, see [raw-data/README.md](raw-data/README.md) for details.

### Manuscript

- `manuscript.Rmd`: main file (contains Abstract and author information) loading all subsections.
- `sections/*.Rmd`: a file per subsection containing the manuscript content.

### Miscellaneous files

- `guix/`: [guix](https://guix.gnu.org) releated files to ensure a reproducible `R` and `pandoc` environment.
- `bibliography/`: references in bibtex format.
- `pandoc/`: `pandoc` related files for word counts etc.

## Project history

### [current](https://github.com/umg-minai/vct-or/tree/main) - since 2023-10-09

### [pilot-draeger-connect](https://github.com/umg-minai/vct-or/tree/pilot-draeger-connect) - 2023-08-06 to 2023-10-08

Initially we used sevoflurane usage data logged by "Dräger connect" in the assumption it was reading the D-Vapor 3000 dial settings and fresh gas flows.
The data from "Dräger connect" were estimated based on the flow and the inspiratory/endtidal sevoflurane concentration.
While the measurements are reasonably for Dräger Primus anaesthesia machines (see [Biro et al. 2014](https://doi.org/10.1007/s10877-014-9639-6)) we restart our study and weigh the sevoflurane bottles to determine the amount of used agent.

## Analysis/writing

We use [guix](https://guix.gnu.org) to ensure an reproducible computing environment.

### Bootstrap

#### Guix on debian

```bash
sudo apt install make git guix
```

#### Fetch sources

```bash
git clone git@github.com:umg-minai/vct-or.git
```

### Build manuscript

Running `make` the first time will take some time because
`guix` hast to download the given state and build the image.

```bash
make
```

### Modify the manuscript

All the work has to be done in the `sections/*.Rmd` files.

### Make targets

- `make` or `make manuscript` produces an `.html` file in `output/`.
- `make dist` produces a `.docx` in `distribute/` which could be send to the
  co-authors.
- `make gh-pages` updates the `gh-pages` branch to the latest manuscript.
- `make clean` removes all generated files.


## Contact/Contribution

You are welcome to:

- submit suggestions and bug-reports at: <https://github.com/umg-minai/vct-or/issues>
- send a pull request on: <https://github.com/umg-minai/vct-or/>
- compose an e-mail to: <mail@sebastiangibb.de>

We try to follow:

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Semantic Line Breaks](https://sembr.org/)
