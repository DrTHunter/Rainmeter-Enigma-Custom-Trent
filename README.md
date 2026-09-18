# Rainmeter Enigma Custom (Trent)

A ready-to-install [Rainmeter](https://www.rainmeter.net/) desktop: top bar, two sidebars, live
news ticker, calendar, weather, drive gauges — set up from one panel, no file editing.

## Quick start

1. **Get Rainmeter** — download it from **[rainmeter.net](https://www.rainmeter.net/)** and install it.
2. **Get this desktop** — **[⬇ click here to download it (.zip)](https://github.com/DrTHunter/Rainmeter-Enigma-Custom-Trent/archive/refs/heads/main.zip)**, then right-click the file → **Extract All…**
3. **Install it** — open the extracted folder and double-click **`install.cmd`**.

**Done.** Click the **gear (⚙)** in the new top bar to put in your name, location and calendars.

[![Download the latest version (zip)](https://img.shields.io/badge/Download-latest%20version%20(.zip)-ff0099?style=for-the-badge&logo=github)](https://github.com/DrTHunter/Rainmeter-Enigma-Custom-Trent/archive/refs/heads/main.zip)

> Extract the zip somewhere permanent (like `Documents`), not `Downloads` — the desktop runs
> from that folder. If Windows SmartScreen appears, choose *More info → Run anyway*.
>
> Stuck? Email **[dr_hunter@yahoo.com](mailto:dr_hunter@yahoo.com?subject=Rainmeter%20Enigma%20Custom%20-%20question)** — see [Need help?](#need-help).

---

## What you get

- **Top bar** — sunrise / sunset, moon phase, your next calendar event, a scrolling **LIVE FEED**
  news ticker, Google search, three drive gauges, CPU, RAM, battery, a settings gear and a
  sidebar toggle.
- **Left sidebar** — weather with a four-day forecast, now-playing, CPU / RAM / drive / power,
  network graphs in Mbps, top processes.
- **Right sidebar** — clock, month calendar with event markers, Google Calendar agenda, notes,
  a five-feed news reader, volume.
- **Extras** — a Pomodoro timer and a time-of-day greeting, both hidden by the sidebar toggle.

Built on Kaelri's **Enigma** suite, reworked for current Windows and current web services.
You need **Windows 10 or 11**; the layout was arranged on a 1920×1080 screen.

## Installation details

**What `install.cmd` does:**

1. installs Rainmeter with `winget` if it isn't there yet (so Quick start step 1 is optional on
   a current Windows 10/11),
2. closes Rainmeter,
3. backs up your existing `Rainmeter.ini` (as `Rainmeter.ini.before-install-<date>`),
4. installs the config, the layout and the one plugin into `%APPDATA%\Rainmeter`, pointing
   Rainmeter's skins folder at the folder you extracted,
5. starts Rainmeter again.

Nothing else on the PC is changed, and the last thing it prints is how to undo it. If you
already use Rainmeter, note that step 4 switches Rainmeter to *this* skins folder — your old
skins are not deleted, and restoring the backup brings them back.

**Prefer the command line?** This downloads the repo to
`Documents\Rainmeter-Enigma-Custom-Trent` and installs it in one go:

```powershell
irm https://raw.githubusercontent.com/DrTHunter/Rainmeter-Enigma-Custom-Trent/main/install.ps1 | iex
```

`git clone` works too — run `install.cmd` inside the clone.

## Make it yours

Click the **gear (⚙)** in the top bar. That opens **Enigma Setup**, one panel for:

- **You** — the name the desktop greeting uses.
- **Weather** — location name, latitude, longitude, Fahrenheit or Celsius. Right-click a spot
  in Google Maps to copy its coordinates.
- **Google Calendar** — up to eight *secret iCal addresses* (Google Calendar → Settings → pick
  a calendar → *Integrate calendar* → *Secret address in iCal format*). Shown masked once saved.
- **News feeds** — five RSS/Atom addresses; Feed 1 also drives the LIVE FEED ticker.
- **Drives** — the letters the drive gauges watch.

Click a value, type, press **Enter**. Right-click a calendar or feed to clear it. Changes are
saved to `Skins\Enigma\@Resources\User\Options.inc` and applied immediately. Until you do this
you get New York weather, empty calendars and a greeting for "Friend".

On a screen that isn't 1920×1080, drag the widgets where you want them, then right-click the
Rainmeter tray icon → **Manage → Layouts** and save your own layout.

> **Your calendar addresses are secrets.** Anyone holding one can read that calendar. If you
> fork this repo, never commit your own `Options.inc`. When you install from a git clone, the
> installer marks the personal files `skip-worktree` so git ignores your edits to them.

## Good to know

- **Music widget** needs the [WebNowPlaying](https://github.com/keifufu/WebNowPlaying-Redux)
  browser extension; without it the player stays blank.
- The sidebar **toggle** (top-right) hides the sidebars, the Pomodoro timer and the greeting.
- Drive gauges read `464 G` below a terabyte and `1.82 T` above it; network speeds are in bits
  per second, like a speed test.
- Hover the news ticker to pause it; click a headline to open it.
- The Pomodoro timer plays its alarms but shows no pop-up toasts unless you add Raintoaster
  yourself — see [CREDITS.md](CREDITS.md) for why and how.
- Right-click any widget → **Variants** to switch its style (icon only, text only, mini…).

## Updating

Re-run the one-step command, or `git pull` in the folder and run `install.cmd` again. Your own
`Options.inc` is yours: if git ever reports a conflict on it, keep your version.

## Uninstalling

Exit Rainmeter, copy the `Rainmeter.ini.before-install-<date>` backup in `%APPDATA%\Rainmeter`
back over `Rainmeter.ini` (or delete `Rainmeter.ini` for a factory default), and delete this
folder. Remove Rainmeter itself from *Settings → Apps* if you no longer want it.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| Music widget says "Unable to load plugin" | Run `install.cmd` again — it copies `Plugins\WebNowPlaying.dll` to `%APPDATA%\Rainmeter\Plugins`. |
| No skins at all after installing | This folder was moved or deleted. Put it back, or run `install.cmd` from its new location. |
| Calendar or weather is empty | Fill it in through the gear (⚙) → Enigma Setup. |
| A drive gauge says "Removed" | That drive letter doesn't exist on your PC — change it in Enigma Setup. |
| Windows SmartScreen blocks `install.cmd` | *More info → Run anyway*. Administrator rights are not needed. |

## Need help?

Technical questions about installing or customising this setup: email **[dr_hunter@yahoo.com](mailto:dr_hunter@yahoo.com?subject=Rainmeter%20Enigma%20Custom%20-%20question)**.
It helps to include your Windows version, your screen resolution, what you clicked, and what
happened instead — a screenshot is ideal.

Found a bug or want a feature? Open an
[issue](https://github.com/DrTHunter/Rainmeter-Enigma-Custom-Trent/issues) so others can find the answer too.

## What's changed from stock Enigma

- A scrolling headline ticker (`Taskbar\Reader\Reader1\Reader1-Ticker.ini`) in place of the
  long-dead Facebook notifications widget.
- The Setup panel and its gear (`Setup\`, `Taskbar\Setup\`); `Setup.ini` is generated by
  `Setup\make-setup.ps1` — add a row to the table at the top and re-run it.
- Five reader tabs instead of three; network speeds in bits on the adapter that carries your
  internet traffic; drive gauges that switch between GB and TB and pack tightly.
- Fixes: a missing `Notes.txt` no longer crashes Rainmeter; calendar event markers and other
  mangled characters restored; double-clicking a top-bar widget no longer silently switches
  its variant (re-enable it in `@Resources\Styles\<stylesheet>\TaskbarCommon.inc`).

## Credits and license

See [CREDITS.md](CREDITS.md). In short: Enigma is by **Kaelri** and contributors and is
licensed **CC BY-NC-SA 3.0**, so this repository as a whole is shared under the same terms —
use it, change it, share it, credit the authors, not for commercial use. The Pomodoro timer is
derived from Eclectic Tech's (CC BY 4.0) and the WebNowPlaying plugin is MIT.

If you found this valuable feel free to buy me a coffee: [$TrentHun on Cash App](https://cash.app/$TrentHun).
