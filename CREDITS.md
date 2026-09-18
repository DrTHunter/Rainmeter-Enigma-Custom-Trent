# Credits and licenses

This desktop stands almost entirely on other people's work. Thank you to all of them.

## Enigma — `Skins/Enigma`

**Enigma 4 Patch 1** by **Kaelri** (Michael Engard), with contributing authors **Smurfier** and
**dragonmage**, and concepts and feedback from Alex2539, Alex Becherer, FlyingHyrax,
Greg Schoppe, Jeffrey Morley, Jiri Mahel, kenz0, miniority and Zinsho. LuaCalendar is by
Smurfier. The full original credits are in [`Skins/Enigma/About.txt`](Skins/Enigma/About.txt).

License: **Creative Commons Attribution-NonCommercial-ShareAlike 3.0**
(<https://creativecommons.org/licenses/by-nc-sa/3.0/>).

Because Enigma is share-alike, the changes and additions made to it here are released under the
same license: the headline ticker (`Taskbar/Reader/Reader1/Reader1-Ticker.ini`, `Ticker.lua`),
the Setup panel and its gear (`Setup/`, `Taskbar/Setup/`), the greeting (`Greeting/`), and the
fixes listed in the README. Those parts are by **DrTHunter**.

Enigma's weather skins note in their own metadata that they were adapted from MoxaWeather.
The weather API keys inside them are the shared public keys those skins ship with, not
personal ones.

## Pomodoro — `Skins/Pomodoro`

Derived from **Eclectic Tech**'s Pomodoro timer, rebuilt on the Fokus session model.
License: **Creative Commons Attribution 4.0** (<https://creativecommons.org/licenses/by/4.0/>).

Two things the original bundles are deliberately **not** redistributed here:

- the Windows ring sounds — the skin plays the copy every Windows PC already has in
  `%WINDIR%\Media` instead;
- `Raintoaster.exe` by death.crafter, which publishes no license. Without it the timer's
  pop-up toast notifications are skipped; the alarm sounds still play. To get the toasts, put
  Raintoaster from <https://github.com/deathcrafter/Raintoaster> in
  `Skins/Pomodoro/@Resources/Raintoaster/`.

`@Resources/Sounds/alarm.wav` comes from DrTHunter's own Flowmodoro project.

## WebNowPlaying plugin — `Plugins/WebNowPlaying.dll`

© 2023 **keifufu** and **Trevor Hamilton** (tjhrulz), **MIT License** —
<https://github.com/keifufu/WebNowPlaying-Rainmeter>. It needs the matching browser extension,
<https://github.com/keifufu/WebNowPlaying>.

## Rainmeter

The desktop customization tool all of this runs on: <https://www.rainmeter.net/> (GPL v2).

## Installer and documentation

`install.ps1`, `install.cmd` and the README are by DrTHunter, released under the same
CC BY-NC-SA 3.0 terms as the rest of the repository.
