<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset=".github/assets/logo-dark.png">
  <source media="(prefers-color-scheme: light)" srcset=".github/assets/logo-light.png">
  <img alt="Doska" src=".github/assets/logo-light.png" width="180">
</picture>
<p></p>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset=".github/assets/tagline-dark.png">
  <source media="(prefers-color-scheme: light)" srcset=".github/assets/tagline-light.png">
  <img alt="Open source · self-hosted · Kanban board · Markdown cards" src=".github/assets/tagline-light.png" width="460">
</picture>
<p></p>

<p align="center">
  <a href="https://github.com/romenkova/doska/releases/latest"><img alt="Release" src="https://img.shields.io/github/v/release/romenkova/doska?color=9585ff&label=release"></a>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/github/license/romenkova/doska?color=7b8199"></a>
</p>
<p></p>

<p align="center">
  <strong><a href="https://app.doska.sh/d/welcome">Open demo</a></strong> ·
  <a href="https://doska.sh/docs">Documentation</a> ·
  <a href="https://github.com/romenkova/doska/releases/latest">Download the app</a>
</p>

![A Doska board with a card open in the editor](.github/assets/board-demo-dark-5.png)

</div>

## Why

I wanted a kanban app that is quick, Markdown-first, minimal, and still feature-rich. I couldn't find all of that in one app, so I made Doska.

Doska keeps everything in IndexedDB first, because it's fast and persistent. Then it syncs to a destination of your choice, a folder or a server, shortly after every change.

When the destination is a server, you also get multiple users with live updates, public boards, SSO, and MCP.

Doska never makes you wait on the server, doesn't keep features behind a paywall, and aims to have everything necessary without looking bloated.

## Features

- [x] **Offline-first**, local-first
- [x] **Markdown editor**: syntax highlighting, tasks with a counter, slash menu
- [x] Server to **sync** boards across devices
- [x] **Accounts:** members, shared boards, public boards
- [x] **Local folder sync:** boards and columns as folders, cards as Markdown files
- [x] **Attachments:** files, images
- [x] **SSO:** OIDC-compatible auth provider
- [x] **Deadlines, priorities** and sorting for cards on the board
- [x] **MCP** server
- [x] Cross-board deadlines view
- [x] **Quick note window** (beta): always on top, opened with a keyboard shortcut
- [ ] Activity/history view
- [ ] User mentions with `@`
- [ ] Tags

## Apps

- **Web**: PWA, mobile-friendly layout.
- **macOS**: universal build, signed and notarized.
- **Windows** (beta): NSIS installer, unsigned. See [desktop docs](https://doska.sh/docs/desktop).
- **Linux** (beta): AppImage, deb and rpm.

## Self-hosting guide

The easiest way to self-host is to use the script:

```sh
curl -fsSL https://raw.githubusercontent.com/romenkova/doska/main/install.sh -o install.sh && sh install.sh
```

For manual setup:

1. Copy [docker-compose.selfhost.yml](docker-compose.selfhost.yml)
2. Copy [.env.selfhost.example](.env.selfhost.example) to `.env` next to it
3. Fill in `AUTH_LOGIN`, `AUTH_PASSWORD`, `AUTH_SECRET` and `BASE_URL`
4. Run `docker compose -f docker-compose.selfhost.yml up -d`

Then open `http://<your-host>:8080` and sign in with the credentials you gave it.

Environment variables, HTTPS, attachments and
backups: [doska.sh/docs/self-hosting](https://doska.sh/docs/self-hosting).

What the compose file contains:

- Sync server
- Web interface server
- Database: pass a database URL, or the bundled Postgres is used.
- File storage: pass S3 credentials, or files are stored on the server.

### Local macOS deployment

With dependencies installed and `apps/server/.env` configured, run `mise deploy`
from this checkout. This builds and copies the desktop executable to `bin/`, then
installs `com.kenbanks.doska.plist` into `~/Library/LaunchAgents/` and restarts the
server for the current logged-in user (no `sudo`). The agent starts at login and
restarts if the server exits.

Deployment fills in absolute paths to this checkout and the current Node runtime.
Keep the checkout and its dependencies in place; deploy again after moving it or
changing Node versions. The agent uses the same entry point and `.env` file as
`mise server`; it does not start a separate database or inherit your shell's
environment variables. Configure any required database in `apps/server/.env`.

Logs are in `~/Library/Logs/doska/server.log` and `server.error.log`. To inspect or
stop the agent:

```sh
launchctl print "gui/$(id -u)/com.kenbanks.doska"
launchctl bootout "gui/$(id -u)/com.kenbanks.doska"
```

To uninstall it, stop it first and remove
`~/Library/LaunchAgents/com.kenbanks.doska.plist`.

## Updating

The same script updates an existing install, and the useful part is that it takes a backup first.

```sh
curl -fsSL https://raw.githubusercontent.com/romenkova/doska/main/install.sh -o install.sh && sh install.sh
```

Or, for a manual update, back up your instance and then rerun compose.

The desktop app follows whatever version its server runs, so update the server
first. The app's settings modal then has a button to check for updates and
install them.

## MCP

The server exposes your boards to an MCP client at `/mcp`:

```sh
claude mcp add --transport http doska https://your-server/mcp
```

Tools are listed in [packages/mcp/README.md](packages/mcp/README.md); setup is at
[doska.sh/docs/mcp](https://doska.sh/docs/mcp).

## Development

```sh
pnpm install
pnpm dev        # web client + server, in watch mode
pnpm desktop    # native desktop shell (Tauri)
```

Requirements, the full command list and the repository layout:
[doska.sh/docs/development](https://doska.sh/docs/development).

## License

MIT, see [LICENSE](LICENSE).
