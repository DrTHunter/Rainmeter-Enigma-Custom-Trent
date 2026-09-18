;--------------------------------------------------------------------------------------------
; SIDEBAR NOTES

;-----------------------

[StyleNotesBackground]
H=(#NoteHeight#+57)

[StyleNotesBorder]
SolidColor=#ColorBorder4#
X=10
Y=5
W=(#SidebarWidth#-20)
H=1
Hidden=#HideBordersTop#

[StyleNotesIcon]
ImageName=#@#Images\Notes.#ColorImage#.png
X=10
Y=10
W=25
H=25
;ImageAlpha=128
;AntiAlias=1

[StyleNotesTitle]
X=40
Y=15
H=15
W=(#SidebarWidth#-40)
StringStyle=BOLD
FontColor=#ColorHeading#
FontSize=(#Size3#+2)
FontFace=#Font#
AntiAlias=1
ToolTipWidth=#SidebarWidth#

[StyleNotesText]
X=12
Y=37
W=(#SidebarWidth#-24)
H=#NoteHeight#
FontColor=255,255,255,255
FontFace=#Font#
FontSize=(#Size4#+1)
StringAlign=LEFT
StringStyle=NORMAL
InlineSetting=Color | #Color2#
InlinePattern=\d+(\.\d+)*
AntiAlias=1
ClipString=1
ToolTipWidth=#SidebarWidth#

;-----------------------
; BORDER

[StyleNotesBorderBottom]
SolidColor=#ColorBorder4#
X=10
Y=(37+#NoteHeight#+15)
W=(#SidebarWidth#-26)
H=1
Hidden=#HideBordersBottom#

;-----------------------
; GRABBERS

[StyleNotesGrabber]
X=R
Y=r
H=15
W=15
DynamicVariables=1

[StyleNotesGrabberFirst]
X=(#SidebarWidth#-(#NumberOfTabs#*15)-10)
Y=-7r

[StyleNotesGrabber0]
ImageName=#@#Images\Grabber.#ColorImage#.png
ImageAlpha=128

[StyleNotesGrabber1]
ImageName=#@#Images\GrabberActive.#ColorImage#.png