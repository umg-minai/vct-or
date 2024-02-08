library("data.table")

frf <- function(...)
    rprojroot::find_root_file(..., criterion = ".editorconfig", path = ".")

contrafluran <- fread(frf("raw-data", "contrafluran.csv"))[, .(OR, Start, End)]

setorder(contrafluran, OR, Start)

times <- unique(
    contrafluran[, .(Start = min(Start), End = max(End)), by = .(OR)]
)

fwrite(times, frf("data", "period.csv"), row.names = FALSE)
