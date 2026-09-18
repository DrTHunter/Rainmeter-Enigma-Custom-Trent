; This file is included from inside [Variables], so anything above the first
; section header is a variable. G until MeasureDriveFree has measured the drive.
SizeUnit=G

;---------------------------------------------------------------------
; MEASURES

[MeasureDriveFree]
Measure=FreeDiskSpace
Drive=#Drive#:
IgnoreRemovable=0
IfCondition=(MeasureDriveFree >= 1099511627776)
IfTrueAction=[!SetVariable SizeUnit "T"][!SetOption Text MeasureName MeasureDriveFreeTB][!SetOption Text NumOfDecimals 2][!UpdateMeter Text][!Redraw]
IfFalseAction=[!SetVariable SizeUnit "G"][!SetOption Text MeasureName MeasureDriveFreeGB][!SetOption Text NumOfDecimals 0][!UpdateMeter Text][!Redraw]

; Free space for display: whole gigabytes below 1 TB, terabytes to two
; decimals from there up (464 G, 1.82 T). AutoScale cannot vary the number
; of decimals with the unit, so the two scales are separate measures and
; MeasureDriveFree picks between them.
[MeasureDriveFreeGB]
Measure=Calc
Formula=MeasureDriveFree / 1073741824

[MeasureDriveFreeTB]
Measure=Calc
Formula=MeasureDriveFree / 1099511627776

; TaskbarCommon pads every taskbar skin to a 60 px minimum, which left a
; block of empty bar to the right of each drive. Reserve only what the widest
; reading needs - "88.88 T" is 40 px - so a drive never outgrows its slot and
; overlaps its neighbour when it crosses from gigabytes into terabytes.
[MeasureTaskbarSkinWidth]
MinWidth=40

[MeasureDriveUsed]
Measure=FreeDiskSpace
Drive=#Drive#:
IgnoreRemovable=0
InvertMeasure=1

[MeasureDriveTotal]
Measure=FreeDiskSpace
Drive=#Drive#
IgnoreRemovable=0
Total=1

[MeasureDriveType]
Measure=FreeDiskSpace
Drive=#Drive#:
IgnoreRemovable=0
Type=1
IfAboveValue=2
IfAboveAction=!SetOption "Text" "Text" "%1 #*SizeUnit*#"
IfBelowValue=2
IfBelowAction=!SetOption "Text" "Text" "Removed"

; [MeasureDriveName]
; Measure=FreeDiskSpace
; Drive=#Drive#:
; IgnoreRemovable=0
; Label=1
; UpdateDivider=-1

;---------------------------------------------------------------------
; METERS

[Background]
Meter=Image
MeterStyle=Style#Variant#Background

[Icon]
Meter=IMAGE
MeterStyle=Style#Variant#Icon | StyleHDDIcon
LeftMouseUpAction=["#Drive#:\"]
ToolTipTitle=Explore #Drive#:\

[Bar]
Meter=BAR
MeterStyle=Style#Variant#Bar | StyleHDD#Variant#Bar
MeasureName=MeasureDriveUsed

[Text]
Meter=STRING
MeterStyle=Style#Variant#Text
MeasureName=MeasureDriveFreeGB
NumOfDecimals=0
LeftMouseUpAction=["#Drive#:\"]
ToolTipTitle=Explore #Drive#:\

[Label]
Meter=STRING
MeterStyle=Style#Variant#Label
; MeasureName=MeasureDriveName
Text=#Drive#