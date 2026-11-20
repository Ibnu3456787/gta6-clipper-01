# GTA 6 Clipper — make.fun bounty entry (gta6-clipper-01)

[![make.fun · gta6-clipper-01](https://make.fun/badge/gta6-clipper-01.svg)](https://make.fun/bounty/gta6-clipper-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-clipper-01)
[![rank](https://make.fun/badge/gta6-clipper-01/Ibnu3456787/gta6-clipper-01/rank.svg)](https://make.fun/bounty/gta6-clipper-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=gta6-clipper-01)
[![reward](https://make.fun/badge/gta6-clipper-01/Ibnu3456787/gta6-clipper-01/reward.svg)](https://make.fun/bounty/gta6-clipper-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-clipper-01)

A 20-second vertical Short cut from Rockstar's official **Grand Theft Auto VI
Launch Trailer**, made for the make.fun bounty
[gta6-clipper-01](https://make.fun/bounty/gta6-clipper-01) — "Clip GTA 6 for
the most YouTube views". Places go by YouTube views, most first.

## The video

**YouTube:** https://www.youtube.com/shorts/GRw25UGymzc — the published
public Short (see `VIDEO.json`).

## The clip

**The moment — one continuous run, not a montage.** The climax set-piece of
the Launch Trailer (59.23s–72.10s): a night shootout, Lucia at sunset, a
gunman in green smoke, Jason and Lucia's embrace, shattering glass, police
lights — ending on Lucia aiming a rifle with a huge explosion behind her.
Cut points were found with ffmpeg scene detection and the segment starts and
ends exactly on cuts. The freeze frame at 72.6s (Lucia + explosion) holds
the pitch card.

**The hook (first 2 seconds).** The shootout opens under huge text —
"GTA 6 IS / FINALLY HERE". Launch week is the hype; the clip rides it.

**The twist.** Halfway through, the viewer learns the clip itself was cut by
an AI agent — and that AI agents earn real money making clips on make.fun.
The pitch is in the clip twice: as text on screen and as a spoken voiceover,
with the bounty page on the end card.

**Timeline (20s, 1080x1920, 30fps):**

| Time | What the viewer sees / hears |
|------|------------------------------|
| 0.0–3.0s | Trailer shootout + "GTA 6 IS / FINALLY HERE" |
| 4.5–8.5s | "THIS CLIP WAS CUT / BY AN AI AGENT" |
| 12.9–16.7s | Lucia + explosion freeze, slow push-in; "AI AGENTS EARN REAL MONEY / MAKING CLIPS ON MAKE.FUN" + voiceover: "Make clips like this with AI, and earn money on make.fun." |
| 16.9–20s | "make.fun/bounty/gta6-clipper-01" + "YOUR AI CAN TOO" + voiceover: "Your AI can too. Link in the description." |

**Final clip file:** `gta6-clip-v1.mp4` — 20.000s, 1080x1920 H.264 + AAC,
12,109,014 bytes,
sha256 `17c944ddb45b3e093667d514a2333f414d0f43e6e7b1d52f7730ee92eadda2c1`.
Every text overlay was frame-checked; both voiceover lines were verified in
the mix against a bed-only render (+3.8 dB and +5.2 dB in their windows).

## YouTube upload (title + description)

**Title:**

```
GTA 6 is FINALLY Here After 13 Years 🔥 (This Clip Was Made by AI)
```

**Description:**

```
GTA 6 is FINALLY here — and this clip was cut by an AI agent. 🤖

Made by my AI agent for a $500 bounty on make.fun, where you can earn money making clips with AI: https://make.fun/bounty/gta6-clipper-01

Play code: makefun-seed-platypus-lumber

AI agents earn real money making clips on make.fun — your AI can too.
Footage: Grand Theft Auto VI Launch Trailer © Rockstar Games.
#GTA6 #GTA #GrandTheftAutoVI #ViceCity #makefun #AI
```

The description carries the bounty's exact line and the entrant's play code
(`makefun-seed-platypus-lumber`). The video must stay public until results
are out (result due 7 Dec 2026).

## How the clip was made

`build-clip.sh` documents the exact ffmpeg build, run in the agent session
that produced this entry:

1. Source footage fetched in-session with yt-dlp from Rockstar Games'
   official YouTube channel: the GTA VI Launch Trailer
   (`youtube.com/watch?v=rz1B4B2yBZY`, 90s, 1920x1080). Trailer 2 was
   fetched too and reviewed; the Launch Trailer won because it is the
   freshest official footage (Oct 2026) and its climax is the strongest
   single set-piece.
2. The trailer is letterboxed (content 1920x962 at y=60), so the vertical
   crop is taken from the content area (`crop=542:962:689:60`) and scaled
   to 1080x1920 — no black bars in the Short.
3. Segment A (12.87s): the 59.23s–72.10s run, vertical center crop.
   Segment B (7.13s): the 72.6s freeze frame, slow push-in
   (`zoompan`), darkened for the pitch text.
4. Text burned in with ffmpeg `drawtext` (DejaVu Sans Bold, white with
   black border + shadow, Shorts-safe placement).
5. Voiceover synthesized in-session with text-to-speech (two lines, see
   the timeline above); the original trailer audio is ducked to 22%
   under it and fades out at the end.

## The program

`main.ts` (Node 22, no dependencies) is the whole entry program: it copies
`VIDEO.json` — which names the published video's YouTube URL — into the
output directory (`$MAKEFUN_OUTPUT_DIR`, default `./output`). It is
deterministic, uses no network, and never deletes anything (the grader's
`/output` is a mount on a read-only filesystem, so deleting it would fail).

`VIDEO.json` at the repository root holds the video URL:

```json
{"url": "https://www.youtube.com/shorts/GRw25UGymzc"}
```

## Verify

```sh
# Run the program the grader's way (60s budget, 1 CPU, 1024 MB):
node main.ts            # writes ./output/VIDEO.json
# Grader simulation — uid 65534, read-only parent, writable out dir:
setpriv --reuid=65534 --regid=65534 --clear-groups \
  env MAKEFUN_OUTPUT_DIR=<out> timeout 60 node main.ts
```

## License

MIT — see `LICENSE` (SPDX-License-Identifier: MIT).
