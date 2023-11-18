# Observational study of vapour capture technology in the OR (VCT-OR)

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

We use [guix](https://guix.gnu.org) to ensure an reproducible computing environment.

## Bootstrap

### Guix on debian

```bash
sudo apt install make git guix
```

### Fetch sources

```bash
git clone git@github.com:umg-minai/vct-or.git
```

## Build manuscript

Running `make` the first time will take some time because
`guix` hast to download the given state and build the image.

```bash
make
```

## Modify the manuscript

All the work has to be done in the `sections/*.Rmd` files.

## Make targets

- `make` or `make manuscript` produces an `.html` file in `output/`.
- `make dist` produces a `.docx` in `distribute/` which could be send to the
  co-authors.
- `make clean` removes all generated files.
- `make env` runs a shell in the `guix` generated environment.

## Project history

### current - since 2023-10-09 [HEAD](https://github.com/umg-minai/vct-or/tree/main)

### pilot-draeger-connect - 2023-08-06 to 2023-10-08 [c49a8ce](https://github.com/umg-minai/vct-or/tree/pilot-draeger-connect)

Initially we used sevoflurane usage data logged by "Dräger connect" in the assumption it was reading the D-Vapor 3000 dial settings and fresh gas flows.
The data from "Dräger connect" were estimated based on the flow and the inspiratory/endtidal sevoflurane concentration.
While the measurements are reasonably for Dräger Primus anaesthesia machines (see [Biro et al. 2014](https://doi.org/10.1007/s10877-014-9639-6)) we restart our study and weigh the sevoflurane bottles to determine the amount of used agent.


## Contact/Contribution

You are welcome to:

- submit suggestions and bug-reports at: <https://github.com/umg-minai/vct-or/issues>
- send a pull request on: <https://github.com/umg-minai/vct-or/>
- compose an e-mail to: <mail@sebastiangibb.de>

We try to follow:

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Semantic Line Breaks](https://sembr.org/)
