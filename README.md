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
- `make dist` produces a `.docx` in `output/` which could be send to the
  co-authors.
- `make clean` removes all generated files.
- `make env` runs a shell in the `guix` generated environment.

## Contact/Contribution

You are welcome to:

- submit suggestions and bug-reports at: <https://github.com/umg-minai/vct-or/issues>
- send a pull request on: <https://github.com/umg-minai/vct-or/>
- compose an e-mail to: <mail@sebastiangibb.de>

We try to follow:

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Semantic Line Breaks](https://sembr.org/)
