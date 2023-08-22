library("lubridate")
library("data.table")

frf <- function(...)
    rprojroot::find_root_file(..., criterion = ".editorconfig", path = ".")

cases <- fread(frf("data", "cases.csv"))[,
    .(OR, Start, End, Duration, UsedVolumeSev, UptakeVolumeSev)
]
setorder(cases, OR, Start)
setnames(cases, c("Start", "End"), c("CaseStart", "CaseEnd"))

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
            c(rep_len(NA, .N - 1), Duration[.N] - (CaseEnd[.N] - AcgEnd[.N])),
        OverhangUsedVolumeSev =
            c(rep_len(NA, .N - 1), UsedVolumeSev[.N] - AcgUsedVolumeSev[.N]),
        OverhangUptakeVolumeSev =
            c(rep_len(NA, .N - 1), UptakeVolumeSev[.N] - AcgUptakeVolumeSev[.N])
    ),
    by = .(AcgId)
]
acg[, `:=` (
        TotalDurationCases = sum(Duration[-.N]) + (CaseEnd[.N] - AcgEnd[.N]),
        TotalUsedVolumeSev = sum(UsedVolumeSev[-.N]) + AcgUsedVolumeSev[.N],
        TotalUptakeVolumeSev = sum(UptakeVolumeSev[-.N] + AcgUptakeVolumeSev[.N])
    ),
    by = .(AcgId)
]

## drop single case information
acg <- acg[, .SD[.N], by = .(AcgId)]
## add overhang from previous case
acg <- acg[, `:=` (
        TotalDurationCases =
            TotalDurationCases + c(0, OverhangDuration[-.N]),
        TotalUsedVolumeSev =
            TotalUsedVolumeSev + c(0, OverhangUsedVolumeSev[-.N]),
        TotalUptakeVolumeSev =
            TotalUptakeVolumeSev + c(0, OverhangUptakeVolumeSev[-.N]),
    by = .(AcgId)
)]
acg <- acg[,
    .(AcgId, AcgOR, AcgInitialWeight, AcgFinalWeight, AcgStart, AcgEnd,
      TotalDurationCases, TotalUsedVolumeSev, TotalUptakeVolumeSev)
]
setnames(acg, colnames(acg), sub("^Acg", "", colnames(acg)))
fwrite(acg, frf("data", "acg.csv"), row.names = FALSE)
