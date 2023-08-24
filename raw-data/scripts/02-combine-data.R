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

contrafluran <- fread(frf("raw-data", "contrafluran.csv"))
contrafluran[, `:=` (Start = ymd_hms(Start), End = ymd_hms(End))]
setorder(contrafluran, OR, Start)
setnames(contrafluran, colnames(contrafluran), paste0("Acg", colnames(contrafluran)))

## perform non-equi join to get contrafluran case connection, tmp columns needed
cases[, jCaseStart := CaseStart]
contrafluran[, `:=` (jAcgStart = AcgStart, jAcgEnd = AcgEnd)]

acg <- contrafluran[
    cases,
    ,
    on = .(jAcgStart <= jCaseStart, jAcgEnd > jCaseStart, AcgOR == OR)
]

## drop temporary columns
acg[, `:=` (jAcgStart = NULL, jAcgEnd = NULL)]

## drop unmatched cases
acg <- acg[!is.na(AcgId),]

## sum usage and uptake
## (don't add last entry from draeger connect, change of acg could happen during
## anaesthesia)
acg[, `:=` (
        OverhangDuration =
            c(rep_len(NA, .N - 1),
                if (CaseEnd[.N] > AcgEnd[.N])
                    Duration[.N] - (CaseEnd[.N] - AcgEnd[.N])
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
acg[, `:=` (
        TotalDurationCases =
            if (CaseEnd[.N] <= AcgEnd[.N])
                sum(Duration)
            else
                sum(Duration[-.N]) + (AcgEnd[.N] - CaseStart[.N])
        ,
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
acg <- acg[, .SD[.N], by = .(AcgId)]
## add overhang from previous case
ocols <- grep("^Overhang", colnames(acg), value = TRUE)
lcols = paste0("Last", ocols)
acg[, (lcols) := shift(.SD, 1, 0, "lead"), .SDcols = ocols]
acg <- acg[, `:=` (
        TotalDurationCases =
            TotalDurationCases + LastOverhangDuration,
        TotalUsedVolumeSev =
            TotalUsedVolumeSev + LastOverhangUsedVolumeSev,
        TotalUptakeVolumeSev =
            TotalUptakeVolumeSev + LastOverhangUptakeVolumeSev
)]
acg <- acg[,
    .(AcgId, AcgOR, AcgInitialWeight, AcgFinalWeight, AcgStart, AcgEnd,
      TotalDurationCases, TotalUsedVolumeSev, TotalUptakeVolumeSev)
]
## convert Duration back to mins
acg[, TotalDurationCases := TotalDurationCases / 60]

setnames(acg, colnames(acg), sub("^Acg", "", colnames(acg)))
fwrite(acg, frf("data", "acg.csv"), row.names = FALSE)
