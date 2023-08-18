# Code book for raw data

## mapping.csv

Mapping between device id and operating room.

- Device: device id (name of the Draeger Perseus device).
- Description: human readable location (could change during study due to relocation of the Draeger Perseus device to another operating room).
- OR: medlinq operating room Id e.g 21 for ZOP2/Saal 1, or 30 for ZOP2/Saal 10.

## contrafluran.csv

Information about the CONTRAfluran anaesthetic gas canister.

- Id: id of the anaesthetic gas canister (AGC).
- InitialWeight: weight of the AGC before use.
- FinalWeight: weight of the AGC after use (red LED on SENSOfluran unit).
- OR: medlinq operating room Id e.g 21 for ZOP2/Saal 1, or 30 for ZOP2/Saal 10.
- Start: date and time when the AGC was installed.
- End: date and time when the AGC was removed.
- UsedVolumeSev: sevoflurane volume usage in ml as reported by the Draeger Perseus.
- UptakeVolumeSev: sevoflurane volume uptake in ml as reported by the Draeger Perseus.

## 2023xxxx/Device_overview_x*.csv

Weekly summary report exported from Draeger connect software.

First line contains the total summary of all rows below.

- Geräte_Produkt: type of device (not used).
- Geräte_Standort: location/id of the device.
- Geräte_Seriennummer: serial number, empty (not used).
- Geräte_Gerätenummer; device number, empty (not used).
- Fälle_Gesamt: total cases, used to map the reports from the operating rooms to the devices.
- Fälle_Inhalativ: not used.
- Fälle_Durchschnittl. Dauer [min]: not used.
- Durchschnittl. Kosten_Pro Fall [EUR]: not used.
- Durchschnittl. Kosten_Pro Minute [EUR]: not used.
- Durchschnittl. FG-Flow pro Fall [L/min]_Gesamt: not used.
- Durchschnittl. FG-Flow pro Fall [L/min]_O2: not used.
- Durchschnittl. FG-Flow pro Fall [L/min]_N2O: not used.
- Durchschnittl. FG-Flow pro Fall [L/min]_Air: not used.
- Durchschnittl. Verbrauch pro Fall (mL)_Gesamt: not used.
- Durchschnittl. Verbrauch pro Fall (mL)_Iso: not used.
- Durchschnittl. Verbrauch pro Fall (mL)_Des: not used.
- Durchschnittl. Verbrauch pro Fall (mL)_Sev: not used.
- Durchschnittl. Uptake pro Fall [mL]_Gesamt: not used.
- Durchschnittl. Uptake pro Fall [mL]_Iso: not used.
- Durchschnittl. Uptake pro Fall [mL]_Des: not used.
- Durchschnittl. Uptake pro Fall [mL]_Sev: not used.
- Durchschnittl. Effizienz pro Fall [%]_Gesamt: not used.
- Durchschnittl. Effizienz pro Fall [%]_Iso: not used.
- Durchschnittl. Effizienz pro Fall [%]_Des: not used.
- Durchschnittl. Effizienz pro Fall [%]_Sev: not used.
- CO2-Äquivalent gesamt [kg]_Gesamt: not used.
- CO2-Äquivalent gesamt [kg]_Iso: not used.
- CO2-Äquivalent gesamt [kg]_Des: not used.
- CO2-Äquivalent gesamt [kg]_Sev not used.

## 2023xxxx/fall_analyse_xxxx*.csv

Weekly individual report exported from Draeger connect software.

First line contains the total summary of all rows below.

- Geräte_Produkt: type of device (not used).
- Fälle Datum: date, format: Weekday, Day. Month Year.
- Fälle Zeit: time, format: HH:MM - HH:MM (from - to).
- Fälle Inhalativ: inhaled anaesthetics used yes/no (ja/nein), not used.
- Fälle Dauer (min): duration in minutes.
- Kosten Pro Fall [EUR]: not used.
- Kosten Pro Minute [EUR]: not used.
- Durchschnittl. FG-Flow pro Fall [L/min] Gesamt: average total fresh gas flow.
- Durchschnittl. FG-Flow pro Fall [L/min] O<sub>2</sub>: average oxygen fresh gas flow.
- Durchschnittl. FG-Flow pro Fall [L/min] N<sub>2</sub>O: not used.
- Durchschnittl. FG-Flow pro Fall [L/min] Air: average air fresh gas flow.
- Verbrauch pro Fall (ml) Gesamt: not used.
- Verbrauch pro Fall (ml) Iso: not used.
- Verbrauch pro Fall (ml) Des: not used.
- Verbrauch pro Fall (ml) Sev: used sevoflurane in ml.
- Uptake pro Fall (ml) Gesamt: not used.
- Uptake pro Fall (ml) Iso: not used.
- Uptake pro Fall (ml) Des: not used.
- Uptake pro Fall (ml) Sev: sevoflurane uptake in ml.
- Effizienz pro Fall (%) Gesamt: not used.
- Effizienz pro Fall (%) Iso: not used.
- Effizienz pro Fall (%) Des: not used.
- Effizienz pro Fall (%) Sev: efficiency sevoflurane in %.
- CO2-Äquivalent Gesamt: not used.
- CO2-Äquivalent Iso: not used.
- CO2-Äquivalent Des: not used.
- CO2-Äquivalent Sev: not used.
