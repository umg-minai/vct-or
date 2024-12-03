library("lubridate")
library("data.table")

frf <- function(...)
    rprojroot::find_root_file(..., criterion = ".editorconfig", path = ".")

cases <- fread(frf("data", "cases.csv"))[,
    .(OR, Start, End, Duration, UsedVolumeSev, UptakeVolumeSev)
]
setorder(cases, OR, Start)
setnames(cases, c("Start", "End"), c("CaseStart", "CaseEnd"))

## drop cases with a duration less or equal 5 min
cases <- cases[Duration > 5,]

## replace NA with 0 for Uptake (often too short; accidentially turned on)
## throw error if UsedVolumeSev is high
i <- is.na(cases$UptakeVolumeSev)
if (any(cases$UsedVolumeSev[i] > 1 & cases$Date > ymd("2023-10-08")))
    stop("Mismatch between sevoflurane use and uptake")
cases$UptakeVolumeSev[i] <- 0
cases$UsedVolumeSev[is.na(cases$UsedVolumeSev)] <- 0
cases[, IsTiva := UsedVolumeSev == 0]

contrafluran <- fread(frf("raw-data", "contrafluran.csv"))
contrafluran[, `:=` (Start = ymd_hms(Start), End = ymd_hms(End))]
setorder(contrafluran, OR, Start)
setnames(
    contrafluran, colnames(contrafluran), paste0("Agc", colnames(contrafluran))
)

## perform non-equi join to get contrafluran case connection, tmp columns needed
cases[, jCaseStart := CaseStart]
contrafluran[, `:=` (jAgcStart = AgcStart, jAgcEnd = AgcEnd)]

agc <- contrafluran[
    cases,
    ,
    on = .(jAgcStart <= jCaseStart, jAgcEnd > jCaseStart, AgcOR == OR),
    nomatch = NULL
]

## drop temporary columns
agc[, `:=` (jAgcStart = NULL, jAgcEnd = NULL)]

## sum usage and uptake
## (don't add last entry from draeger connect, change of agc could happen during
## anaesthesia)
agc[, `:=` (
        OverhangCases =
            c(rep_len(NA, .N - 1),
                if (CaseEnd[.N] > AgcEnd[.N]) {
                    as.numeric(
                        difftime(CaseEnd[.N], AgcEnd[.N], units = "mins")
                    ) / (Duration[.N])
                }
                else 0L
            ),
        OverhangDuration =
            c(rep_len(NA, .N - 1),
                if (CaseEnd[.N] > AgcEnd[.N]) {
                    Duration[.N] - as.numeric(
                        difftime(CaseEnd[.N], AgcEnd[.N], units = "mins")
                    )
                }
                else 0L
            )
    ),
    by = .(AgcId, AgcStart)
]

agc[, `:=` (
        TotalCasesTiva =
            sum(IsTiva) - as.integer(IsTiva[.N]) * OverhangCases[.N],
        TotalCasesSev =
            sum(!IsTiva) - as.integer(!IsTiva[.N]) * OverhangCases[.N],
        TotalDurationCasesTiva =
            sum(Duration[IsTiva]) -
            as.integer(IsTiva[.N]) * OverhangDuration[.N],
        TotalDurationCasesSev =
            sum(Duration[!IsTiva]) -
            as.integer(!IsTiva[.N]) * OverhangDuration[.N]
    ),
    by = .(AgcId, AgcStart)
]

## drop single case information
agc <- agc[, .SD[.N], by = .(AgcId, AgcStart)]
## add overhang from previous case
ocols <- grep("^Overhang|^IsTiva", colnames(agc), value = TRUE)
lcols = paste0("Last", ocols)
agc[, (lcols) := shift(.SD, 1, 0, "lag"), .SDcols = ocols]
agc <- agc[, `:=` (
        TotalCasesTiva = round(
            TotalCasesTiva + as.integer(LastIsTiva) * LastOverhangCases,
            2
        ),
        TotalCasesSev = round(
            TotalCasesSev + as.integer(!LastIsTiva) * LastOverhangCases,
            2
        ),
        TotalDurationCasesTiva = round(
            TotalDurationCasesTiva +
                as.integer(LastIsTiva) * LastOverhangDuration,
            2
        ),
        TotalDurationCasesSev = round(
            TotalDurationCasesSev +
                as.integer(!LastIsTiva) * LastOverhangDuration,
            2
        )
)]

## add consumption data

files <- list.files(
    frf("raw-data", "sevoflurane-consumption"),
    pattern = "^2[0-9]\\.csv$",
    full.names = TRUE
)
consumption <- do.call(rbind, c(mapply(
    function(file, or)cbind.data.frame(
        OR = as.numeric(or), read.csv(file, comment.char = "#")
    ),
    file = files, or = tools::file_path_sans_ext(basename(files)),
    SIMPLIFY = FALSE
), make.row.names = FALSE))

consumption$DiffWeight <- consumption$InitialWeight - consumption$FinalWeight
consumption <- as.data.table(consumption)

## perform non-equi join to get contrafluran consumption connection, tmp
## columns needed
consumption[, Date := ymd_hms(Date)]
agc[, `:=` (jAgcStart = AgcStart, jAgcEnd = AgcEnd)]

agc <- agc[
    consumption[, .(OR, Date, DiffWeight)],
    ,
    on = .(jAgcStart < Date, jAgcEnd >= Date, AgcOR == OR),
    nomatch = NULL
]

## drop temporary columns
agc[, `:=` (jAgcStart = NULL, jAgcEnd = NULL)]

agc[, TotalUsedWeightSev := sum(DiffWeight), by = .(AgcId, AgcStart)]

## calculate storage loss
agc <- agc[, `:=` (
        AgcLostWeight = AgcFinalWeight - AgcFinalWeight2,
        AgcLostWeight2 = AgcFinalWeight - AgcFinalWeight3,
        AgcDaysStored = as.integer(
            round(difftime(ymd("20240409"), AgcEnd, units = "days"))
        ),
        AgcDaysStored2 = as.integer(
            round(difftime(ymd("20241202"), AgcEnd, units = "days"))
        )
)]

## drop duplicated cases (before one row per entry in consumption data)
agc <- unique(agc[,.(
        AgcId, AgcOR, AgcInitialWeight, AgcFinalWeight,
        AgcLostWeight, AgcLostWeight2,
        AgcDaysStored, AgcDaysStored2,
        TotalCasesTiva, TotalCasesSev,
        TotalDurationCasesTiva, TotalDurationCasesSev,
        TotalUsedWeightSev
)])

## group multiple AGC periods and drop now duplicated AGC information
agc <- unique(agc[, .(
        AgcOR,
        AgcInitialWeight = min(AgcInitialWeight),
        AgcFinalWeight = max(AgcFinalWeight),
        AgcLostWeight = max(AgcLostWeight),
        AgcLostWeight2 = max(AgcLostWeight2),
        AgcDaysStored = min(AgcDaysStored),
        AgcDaysStored2 = min(AgcDaysStored2),
        TotalUsedWeightSev = sum(TotalUsedWeightSev),
        TotalCasesTiva = sum(TotalCasesTiva),
        TotalCasesSev = sum(TotalCasesSev),
        TotalDurationCasesTiva = sum(TotalDurationCasesTiva),
        TotalDurationCasesSev = sum(TotalDurationCasesSev)
    ),
    by = .(AgcId)
])
agc[, `:=` (
    TotalCases = TotalCasesTiva + TotalCasesSev,
    TotalDurationCases = TotalDurationCasesTiva + TotalDurationCasesSev
)]
setcolorder(agc, c(
    "AgcId", "AgcOR",
    "AgcInitialWeight", "AgcFinalWeight",
    "AgcLostWeight", "AgcLostWeight2",
    "AgcDaysStored", "AgcDaysStored2",
    "TotalUsedWeightSev", "TotalCases", "TotalCasesTiva", "TotalCasesSev",
    "TotalDurationCases", "TotalDurationCasesTiva", "TotalDurationCasesSev"
))
setorder(agc, AgcId)

setnames(agc, colnames(agc), sub("^Agc", "", colnames(agc)))
fwrite(agc, frf("data", "agc.csv"), row.names = FALSE)
