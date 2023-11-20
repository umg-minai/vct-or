library("lubridate")
library("data.table")

frf <- function(...)
    rprojroot::find_root_file(..., criterion = ".editorconfig", path = ".")

cases <- fread(frf("data", "cases.csv"))[,
    .(OR, Start, End, Duration, UsedVolumeSev, UptakeVolumeSev)
]
setorder(cases, OR, Start)
setnames(cases, c("Start", "End"), c("CaseStart", "CaseEnd"))

## drop cases without a duration
cases <- cases[Duration > 0,]

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
setnames(contrafluran, colnames(contrafluran), paste0("Agc", colnames(contrafluran)))

## perform non-equi join to get contrafluran case connection, tmp columns needed
cases[, jCaseStart := CaseStart]
contrafluran[, `:=` (jAgcStart = AgcStart, jAgcEnd = AgcEnd)]

agc <- contrafluran[
    cases,
    ,
    on = .(jAgcStart <= jCaseStart, jAgcEnd > jCaseStart, AgcOR == OR)
]

## drop temporary columns
agc[, `:=` (jAgcStart = NULL, jAgcEnd = NULL)]

## drop unmatched cases
agc <- agc[!is.na(AgcId),]

agc[, `:=` (
    DurationTiva = fifelse(IsTiva, Duration, 0),
    DurationSev = fifelse(IsTiva, 0, Duration)
)]

## sum usage and uptake
## (don't add last entry from draeger connect, change of agc could happen during
## anaesthesia)
agc[, `:=` (
        OverhangCasesSev =
            c(rep_len(NA, .N - 1),
                if (CaseEnd[.N] > AgcEnd[.N]) {
                    as.numeric(
                        difftime(CaseEnd[.N], AgcEnd[.N], units = "mins")
                    ) / (DurationSev[.N])
                }
                else 0L
            ),
        OverhangDurationSev =
            c(rep_len(NA, .N - 1),
                if (CaseEnd[.N] > AgcEnd[.N]) {
                    DurationSev[.N] - as.numeric(
                        difftime(CaseEnd[.N], AgcEnd[.N], units = "mins")
                    )
                }
                else 0L
            )
    ),
    by = .(AgcId)
]
agc[, `:=` (
        TotalCasesTiva = sum(IsTiva),
        TotalCasesSev =
            if (CaseEnd[.N] <= AgcEnd[.N])
                sum(!IsTiva)
            else
                sum(!IsTiva) - OverhangCasesSev[.N]
        ,
        TotalDurationCasesSev =
            if (CaseEnd[.N] <= AgcEnd[.N])
                sum(DurationSev)
            else
                sum(DurationSev) - OverhangDurationSev[.N]
        ,
        # change of the ACG during a TIVA case should never happen
        TotalDurationCasesTiva = sum(DurationTiva)
    ),
    by = .(AgcId)
]

## drop single case information
agc <- agc[, .SD[.N], by = .(AgcId)]
## add overhang from previous case
ocols <- grep("^Overhang", colnames(agc), value = TRUE)
lcols = paste0("Last", ocols)
agc[, (lcols) := shift(.SD, 1, 0, "lag"), .SDcols = ocols]
agc <- agc[, `:=` (
        TotalCasesSev =
            TotalCasesSev + LastOverhangCasesSev,
        TotalDurationCasesSev =
            TotalDurationCasesSev + LastOverhangDurationSev
)]
agc[, `:=` (
    TotalCases = TotalCasesTiva + TotalCasesSev,
    TotalDurationCases = TotalDurationCasesTiva + TotalDurationCasesSev
)]
agc <- agc[,
    .(AgcId, AgcOR, AgcInitialWeight, AgcFinalWeight, AgcStart, AgcEnd,
      TotalCases, TotalCasesTiva, TotalCasesSev,
      TotalDurationCases, TotalDurationCasesTiva, TotalDurationCasesSev,
      TotalUsedVolumeSev, TotalUptakeVolumeSev)
]

setnames(agc, colnames(agc), sub("^Acg", "", colnames(agc)))
fwrite(agc, frf("data", "agc.csv"), row.names = FALSE)
