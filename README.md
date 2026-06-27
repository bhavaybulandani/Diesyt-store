# DIESYT STORE — Cinematic Loading Screen

A production-ready 10-second AAA cinematic loader built in pure HTML5, CSS3, and Vanilla JavaScript. No frameworks, no external animation libraries.

---

## Project Structure

```
loader/
├── index.html      Entry point — DOM skeleton, canvas layers, script loading order
├── style.css       All styling: layout, letter gradients, bar glass effect, keyframes
├── particles.js    300+ floating dust particles with organic randomised motion
├── smoke.js        12-layer volumetric fog blobs with slow drift and breathe-scale
├── effects.js      Film grain, eye renderer (iris/pupil/glow), light rays, chromatic aberration
├── main.js         Master orchestrator — 10s scene timeline, rAF loop, all transitions
└── assets/         (Place any future icon/font assets here)
```

---

## Scene Breakdown

| Time       | Scene                          | What Happens                                              |
|------------|--------------------------------|-----------------------------------------------------------|
| 0.0 – 2.0s | **Dark Atmosphere**            | Purple fog, 300+ floating particles, film grain fade-in   |
| 2.0 – 4.0s | **Eyes**                       | Glowing purple iris eyes emerge, pulse, blink, dissolve   |
| 4.0 – 6.0s | **DIESYT Reveal**              | Letters fly in one-by-one with bloom + RGB glitch flash   |
| 6.0 – 8.0s | **STORE + Scanner**            | Sub-line appears, scanner traverses logo, chromatic burst |
| 8.0 – 10.0s| **Loading + Status**           | Cycling status text, glass loading bar fills to 100%      |
| 10.2s+     | **Transition**                 | Smooth opacity fade to homepage — no black flash          |

---

## Technology

- **HTML5 Canvas (2D)** — smoke, particles, film grain, eyes, light rays
- **CSS3** — GPU-accelerated transforms, letter gradients, glass loading bar, keyframe glitch
- **Vanilla JavaScript** — rAF loop, smoothstep interpolation, scene timeline, all DOM mutations
- **No Three.js** — all WebGL-level richness achieved via layered 2D Canvas techniques

---

## Color Palette

| Role           | Hex       |
|----------------|-----------|
| Background     | `#07070B` |
| Primary Purple | `#8A2BE2` |
| Accent Purple  | `#A855F7` |
| Soft Purple    | `#C084FC` |
| White          | `#FFFFFF` |

---

## Performance

- All animations are `transform` / `opacity` / `filter` — no layout thrashing
- `will-change` applied to every animated layer
- Canvas operations batched per frame; `globalAlpha` set once per draw call
- Target: **60 FPS** on mid-range hardware
- Respects `prefers-reduced-motion` via CSS media query

---

## Responsive Behaviour

- Logo uses `clamp()` for fluid type sizing from 320px → 2560px viewports
- All canvas elements fill 100vw × 100vh and scale via DPR for retina sharpness
- Eyes canvas uses CSS `width: min(700px, 90vw)` to remain contained on mobile

---

## Usage

Open `index.html` in any modern browser. No build step required.

```bash
# Simple local server (Python)
cd loader
python3 -m http.server 8080
# then open http://localhost:8080
```

---

## Customisation

| What to change          | Where                                          |
|-------------------------|------------------------------------------------|
| Brand name / text       | `index.html` — letter `<span>` elements        |
| Color palette           | `style.css` — `:root` custom properties        |
| Timeline durations      | `main.js` — `driveTimeline()` time constants   |
| Particle count          | `main.js` — `new ParticleSystem(bgCtx, 320)`   |
| Smoke layer density     | `main.js` — `new SmokeSystem(bgCtx, 14)`       |
| Status messages         | `main.js` — `STATUS_MESSAGES` array            |
| Eye appearance          | `effects.js` — `EyesRenderer._drawEye()`       |
