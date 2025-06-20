# Codebook for preprocessed data

## agc.csv

One line per anaesthetic gas canister (AGC).

- Id: id of the AGC.
- OR: medlinq operating room Id e.g 21 for ZOP2/Saal 1, or 30 for ZOP2/Saal 10.
- InitialWeight: weight [g] of the AGC before use.
- FinalWeight: weight [g] of the AGC after use (red LED on SENSOfluran unit).
- LostWeight: weight lost [g] during storage at our hospital.
- DaysStored: days the AGC was stored in our hospital before shipping.
- TotalCases: total number of cases for this agc.
- TotalCasesTiva: total number of total intravenous anaesthesia cases for this agc.
- TotalCasesSev: total number of inhaled anaesthesia (sevoflurane) cases for this agc.
- TotalDurationCases: total (summed) duration of all cases where this agc was used.
- TotalDurationCasesTiva: total (summed) duration of all total intravenous anaesthesia cases where this agc was used.
- TotalDurationCasesSev: total (summed) duration of all inhaled anaesthesia (sevoflurane) cases where this agc was used.
- TotalUsedWeightSev: total sevoflurane consumption in gram of all cases where this agc was used.

## cases.csv

One line per case.

- Device: device id.
- Description: human readable location (could change during study due to relocation of the Draeger Perseus device to another operating room).
- OR: medlinq operating room Id e.g 21 for ZOP2/Saal 1, or 30 for ZOP2/Saal 10.
- Date: date, format YYYY-MM-DD.
- Start: start time of case, format YYYY-MM-DD HH:MM:SS.
- End: end time of case, format YYYY-MM-DD HH:MM:SS.
- Duration: duration in minutes.
- AvgFlowTotal: average total fresh gas flow in L/min.
- AvgFlowO2: average oxygen fresh gas flow in L/min.
- AvgFlowAir: average air fresh gas flow in L/min.
- UsedVolumeSev: used sevoflurane in ml as exported from Draeger connect.
- UptakeVolumeSev: sevoflurane uptake in ml as exported from Draeger connect.
- EfficiencySev: efficiency sevoflurane in % as exported from Draeger connect.

## flow-vapor-settings.csv

- Case: case id.
- TimeStamp: timestamp, format YYYY-MM-DD HH:MM:SS.
- Flow: fresh gas flow in L/min.
- Vapor: vapor setting in Vol%.
- Duration: duration of "Flow" and "Vapor" setting combination in minutes.

## periods.csv

- OR: medlinq operating room Id e.g 21 for ZOP2/Saal 1, or 30 for ZOP2/Saal 10.
- Start: date and time when the first anaesthetic gas canister (AGC) was installed.
- End: date and time when the last AGC was removed.

## scale-comparison.csv

For comparison of our measurement method (weighting the sevoflurane bottles
before and after filling the vaporizer) against the gold standard of weighting
the vaporizer before and after filling (or each anaesthesia).

The sevoflurane bottles were weighed with a Kern PCB 2500-2; Kern&Sohn GmbH, Balingen-Frommern; Germany; maximum weight = 2500 g; d = 0.01 g.
The vaporizers were weighed with a Kern PNJ 12000-M1; Kern&Sohn GmbH, Balingen-Frommern; Germany; maximum weight = 12000 g; d = 0.1 g.

- Id: id of the measurement.
- OR: id of the operating room.
- Date: date, format YYYY-MM-DD.
- InitialWeightVaporizer: weight of the vaporizer before it was filled.
- FinalWeightVaporizer: weight of the vaporizer after it was filled.
- InitialWeightBottle: weight of the sevoflurane bottle before the vaporizer was filled.
- FinalWeightBottle: weight of the sevoflurane bottle after the vaporizer was filled.
