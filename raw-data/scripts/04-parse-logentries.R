library("lubridate")

frf <- function(...)
    rprojroot::find_root_file(..., criterion = ".editorconfig", path = ".")

f <- frf("raw-data", "perseus-logentry", "2024040301.csv")

.parse_vapor_settings <- function(x) {
    gsub(
        "^.*#([0-8]\\.[0-9]{6,})#201a#.*#([0-8]\\.[0-9]{6,})#201a#.*$",
        "\\1;\\2",
        x
    )
}

.parse_fgf_settings <- function(x) {
    gsub(
        "^.*#([0-9]+\\.[0-9]{6,})#201d#.*#([0-9]+\\.[0-9]{6,})#201d#.*$",
        "\\1;\\2",
        x
    )
}

.parse_settings <- function(x) {
    s <- .parse_fgf_settings(x)
    s <- .parse_vapor_settings(s)
    l <- do.call(rbind, strsplit(s, ";", fixed = TRUE))
    colnames(l) <- c("From", "To")
    mode(l) <- "numeric"
    l[, 2L]
}

.parse_type <- function(x) {
    type <- character(length(x))
    type[grepl("#201a#", x)] <- "VAPOR"
    type[grepl("#201d#", x)] <- "FGF"
    type
}

.read_logentry_file <- function(file) {
    entries <- read.csv2(file)[c("TimeStamp", "Decription", "CodeExtension")]

    entries <- data.frame(
        TimeStamp = dmy_hm(entries$TimeStamp),
        Type = .parse_type(entries$CodeExtension),
        Setting = .parse_settings(entries$CodeExtension)
    )

    # resolution is only in minutes; keep just last setting per minute
    entries <- entries[order(entries$TimeStamp, entries$Type),]
    entries <- entries[
        !duplicated(entries[c("TimeStamp", "Type")], fromLast = TRUE),
    ]

    # convert from long to wide, but index (time) could be different
    entries$Flow <-
        c(0, entries$Setting[entries$Type == "FGF"])[cumsum(entries$Type == "FGF") + 1]
    entries$Vapor <-
        c(0, entries$Setting[entries$Type == "VAPOR"])[cumsum(entries$Type == "VAPOR") + 1]
    entries$Duration <-
        c(as.numeric(c(difftime(entries$TimeStamp[-1], entries$TimeStamp[-nrow(entries)], units = "mins"))), 0)
    entries[entries$Duration > 0 & entries$Vapor > 0, c("TimeStamp", "Flow", "Vapor", "Duration")]
}

files <- list.files(
    frf("raw-data", "perseus-logentry"), pattern = "*\\.csv",
    full.names = TRUE
)

entries <- lapply(files, .read_logentry_file)

entries <- cbind(
    Case = rep(seq_along(entries), vapply(entries, nrow, NA_integer_)),
    do.call(rbind, entries)
)

write.csv(
    entries, file = frf("data", "flow-vapor-settings.csv"), row.names = FALSE
)
