# HI PANDO — Pando Voice Content & Movement Spec (v3)

> Builds on `HI-PANDO-mobile-app-spec.md` and `HI-PANDO-mobile-app-revisions-v2.md`. This file replaces the short placeholder lines in v2's "What Pando says here" sections with the **full, detailed content** Pando should actually speak on each screen, plus a clarification on **which Pando moves**.

---

## 1. The Core Rule

Pando must never say a generic, filler line. **Every time Pando speaks, the words must come from the real data currently on screen** — the actual properties, counts, names, and numbers the user is looking at, not a static sentence. Treat each script below as a **template**: the fixed wording stays, the bracketed parts are filled from live data every time the screen (or the selected item on it) changes.

Pando still speaks automatically on screen load/change (per v2 §1.6), and the sticky note's speaker icon still mutes/replays that same utterance (per v2 §1.4/§1.6). This file only changes **what gets said**, not the mute/replay mechanism.

---

## 2. Which Pando Moves (important clarification)

There are **two different Pando graphics** in the app — they must **not** behave the same way:

| Element | What it is | Movement |
|---|---|---|
| **Speaking Pando** (`PandoCharacter`) | The single big floating mascot next to the sticky note, present once per screen | **Moves** — gentle drifting/shaking motion (up, down, left, right) while actively speaking; returns to a calm resting pose when silent |
| **Map location pins** (`PropertyMapPin`) | The small Pando-face markers scattered across the Explore map, one per property | **Static** — no movement, no shake, no drift, ever. They are location markers, not the assistant. |

Only the **one** speaking Pando (the assistant character) gets the movement effect. The map pins stay completely still at all times, including when the speaking Pando is actively talking about a place they represent.

### 2.1 Speaking Pando movement detail
- While speaking: small-amplitude, slow, continuous drift — nudges up/down/left/right in a loose, organic loop (not a fixed bounce loop), combined with a very slight shake/wobble to feel like it's "talking with its body."
- While silent (muted or finished): motion stops, Pando settles back to its normal resting position and pose.
- Movement is confined to a small radius around Pando's anchored position — it should never drift far enough to overlap the sticky note text or leave its designated screen area (see v2 for per-screen placement: bottom-right on Landing/Explore, beside the note on Search, middle-right on Details).

---

## 3. Landing Screen — Welcome Note

**Trigger:** Auto-speaks once, immediately on app open / landing on this screen.

**Content to include:**
1. A warm welcome, introducing itself as Pando.
2. What the app does (helps find a home/place in Dubai).
3. A prompt for what it needs from the user to help (city/area, budget, one must-have).

**Script template:**
```
"Hi, I'm Pando 👋 Welcome to Hi Pando. I help you find a place in Dubai that actually feels
right for you — not just a list of listings. Tell me an area, your budget, and one thing
that's non-negotiable, and I'll start narrowing things down for you. You can type in the
box above, or just ask me directly."
```

**Data used:** none dynamic — this is a fixed welcome, since there's no property context yet on first load. If the user has searched before in this session (returning to Landing after browsing), optionally vary it:
```
"Welcome back. Want to pick up where you left off in [last searched area/community], or start a new search?"
```

---

## 4. Explore Map Screen — Two Speaking States

This screen has **two distinct things Pando says**, depending on whether a specific pin has been tapped.

### 4.1 Default state — describing what's on the map (auto-speaks on load / whenever the visible set of pins changes, e.g. after panning or filtering)
Pando must **list out the relevant places actually shown on the map right now** — not a vague summary.

**Content to include:**
1. Total count of properties currently visible.
2. The specific communities/areas they're spread across (name them).
3. A short nudge on what to do next (tap a pin, or search another area).

**Script template:**
```
"I'm showing [count] properties right now across [community 1], [community 2], and
[community 3]. That includes [count of sale] for sale and [count of rent] for rent.
Tap any pin to see the details, or search a specific area or project in Dubai."
```

**Example (filled in):**
```
"I'm showing 12 properties right now across Dubai Marina, Downtown Dubai, and Palm
Jumeirah. That includes 9 for sale and 3 for rent. Tap any pin to see the details, or
search a specific area or project in Dubai."
```

If a **Property Type filter** is active (per v2 §3), Pando should mention it:
```
"Showing 5 Villas across Arabian Ranches and Dubai Hills Estate. Tap any pin for details,
or clear the filter to see everything."
```

### 4.2 On tapping a specific pin — describing that one place
**Trigger:** The moment a map pin is tapped (before or instead of navigating into full Details — this covers the in-context "tell me about this one" moment on the map itself, e.g. via the mini-card that surfaces in the bottom carousel).

**Content to include:**
1. Property title/type and community.
2. Price.
3. Bedrooms, bathrooms, area.
4. One standout feature if available (view, amenity, etc.).

**Script template:**
```
"This is [property title] in [community] — [purpose: for sale / for rent] at AED [price].
It has [bedrooms] bedrooms, [bathrooms] bathrooms, and [area] square feet. [Optional
standout feature, e.g. 'It also has direct Burj Khalifa views.']"
```

**Example (filled in):**
```
"This is the Downtown Dubai Burj View Royal Penthouse in Downtown Dubai — for sale at
AED 52,000,000. It has 5 bedrooms, 6 bathrooms, and 7,250 square feet. It also has direct
Burj Khalifa views and a heated sky pool."
```

Tapping a **different** pin immediately replaces this note and re-triggers speech for the newly selected property — it does not stack or queue.

---

## 5. Recommended Properties (Search) Screen — Reading the List

**Trigger:** Auto-speaks on load, and **updates whenever the property currently in view changes** as the user scrolls (per v2 §4), but must also be able to summarize the whole list, not just one card at a time.

**Two layers of content here:**

### 5.1 On first load — summarize the full recommended list
**Content to include:**
1. How many properties are being recommended.
2. A quick run-through naming the top few (2–3), each with one defining detail (price or standout feature) — an actual spoken list, not just a count.

**Script template:**
```
"I've put together [count] properties that match what you're looking for. Top picks:
[Property 1] in [Community 1] at AED [price 1], [Property 2] in [Community 2] at AED
[price 2], and [Property 3] in [Community 3] at AED [price 3]. Scroll through and I'll
tell you more about each one as you go."
```

**Example (filled in):**
```
"I've put together 8 properties that match what you're looking for. Top picks: the
Downtown Dubai Burj View Royal Penthouse at AED 52,000,000, a Dubai Hills Estate mansion
at AED 110,000,000, and a Palm Jumeirah beachfront villa at AED 85,000,000. Scroll through
and I'll tell you more about each one as you go."
```

### 5.2 As the user scrolls to a specific card — describe that one property
Same level of detail as the map-pin-tap script (§4.2), scoped to whichever card is currently centered/in-focus on screen:
```
"This [community] [property type] scores well for [standout reason — view / privacy /
scarcity / value]. It's AED [price] for [bedrooms] bedrooms and [area] square feet."
```

**Example:**
```
"This Downtown penthouse scores highest for iconic views, privacy, and long-term
scarcity. It's AED 52,000,000 for 5 bedrooms and 7,250 square feet."
```

---

## 6. Selected Property (Details) Screen — Full Detailed Narration

**Trigger:** Auto-speaks on load of this specific property's page. Must cover the property comprehensively since this screen has no separate Description/Amenities section anymore (per v2 §5) — the spoken note is now the primary place these details live.

**Content to include (all of it, in this order):**
1. Title and community/location.
2. Sale or rent status, and price.
3. Bedrooms, bathrooms, area (sq.ft), furnishing status.
4. A natural-language rundown of the description/highlights (pulled from the property's description field).
5. Key amenities, named individually (not just "has amenities" — list 2–4 of them).

**Script template:**
```
"[Property title], in [community]. This is [for sale / for rent] at AED [price]. It offers
[bedrooms] bedrooms, [bathrooms] bathrooms, and [area] square feet of [furnishing status]
space. [Description highlight in natural language.] It also comes with [amenity 1],
[amenity 2], and [amenity 3]."
```

**Example (filled in):**
```
"Downtown Dubai Burj View Royal Penthouse, in Downtown Dubai. This is for sale at
AED 52,000,000. It offers 5 bedrooms, 6 bathrooms, and 7,250 square feet of fully
furnished space. It's an ultra-exclusive residence facing the Burj Khalifa and the Dubai
Fountains directly. It also comes with a heated sky pool, a private cinema, and dedicated
parking."
```

If the user then asks Pando a follow-up question on this screen (via the small ask box, per v2 §1.7), the answer should be pulled from this same property object and replace the note content/speech — e.g. asking "is it furnished?" → note updates to just that answer, still spoken aloud, same mute/replay control applies.

---

## 7. Implementation Notes

### 7.1 Central script generator
Extend `data/pandoScripts.js` from the original spec into real generator functions (not static strings) that take live data and return the finished sentence:

```js
export const pandoScripts = {
  landing: (session) =>
    session.lastCommunity
      ? `Welcome back. Want to pick up where you left off in ${session.lastCommunity}, or start a new search?`
      : `Hi, I'm Pando 👋 Welcome to Hi Pando. I help you find a place in Dubai that actually feels right for you — not just a list of listings. Tell me an area, your budget, and one thing that's non-negotiable, and I'll start narrowing things down for you. You can type in the box above, or just ask me directly.`,

  mapOverview: (visibleProperties, activeFilter) => {
    const communities = [...new Set(visibleProperties.map(p => p.community))].slice(0, 3);
    const saleCount = visibleProperties.filter(p => p.purpose === "sale").length;
    const rentCount = visibleProperties.filter(p => p.purpose === "rent").length;
    const filterNote = activeFilter ? `Showing ${activeFilter} properties ` : `I'm showing ${visibleProperties.length} properties right now `;
    return `${filterNote}across ${communities.join(", ")}. That includes ${saleCount} for sale and ${rentCount} for rent. Tap any pin to see the details, or search a specific area or project in Dubai.`;
  },

  mapPinTap: (property) =>
    `This is ${property.title} in ${property.community} — ${property.purpose === "sale" ? "for sale" : "for rent"} at AED ${property.price.toLocaleString()}. It has ${property.bedrooms} bedrooms, ${property.bathrooms} bathrooms, and ${property.areaSqft.toLocaleString()} square feet.${property.highlight ? ` ${property.highlight}` : ""}`,

  searchListOverview: (properties) => {
    const top3 = properties.slice(0, 3);
    const picks = top3.map(p => `${p.title} in ${p.community} at AED ${p.price.toLocaleString()}`).join(", ");
    return `I've put together ${properties.length} properties that match what you're looking for. Top picks: ${picks}. Scroll through and I'll tell you more about each one as you go.`;
  },

  searchCardFocus: (property) =>
    `This ${property.community} ${property.type.toLowerCase()} scores well for ${property.standoutReason || "value and location"}. It's AED ${property.price.toLocaleString()} for ${property.bedrooms} bedrooms and ${property.areaSqft.toLocaleString()} square feet.`,

  propertyDetails: (property) =>
    `${property.title}, in ${property.community}. This is ${property.purpose === "sale" ? "for sale" : "for rent"} at AED ${property.price.toLocaleString()}. It offers ${property.bedrooms} bedrooms, ${property.bathrooms} bathrooms, and ${property.areaSqft.toLocaleString()} square feet of ${property.furnishing.toLowerCase()} space. ${property.description} It also comes with ${property.amenities.slice(0, 3).join(", ")}.`
};
```

### 7.2 Trigger map (when each script fires)

| Screen | Fires on |
|---|---|
| Landing | Screen mount (once per app open) |
| Explore Map | Screen mount, and again whenever the visible pin set changes (pan/zoom settles, filter changes) → `mapOverview` |
| Explore Map | Every pin tap → `mapPinTap` (replaces `mapOverview` until the user backs out to the general map view, which restores `mapOverview`) |
| Search | Screen mount → `searchListOverview`; then on each new card scrolling into focus → `searchCardFocus` |
| Property Details | Screen mount → `propertyDetails`; on a follow-up question via the ask box → the answer text (derived from the same property object) |

### 7.3 Data fields required
Make sure `data/properties.js` entries include (add if missing): `highlight` (one short standout phrase, e.g. "Direct Burj Khalifa views.") and `standoutReason` (short phrase for the search-list narration, e.g. "iconic views, privacy, and long-term scarcity") so the scripts above have real content to pull instead of falling back to generic filler.
