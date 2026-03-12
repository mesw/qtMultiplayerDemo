# Qt Multiplayer Demo

A minimal real-time multiplayer demo built with **Qt 6.8 WebAssembly** and **Cloudflare Durable Objects**.

Any connected user clicks a button — the counter increments for everyone instantly.

**[▶ Live Demo](https://mesw.github.io/qtMultiplayerDemo)** · **[Project Plan](PLAN.md)**

---

## How it works

```
Browser (Qt WASM)  ──WebSocket──▶  Cloudflare Worker
                                        │
                                   Durable Object
                                   (single global room)
                                        │
                   ◀──broadcast──  all connected clients
```

- The client is a **Qt Quick** app compiled to WebAssembly. It connects via WebSocket and sends `{ "type": "increment" }` when the button is clicked.
- The server is a **Cloudflare Durable Object** that holds the counter in persistent storage and broadcasts the new value to every connected client.
- Opening the demo in multiple tabs or on multiple devices shares the same counter in real time.

## Stack

| Part | Technology |
|------|------------|
| Client | Qt 6.8.3, Qt Quick, Qt WebSockets, WebAssembly (single-threaded) |
| Server | Cloudflare Workers, Durable Objects, WebSocket Hibernation API |
| Hosting | GitHub Pages (client), Cloudflare (server) |

## Repository structure

```
qtMultiplayerDemo/
├── client/                  Qt Quick application
│   ├── CMakeLists.txt
│   ├── main.cpp
│   ├── main.qml
│   ├── CounterClient.h/.cpp
│   └── build/
│       └── WebAssembly_Qt_6_8_3_single_threaded-Release/   ← served by GitHub Pages
├── server/                  Cloudflare Worker
│   ├── src/index.ts
│   ├── wrangler.toml
│   └── package.json
├── index.html               GitHub Pages entry point (redirects to WASM build)
└── PLAN.md                  Full project plan and progress log
```

## Running locally

**Server**
```bash
cd server
npm install
npx wrangler dev   # starts on ws://localhost:8787
```

**Client** — open `client/` in Qt Creator, switch to the Desktop kit and build. The desktop build points to `ws://localhost:8787` by default.

## Deploying

**Server**
```bash
cd server
npx wrangler deploy
```

**Client** — build the `WebAssembly_Qt_6_8_3_single_threaded-Release` target in Qt Creator, then commit the five output files (`*.html`, `*.js`, `*.wasm`, `qtloader.js`, `qtlogo.svg`) and push. GitHub Pages serves them automatically.
