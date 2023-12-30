options(warn = 2)
frf <- function(...)
    rprojroot::find_root_file(..., criterion = ".editorconfig", path = ".")

f <- list.files(
    frf("raw-data", "scripts"), pattern = "^0[1-9].*\\.R$", full.names = TRUE
)
invisible(lapply(f, source))
