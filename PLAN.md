# Qt Multiplayer Demo — Project Plan

## Goal
A minimal multiplayer demo: one shared counter. Any connected user clicks a button → counter increments for all users in real time.

## Architecture

```
qtMultiplayerDemo/
├── server/          ← Cloudflare Worker + Durable Object (TypeScript)
│   ├── src/index.ts
│   ├── wrangler.toml
│   └── package.json
└── client/          ← Qt Quick + WebAssembly (C++/QML)
    ├── CMakeLists.txt
    ├── main.cpp
    ├── main.qml
    └── CounterClient.h / .cpp
```

### Communication Protocol (WebSocket, JSON)
| Direction | Message |
|-----------|---------|
| Client → Server | `{ "type": "increment" }` |
| Server → All clients | `{ "type": "counter", "value": 42 }` |
| Server → New client (on connect) | `{ "type": "counter", "value": 42 }` |

## Key Decisions
| Decision | Choice | Reason |
|----------|--------|--------|
| Server framework | Raw Durable Objects (no PartyKit) | Fewer deps, minimal footprint |
| Counter persistence | DO storage | Survives DO restarts |
| Room model | Single global room | Simplest for a demo |
| Qt WebSocket | C++ QWebSocket exposed to QML | Better control, easier to extend |
| Build targets | Native desktop + WASM | Desktop for fast iteration, WASM for release |
| wrangler format | TOML | Conventional, readable |

## Resolved
- Qt 6.8.3 single-threaded WASM — builds and runs correctly
- Wrangler v4.72.0

---

## Tasks

### Phase 1 — Server

- [x] **1.1** `server/wrangler.toml` — worker name, DO binding, migration
- [x] **1.2** `server/package.json` — wrangler dev/deploy scripts
- [x] **1.3** `server/src/index.ts` — Durable Object with:
  - WebSocket hibernation API (`ctx.acceptWebSocket`)
  - Counter persisted in DO storage
  - Broadcast helper (send current value to all connections)
  - Handle `increment` message → update + broadcast
  - Send current counter on new connection

### Phase 2 — Client Build System

- [x] **2.1** `client/CMakeLists.txt` for Qt 6.8.3:
  - `qt_add_executable` with WASM finalization
  - Link `Qt6::Quick`, `Qt6::WebSockets`
  - `qt_add_qml_module` for QML resources
  - Conditional WASM-specific flags
  - Native desktop build for iteration

### Phase 3 — Client Application

- [x] **3.1** `client/CounterClient.h` / `CounterClient.cpp`
  - Wraps `QWebSocket`
  - `Q_PROPERTY int counter`
  - `Q_PROPERTY bool connected`
  - `Q_INVOKABLE void increment()`
  - Reconnect logic
- [x] **3.2** `client/main.cpp` — QGuiApplication, QQmlEngine, register CounterClient
- [x] **3.3** `client/main.qml` — UI: connection status, counter display, increment button

### Phase 4 — Integration & Testing

- [ ] **4.1** Run server locally with `wrangler dev` *(skipped — went straight to Cloudflare deploy)*
- [x] **4.2** Run client as native desktop build, connect to live server
- [x] **4.3** Open two client windows, verify counter syncs — confirmed working
- [x] **4.4** Build client as WASM, full local test — confirmed working
- [x] **4.6** `index.html` + `.nojekyll` at repo root for GitHub Pages — redirects to WASM build output in place
- [x] **4.5** Deploy server to Cloudflare, test WASM client against live server
  - Live URL: `wss://qt-multiplayer-demo.mesw.workers.dev`
  - Client `main.cpp` updated with production URL

---

## Progress Log
| Date | Update |
|------|--------|
| 2026-03-12 | Project plan created. Architecture and decisions defined. |
| 2026-03-12 | Phases 1–3 complete. All server and client files generated. Ready for Phase 4 (integration testing). |
| 2026-03-13 | Verification pass: fixed missing `using namespace Qt::StringLiterals` and `#include <QCoreApplication>` in main.cpp; removed erroneous `SUFFIX ".html"` from CMakeLists (Qt WASM toolchain generates it automatically). |
| 2026-03-13 | Server deployed to Cloudflare. Fixed wrangler.toml migration (`new_classes` → `new_sqlite_classes` required by free plan). Live at `wss://qt-multiplayer-demo.mesw.workers.dev`. |
| 2026-03-13 | Replaced `collect_wasm.sh` with root `index.html` redirect + `.nojekyll`; WASM files committed in place from build dir. |
| 2026-03-13 | Full end-to-end test passed: desktop build, two WASM instances, live Cloudflare server — counter syncs correctly. Demo complete. |
