# Playlists / Queue + Video Playback

## Overview

Users can queue YouTube videos from the feed and watch them on a dedicated `/queue` page, with a fullscreen/sidebar layout toggle.

## Architecture

### QueueCache (`lib/framelens/queue_cache.ex`)

An `Agent` (same pattern as `FeedCache`) storing per-user video queues in memory, keyed by email.

- State: `%{email => [post_map, ...]}`
- Ephemeral — resets on server restart. No DB table.
- API: `get/1`, `add/2`, `remove/2`, `clear/1`
- Registered in `application.ex` supervision tree.

### VideoPlayerComponent (`lib/framelens_web/live/video_player_component.ex`)

A plain function component (`use FramelensWeb, :html`) that accepts a `video_url` and `title`. Extracts YouTube video IDs from `watch?v=` and `youtu.be/` URL formats and renders an iframe embed. Returns a placeholder `<div>` for nil or non-YouTube URLs.

### Feed Enhancement (`lib/framelens_web/live/feed_live.*`)

- New "Queue" column in the feed table with a `+` button per row.
- `add_to_queue` event handler: looks up the post from `socket.assigns.posts` by URL, calls `QueueCache.add/2`, flashes a confirmation.

### QueueLive (`lib/framelens_web/live/queue_live.*`)

Route: `GET /queue` (authenticated).

Assigns:
- `email` — current user's email (queue key)
- `queue` — full list from `QueueCache.get/1`
- `current_video` — post map currently in the player (defaults to first in queue)
- `mode` — `:fullscreen` | `:sidebar`

Events:
- `play` — sets `current_video` to a queue item by URL
- `remove_from_queue` — removes from cache and refreshes queue; advances `current_video` if it was the removed item
- `next` — advances `current_video` to the next item; `nil` at end of queue
- `toggle_mode` — flips between `:fullscreen` and `:sidebar`

Layout modes are CSS-only (`sidebar-mode ml-auto w-80` class on the root div) — no JS or global state required.

## Key Files

| File | Purpose |
|------|---------|
| `lib/framelens/queue_cache.ex` | In-memory queue Agent |
| `lib/framelens/application.ex` | QueueCache added to supervision tree |
| `lib/framelens_web/live/video_player_component.ex` | YouTube iframe component |
| `lib/framelens_web/live/queue_live.ex` | Queue page LiveView |
| `lib/framelens_web/live/queue_live.html.heex` | Queue page template |
| `lib/framelens_web/live/feed_live.ex` | `add_to_queue` handler |
| `lib/framelens_web/live/feed_live.html.heex` | Queue column + button |
| `lib/framelens_web/components/layouts/root.html.heex` | Queue nav link |
| `lib/framelens_web/router.ex` | `/queue` route |

## Tests

| File | Coverage |
|------|---------|
| `test/framelens/queue_cache_test.exs` | QueueCache unit tests (9 cases) |
| `test/framelens_web/live/video_player_component_test.exs` | URL parsing + render (6 cases) |
| `test/framelens_web/live/feed_live_queue_test.exs` | Feed queue button integration (5 cases) |
| `test/framelens_web/live/queue_live_test.exs` | QueueLive interactions (12 cases) |
| `test/framelens_web/live/navigation_test.exs` | Nav link visibility (2 cases) |

## Future Extensions

- **Persistence** — swap `QueueCache` for a DB-backed queue (new `queues` table with `user_id` FK and a JSONB `items` column, or a dedicated `queue_items` table).
- **Non-YouTube playback** — `VideoPlayerComponent` can be extended to detect other platform URLs and embed them, or open in a new tab as a fallback.
- **Auto-advance** — use a JS hook that listens for the YouTube iframe `onStateChange` event (state `0` = ended) and fires a `phx-hook` to call `next` automatically.
- **Drag-to-reorder** — add a Sortable.js hook to the queue list.
- **Shared queues / playlists** — persist queues with names in the DB and allow sharing via URL.
