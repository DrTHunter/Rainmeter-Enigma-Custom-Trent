;---------------------------------------------------------------------
; MEASURES: WEBNOWPLAYING
; Spotify support via the WebNowPlaying plugin + Spicetify's
; webnowplaying.js extension. Measure names are unchanged, so all
; Music skin variants work without modification.

[MeasureMediaPlayer]
Measure=Plugin
Plugin=WebNowPlaying
PlayerType=Status

[MeasureTrack]
Measure=Plugin
Plugin=WebNowPlaying
PlayerType=Title

[MeasureAlbum]
Measure=Plugin
Plugin=WebNowPlaying
PlayerType=Album

[MeasureArtist]
Measure=Plugin
Plugin=WebNowPlaying
PlayerType=Artist

[MeasureCover]
Measure=Plugin
Plugin=WebNowPlaying
PlayerType=Cover

[MeasureTimeDuration]
Measure=Plugin
Plugin=WebNowPlaying
PlayerType=Duration

[MeasureTimePosition]
Measure=Plugin
Plugin=WebNowPlaying
PlayerType=Position

[MeasureTimeProgress]
Measure=Plugin
Plugin=WebNowPlaying
PlayerType=Progress

[MeasureState]
Measure=Plugin
Plugin=WebNowPlaying
PlayerType=State

[MeasureRepeatRaw]
Measure=Plugin
Plugin=WebNowPlaying
PlayerType=Repeat

; WebNowPlaying reports three repeat modes; the button styles only
; index 0/1, so clamp any active mode to 1.
[MeasureRepeat]
Measure=Calc
Formula=MeasureRepeatRaw > 0 ? 1 : 0

[MeasureShuffle]
Measure=Plugin
Plugin=WebNowPlaying
PlayerType=Shuffle
