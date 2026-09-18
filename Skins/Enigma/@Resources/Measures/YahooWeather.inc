;---------------------------------------------------------------------
; ENIGMA WEATHER MEASURES
;
; The original Yahoo! Weather API was retired, so these measures now
; pull from The Weather Company / weather.com API v3.
; Measure names are unchanged so all existing skins keep working.
;
; Skins including this file must define:
;   CurrentCode, CurrentCodeName, CurrentCodeLat, CurrentCodeLon
;
; WeatherAPIKey below is the public key embedded in weather.com's own
; web app. Replace it with your own key if you have one.

[Variables]
WeatherAPIKey=e1f10a1e78da46f5b10a1e78da96f525

; Unit system: Enigma's #Unit# is f or c; weather.com uses e or m.
WxUnitf=e
WxUnitc=m
UnitTempLabelf=F
UnitTempLabelc=C
UnitSpeedLabelf=mph
UnitSpeedLabelc=km/h
UnitDistanceLabelf=mi
UnitDistanceLabelc=km
UnitPressureLabelf=in
UnitPressureLabelc=mb
; Imperial reads pressureAltimeter (inHg), metric pressureMeanSeaLevel (mb).
PressureIndexf=3
PressureIndexc=4

; Icon code -> description (standard TWC/Yahoo codes 0-47).
WeatherDescMap="^0$":"Tornado","^1$":"Tropical Storm","^2$":"Hurricane","^3$":"Severe Thunderstorms","^4$":"Thunderstorms","^5$":"Rain and Snow","^6$":"Rain and Sleet","^7$":"Snow and Sleet","^8$":"Freezing Drizzle","^9$":"Drizzle","^10$":"Freezing Rain","^11$":"Showers","^12$":"Showers","^13$":"Snow Flurries","^14$":"Light Snow","^15$":"Blowing Snow","^16$":"Snow","^17$":"Hail","^18$":"Sleet","^19$":"Dust","^20$":"Foggy","^21$":"Haze","^22$":"Smoky","^23$":"Blustery","^24$":"Windy","^25$":"Cold","^26$":"Cloudy","^27$":"Mostly Cloudy","^28$":"Mostly Cloudy","^29$":"Partly Cloudy","^30$":"Partly Cloudy","^31$":"Clear","^32$":"Sunny","^33$":"Fair","^34$":"Fair","^35$":"Rain and Hail","^36$":"Hot","^37$":"Isolated Storms","^38$":"Scattered Storms","^39$":"Scattered Showers","^40$":"Heavy Rain","^41$":"Scattered Snow","^42$":"Heavy Snow","^43$":"Blizzard","^44$":"Not Available","^45$":"Scattered Showers","^46$":"Snow Showers","^47$":"Isolated Storms","^null$":""

; "2026-08-01T07:00:00-0400" -> "Aug 1". Applied in order: keep month/day,
; name the month, then drop a leading zero on the day.
WxMonthDayMap="^\d{4}-(\d{2})-(\d{2})T.*$":"\1 \2","^01 ":"Jan ","^02 ":"Feb ","^03 ":"Mar ","^04 ":"Apr ","^05 ":"May ","^06 ":"Jun ","^07 ":"Jul ","^08 ":"Aug ","^09 ":"Sep ","^10 ":"Oct ","^11 ":"Nov ","^12 ":"Dec ","^([A-Za-z]{3}) 0(\d)$":"\1 \2"

WxDowMap="^Monday$":"Mon","^Tuesday$":"Tue","^Wednesday$":"Wed","^Thursday$":"Thu","^Friday$":"Fri","^Saturday$":"Sat","^Sunday$":"Sun"

; "2026-07-31T06:12:52-0400" -> "6:12 AM". Rainmeter's Time measure cannot
; parse these reliably, so the 12-hour conversion is done with substitutions.
WxTimeMap="^.{11}(\d\d):(\d\d).*$":"\1:\2","^00:(\d\d)$":"12:\1 AM","^01:(\d\d)$":"1:\1 AM","^02:(\d\d)$":"2:\1 AM","^03:(\d\d)$":"3:\1 AM","^04:(\d\d)$":"4:\1 AM","^05:(\d\d)$":"5:\1 AM","^06:(\d\d)$":"6:\1 AM","^07:(\d\d)$":"7:\1 AM","^08:(\d\d)$":"8:\1 AM","^09:(\d\d)$":"9:\1 AM","^10:(\d\d)$":"10:\1 AM","^11:(\d\d)$":"11:\1 AM","^12:(\d\d)$":"12:\1 PM","^13:(\d\d)$":"1:\1 PM","^14:(\d\d)$":"2:\1 PM","^15:(\d\d)$":"3:\1 PM","^16:(\d\d)$":"4:\1 PM","^17:(\d\d)$":"5:\1 PM","^18:(\d\d)$":"6:\1 PM","^19:(\d\d)$":"7:\1 PM","^20:(\d\d)$":"8:\1 PM","^21:(\d\d)$":"9:\1 PM","^22:(\d\d)$":"10:\1 PM","^23:(\d\d)$":"11:\1 PM"

;---------------------------------------------------------------------
; CURRENT CONDITIONS
; Name kept as MeasureYahooWeather: skins reference it for refresh-on-click.

[MeasureYahooWeather]
Measure=Plugin
Plugin=WebParser
UpdateRate=1800
Url=https://api.weather.com/v3/wx/observations/current?geocode=#CurrentCodeLat#,#CurrentCodeLon#&units=[#WxUnit[#Unit]]&language=en-US&format=json&apiKey=#WeatherAPIKey#
RegExp=(?siU)"cloudCover":(.*),"cloudCoverPhrase".*"iconCode":(.*),"iconCodeExtend".*"pressureAltimeter":(.*),"pressureChange".*"pressureMeanSeaLevel":(.*),"pressureTendencyCode".*"relativeHumidity":(.*),"snow1Hour".*"sunriseTimeLocal":"(.*)".*"sunsetTimeLocal":"(.*)".*"temperature":(.*),"temperatureChange24Hour".*"temperatureFeelsLike":(.*),"temperatureHeatIndex".*"temperatureWindChill":(.*),"uvDescription".*"visibility":(.*),"windDirection":(.*),"windDirectionCardinal":"(.*)".*"windSpeed":(.*),"wxPhraseLong":"(.*)"
StringIndex=15
DynamicVariables=1
RegExpSubstitute=1
Substitute="^.*$":"https://weather.com/weather/today/l/#CurrentCodeLat#,#CurrentCodeLon#"

;---------------------------------------------------------------------
; DAILY FORECAST
; The parent holds the raw JSON; each sub-parser below re-parses it with
; its own RegExp, so adding a field never renumbers the others.

[MeasureWeatherForecast]
Measure=Plugin
Plugin=WebParser
UpdateRate=1800
Url=https://api.weather.com/v3/wx/forecast/daily/5day?geocode=#CurrentCodeLat#,#CurrentCodeLon#&units=[#WxUnit[#Unit]]&language=en-US&format=json&apiKey=#WeatherAPIKey#
RegExp=(?siU)^(.*)$
StringIndex=1
DynamicVariables=1

; Daily arrays: 6 entries, index 1 = today.
[MeasureWxFcMax]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWeatherForecast]
RegExp=(?siU)"temperatureMax":\[(.*),(.*),(.*),(.*),(.*),(.*)\]
StringIndex=1

[MeasureWxFcMin]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWeatherForecast]
RegExp=(?siU)"temperatureMin":\[(.*),(.*),(.*),(.*),(.*),(.*)\]
StringIndex=1

; calendarDay* never goes null; used as the day-1 fallback after ~3pm local.
[MeasureWxFcMaxCal]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWeatherForecast]
RegExp=(?siU)"calendarDayTemperatureMax":\[(.*),(.*),(.*),(.*),(.*),(.*)\]
StringIndex=1

[MeasureWxFcMinCal]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWeatherForecast]
RegExp=(?siU)"calendarDayTemperatureMin":\[(.*),(.*),(.*),(.*),(.*),(.*)\]
StringIndex=1

[MeasureWxFcDate]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWeatherForecast]
RegExp=(?siU)"validTimeLocal":\["(.*)","(.*)","(.*)","(.*)","(.*)","(.*)"\]
StringIndex=1

[MeasureWxFcDayOfWeek]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWeatherForecast]
RegExp=(?siU)"dayOfWeek":\["(.*)","(.*)","(.*)","(.*)","(.*)","(.*)"\]
StringIndex=1

; Daypart arrays: 12 entries alternating day/night (1 = today daytime,
; 2 = tonight, 3 = tomorrow daytime...). Index 1 turns null after ~3pm
; local, so day-1 measures fall back to the nighttime value.
[MeasureWxFcIcon]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWeatherForecast]
RegExp=(?siU)"iconCode":\[(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*)\]
StringIndex=1

[MeasureWxFcPrecip]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWeatherForecast]
RegExp=(?siU)"precipChance":\[(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*)\]
StringIndex=1

[MeasureWxFcPart]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWeatherForecast]
RegExp=(?siU)"daypartName":\[(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*)\]
StringIndex=1

;-----------------------
; LOCATION

[MeasureWeatherCity]
Measure=String
String=#CurrentCodeName#
DynamicVariables=1

[MeasureWeatherRegion]
Measure=String
String=

[MeasureWeatherCountry]
Measure=String
String=

[MeasureWeatherLatitude]
Measure=String
String=#CurrentCodeLat#
DynamicVariables=1

[MeasureWeatherLongitude]
Measure=String
String=#CurrentCodeLon#
DynamicVariables=1

[MeasureWeatherTimeZone]
Measure=String
String=

;-----------------------
; UNITS

[MeasureWeatherUnitTemp]
Measure=String
String=[#UnitTempLabel[#Unit]]
DynamicVariables=1

[MeasureWeatherUnitDistance]
Measure=String
String=[#UnitDistanceLabel[#Unit]]
DynamicVariables=1

[MeasureWeatherUnitPressure]
Measure=String
String=[#UnitPressureLabel[#Unit]]
DynamicVariables=1

[MeasureWeatherUnitSpeed]
Measure=String
String=[#UnitSpeedLabel[#Unit]]
DynamicVariables=1

;-----------------------
; WIND

[MeasureWeatherWindChillRaw]
Measure=Plugin
Plugin=WebParser
Url=[MeasureYahooWeather]
StringIndex=10

[MeasureWeatherWindChill]
Measure=Calc
Formula=Round(MeasureWeatherWindChillRaw)

[MeasureWeatherWindDirectionRaw]
Measure=Plugin
Plugin=WebParser
Url=[MeasureYahooWeather]
StringIndex=12

[MeasureWeatherWindDirection]
Measure=Calc
Formula=Round(MeasureWeatherWindDirectionRaw)

[MeasureWeatherWindDirectionCardinal]
Measure=Plugin
Plugin=WebParser
Url=[MeasureYahooWeather]
StringIndex=13

[MeasureWeatherWindSpeedRaw]
Measure=Plugin
Plugin=WebParser
Url=[MeasureYahooWeather]
StringIndex=14

[MeasureWeatherWindSpeed]
Measure=Calc
Formula=Round(MeasureWeatherWindSpeedRaw)

;-----------------------
; ATMOSPHERE

[MeasureWeatherAtmoHumidity]
Measure=Plugin
Plugin=WebParser
Url=[MeasureYahooWeather]
StringIndex=5

[MeasureWeatherAtmoVisibility]
Measure=Plugin
Plugin=WebParser
Url=[MeasureYahooWeather]
StringIndex=11

[MeasureWeatherAtmoCloudCover]
Measure=Plugin
Plugin=WebParser
Url=[MeasureYahooWeather]
StringIndex=1

[MeasureWeatherAtmoPressureRaw]
Measure=Plugin
Plugin=WebParser
Url=[MeasureYahooWeather]
StringIndex=[#PressureIndex[#Unit]]
DynamicVariables=1

[MeasureWeatherAtmoPressure]
Measure=String
String=[MeasureWeatherAtmoPressureRaw]
DynamicVariables=1

[MeasureWeatherAtmoRising]
Measure=String
String=

;--------------------------------
; SUN

[MeasureWeatherSunrise]
Measure=Plugin
Plugin=WebParser
Url=[MeasureYahooWeather]
StringIndex=6
RegExpSubstitute=1
Substitute=#WxTimeMap#

[MeasureWeatherSunset]
Measure=Plugin
Plugin=WebParser
Url=[MeasureYahooWeather]
StringIndex=7
RegExpSubstitute=1
Substitute=#WxTimeMap#

; Kept for compatibility: some skins referenced the pre-formatted values.
[MeasureWeatherSunriseRaw]
Measure=String
String=[MeasureWeatherSunrise]
DynamicVariables=1

[MeasureWeatherSunsetRaw]
Measure=String
String=[MeasureWeatherSunset]
DynamicVariables=1

;--------------------------------
; CURRENT

[MeasureWeatherDesc]
Measure=Plugin
Plugin=WebParser
Url=[MeasureYahooWeather]
StringIndex=15

[MeasureWeatherIcon]
Measure=Plugin
Plugin=WebParser
Url=[MeasureYahooWeather]
StringIndex=2
RegExpSubstitute=1
Substitute="^null$":"na"

[MeasureWeatherTempRaw]
Measure=Plugin
Plugin=WebParser
Url=[MeasureYahooWeather]
StringIndex=8

[MeasureWeatherTemp]
Measure=Calc
Formula=Round(MeasureWeatherTempRaw)

[MeasureWeatherFeelsLikeRaw]
Measure=Plugin
Plugin=WebParser
Url=[MeasureYahooWeather]
StringIndex=9

[MeasureWeatherFeelsLike]
Measure=Calc
Formula=Round(MeasureWeatherFeelsLikeRaw)

;-------------------------
; 5-DAY FORECAST
; Day 1 = today. Legacy Enigma names (Day2 = today, Day3 = tomorrow) are
; mapped at the bottom of this file so existing skins keep working.

; ---- DAY 1 (today) ----

[MeasureWxMd1]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcDate]
StringIndex=1
RegExpSubstitute=1
Substitute=#WxMonthDayMap#

[MeasureWxDow1]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcDayOfWeek]
StringIndex=1
RegExpSubstitute=1
Substitute=#WxDowMap#

[MeasureWxPart1Night]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcPart]
StringIndex=2
Substitute='"':""

[MeasureWxPart1]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcPart]
StringIndex=1
Substitute='"':"","null":"[MeasureWxPart1Night]"
DynamicVariables=1

[MeasureWxHigh1Cal]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcMaxCal]
StringIndex=1

[MeasureWxHigh1]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcMax]
StringIndex=1
Substitute="null":"[MeasureWxHigh1Cal]"
DynamicVariables=1

[MeasureWxLow1Cal]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcMinCal]
StringIndex=1

[MeasureWxLow1]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcMin]
StringIndex=1
Substitute="null":"[MeasureWxLow1Cal]"
DynamicVariables=1

[MeasureWxIcon1Night]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcIcon]
StringIndex=2

[MeasureWxIcon1]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcIcon]
StringIndex=1
Substitute="null":"[MeasureWxIcon1Night]"
DynamicVariables=1

[MeasureWxPrecip1Night]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcPrecip]
StringIndex=2

[MeasureWxPrecip1]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcPrecip]
StringIndex=1
Substitute="null":"[MeasureWxPrecip1Night]"
DynamicVariables=1

; ---- DAY 2 ----

[MeasureWxMd2]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcDate]
StringIndex=2
RegExpSubstitute=1
Substitute=#WxMonthDayMap#

[MeasureWxDow2]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcDayOfWeek]
StringIndex=2
RegExpSubstitute=1
Substitute=#WxDowMap#

[MeasureWxHigh2]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcMax]
StringIndex=2

[MeasureWxLow2]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcMin]
StringIndex=2

[MeasureWxIcon2]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcIcon]
StringIndex=3

[MeasureWxPrecip2]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcPrecip]
StringIndex=3

; ---- DAY 3 ----

[MeasureWxMd3]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcDate]
StringIndex=3
RegExpSubstitute=1
Substitute=#WxMonthDayMap#

[MeasureWxDow3]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcDayOfWeek]
StringIndex=3
RegExpSubstitute=1
Substitute=#WxDowMap#

[MeasureWxHigh3]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcMax]
StringIndex=3

[MeasureWxLow3]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcMin]
StringIndex=3

[MeasureWxIcon3]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcIcon]
StringIndex=5

[MeasureWxPrecip3]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcPrecip]
StringIndex=5

; ---- DAY 4 ----

[MeasureWxMd4]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcDate]
StringIndex=4
RegExpSubstitute=1
Substitute=#WxMonthDayMap#

[MeasureWxDow4]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcDayOfWeek]
StringIndex=4
RegExpSubstitute=1
Substitute=#WxDowMap#

[MeasureWxHigh4]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcMax]
StringIndex=4

[MeasureWxLow4]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcMin]
StringIndex=4

[MeasureWxIcon4]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcIcon]
StringIndex=7

[MeasureWxPrecip4]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcPrecip]
StringIndex=7

; ---- DAY 5 ----

[MeasureWxMd5]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcDate]
StringIndex=5
RegExpSubstitute=1
Substitute=#WxMonthDayMap#

[MeasureWxDow5]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcDayOfWeek]
StringIndex=5
RegExpSubstitute=1
Substitute=#WxDowMap#

[MeasureWxHigh5]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcMax]
StringIndex=5

[MeasureWxLow5]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcMin]
StringIndex=5

[MeasureWxIcon5]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcIcon]
StringIndex=9

;-------------------------
; LEGACY NAMES
; Enigma's original scheme: Day2 = today, Day3 = tomorrow.

[MeasureWeatherDay2Date]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcDayOfWeek]
StringIndex=1

[MeasureWeatherDay2Low]
Measure=Calc
Formula=Round(MeasureWxLow1)

[MeasureWeatherDay2High]
Measure=Calc
Formula=Round(MeasureWxHigh1)

[MeasureWeatherDay2Average]
Measure=Calc
Formula=Round((MeasureWeatherDay2Low+MeasureWeatherDay2High)/2)

[MeasureWeatherDay2Icon]
Measure=String
String=[MeasureWxIcon1]
DynamicVariables=1

[MeasureWeatherDay2Desc]
Measure=String
String=[MeasureWxIcon1]
DynamicVariables=1
RegExpSubstitute=1
Substitute=#WeatherDescMap#

[MeasureWeatherDay3Date]
Measure=Plugin
Plugin=WebParser
Url=[MeasureWxFcDayOfWeek]
StringIndex=2

[MeasureWeatherDay3Low]
Measure=Calc
Formula=Round(MeasureWxLow2)

[MeasureWeatherDay3High]
Measure=Calc
Formula=Round(MeasureWxHigh2)

[MeasureWeatherDay3Average]
Measure=Calc
Formula=Round((MeasureWeatherDay3Low+MeasureWeatherDay3High)/2)

[MeasureWeatherDay3Icon]
Measure=String
String=[MeasureWxIcon2]
DynamicVariables=1

[MeasureWeatherDay3Desc]
Measure=String
String=[MeasureWxIcon2]
DynamicVariables=1
RegExpSubstitute=1
Substitute=#WeatherDescMap#
