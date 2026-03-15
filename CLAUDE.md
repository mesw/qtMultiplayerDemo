# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Minimal real-time multiplayer demo: a shared counter that syncs instantly across all connected clients. Live demo at https://mesw.github.io/qtMultiplayerDemo.

**Stack:**
- **Client:** Qt 6.8.3, Qt Quick, Qt WebSockets — builds for Desktop (native) and WebAssembly (single-threaded)
- **Server:** Cloudflare Workers + Durable Objects with WebSocket Hibernation API

## Build & Run

### Server (Node.js / Cloudflare Workers)
```bash
cd server
npm install
npx wrangler dev        # starts local server at ws://localhost:8787
npx wrangler deploy     # deploy to Cloudflare
```

### Client (Qt)
Open `client/` in Qt Creator. Two build targets:
- **Desktop kit** — connects to `ws://localhost:8787` (for local dev against `wrangler dev`)
- **WebAssembly_Qt_6_8_3_single_threaded** — connects to `wss://qt-multiplayer-demo.mesw.workers.dev`

No CLI build commands — Qt Creator handles CMake configuration.

### Deploy WASM Client
Build the WASM Release target in Qt Creator, then commit only these 5 files from `client/build/WebAssembly_Qt_6_8_3_single_threaded-Release/`:
- `QtMultiplayerClient.html`, `.js`, `.wasm`
- `qtloader.js`, `qtlogo.svg`

GitHub Pages serves the root `index.html` which redirects to the WASM build.

## Architecture

```
Qt Client (Desktop or WASM)
  CounterClient (C++ QWebSocket wrapper)  ←→  WebSocket  ←→  Cloudflare Worker
  main.qml (Qt Quick UI)                                        CounterRoom (Durable Object)
```

**Message protocol (JSON over WebSocket):**
- Client → Server: `{ "type": "increment" }`
- Server → All Clients: `{ "type": "counter", "value": 42 }`
- On connect: server immediately sends current counter value

**Server state** lives in a single global Durable Object (`idFromName("global")`), persisted in DO storage — survives worker restarts.

**Client auto-reconnects** every 3 seconds on disconnect (`CounterClient.cpp`).

**Desktop vs WASM conditional:** `main.cpp` checks `#ifdef DESKTOP_BUILD` (set in CMakeLists.txt) to choose the server URL injected into QML context as `defaultServerUrl`.

## Key Files

| File | Purpose |
|------|---------|
| `client/CounterClient.h/.cpp` | C++ WebSocket wrapper; exposes `counter`, `connected`, `serverUrl` properties and `increment()` to QML |
| `client/main.qml` | Full UI — status label, counter display, increment button |
| `client/main.cpp` | App setup; injects `defaultServerUrl` into QML context |
| `client/CMakeLists.txt` | Qt 6.8 build config; WASM heap=32MB, no pthreads |
| `server/src/index.ts` | Durable Object (`CounterRoom`) + Worker entry point |
| `server/wrangler.toml` | Worker name, DO binding (`COUNTER_ROOM`), SQLite migration |
