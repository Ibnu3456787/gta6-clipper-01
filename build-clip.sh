#!/usr/bin/env bash
# gta6-clipper-01 — build the vertical Short from Rockstar's official GTA VI Launch Trailer.
#
# SOURCE (fetched in-session with yt-dlp, official Rockstar Games YouTube):
#   launch-trailer.mp4 — GTA VI Launch Trailer, youtube.com/watch?v=rz1B4B2yBZY
#   The trailer is letterboxed (content 1920x962 at y=60), so the vertical crop
#   is taken from the content area: crop=542:962:689:60, then scaled 1080x1920.
#
# THE MOMENT (one continuous run, 59.23s-72.10s of the trailer, 12.87s):
#   night shootout -> Lucia at sunset -> green-smoke gunman -> Jason & Lucia
#   embrace -> glass shatter -> police night. Clean cuts found with ffmpeg
#   scene detection (threshold 0.35); segment starts/ends exactly on cuts.
# THE PITCH CARD (12.87s-20s, 7.13s): freeze frame at 72.6s — Lucia aiming a
#   rifle with a huge explosion behind her — slow push-in, darkened, with the
#   make.fun pitch as text on screen AND a spoken voiceover (TTS, in-session).
#
# TIMELINE (20s total, 1080x1920, 30fps, H.264 + AAC):
#   0.0-3.0s    "GTA 6 IS / FINALLY HERE" (hook)
#   4.5-8.5s    "THIS CLIP WAS CUT / BY AN AI AGENT" (the twist)
#   12.87-16.7s "AI AGENTS EARN REAL MONEY / MAKING CLIPS ON MAKE.FUN"
#               + voiceover: "Make clips like this with AI, and earn money on make.fun."
#   16.9-20s    "make.fun/bounty/gta6-clipper-01" + "YOUR AI CAN TOO"
#               + voiceover: "Your AI can too. Link in the description."
# Audio: original trailer audio, ducked to 22% under the voiceover, faded out.
set -euo pipefail

DIR="$HOME/workspace/makefun/gta6-clipper-01"
F="$DIR/footage"
VO="$DIR/vo"
OUT="$DIR/gta6-clip-v1.mp4"
FONT="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
CROP="crop=542:962:689:60,scale=1080:1920:flags=lanczos"

# --- Segment A: 12.87s of trailer action, vertical center crop ----------------
ffmpeg -y -v error -ss 59.23 -i "$F/launch-trailer.mp4" -t 12.87 \
  -vf "$CROP,fps=30,format=yuv420p" \
  -c:v libx264 -preset medium -crf 18 -an "$DIR/segA.mp4"

# --- Segment B: freeze frame, slow push-in, darkened for the pitch text ------
ffmpeg -y -v error -loop 1 -framerate 30 -i "$F/freeze-72.6.png" \
  -vf "$CROP,zoompan=z='min(1+0.00045*on,1.10)':d=1:s=1080x1920:fps=30,eq=brightness=-0.10:saturation=0.92,format=yuv420p" \
  -t 7.13 -c:v libx264 -preset medium -crf 18 -an "$DIR/segB.mp4"

# --- Text overlays: multi-line text MUST come from files -----------------------
# drawtext's text='...' swallows the backslash, so 'A\nB' renders literally as
# "AnB" on one line (v1 bug: "GTA 6 ISnFINALLY HERE", overflowing the frame).
# textfile= with real newlines is the robust route. No trailing newline.
printf 'GTA 6 IS\nFINALLY HERE' > "$DIR/text-hook.txt"
printf 'THIS CLIP WAS CUT\nBY AN AI AGENT' > "$DIR/text-reveal.txt"
printf 'AI AGENTS EARN REAL MONEY\nMAKING CLIPS ON MAKE.FUN' > "$DIR/text-pitch.txt"

# --- Concat + burned-in text --------------------------------------------------
ffmpeg -y -v error -i "$DIR/segA.mp4" -i "$DIR/segB.mp4" -filter_complex \
"[0:v][1:v]concat=n=2:v=1:a=0,\
drawtext=fontfile=$FONT:textfile=$DIR/text-hook.txt:fontsize=92:fontcolor=white:borderw=4:bordercolor=black:shadowcolor=black:shadowx=3:shadowy=3:x=(w-text_w)/2:y=h*0.14:enable='between(t,0,3)',\
drawtext=fontfile=$FONT:textfile=$DIR/text-reveal.txt:fontsize=66:fontcolor=white:borderw=4:bordercolor=black:shadowcolor=black:shadowx=3:shadowy=3:x=(w-text_w)/2:y=h*0.14:enable='between(t,4.5,8.5)',\
drawtext=fontfile=$FONT:textfile=$DIR/text-pitch.txt:fontsize=58:fontcolor=white:borderw=4:bordercolor=black:shadowcolor=black:shadowx=3:shadowy=3:x=(w-text_w)/2:y=h*0.30:enable='between(t,12.87,16.7)',\
drawtext=fontfile=$FONT:text='make.fun/bounty/gta6-clipper-01':fontsize=46:fontcolor=0xFFDD55:borderw=4:bordercolor=black:shadowcolor=black:shadowx=3:shadowy=3:x=(w-text_w)/2:y=h*0.42:enable='between(t,16.9,20)',\
drawtext=fontfile=$FONT:text='YOUR AI CAN TOO':fontsize=80:fontcolor=white:borderw=4:bordercolor=black:shadowcolor=black:shadowx=3:shadowy=3:x=(w-text_w)/2:y=h*0.56:enable='between(t,16.9,20)'[v]" \
  -map "[v]" -c:v libx264 -preset medium -crf 18 -an "$DIR/clip-video.mp4"

# --- Audio: trailer bed ducked under the voiceover -----------------------------
# NOTE: the ducking volume expression uses t, so the volume filter MUST run
# with eval=frame — with the default eval=once, t is NaN at init and ffmpeg
# fails with "Invalid value NaN for volume" (hit on the first build run).
# NOTE 2: -t 20 MUST sit before the trailer -i (input option). Placed after
# the first -i it binds to the NEXT input (vo1.mp3) and the bed runs to the
# end of the trailer (30.82s) — the second build's audio came out 30.8s.
ffmpeg -y -v error -ss 59.23 -t 20 -i "$F/launch-trailer.mp4" \
  -i "$VO/vo1.mp3" -i "$VO/vo2.mp3" -filter_complex \
"[0:a]volume=eval=frame:volume='1-0.78*clip((t-12.87)/1.1,0,1)',afade=t=out:st=19:d=1[bed];\
[1:a]adelay=13000:all=1[vo1];[2:a]adelay=16900:all=1[vo2];\
[bed][vo1][vo2]amix=inputs=3:duration=first:normalize=0,alimiter=limit=0.95[a]" \
  -map "[a]" -c:a aac -b:a 160k "$DIR/clip-audio.m4a"

# --- Mux -----------------------------------------------------------------------
ffmpeg -y -v error -i "$DIR/clip-video.mp4" -i "$DIR/clip-audio.m4a" -c copy "$OUT"
ffprobe -v error -show_entries format=duration,size -show_entries stream=codec_type,width,height -of default=noprint_wrappers=1 "$OUT"
echo "BUILT: $OUT"
