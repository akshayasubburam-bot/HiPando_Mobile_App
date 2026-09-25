# HI PANDO — Mobile App Revision Spec (v2)

> This file lists **changes to apply on top of** `HI-PANDO-mobile-app-spec.md`. It does not replace that file — read it alongside the original. Anything not mentioned here stays as originally specced.

---

## 1. Global Changes (apply across every screen)

### 1.1 Pando brand logo — consistent everywhere
The small top **Pando avatar + "Hi Pando" wordmark** (the brand lockup, not the big floating character) must use the **exact same mark, size, and position treatment** on every screen — Landing, Explore, Search, Details, Sign In. Build it as one shared component (`PandoLogo.jsx`) and reuse it everywhere instead of re-styling it per screen.

### 1.2 Big floating Pando character — bigger everywhere
Increase the size of the **floating 3D Pando character** (the mascot next to the sticky note) on **all screens**. It should read as a clear, prominent presence, not a small accessory.

### 1.3 Pando movement while speaking
While Pando is speaking, animate the character with a **subtle idle motion** — small, slow drifts up/down/left/right (a gentle float/bob, not a bounce or spin). This should feel alive but not distracting, and should stop (return to a calm resting pose) once Pando finishes speaking.

### 1.4 Sticky note — speaker icon only
Remove the **mic icon** from the sticky note header. The note header now shows only: red dot + "PANDO SAYS" label + a single **speaker icon**.
- The speaker icon is now a **speak/mute toggle** for that note (see Section 1.6), not a separate "listen" action.
- Voice input (asking Pando something) still exists, but it now happens through the **ask box** near Pando (Section 1.7) — not through a mic icon on the note itself.

### 1.5 Remove the global "Voice On" toggle
Delete the dark "VOICE ON" pill/switch entirely (it was on the Landing screen). It's replaced by the per-note speaker toggle described below — there's no separate global voice setting anymore.

### 1.6 Pando speaks automatically, per screen, and can be muted
- **On every screen load/switch, Pando automatically speaks** a summary of what's on that screen, using the real data for that screen (see per-screen "What Pando says" notes below).
- The **speaker icon on the sticky note is the on/off control for this specific utterance**:
  - Tap it while Pando is speaking → speech stops immediately (mutes).
  - Tap it again → Pando speaks the current note's text again from the start.
- This behavior is **per screen/per note**, not a persistent global setting — arriving on a new screen always triggers a fresh auto-speak for that screen's content.

### 1.7 Asking Pando a question — no chat bot UI
Remove the chat-bubble bottom sheet (`PandoChatSheet` with a scrolling message history) entirely. Replace it with this simpler pattern:
- A small **ask box** near Pando (see per-screen placement) where the user types (or uses voice input in the box) a question.
- Submitting the question does **not** open a chat thread. Instead:
  - The **sticky note updates in place** with Pando's answer.
  - Pando **speaks the answer** (same auto-speak + mute/replay behavior as Section 1.6).
- There is no message history, no chat bubbles, no separate panel — the sticky note **is** the conversation, one turn at a time, always anchored next to Pando.
- Keep the underlying answer logic from the original spec (search intent parsing → FAQ keyword match → fallback), just surface the result through the sticky note instead of a chat sheet.

### 1.8 Search behavior — Landing search box is the only property search
Only the **search box on the Landing screen** takes a free-text query and returns a results list (routes to the Search/Recommended Properties screen). Search-like inputs that appear on other screens (e.g. the map's top search bar) are scoped to **that screen only** (e.g. filtering/panning the map) and must **not** trigger the same "go to property results list" behavior. Don't let two different inputs in the app do the same global search job.

---

## 2. Landing Screen — Changes

**Layout order, top to bottom (replaces the previous hero-photo-with-overlay layout order):**
1. `PandoLogo` (avatar + "Hi Pando" wordmark) at the very top
2. Headline **"Find your next place."** directly below the logo (moved up from the lower-third overlay position; "next place." keeps the red italic treatment)
3. **Search box** below the headline — placeholder "A home, a neighborhood, a plan…" with the red submit arrow (voice input inside the box is fine; this is the one box covered by Section 1.8)
4. Big Pando character + sticky note, positioned **below the search box**

**Other changes:**
- Remove the "VOICE ON" toggle (Section 1.5).
- Remove the mic icon from the sticky note (Section 1.4).
- **Sign In button** needs a visible pressable feel — give it a soft shadow/elevation at rest and a clear pressed/hover state (slightly deeper shadow or a subtle scale-down) so it doesn't look flat against the photo background.
- Background photo can remain full-bleed behind all of the above, with a scrim strong enough to keep the logo, headline, and search box legible near the top.

**What Pando says here (auto-spoken on load):**
> "I can help you find a place that feels like home. Tell me your city, budget, and one non-negotiable."

---

## 3. Explore Map Screen — Changes

- **Map pins:** Remove the dark shadow/blob currently rendered behind each Pando-face pin — show the Pando pin character on its own, cleanly placed on the map with no background shape behind it.
- **Layers control** (top-left, below the search box): tapping it expands a small set of map-style options — **Default, Satellite, Terrain**. Selecting one switches the map tile style immediately. **Default is the initial/selected state** on screen load.
- **Filter control** (below Layers): simplify to a **single filter — Property Type** only (remove the other filter categories from this icon's flow). Tapping it opens its options **anchored right next to the icon itself** (a small inline flyout/popover), not a full-screen or bottom-sheet popup.
  - When a filter is actively applied, the Filter icon itself must show a clear visual indicator (e.g. a colored dot/badge or filled state) so the user can tell filtering is active at a glance.
  - No filter applied = default state = **all properties shown**.
- **Big Pando** (using the larger global size from Section 1.2) appears next to the sticky note, speaking about the current map view.

**What Pando says here (auto-spoken on load / on major map changes):**
> Something like: "Showing 12 properties across Dubai Marina, Downtown Dubai, and Palm Jumeirah. Tap any pin to explore, or search a specific area or project."
(Generate this dynamically from the properties currently visible/loaded on the map.)

---

## 4. Recommended Properties (Search) Screen — Changes

- **Header:** remove the **"QUANTUM"** badge next to "Hi Pando". Also remove the **"!"** — the wordmark reads plain **"Hi Pando"** (matches the shared `PandoLogo` from Section 1.1, so this also keeps it consistent with the other screens).
- **Remove the status chip row** entirely (the row that showed "4 Assets Synced", "MLS Latency 8ms", "Dubai Ultra-Prime & Off-Market", "Neural Audio Active").
- **Remove the controls row** below the "Recommended Properties" heading — no dropdown ("Waterfront & Skyline") and no "Refine" button on this screen anymore.
- **Remove the "Curation 02" badge** next to the heading.
- **Add the big Pando character**, speaking, next to the sticky note on this screen (bigger size per Section 1.2).
- **Ask box:** make the "Ask Pando…" input **smaller**, and position it **below** the Pando character + sticky note (not as a full-width bar pinned above the bottom nav).

**What Pando says here (auto-spoken on load, updates as the user scrolls to a different card):**
> "This Downtown penthouse scores highest for iconic views, privacy, and long-term scarcity."
(Text is generated per the property currently in view, same as originally specced.)

**Resulting heading area, top to bottom:** `Hi Pando` logo (no badge, no "!") → small red "DUBAI PRIME / AI CONCIERGE WORKSPACE" label → "Recommended Properties" heading (no badge) → subtitle → property card list. No status chips, no dropdown/refine row.

---

## 5. Selected Property (Details) Screen — Changes

- **Remove** the green **"✓ VERIFIED PROPERTY"** badge entirely.
- **Background:** the property's photo becomes the **full-screen background** for the whole screen (not just the top portion) — all text and controls sit **on top of** the image, not in a separate white sheet below it.
- **Image gallery:** 2–3 images of the selected property, advanced via the numbered counter/arrows at the top (e.g. "1 / 3" with a next arrow) — tapping the arrow cycles to the next image, updating the full-screen background.
- **Top of screen:** property **name/title** and **location** go here (e.g. "Downtown Dubai Burj View Royal Penthouse" + "Downtown Dubai, Dubai • Royal Penthouse").
- **Bottom of screen:** all remaining details go here — price, and the stat strip (bedrooms / sq.ft / bathrooms / furnishing).
- **Remove entirely:** no scroll section below the property — no Description block, no Amenities grid, no Location/map preview, no "Similar Properties" carousel. This screen shows **only** the selected property's own image(s) and core details, nothing else.
- **Pando placement:** the speaking Pando character + its sticky note + its ask box must sit at the **middle-right** of the screen, vertically centered over the property image.
  - The **ask box** is **small**, positioned **below** the Pando character + sticky note (same relative pattern as the Search screen, just relocated to middle-right here).

**What Pando says here (auto-spoken on load):**
> "A rare, fully furnished sky residence with protected Burj views and exceptional privacy."
(Generated from the specific property's real attributes, same as originally specced — price, beds, baths, area, furnishing, standout features.)

---

## 6. Component Updates

| Component | Change |
|---|---|
| `PandoLogo.jsx` | **New/shared** — one consistent avatar + "Hi Pando" wordmark used on every screen |
| `PandoCharacter.jsx` | Increase base size (global); add idle float/drift animation while speaking |
| `PandoStickyNote.jsx` | Remove mic icon; speaker icon becomes a speak/mute toggle for the current note; note text is also the answer surface for user questions (no separate chat bubbles) |
| `PandoChatSheet.jsx` | **Remove** — replaced by inline note updates (Section 1.7) |
| `ChatMessage.jsx` / `ChatQuickReplies.jsx` | **Remove** — no longer needed without the chat sheet |
| `PandoAskBox.jsx` | **New** — small input near Pando (placement varies per screen); submits a question, updates + re-speaks the sticky note with the answer |
| `VoiceToggle.jsx` | **Remove** — no global voice toggle (Section 1.5) |
| `MapLayerControl.jsx` | **New** — Layers icon expanding to Default / Satellite / Terrain, Default selected on load |
| `MapFilterControl.jsx` | **New** — Property Type–only filter, options shown inline next to the icon, icon shows an active/filtered indicator state |
| `PropertyMapPin.jsx` | Remove the shadow/background shape behind the pin graphic |
| `StatusChipRow.jsx` | **Remove** from the Search screen |
| `StatStrip.jsx` | Now rendered at the bottom of the full-bleed Details screen, over the image, instead of inside a white sheet |

---

## 7. Behavior Summary (quick reference)

- **One search box that searches properties app-wide:** Landing screen only.
- **One consistent brand logo:** same on every screen.
- **One big, moving, speaking Pando:** present on every screen, bigger than before, gently drifting while talking.
- **One voice control per note:** the speaker icon — tap to mute mid-speech, tap again to replay.
- **One way to ask Pando something:** a small ask box near Pando; the answer always appears (and is spoken) in the sticky note itself — never a separate chat panel.
- **Screen switches always trigger a fresh, screen-specific thing for Pando to say**, generated from that screen's real data.
