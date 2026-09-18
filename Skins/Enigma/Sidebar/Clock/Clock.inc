;---------------------------------------------------------------------
; MEASURES

[MeasureTime]
Measure=Time

[MeasureWeek]
Measure=Time
Format="%A"

[MeasureDate]
Measure=Time
Format="%#d %B, %Y"

[MeasureText]
Measure=Time
Format="%#I.%M"

[MeasureLabel]
Measure=Time
Format="%p"

;---------------------------------------------------------------------
; METERS

[Background]
Meter=IMAGE
MeterStyle=StyleSidebarBackground | StyleClock#Variant#Background

;-----------------------
; CLOCK

[Clock]
Meter=IMAGE
MeterStyle=StyleClockFace | StyleClock#Variant#Face

[Seconds]
Meter=ROUNDLINE
MeasureName=MeasureTime
MeterStyle=StyleClockSeconds | StyleClock#Variant#Seconds

[Hours]
Meter=ROUNDLINE
MeasureName=MeasureTime
MeterStyle=StyleClockHours | StyleClock#Variant#Hours

[Minutes]
Meter=ROUNDLINE
MeasureName=MeasureTime
MeterStyle=StyleClockMinutes | StyleClock#Variant#Minutes

;-------------------------
; WEEK, DATE & LOCATION

[Week]
Meter=STRING
MeasureName=MeasureWeek
MeterStyle=StyleClockWeek | StyleClock#Variant#Week

[Date]
Meter=STRING
MeasureName=MeasureDate
MeterStyle=StyleClockDate | StyleClock#Variant#Date

[Location]
Meter=STRING
MeasureName=MeasureWeatherCity
MeterStyle=StyleClockLocation | StyleClock#Variant#Location

;-------------------------
; DIGITAL TIME (ON THE CLOCK FACE)

[Text]
Meter=STRING
MeasureName=MeasureText
MeterStyle=StyleClockText | StyleClock#Variant#Text

[Label]
Meter=STRING
MeasureName=MeasureLabel
MeterStyle=StyleClockLabel | StyleClock#Variant#Label