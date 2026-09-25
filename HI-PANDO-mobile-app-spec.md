# HI PANDO — Mobile App Build Spec

> Companion to `HI-PANDO-frontend-spec.md` (web) and `HI-PANDO-chatbot-spec.md`.
> **Functionality is identical to the Hi Pando web app** — only the layout is re-designed for mobile. This spec is built directly from the approved mobile UI screens.

---

## 1. Overview

**App name:** Hi Pando
**Platform:** Mobile (phone-first)
**Market:** Dubai, UAE real estate
**Core idea:** An AI concierge named **Pando** guides the user through discovering, exploring, and understanding properties. Pando is present on **every screen** and **speaks about whatever is on that screen**.

**Language:** JavaScript only (no TypeScript) — consistent with the web project.

**Framework options:**
- **Native build:** React Native + Expo (recommended for a real installable app)
- **Mobile-web build:** Next.js + React, phone-viewport layout (reuse the existing web codebase and mock data)

Pick one and keep it consistent. All component names below work for either.

**Data:** Same mock datasets as the web app — `data/properties.js`, `data/localities.js`, `data/botFaq.js`. No backend in this phase.

---

## 2. Brand System (locked — matches the approved screens)

| Token | Value | Usage |
|---|---|---|
| `--red` | `#E0322B` | Primary actions, active nav, prices, accent labels |
| `--ink` | `#111111` | Headlines, primary text |
| `--cream` | `#F5E9C8` | Pando sticky note background |
| `--cream-text` | `#4A3B1E` | Sticky note body text |
| `--surface` | `#FFFFFF` | Cards, sheets |
| `--bg-warm` | `#FAF7F2` | Search screen background |
| `--map-dark` | `#0E1418` | Explore map base |
| `--muted` | `#7A7A7A` | Secondary text |
| `--green` | `#16A34A` | "Verified Property" badge |
| `--pink` | `#FADCE4` | "Curation 02" badge |

**Typography**
- **Headlines:** high-contrast serif (e.g. Playfair Display). Used for "Find you
 r next place.", "Recommended Properties", "Welcome back", property titles. Selective red italic for emphasis (`place.` in the hero).
- **Labels/UI:** clean sans-serif, **uppercase with wide letter-spacing** for micro-labels ("WHAT ARE YOU LOOKING FOR?", "PANDO SAYS", "PRIVATE ACCESS", nav labels).
- **Body:** regular sans-serif.

**Shape language:** fully rounded pills for inputs, chips, and buttons. Large corner radius (~20–24px) on cards and sheets. Soft, wide, low-opacity shadows. Full-bleed photography behind rounded overlays.

---

## 3. Pando — The Speaking Assistant (the core feature)

Pando is a glossy 3D red map-pin mascot with large green eyes, a warm smile, small arms, and a gold coin emblem.

### 3.1 The Sticky Note
Pando always communicates through a **cream sticky note** anchored beside the character:
- Cream/parchment background, large rounded corners, soft drop shadow
- A small **tail** pointing down/right toward Pando
- Header row: a small red dot + **"PANDO SAYS"** in uppercase, letter-spaced red type
- Top-right of the header: a **speaker icon** (listen / text-to-speech) and a **mic icon** (voice input)
- Body: 2–3 lines of dark-brown text, conversational tone

### 3.2 Behavior rules
- Pando + sticky note appear on **every screen**, positioned in the lower-right region.
- The note content is **contextual to the current screen and current data** — see the per-screen copy in Section 4.
- On the Property Details screen the note describes **that specific property** (pulled from the property object).
- On the Search screen the note comments on **the specific listing being viewed/scrolled**.
- Tapping the **speaker icon** reads the note aloud (text-to-speech). Tapping the **mic icon** opens voice input.
- Tapping **Pando** expands the full chat sheet (Section 5).
- The note can be dismissed with a tap-away; Pando remains, and tapping Pando brings the note back.

### 3.3 Voice
- A **"VOICE ON"** toggle pill (dark pill, red switch) sits on the Home screen. When on, Pando automatically speaks each screen's note aloud on arrival.
- Voice state is global and persists across screens.

---

## 4. Screens

### 4.1 HOME / LANDING — `/` (tab: HOME)
Full-bleed cinematic Dubai architecture photo (latticed golden dome, water, skyline at dusk) with a dark gradient scrim at the bottom.

- **Top bar (transparent, over photo):** Pando circular avatar + **"Hi Pando!"** serif wordmark on the left. **"SIGN IN"** text button on the right.
- **Hero headline** (lower-left, serif, white): "Find your **next place.**" — `next place.` in red italic on its own line.
- **Micro-label:** "WHAT ARE YOU LOOKING FOR?" (uppercase, letter-spaced, white)
- **Search pill:** white rounded input, placeholder "A home, a neighborhood, a plan.", a **mic icon**, and a **red circular arrow button**. Submitting routes to the Search screen with the query applied.
- **Pando** floats right of the sticky note; **sticky note** reads:
  > "I can help you find a place that feels like home. Tell me your city, budget, and one non-negotiable."
- **VOICE ON toggle** pill sits below/right of the note.
- **Bottom nav** (see 4.6).

**Note:** The Sign In entry point exists **only on this screen** (per requirement) — no Sign In button in the header of Explore, Search, or Details.

---

### 4.2 EXPLORE MAP — `/explore` (tab: EXPLORE)
Full-screen dark satellite map of Dubai.

- **Top:** floating white search pill — "Search Marina, Downtown, Villa, Penthouse…" with a red search icon.
- **Category chips** below the search pill, horizontally scrollable: **BUY** (active, solid red), **RENT**, **OFF-PLAN**, **EXPLORE** (inactive = cream/translucent pills).
- **Map pins:** custom **Pando-face pins** (red pin with the mascot's face) at each property's coordinates. Selected pin scales up slightly.
- **Left edge floating buttons:** circular **Layers** button and circular **Filter** button, stacked.
- **Pando + sticky note** floating right, above the carousel:
  > "Tap any Pando pin to explore details, or search an area or project in Dubai."
- **Bottom carousel:** swipeable horizontal property mini-cards sitting above the bottom nav. Each card: square thumbnail on the left; on the right a serif community name ("Downtown Dubai"), a grey subtitle line ("Downtown Dubai Burj View Royal Penthouse"), and a red price ("AED 52,000,000").
- **Interaction:**
  - Tapping a pin → carousel scrolls to that property's card + map pans to it
  - Swiping the carousel → map pans to the corresponding pin
  - **Tapping a card → opens the Property Details screen** for that property
- **Filter button** opens a draggable bottom sheet (purpose, property type, price range AED, bedrooms, area sq.ft, amenities).

---

### 4.3 SEARCH / RECOMMENDED PROPERTIES — `/search` (tab: SEARCH)
Warm off-white background. Reached by submitting a search from Home, or via the SEARCH tab.

- **Header:** Pando avatar + "Hi Pando!" serif wordmark + small dark **"QUANTUM"** pill badge. Beneath it, a tiny uppercase letter-spaced subtitle: "DIFC DUBAI PRIME RESIDENTIAL INTELLIGENCE". On the right: a **bell** icon and a circular **user avatar**.
- **Status chip row** (horizontally scrollable, each with a colored status dot): "4 Assets Synced", "MLS Latency 8ms", "Dubai Ultra-Prime & Off-Market", "Neural Audio Active".
- **Section label:** red dot + "DUBAI PRIME / AI CONCIERGE WORKSPACE" (uppercase, letter-spaced, red)
- **Title:** large serif **"Recommended Properties"** with a pink **"CURATION 02"** badge aligned right.
- **Subtitle:** "Handpicked homes that match your preferences"
- **Controls row:** a white dropdown pill ("Waterfront & Skyline") and a **"Refine"** button with a sliders icon (opens the filter bottom sheet).
- **Property cards** — single-column vertical scroll. Each card:
  - Large photo with a dark **"INDEX: 99.8 / BURJ VIEW"** badge top-left and a circular **bookmark** button top-right
  - A "Sector 04" tag and optional corner ribbon ("Royal Elevation", "Exclusive")
  - Body: serif community name, meta line ("Burj Khalifa View • 5 Beds • 7,250 sq.ft"), small feature tags ("Direct Burj View", "Heated Sky Pool", "+1")
  - Price block: bold "AED 52,000,000" with smaller grey USD conversion beneath
  - Red circular arrow button → opens Property Details
- **Pando + sticky note** overlays the card currently in view, commenting on that listing:
  > "This Downtown penthouse scores highest for iconic views, privacy, and long-term scarcity."
  The note text updates as the user scrolls to a different card.
- **Persistent input pill** above the bottom nav: "Ask Pando anything about the property…" with mic and red send button.

---

### 4.4 PROPERTY DETAILS — `/property/[id]`
Opened from a map card, a search card, or a chat mini-card. **Background is the property's own photography.**

- **Full-bleed hero gallery** (swipeable, 3+ images) occupying the top ~60%.
- **Floating top controls:** a cream **"← Back"** pill (left), a green **"✓ VERIFIED PROPERTY"** badge (center), and a dark **"1 / 3"** counter with left/right arrows (right).
- **Over the lower hero:** serif property title across two lines ("Downtown Dubai Burj View Royal Penthouse"), and a location line with a red pin icon ("Downtown Dubai, Dubai • Royal Penthouse").
- **White rounded sheet** rising over the photo: a small uppercase label "PRIVATE SALE", then the serif price **"AED 52,000,000"**.
- **Stat strip** (divided, uppercase small caps): `5 BEDROOMS | 7,250 SQ.FT. | 6 BATHROOMS | FURNISHED`
- **Pando + sticky note** overlapping the sheet on the right, describing **this property**:
  > "A rare, fully furnished sky residence with protected Burj views and exceptional privacy."
- **Scrolling further** reveals, inside the sheet: Description, Amenities icon grid, Location block with map preview, and a "Similar Properties" horizontal carousel.
- **Sticky bottom bar:** an "Ask Pando anything…" input pill with a mic icon, beside a solid red **"CONTACT AGENT"** button.

---

### 4.5 SIGN IN / SIGN UP — `/sign-in`
Reached **only** from the SIGN IN button on the Home screen. Presented as a full-screen modal over a softly blurred Dubai skyline.

- Circular **back button** top-left.
- Centered Pando avatar + "Hi Pando!" wordmark.
- Red uppercase letter-spaced label: **"PRIVATE ACCESS"**
- Large serif headline: **"Welcome back"**
- Subtitle: "Continue with your UAE mobile number."
- **Phone input:** white pill with an "AE +971" country prefix block on the left and placeholder "50 123 4567".
- Full-width red **"CONTINUE"** button → advances to an OTP step (6 boxed digit inputs + resend timer).
- Underlined link: "New to Hi Pando? Create an account"
- **Pando + sticky note** at the bottom:
  > "Welcome. I'll keep your searches, saved homes, and conversations ready whenever you return."
- No bottom nav on this screen.
- Auth is **UI-only** in this phase (Clerk integration comes later).

---

### 4.6 BOTTOM NAVIGATION (persistent)
Five tabs, icon above an uppercase letter-spaced label. Active tab is red (icon + label); inactive is grey.

`HOME` · `EXPLORE` · `SEARCH` · `SAVED` · `PROFILE`

- **SAVED:** vertical list of bookmarked properties, reusing the search card component. Empty state with a Pando note.
- **PROFILE:** account details, saved searches, notification preferences, voice toggle, sign-out. Shows a signed-out state prompting the user to sign in from Home.
- The bottom nav is hidden on Property Details (full-bleed) and Sign In.

---

## 5. Pando Chat Sheet (expanded assistant)

Tapping Pando anywhere opens a draggable **bottom sheet** (not a side panel — that's the web pattern).

- **Grab handle** at the top, then a header: Pando avatar, "Pando" name, an "Online" status dot, and a close (×) button.
- **Message list:** bot messages in cream bubbles (left-aligned, Pando avatar beside the first in a sequence); user messages in solid red bubbles with white text (right-aligned).
- **Quick reply chips** under bot messages: `Buy a property` · `Rent a property` · `Off-plan` · `FAQs` · `Talk to an agent`
- **Inline property results:** compact mini-cards rendered in the chat when Pando finds matches; tapping one opens Property Details.
- **Typing indicator:** three-dot animation in a cream bubble, with a short artificial delay before each response.
- **Input bar:** "Ask Pando anything…" text field, mic button (voice input), red circular send button.
- **Conversation state persists** across tab changes within a session.

### 5.1 Answer logic (this phase — local, no backend)
1. **Search intent** — parse bedrooms, community, purpose, and max price from the message; filter `data/properties.js`; reply with a summary + 2–3 mini-cards + a "See all results" button that routes to Search with those filters applied.
2. **Property question** — if the user is on a Property Details screen, answer from that property object (price, area, bedrooms, amenities, furnishing).
3. **FAQ** — keyword-match against `data/botFaq.js` (brokerage, documents, freehold vs leasehold, foreigner ownership, site visits, negotiation).
4. **Fallback** — "I couldn't find an exact answer for that. Would you like to talk to one of our agents?" with `Talk to an agent` / `Try again` buttons.

Swap-ready: when the real AI layer is available, only the message-handling function changes — the UI stays identical.

---

## 6. Components

| Component | Responsibility |
|---|---|
| `PandoProvider.jsx` | Global state: voice on/off, chat messages, sheet open/closed, current screen context |
| `PandoCharacter.jsx` | The floating 3D mascot, positioned per screen |
| `PandoStickyNote.jsx` | Cream note with "PANDO SAYS" header, speaker + mic icons, tail, contextual text |
| `PandoChatSheet.jsx` | Expanded draggable chat bottom sheet |
| `ChatMessage.jsx` | Bot (cream) vs user (red) bubble variants |
| `ChatQuickReplies.jsx` | Row of pill shortcut chips |
| `VoiceToggle.jsx` | "VOICE ON" dark pill with red switch |
| `BottomNav.jsx` | 5-tab persistent navigation |
| `SearchPill.jsx` | Rounded search input with mic + red submit arrow (hero and compact variants) |
| `CategoryChips.jsx` | BUY / RENT / OFF-PLAN / EXPLORE selector |
| `PropertyCard.jsx` | Full card used on Search and Saved |
| `PropertyMiniCard.jsx` | Compact card for the map carousel and chat results |
| `PropertyMapPin.jsx` | Custom Pando-face map marker |
| `FilterSheet.jsx` | Draggable filter bottom sheet |
| `PropertyGallery.jsx` | Swipeable hero gallery with counter and arrows |
| `StatStrip.jsx` | Divided bedrooms / sq.ft / bathrooms / furnishing row |
| `StatusChipRow.jsx` | Scrollable live status chips on the Search screen |

---

## 7. Folder Structure

```
hi-pando-mobile/
├─ app/                        # or screens/ for React Native
│  ├─ _layout.js               # mounts PandoProvider + BottomNav
│  ├─ index.js                 # Home
│  ├─ explore.js               # Map
│  ├─ search.js                # Recommended Properties
│  ├─ saved.js
│  ├─ profile.js
│  ├─ property/[id].js         # Details
│  └─ sign-in.js
├─ components/
│  ├─ pando/
│  │  ├─ PandoProvider.jsx
│  │  ├─ PandoCharacter.jsx
│  │  ├─ PandoStickyNote.jsx
│  │  ├─ PandoChatSheet.jsx
│  │  ├─ ChatMessage.jsx
│  │  ├─ ChatQuickReplies.jsx
│  │  └─ VoiceToggle.jsx
│  ├─ property/
│  │  ├─ PropertyCard.jsx
│  │  ├─ PropertyMiniCard.jsx
│  │  ├─ PropertyMapPin.jsx
│  │  ├─ PropertyGallery.jsx
│  │  └─ StatStrip.jsx
│  └─ ui/
│     ├─ BottomNav.jsx
│     ├─ SearchPill.jsx
│     ├─ CategoryChips.jsx
│     ├─ FilterSheet.jsx
│     └─ StatusChipRow.jsx
├─ data/
│  ├─ properties.js
│  ├─ localities.js
│  ├─ botFaq.js
│  ├─ botIntents.js
│  └─ pandoScripts.js          # per-screen sticky note copy
└─ assets/
   ├─ pando/                   # mascot renders, pin variants
   └─ images/
```

---

## 8. `data/pandoScripts.js` — Screen-Aware Dialogue

```js
export const pandoScripts = {
  home: "I can help you find a place that feels like home. Tell me your city, budget, and one non-negotiable.",
  explore: "Tap any Pando pin to explore details, or search an area or project in Dubai.",
  search: (property) =>
    `This ${property.community} ${property.type.toLowerCase()} scores highest for iconic views, privacy, and long-term scarcity.`,
  property: (p) =>
    `This ${p.type.toLowerCase()} in ${p.community} offers ${p.bedrooms} bedrooms, ${p.bathrooms} bathrooms and ${p.areaSqft.toLocaleString()} sq.ft of ${p.furnishing.toLowerCase()} space, priced at AED ${p.price.toLocaleString()}.`,
  saved: "Everything you've bookmarked lives here. Want me to compare any two of them?",
  profile: "You can manage your preferences here — I'll tune my recommendations to match.",
  signIn: "Welcome. I'll keep your searches, saved homes, and conversations ready whenever you return."
};
```

Each screen calls `PandoProvider.setContext(screenKey, data)` on mount; the provider resolves the script and updates the sticky note (and speaks it if voice is on).

---

## 9. Build Order

1. Scaffold the project, add fonts (serif + sans), and define the brand tokens from Section 2 as theme constants.
2. Build `BottomNav` and the root layout with `PandoProvider` mounted globally.
3. Build `PandoCharacter` + `PandoStickyNote` and get the floating position, tail, and icon row visually right — this is the signature element, so finish it before anything else.
4. Build the **Home** screen: hero photo, serif headline, `SearchPill`, `VoiceToggle`, Pando note.
5. Build `PropertyCard` and `PropertyMiniCard` against the mock data.
6. Build the **Search** screen: header, `StatusChipRow`, title block, controls row, card list, scroll-linked Pando note.
7. Build the **Property Details** screen: gallery, floating controls, white sheet, `StatStrip`, contextual Pando note, sticky bottom bar.
8. Build the **Explore** map: dark map, `PropertyMapPin`, chips, layers/filter buttons, bottom carousel, pin↔carousel sync.
9. Build `FilterSheet` and wire it to both Explore and Search.
10. Build the **Sign In** screen + OTP step (UI only), launched from Home only.
11. Build `PandoChatSheet` with local answer logic (Section 5.1).
12. Add text-to-speech for the speaker icon and wire the global voice toggle.
13. Build **Saved** and **Profile** tabs.
14. Pass on safe areas (notch / home indicator), empty states, and loading states.

---

## 10. Out of Scope for This Phase

- Real backend (FastAPI, MongoDB) and live listing data
- Real authentication (Clerk)
- Real AI responses (Claude / GPT-4o-mini + RAG) — local logic only for now
- WhatsApp handoff (Kapso.ai) and telephony voice (Vapi.ai)
- Payments and lead management

Everything above is UI + local mock logic, structured so each piece swaps cleanly to the real services later.
