# Codebook for preprocessed data

## cases.csv

One line per case.

- Device: device id.
- Description: human readable location (could change during study due to relocation of the Draeger Perseus device to another operating room).
- OR: medlinq operating room Id e.g 21 for ZOP2/Saal 1, or 30 for ZOP2/Saal 10.
- Date: date.
- Start: start time of case.
- End: end time of case.
- Duration: duration in minutes.
- AvgFlowTotal: average total fresh gas flow in L/min.
- AvgFlowO2: average oxygen fresh gas flow in L/min.
- AvgFlowAir: average air fresh gas flow in L/min.
- UsedVolumeSev: used sevoflurane in ml.
- UptakeVolumeSev: sevoflurane uptake in ml.
- WastedVolumeSev: wasted sevoflurane in ml (UsedVolumeSev - UptakeVolumeSev).
- EfficiencySev: efficiency sevoflurane in %.

## agc.csv

- Id: id of the anaesthetic gas canister (AGC).
- OR: medlinq operating room Id e.g 21 for ZOP2/Saal 1, or 30 for ZOP2/Saal 10.
- InitialWeight: weight of the AGC before use.
- FinalWeight: weight of the AGC after use (red LED on SENSOfluran unit).
- Start: date and time when the AGC was installed.
- End: date and time when the AGC was removed.
- TotalCases: total number of cases for this agc.
- TotalCasesTiva: total number of total intravenous anaesthesia cases for this agc.
- TotalCasesSev: total number of inhaled anaesthesia (sevoflurane) cases for this agc.
- TotalDurationCases: total (summed) duration of all cases where this agc was used.
- TotalDurationCasesTiva: total (summed) duration of all total intravenous anaesthesia cases where this agc was used.
- TotalDurationCasesSev: total (summed) duration of all inhaled anaesthesia (sevoflurane) cases where this agc was used.
- TotalUsedVolumeSev: total sevoflurane volume usage in ml of all cases where this agc was used.
- TotalUptakeVolumeSev: total sevoflurane volume uptake in ml of all cases where this agc was used.
