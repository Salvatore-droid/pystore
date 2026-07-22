# Deploying the PyStore install page 📦

This folder is a complete, self-contained static site. Everything the install
command needs lives right here next to `index.html`.

## What's inside
- `index.html` — the landing page with the copy-paste install command
- `install.sh` — the script that command runs
- `pystore.tar.gz` — the packaged app itself

## Deploy it (pick any one)

**GitHub Pages**
1. Push this folder's contents to a repo (or a `docs/` folder on `main`)
2. Repo Settings → Pages → set source to that folder
3. Done — your URL is `https://<you>.github.io/<repo>/`

**Netlify / Vercel**
1. Drag this folder into Netlify's "deploy manually" box (or `vercel deploy`)
2. Done — you get a URL immediately

**Your own server (nginx, Apache, etc.)**
1. Copy all 3 files into any directory nginx/Apache serves as static files
2. Done

## Important: keep all 3 files together, in the same folder
The page reads its own URL in the browser to build the install command, so as
long as `index.html`, `install.sh`, and `pystore.tar.gz` sit next to each other
at whatever URL you deploy to, everything just works — no editing required.

## Updating PyStore later
Whenever you change PyStore, just rebuild `pystore.tar.gz` from the project
folder and re-upload it (same filename). Anyone who runs the install command
after that gets the new version. Machines that already installed it aren't
automatically updated — this installs a snapshot, it doesn't set up
auto-updates.
