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
