;--------------------------------------------------------------------------------------------
; SIDEBAR CALENDAR

[Variables]
FirstX=38
FirstY=38
SpacingX=((#SidebarWidth#-#FirstX#-19)/6)
SpacingY=20
IndicatorOffsetX=-17
IndicatorOffsetY=-2

;-----------------------

[StyleCalendarBorder]
SolidColor=#ColorBorder4#
X=10
Y=5
W=(#SidebarWidth#-20)
H=1
Hidden=#HideBordersTop#

[StyleCalendarLabelBackground]
X=#SpacingX#r
Y=18
W=16
H=16
SolidColor=255,0,153,40

[StyleCalendarLabelBackgroundFirst]
X=(#FirstX#-18)

[StyleCalendarLabel]
X=#SpacingX#r
Y=20
FontColor=#Color2#
FontFace=#Font#
FontSize=#Size3#
StringAlign=CENTER
StringStyle=NORMAL
AntiAlias=1

[StyleCalendarLabelFirst]
X=(#FirstX#-10)

[StyleCalendarText]
X=#SpacingX#r
Y=r
W=18
H=13
FontColor=#ColorDigit#
FontFace=#Font#
FontSize=#Size3#
StringAlign=RIGHT
StringStyle=NORMAL
AntiAlias=1
DynamicVariables=1

[StyleCalendarTextFirst]
X=#FirstX#
Y=#FirstY#

[StyleCalendarTextExtra]
FontColor=#Color3#

[StyleCalendarTextInvisible]
FontColor=#ColorTransparent#

[StyleCalendarIndicatorText]
StringStyle=BOLD

[StyleCalendarEvent]
Prefix=•

[StyleCalendarIndicatorBox]
SolidColor=#ColorBar#,70
H=16
W=18
DynamicVariables=1

;---------------------------------------------------------------------
; MONTH

[StyleCalendarMonthBackground]
H=170

[StyleCalendarNewWeek]
X=#FirstX#
Y=#SpacingY#r

[StyleCalendarMonthBorderBottom]
SolidColor=#ColorBorder4#
X=10
Y=165
W=(#SidebarWidth#-20)
H=1
Hidden=#HideBordersBottom#

;---------------------------------------------------------------------
; WEEK

[StyleCalendarWeekBackground]
H=63

[StyleCalendarWeekBorderBottom]
SolidColor=#ColorBorder4#
X=10
Y=58
W=(#SidebarWidth#-20)
H=1
Hidden=#HideBordersBottom#