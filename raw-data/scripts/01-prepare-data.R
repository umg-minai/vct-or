library("lubridate")

frf <- function(...)
    rprojroot::find_root_file(..., criterion = ".editorconfig", path = ".")

map <- read.csv(frf("raw-data", "mapping.csv"))

.read_case_files <- function(file) {
    ## first row contains "Gesamt: nCases" in Date column
    ncases <- as.numeric(
        gsub(
            "^Gesamt: *", "",
            read.table(
                file,
                header = TRUE,
                dec = ",",
                sep = ";",
                nrows = 1
            )[1L]
        )
    )

    ## skip header and first row
    cases <- read.table(
        file,
        header = FALSE,
        dec = ",",
        sep = ";",
        na.strings = "---",
        skip = 2,
    )[c(
         1, # "Fälle.Datum",
         2, # "Fälle.Zeit",
         4, # "Fälle.Dauer..min.",
         7, # "Durchschnittl..FG.Flow.pro.Fall..L.min..Gesamt",
         8, # "Durchschnittl..FG.Flow.pro.Fall..L.min..O.sub.2..sub.",
        10, # "Durchschnittl..FG.Flow.pro.Fall..L.min..Air",
        14, # "Verbrauch.pro.Fall..ml..Sev",
        18, # "Uptake.pro.Fall..ml..Sev",
        22  # "Effizienz.pro.Fall.....Sev"
    )]
    names(cases) <- c(
        "Date", "Time", "Duration",
        "AvgFlowTotal", "AvgFlowO2", "AvgFlowAir",
        "UsedVolumeSev", "UptakeVolumeSev", "EfficiencySev"
    )

    ## add ncases for later merging with device overview
    cases$nCases <- ncases
    ## drop TIVA cases
    cases <- cases[!is.na(cases$UsedVolumeSev),]
    ## date format: Weekday, DOM. Month(Name) Year
    cases$Date <- dmy(cases$Date)
    ## time format: HH:MM - HH:MM
    cases$Start <- ymd_hm(paste(cases$Date, gsub(" *-.*", "", cases$Time)))
    cases$End <- ymd_hm(paste(cases$Date, gsub(".*- *", "", cases$Time)))

    cases$Duration <- as.numeric(cases$Duration)

    ## reorder columns
    cases <- cases[c(
        "nCases", "Date", "Start", "End", "Duration",
        "AvgFlowTotal", "AvgFlowO2", "AvgFlowAir",
        "UsedVolumeSev", "UptakeVolumeSev", "EfficiencySev"
    )]
    cases
}

.create_weekly_summary <- function(dir, map) {
    ## sounds stupid but we have to match the files based on number of cases ...
    ## (no other identifier is given in the exported "fall_analysis" file
    devices <- read.table(
            text = readLines(
                list.files(
                    dir, pattern = "Device_overview.*\\.csv",
                    full.names = TRUE, recursive = TRUE
                ),
                warn = FALSE # don't throw warning about incomplete final lines
            ),
            header = TRUE,
            sep = ";"
    )[-1L, c("Geräte_Seriennummer", "Fälle_Gesamt")] # exclude first line (total)
    names(devices) <- c("Device", "nCases")

    devices <- merge(devices, map)

    cases <- do.call(rbind, lapply(
        list.files(
            dir, pattern = "fall_analyse.*\\.csv",
            full.names = TRUE, recursive = TRUE
        ),
        .read_case_files
    ))
    s <- merge(devices, cases)
    s$nCases <- NULL
    s
}

dirs <- list.files(
    frf("raw-data"), pattern = "^202[34][01][0-9][0-3][0-9]",
    include.dirs = TRUE, full.names = TRUE
)

d <- do.call(rbind, lapply(dirs, .create_weekly_summary, map = map))
d <- unique(d)
d <- d[order(d$OR, d$Date, d$Start),]

write.csv(d, file = frf("data", "cases.csv"), row.names = FALSE)
