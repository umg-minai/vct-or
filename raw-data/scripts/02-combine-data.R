library("lubridate")
library("data.table")

frf <- function(...)
    rprojroot::find_root_file(..., criterion = ".editorconfig", path = ".")

cases <- fread(frf("data", "cases.csv"))[,
    .(OR, Start, End, Duration, UsedVolumeSev, UptakeVolumeSev)
]
setorder(cases, OR, Start)
setnames(cases, c("Start", "End"), c("CaseStart", "CaseEnd"))
## convert Duration from mins to secs
cases[, Duration := Duration * 60]

## drop cases without a duration
cases <- cases[Duration > 0,]

## replace NA with 0 for Uptake (often too short; accidentially turned on)
## throw error if UsedVolumeSev is high
i <- is.na(cases$UptakeVolumeSev)
if (any(cases$UsedVolumeSev[i] > 1 & cases$Date > ymd("2023-08-06")))
    stop("Mismatch between sevoflurane use and uptake")
cases$UptakeVolumeSev[i] <- 0
cases$UsedVolumeSev[is.na(cases$UsedVolumeSev)] <- 0
cases[, IsTiva := UsedVolumeSev == 0]

contrafluran <- fread(frf("raw-data", "contrafluran.csv"))
contrafluran[, `:=` (Start = ymd_hms(Start), End = ymd_hms(End))]
setorder(contrafluran, OR, Start)
setnames(contrafluran, colnames(contrafluran), paste0("Acg", colnames(contrafluran)))

## perform non-equi join to get contrafluran case connection, tmp columns needed
cases[, jCaseStart := CaseStart]
contrafluran[, `:=` (jAcgStart = AcgStart, jAcgEnd = AcgEnd)]

agc <- contrafluran[
    cases,
    ,
    on = .(jAcgStart <= jCaseStart, jAcgEnd > jCaseStart, AcgOR == OR)
]

## drop temporary columns
agc[, `:=` (jAcgStart = NULL, jAcgEnd = NULL)]

## drop unmatched cases
agc <- agc[!is.na(AcgId),]

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
                if (CaseEnd[.N] > AcgEnd[.N])
                    (CaseEnd[.N] - AcgEnd[.N]) / (DurationSev[.N])
                else 0L
            ),
        OverhangDurationSev =
            c(rep_len(NA, .N - 1),
                if (CaseEnd[.N] > AcgEnd[.N])
                    DurationSev[.N] - (CaseEnd[.N] - AcgEnd[.N])
                else 0L
            ),
        OverhangUsedVolumeSev =
            c(rep_len(NA, .N - 1),
                if (CaseEnd[.N] > AcgEnd[.N])
                    UsedVolumeSev[.N] - AcgUsedVolumeSev[.N]
                else 0
              ),
        OverhangUptakeVolumeSev =
            c(rep_len(NA, .N - 1),
                if (CaseEnd[.N] > AcgEnd[.N])
                    UptakeVolumeSev[.N] - AcgUptakeVolumeSev[.N]
                else 0
            )
    ),
    by = .(AcgId)
]
agc[, `:=` (
        TotalCasesTiva = sum(IsTiva),
        TotalCasesSev =
            if (CaseEnd[.N] <= AcgEnd[.N])
                sum(!IsTiva)
            else
                sum(!IsTiva) - ((AcgEnd[.N] - CaseStart[.N]) / (Duration[.N]))
        ,
        TotalDurationCasesSev =
            if (CaseEnd[.N] <= AcgEnd[.N])
                sum(DurationSev)
            else
                sum(DurationSev[-.N]) + (AcgEnd[.N] - CaseStart[.N])
        ,
        # change of the ACG during a TIVA case should never happen
        TotalDurationCasesTiva = sum(DurationTiva),
        TotalUsedVolumeSev =
            if (CaseEnd[.N] <= AcgEnd[.N])
                sum(UsedVolumeSev)
            else
                sum(UsedVolumeSev[-.N]) + AcgUsedVolumeSev[.N],
        TotalUptakeVolumeSev =
            if (CaseEnd[.N] <= AcgEnd[.N])
                sum(UptakeVolumeSev)
            else
                sum(UptakeVolumeSev[-.N] + AcgUptakeVolumeSev[.N])
    ),
    by = .(AcgId)
]

## drop single case information
agc <- agc[, .SD[.N], by = .(AcgId)]
## add overhang from previous case
ocols <- grep("^Overhang", colnames(agc), value = TRUE)
lcols = paste0("Last", ocols)
agc[, (lcols) := shift(.SD, 1, 0, "lead"), .SDcols = ocols]
agc <- agc[, `:=` (
        TotalCasesSev =
            TotalCasesSev + LastOverhangCasesSev,
        TotalDurationCasesSev =
            TotalDurationCasesSev + LastOverhangDurationSev,
        TotalUsedVolumeSev =
            TotalUsedVolumeSev + LastOverhangUsedVolumeSev,
        TotalUptakeVolumeSev =
            TotalUptakeVolumeSev + LastOverhangUptakeVolumeSev
)]
## convert Duration back to mins
agc[, `:=` (
    TotalDurationCasesSev = TotalDurationCasesSev / 60,
    TotalDurationCasesTiva = TotalDurationCasesTiva / 60
)]
agc[, `:=` (
    TotalCases = TotalCasesTiva + TotalCasesSev,
    TotalDurationCases = TotalDurationCasesTiva + TotalDurationCasesSev
)]
agc <- agc[,
    .(AcgId, AcgOR, AcgInitialWeight, AcgFinalWeight, AcgStart, AcgEnd,
      TotalCases, TotalCasesTiva, TotalCasesSev,
      TotalDurationCases, TotalDurationCasesTiva, TotalDurationCasesSev,
      TotalUsedVolumeSev, TotalUptakeVolumeSev)
]

setnames(agc, colnames(agc), sub("^Acg", "", colnames(agc)))
fwrite(agc, frf("data", "agc.csv"), row.names = FALSE)
