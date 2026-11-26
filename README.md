# a notebook for you

A small scrapbook-style web page for two people: a shared notebook with a playlist, a diary, photos, a map and a few interactive surprises. Blue-and-white porcelain colours, washi tape, polaroids, piano sounds.

Plain HTML, CSS and JavaScript in one `index.html`, hosted on GitHub Pages. Shared data lives in Supabase.

## Features

| | |
|---|---|
| 🔒 Lock screen | a question to answer before the notebook opens, with hints |
| 💿 Playlist | vinyl player, Spotify / YouTube embeds, "listen together" in real time |
| 🐰 Study break | random cheers, a 5-minute break timer, a bunny to pat |
| 📝 Shared diary | sticky notes, one colour per person |
| 🌱 Lately | a timeline of what each person has been up to |
| 📷 Photos | polaroid wall with captions |
| 🗺️ Places | map with pins and photos for places visited |
| 🎮 Game | game ID card with a one-tap "copy & invite" button |
| ✏️ Notes to self | a short list of things to do better |
| ✉️ Letter | an envelope that opens |
| 🎵 Memories | each line plays a piano note as you scroll |
| 💫 Quick facts | two small profile cards |
| 💘 Biu | a scroll-triggered animation |
| 🌹 Question | a yes / no question where "no" runs away |

Every section can be added to, edited (✎) and deleted (×) right on the page, and changes show up for both people instantly.

## Run locally

```bash
python3 -m http.server 5178
```

Then open `http://localhost:5178`.

## Setup

1. **Supabase**: create a free project, open **SQL Editor**, paste [`supabase/setup.sql`](supabase/setup.sql) and run it (safe to re-run). Copy the Project URL and the publishable / anon key into `CONFIG.supabase` in `index.html`. Without Supabase the page still works, but data stays in each browser.
2. **Phone notifications (optional)**: set `CONFIG.ntfyTopic` to a long random name and subscribe to it in the [ntfy](https://ntfy.sh) app.
3. **Content**: edit the `CONFIG` object at the top of the script, or just use the ✎ buttons on the page.

The publishable key is meant to be public; access is controlled by the row-level security rules in `setup.sql`. Never put a secret / service-role key in the page.

## Notes

- The lock screen is a playful gate, not real security: the site is static. Only a hash of the answer is stored.
- Images in `images/` are only used for this page.
