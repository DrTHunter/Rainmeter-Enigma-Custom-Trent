# Generates Skins\Enigma\Setup\Setup.ini. The panel is a long run of near-identical
# rows, so it is built from a table instead of being typed out by hand.
param([string]$OutFile)

$W = 540; $LabelX = 22; $ValueX = 190; $ValueW = $W - $ValueX - 22; $RowH = 22

$sections = @(
  @{ Title = 'YOU'; Help = 'The name the greeting on the desktop uses.'; Rows = @(
      @{ Key = 'GreetingName'; Label = 'Your name' }) },
  @{ Title = 'WEATHER'; Help = 'Latitude and longitude in decimal degrees, e.g. 40.7128 and -74.0060. Find them by right-clicking a spot in Google Maps.'; Rows = @(
      @{ Key = 'WeatherCodeName'; Label = 'Location name' },
      @{ Key = 'WeatherCodeLat';  Label = 'Latitude' },
      @{ Key = 'WeatherCodeLon';  Label = 'Longitude' },
      @{ Key = 'Unit';            Label = 'Units'; Kind = 'unit' }) },
  @{ Title = 'GOOGLE CALENDAR'; Help = 'Google Calendar > Settings > pick a calendar > Integrate calendar > "Secret address in iCal format". Paste one per row. Addresses are shown masked because anyone holding one can read that calendar.'; Rows = @(
      1..8 | ForEach-Object { @{ Key = "GoogleCalendar$_"; Label = "Calendar $_"; Kind = 'secret'; Clear = 'YourCalendarAddressHere' } }) },
  @{ Title = 'NEWS FEEDS'; Help = 'Any RSS or Atom address. Feed 1 also drives the LIVE FEED ticker in the top bar.'; Rows = @(
      1..5 | ForEach-Object { @{ Key = "Feed$_"; Label = "Feed $_"; Clear = '' } }) },
  @{ Title = 'DRIVES'; Help = 'Drive letters shown by the System and Drive widgets. Letter only, no colon.'; Rows = @(
      1..3 | ForEach-Object { @{ Key = "Drive$_"; Label = "Drive $_" } }) }
)

$sb = New-Object Text.StringBuilder
function Add([string]$s = '') { [void]$sb.AppendLine($s) }

Add ';---------------------------------------------------------------------'
Add '; ENIGMA SETUP'
Add '; One panel for the settings a new install has to fill in: weather'
Add '; your name, location, Google Calendar addresses, news feeds and drive letters.'
Add '; Click a value to edit it; right-click a calendar or feed to clear it.'
Add '; Everything is written to @Resources\User\Options.inc, the same file the'
Add '; rest of Enigma reads, and every skin is refreshed so it applies at once.'
Add ';'
Add '; Open and close it with the gear in the top bar (Taskbar\Setup), or the'
Add '; X in the corner. This file is generated: the rows are identical apart'
Add '; from the variable they edit.'
Add ''
Add '[Rainmeter]'
Add 'Author=DrTHunter'
Add 'Update=1000'
Add 'AccurateText=1'
Add 'DynamicWindowSize=1'
Add '; Opens centred each time, like a dialog. Deliberately NOT always-on-top: the'
Add '; InputText edit box misbehaves over a topmost skin - it opens hidden behind it'
Add '; or never receives keyboard focus, so nothing can be typed.'
Add "OnRefreshAction=[!ZPos 0][!Move ""((#SCREENAREAWIDTH#-$W)/2)"" ""70""]"
Add ''
Add '[Variables]'
Add '@include=#@#User\Options.inc'
Add '@include2=#@#Styles\#Stylesheet#\Options.inc'
Add 'SettingsFile=#@#User\Options.inc'
Add ''
Add ';---------------------------------------------------------------------'
Add '; MEASURES'
Add ''

# Masked display for every secret row, and the unit toggle.
foreach ($sec in $sections) { foreach ($row in $sec.Rows) {
  if ($row.Kind -eq 'secret') {
    Add "[Measure$($row.Key)]"
    Add 'Measure=String'
    Add "String=#$($row.Key)#"
    Add 'RegExpSubstitute=1'
    Add 'Substitute="^\s*$":"not set","^YourCalendarAddressHere$":"not set","^https?://.*$":"set   (hidden)"'
    Add 'UpdateDivider=-1'
    Add ''
  }
}}
Add '[MeasureUnitName]'
Add 'Measure=String'
Add 'String=#Unit#'
Add 'RegExpSubstitute=1'
Add 'Substitute="^[fF]$":"Fahrenheit","^[cCmM]$":"Celsius"'
Add 'UpdateDivider=-1'
Add ''
Add '[MeasureUnitNext]'
Add 'Measure=String'
Add 'String=#Unit#'
Add 'RegExpSubstitute=1'
Add '; Substitutions run one after another, so f -> c would immediately be turned'
Add '; back into f by the second rule. Route it through a token neither rule matches.'
Add 'Substitute="^[fF]$":"<c>","^[cCmM]$":"f","^<c>$":"c"'
Add 'UpdateDivider=-1'
Add ''

# Lay the rows out, collecting the InputText commands as we go.
$y = 58; $cmd = 0; $commands = @(); $meters = New-Object Text.StringBuilder
function M([string]$s = '') { [void]$meters.AppendLine($s) }

foreach ($sec in $sections) {
  $id = ($sec.Title -replace '\W', '')
  M "[Title$id]"; M 'Meter=String'; M 'MeterStyle=StyleSectionTitle'; M "Y=$y"; M "Text=$($sec.Title)"; M ''
  M "[Rule$id]";  M 'Meter=Image';  M 'MeterStyle=StyleRule'; M "Y=$($y + 19)"; M ''
  $y += 26
  M "[Help$id]"; M 'Meter=String'; M 'MeterStyle=StyleHelp'; M "Y=$y"; M "Text=$($sec.Help)"; M ''
  # Help wraps to two lines at this width when it is long.
  $y += $(if ($sec.Help.Length -gt 95) { 34 } else { 20 })

  foreach ($row in $sec.Rows) {
    $k = $row.Key
    M "[Label$k]"; M 'Meter=String'; M 'MeterStyle=StyleLabel'; M "Y=$y"; M "Text=$($row.Label)"; M ''
    M "[Value$k]"; M 'Meter=String'; M 'MeterStyle=StyleValue'; M "Y=$y"
    if ($row.Kind -eq 'unit') {
      M 'MeasureName=MeasureUnitName'; M 'Text=%1'
      M "LeftMouseUpAction=[!WriteKeyValue Variables Unit ""[MeasureUnitNext]"" ""#SettingsFile#""][!Refresh *]"
      M 'ToolTipText=Click to switch between Fahrenheit and Celsius.'
    } else {
      $cmd++
      if ($row.Kind -eq 'secret') { M "MeasureName=Measure$k"; M 'Text=%1'; $default = '' }
      else { M "Text=#$k#"; $default = "#$k#" }
      M "LeftMouseUpAction=[!CommandMeasure MeasureInput ""ExecuteBatch $cmd""]"
      if ($row.ContainsKey('Clear')) {
        M "RightMouseUpAction=[!WriteKeyValue Variables $k ""$($row.Clear)"" ""#SettingsFile#""][!Refresh *]"
        M 'ToolTipText=Click to edit. Right-click to clear.'
      } else { M 'ToolTipText=Click to edit.' }
      $commands += "Command$cmd=[!WriteKeyValue Variables $k ""`$UserInput`$"" ""#SettingsFile#""][!Refresh *] Y=$($y - 1) DefaultValue=""$default"""
    }
    M ''
    $y += $RowH
  }
  $y += 12
}

M '[Footer]'; M 'Meter=String'; M 'MeterStyle=StyleHelp'; M "Y=$y"
M 'Text=Saved to @Resources\User\Options.inc and applied straight away. That file is personal: keep your own copy out of any public repository.'; M ''
$y += 36

# Tip link. The cup is built from its code point: Windows PowerShell reads a
# BOM-less script as ANSI, which would mangle a literal emoji in this file.
$cup = [string][char]0x2615
M '[RuleCoffee]'; M 'Meter=Image'; M 'MeterStyle=StyleRule'; M "Y=$y"; M ''
$y += 12
M '[Coffee]'; M 'Meter=String'; M "X=$([int]($W / 2))"; M "Y=$y"; M 'StringAlign=Center'
M 'FontFace=#Font#'; M 'FontSize=9'; M 'FontColor=#Color1#,200'; M 'AntiAlias=1'
M 'SolidColor=0,0,0,1'; M 'Padding=10,4,10,4'
M "Text=$cup  Like this setup? Buy me a coffee  -  `$TrentHun on Cash App"
M 'InlineSetting=Color | #ColorLink#'; M 'InlinePattern=\$TrentHun'
M 'ToolTipText=Opens cash.app/$TrentHun in your browser.'
M 'LeftMouseUpAction=["https://cash.app/$TrentHun"]'
M 'MouseOverAction=[!SetOption Coffee FontColor "#ColorHeading#"][!UpdateMeter Coffee][!Redraw]'
M 'MouseLeaveAction=[!SetOption Coffee FontColor "#Color1#,200"][!UpdateMeter Coffee][!Redraw]'; M ''
$y += 38
$H = $y

Add '[MeasureInput]'
Add 'Measure=Plugin'
Add 'Plugin=InputText'
Add "X=$ValueX"
Add "W=$ValueW"
Add 'H=20'
Add 'FontFace=#Font#'
Add 'FontSize=9'
Add '; Light box, dark text: it has to look different from the row it covers, or'
Add '; clicking a value appears to do nothing.'
Add 'FontColor=13,11,26'
Add 'SolidColor=236,236,242'
Add 'FocusDismiss=1'
Add 'UpdateDivider=-1'
$commands | ForEach-Object { Add $_ }
Add ''
Add ';---------------------------------------------------------------------'
Add '; STYLES'
Add ''
Add '[StyleSectionTitle]'
Add "X=$LabelX"
Add 'FontFace=#Font#'
Add 'FontSize=8'
Add 'FontWeight=700'
Add 'FontColor=#ColorHeading#'
Add 'AntiAlias=1'
Add 'InlineSetting=CharacterSpacing | 1.5 | 1.5'
Add ''
Add '[StyleRule]'
Add "X=$LabelX"
Add "W=$($W - 2 * $LabelX)"
Add 'H=1'
Add 'SolidColor=#ColorBorder3#'
Add ''
Add '[StyleHelp]'
Add "X=$LabelX"
Add "W=$($W - 2 * $LabelX)"
Add 'H=30'
Add 'ClipString=2'
Add 'FontFace=#Font#'
Add 'FontSize=7'
Add 'FontColor=#Color1#,130'
Add 'AntiAlias=1'
Add ''
Add '[StyleLabel]'
Add "X=$LabelX"
Add 'FontFace=#Font#'
Add 'FontSize=9'
Add 'FontColor=#Color2#'
Add 'AntiAlias=1'
Add ''
Add '[StyleValue]'
Add "X=$ValueX"
Add "W=$ValueW"
Add 'H=18'
Add 'ClipString=1'
Add 'FontFace=#Font#'
Add 'FontSize=9'
Add 'FontColor=#Color1#'
Add 'AntiAlias=1'
Add '; Nearly transparent rather than absent, so the whole row is clickable.'
Add 'SolidColor=255,255,255,8'
Add 'Padding=4,1,4,1'
Add 'DynamicVariables=1'
Add 'MouseOverAction=[!SetOption #CURRENTSECTION# FontColor "#ColorLink#"][!UpdateMeter #CURRENTSECTION#][!Redraw]'
Add 'MouseLeaveAction=[!SetOption #CURRENTSECTION# FontColor "#Color1#"][!UpdateMeter #CURRENTSECTION#][!Redraw]'
Add ''
Add ';---------------------------------------------------------------------'
Add '; METERS'
Add ''
Add '[Panel]'
Add 'Meter=Shape'
Add "Shape=Rectangle 0.5,0.5,$($W - 1),$($H - 1),6 | Fill Color #ColorPanel#,245 | StrokeWidth 1 | Stroke Color #ColorBorder2#"
Add ''
Add '[Heading]'
Add 'Meter=String'
Add "X=$LabelX"
Add 'Y=16'
Add 'FontFace=#Font#'
Add 'FontSize=13'
Add 'FontColor=#Color1#'
Add 'AntiAlias=1'
Add 'Text=Enigma Setup'
Add ''
Add '[Close]'
Add 'Meter=String'
Add "X=$($W - 22)"
Add 'Y=14'
Add 'StringAlign=Right'
Add 'FontFace=#Font#'
Add 'FontSize=13'
Add 'FontColor=#Color1#,160'
Add 'AntiAlias=1'
Add 'SolidColor=0,0,0,1'
Add 'Padding=6,0,6,0'
Add 'Text=X'
Add 'ToolTipText=Close'
Add 'LeftMouseUpAction=[!DeactivateConfig]'
Add 'MouseOverAction=[!SetOption Close FontColor "#ColorHeading#"][!UpdateMeter Close][!Redraw]'
Add 'MouseLeaveAction=[!SetOption Close FontColor "#Color1#,160"][!UpdateMeter Close][!Redraw]'
Add ''
[void]$sb.Append($meters.ToString())
Add ';---------------------------------------------------------------------'
Add '; METADATA'
Add ''
Add '[Metadata]'
Add 'Name=Enigma Setup'
Add 'Information=First-run settings panel: weather your name, location, Google Calendar addresses, news feeds and drive letters. Click a value to edit it.'
Add 'Version=1.0'
Add 'License=Creative Commons BY-NC-SA 3.0'

New-Item -ItemType Directory -Force (Split-Path $OutFile -Parent) | Out-Null
[IO.File]::WriteAllText($OutFile, $sb.ToString(), [Text.Encoding]::Unicode)
"wrote $OutFile  ($cmd editable rows, panel ${W}x$H)"
