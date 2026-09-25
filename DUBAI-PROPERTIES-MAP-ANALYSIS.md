# Technical Analysis — Dubai Properties Map Dataset

**Source:** [src/NewLandingPage.jsx](src/NewLandingPage.jsx) (`PANDO_PROPERTIES` constant, lines 9–201)
**Rendered by:** [src/RealPandoMap.jsx](src/RealPandoMap.jsx) → [src/RealPandoMapInner.jsx](src/RealPandoMapInner.jsx) (React-Leaflet)

---

## 1. Data Schema

Each entry is a flat JS object with 10 fields:

| Field | Type | Example | Notes |
|---|---|---|---|
| `id` | string (slug) | `"royal-atlantis"` | Used as React `key` and lookup key; **not guaranteed unique in meaning** (see §4.1) |
| `title` | string | `"Royal Atlantis Sky Penthouse"` | Display name, also used as case-insensitive search target |
| `location` | string | `"Palm Jumeirah"` | Free-text area/community name, also searchable |
| `price` | string | `"AED 45.0M"` / `"AED 250K/yr"` | **Unstructured string**, not a number — mixes sale price and annual rent in the same field with a suffix convention |
| `meta` | string | `"4 BR · Apartment"` | Composite display string (bedroom count + type), not separately parsed fields |
| `lat` / `lng` | number | `25.1124` / `55.1390` | WGS-84 decimal degrees, ~4 decimal precision (~11m accuracy) |
| `category` | enum-like string | `Apartments \| Villas \| Off-Plan \| Penthouses \| Townhouses` | Drives the "Filter" flyout |
| `type` | enum-like string | `Buy \| Rent \| Off-Plan` | Drives the header nav (Buy/Rent/Off-Plan/Explore) |
| `image` | string (URL) | Unsplash CDN URL | No local fallback asset except `onerror` → `/cheerful-building.png` in the Leaflet icon HTML |
| `description` | string | Free text | Used to build the TTS narration string |

No TypeScript interface or runtime validation (e.g. zod) constrains this shape — it is plain JS, so a malformed future entry (missing `lat`/`lng`) is only guarded defensively at render time (`RealPandoMapInner.jsx:187`: `if (!prop.lat || !prop.lng) return null;`).

---

## 2. Geospatial Coverage

14 properties total. Bounding box:

| | Latitude | Longitude |
|---|---|---|
| Min | 25.0450 (Arabian Ranches) | 55.1260 (Royal Atlantis Sky Penthouse #2) |
| Max | 25.2340 (Sur La Mer) | 55.3370 (Creek Waters) |
| Span | ≈0.189° (~21 km N–S) | ≈0.211° (~19 km E–W at this latitude) |

Default map camera center is hardcoded to `[25.1400, 55.2200]` ([RealPandoMapInner.jsx:133](src/RealPandoMapInner.jsx#L133)) — roughly mid-way between Downtown Dubai and Business Bay, not the dataset centroid.

Areas represented (community-level clustering):

| Area | Count | Properties |
|---|---|---|
| Palm Jumeirah | 4 | royal-atlantis, palm-frond-villa, como-residences, royal-atlantis-penthouse |
| Downtown Dubai | 1 | burj-khalifa-residences |
| Dubai Marina | 1 | marina-shores |
| Business Bay | 1 | peninsula-one |
| Jumeirah | 1 | jumeirah-living |
| Emirates Hills | 1 | emirates-hills-mansion |
| Dubai Hills | 1 | dubai-hills-golf-villa |
| Dubai Creek Harbour | 1 | creek-waters |
| "Water Canal" | 1 | one-canal-penthouse |
| Port de La Mer | 1 | sur-la-mer-townhouse |
| Arabian Ranches | 1 | arabian-ranches-townhouse |

Palm Jumeirah is heavily over-represented (4/14 = 29%), consistent with it being used as the flagship "luxury" showcase area, but this skews any per-area comparison.

---

## 3. Category / Type Cross-Tab

| Category | Buy | Rent | Off-Plan | Total |
|---|---|---|---|---|
| Apartments | 2 | 3 | 0 | 5 |
| Villas | 2 | 1 | 0 | 3 |
| Off-Plan | 0 | 0 | 2 | 2 |
| Penthouses | 1 | 1 | 0 | 2 |
| Townhouses | 1 | 1 | 0 | 2 |
| **Total** | **6** | **6** | **2** | **14** |

Observation: `category` and `type` are two independent taxonomies that happen to fully overlap only for `Off-Plan` (every Off-Plan-category item also has `type: 'Off-Plan'`). This coupling is implicit, not enforced — a future Off-Plan-category item with `type: 'Buy'` would silently vanish from the "Off-Plan" nav tab's OR-condition at [NewLandingPage.jsx:306](src/NewLandingPage.jsx#L306) unless it also matched `category === 'Off-Plan'`, which it would — so it's actually safe by construction, but only because the OR was written defensively.

---

## 4. Data Quality Issues

### 4.1 Duplicate title across distinct listings
`royal-atlantis` (id) and `royal-atlantis-penthouse` (id) both use the exact title **"Royal Atlantis Sky Penthouse"** ([NewLandingPage.jsx:13](src/NewLandingPage.jsx#L13), [:149](src/NewLandingPage.jsx#L149)) but are different listings:

| id | price | type | category | coords |
|---|---|---|---|---|
| royal-atlantis | AED 45.0M | Buy | Apartments | 25.1124, 55.1390 |
| royal-atlantis-penthouse | AED 3.5M/yr | Rent | Penthouses | 25.1320, 55.1260 |

This breaks the title-based search (`handleSearchSubmit`, [NewLandingPage.jsx:283](src/NewLandingPage.jsx#L283)) — `.find()` always returns the **first** match (`royal-atlantis`), so the second listing is unreachable via search by name, only via the mic-mock shortcut that references its `id` directly.

### 4.2 Unstructured `price` field
Prices mix absolute sale price (`"AED 45.0M"`) and annualized rent (`"AED 250K/yr"`) as strings in the same field, differentiated only by a `/yr` suffix convention and the parallel `type` field. This prevents:
- Numeric sorting/filtering by price range
- Currency-safe formatting or localization
- Any min/max price UI without a bespoke string parser

### 4.3 Reused stock imagery
Only 5 distinct Unsplash image URLs are reused across all 14 properties (e.g. the same `photo-1512453979798` image is used for `royal-atlantis`, `como-residences`, and `royal-atlantis-penthouse`). Visually, unrelated listings across different areas/categories render identical photos.

### 4.4 Inconsistent location naming
`location: 'Water Canal'` (one-canal-penthouse) does not match Dubai's actual district name ("Dubai Water Canal"), and is inconsistent in style with the other entries which use official community names (Palm Jumeirah, Business Bay, etc.). This is cosmetic but affects free-text location search.

### 4.5 No live/mock data separation
The mic-input feature ([NewLandingPage.jsx:241-265](src/NewLandingPage.jsx#L241-L265)) does not perform real speech-to-text — it fakes a 2.5s "listening" delay then randomly selects from a **3-entry hardcoded query list**, each hardcoded to a specific `id`. This is a UI demo stub, not a functional voice search, and will misrepresent capability if presented as working voice search.

---

## 5. Filtering Logic ([NewLandingPage.jsx:294-311](src/NewLandingPage.jsx#L294-L311))

```
filteredProperties = PANDO_PROPERTIES.filter(p => {
  if (activeCategory !== 'All' && p.category !== activeCategory) return false;   // category gate
  if (activeNavTab === 'Buy')      return p.type === 'Buy';
  if (activeNavTab === 'Rent')     return p.type === 'Rent';
  if (activeNavTab === 'Off-Plan') return p.type === 'Off-Plan' || p.category === 'Off-Plan';
  return true;                                                                   // 'Explore' tab: category-filtered, unfiltered by type
})
```

Two-stage filter: category is an AND-gate applied first, then nav-tab type is evaluated. Default nav tab is `'Buy'` ([NewLandingPage.jsx:208](src/NewLandingPage.jsx#L208)), so **on initial page load only the 6 `type: 'Buy'` properties are shown** on the map, even though 14 exist in the dataset — worth knowing if "properties not appearing on the map" is ever reported as a bug, since it is filter state, not missing markers.

---

## 6. Rendering Pipeline (map side)

- **`RealPandoMap.jsx`**: wraps `RealPandoMapInner` behind `next/dynamic` with `ssr: false` — required because Leaflet touches `window`/`document` at import time and would crash during Next.js server-side rendering.
- **`RealPandoMapInner.jsx`**:
  - Base map: `react-leaflet` `MapContainer`, min zoom 3, world-bounds clamped (`maxBounds` full lat/lng range, `maxBoundsViscosity: 1.0`), no default zoom control (custom UI implied elsewhere).
  - Three tile layer options: OpenStreetMap (`street`), Esri World Imagery (`satellite`), Esri World Street Map mislabeled as `terrain` (it is not a genuine terrain/elevation layer — same Esri street basemap family, just a different endpoint).
  - Custom marker: each property renders as an `L.divIcon` combining a floating info card (image + title + favorite button + location) and a mascot-shaped pin image, anchored at `[26, 65]` to align the pin tip with the geocoordinate.
  - `MapZoomListener` rescales pins via a CSS custom property (`--map-pin-scale`) driven off `map.getZoom()`, clamped to `[0.3, 2.5]`, rather than relying on Leaflet's native icon scaling.
  - `MapFlyToController` animates the camera (`flyTo`, 1.5s ease) whenever `selectedProperty` or `zoomLevel` changes — this is how clicking a pin or performing a search re-centers the map.
- **Marker click** → `onSelectProperty(prop)` → `handleSelectProperty` in the parent sets `selectedProperty` and rewrites `speechText`, which triggers the `SpeechSynthesisUtterance` effect (browser TTS, not a hosted voice model) to narrate price/meta/description aloud.

---

## 7. Summary of Technical Risk Areas

1. **No schema validation** on `PANDO_PROPERTIES` — a missing `lat`/`lng` fails silently (marker just doesn't render), a missing `image` triggers the `onerror` fallback, but a typo'd `category`/`type` value silently removes the item from all filters with no warning.
2. **Price is not machine-sortable** — any "sort by price" or "price range slider" feature would require parsing the existing string format first.
3. **Duplicate display titles** for two distinct listings breaks name-based search determinism.
4. **Mic/voice search is a non-functional stub** — cosmetic only, not wired to real speech recognition.
5. **Default view under-represents the catalog** — only `Buy`-type items show on first load, which may look like a data-population bug when it's actually filter defaults.
