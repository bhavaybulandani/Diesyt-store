/* ═══════════════════════════════════════════════════════════
   main.js — DIESYT STORE Cinematic Loader Orchestrator
   Drives the full 10-second scene timeline at 60 FPS.

   Scene map:
     0.0 – 2.0s  Scene 1: Dark atmosphere, smoke, particles
     2.0 – 4.0s  Scene 2: Eyes appear, pulse, blink, dissolve
     4.0 – 6.0s  Scene 3: "DIESYT" letters form letter-by-letter
     6.0 – 8.0s  Scene 4: "STORE" + scanner + chrom. aberration
     8.0 – 10.0s Scene 5: Status text cycling + loading bar
     10.0s+       Fade to homepage
   ═══════════════════════════════════════════════════════════ */

'use strict';

/* ── DOM references ─────────────────────────────────────── */
const bgCanvas    = document.getElementById('bgCanvas');
const grainCanvas = document.getElementById('grainCanvas');
const eyesCanvas  = document.getElementById('eyesCanvas');
const bgCtx       = bgCanvas.getContext('2d');

const loaderEl    = document.getElementById('loader');
const eyesCont    = document.getElementById('eyesContainer');
const logoCont    = document.getElementById('logoContainer');
const logoWrap    = document.getElementById('logoWrap');
const logoMain    = document.getElementById('logoMain');
const logoSub     = document.getElementById('logoSub');
const scanLine    = document.getElementById('scanLine');
const logoBloom   = document.getElementById('logoBloom');
const statusCont  = document.getElementById('statusContainer');
const statusText  = document.getElementById('statusText');
const loadFill    = document.getElementById('loadBarFill');
const loadPct     = document.getElementById('loadPercent');
const homepage    = document.getElementById('homepage');
const letters     = Array.from(document.querySelectorAll('.letter'));

/* ── Systems ─────────────────────────────────────────────── */
let particles, smoke, grain, eyes, rays;

/* ── Timeline state ─────────────────────────────────────── */
let startTime = null;
let raf       = null;
let scenePhase = 0;   // which scene events have fired

/* ── Load bar state ──────────────────────────────────────── */
const STATUS_MESSAGES = [
  'INITIALIZING...',
  'CONNECTING MARKETPLACE...',
  'VERIFYING INVENTORY...',
  'LOADING STORE...',
  'ACCESS GRANTED',
];
let barProgress   = 0;        // 0 → 100
let barTarget     = 0;        // driven by timeline
let currentStatus = 0;        // index into STATUS_MESSAGES

/* ── Ambient purple glow intensity (grows over time) ─────── */
let ambientGlow = 0;

/* ── Global opacity controls ─────────────────────────────── */
let smokeOpacity    = 0;
let particleOpacity = 0;
let eyesOpacity     = 0;
let logoOpacity     = 0;
let raysOpacity     = 0;

/* ── Scene-event flags (fire-once) ──────────────────────── */
const flags = {
  eyesFadeIn:      false,
  eyesBlink:       false,
  eyesDissolve:    false,
  logoReveal:      false,
  storeReveal:     false,
  scannerRun:      false,
  chromAberration: false,
  statusShow:      false,
  barActive:       false,
  accessGranted:   false,
  fadeOut:         false,
};

/* ═══════════════════════════════════════════════════════════
   INIT
   ═══════════════════════════════════════════════════════════ */
function init() {
  resize();
  // Debounce resize to avoid thrash on window drag
  let resizeTimer = null;
  window.addEventListener('resize', () => {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(resize, 120);
  });

  /* Instantiate all subsystems */
  particles = new ParticleSystem(bgCtx, 320);
  smoke     = new SmokeSystem(bgCtx, 14);
  grain     = new FilmGrain(grainCanvas);
  eyes      = new EyesRenderer(eyesCanvas);
  rays      = new LightRays();

  /* Start rAF loop */
  raf = requestAnimationFrame(tick);
}

/* ── Resize all canvases to pixel-perfect dimensions ─────── */
function resize() {
  const dpr = Math.min(window.devicePixelRatio || 1, 2);
  const w   = window.innerWidth;
  const h   = window.innerHeight;

  // Re-assign width/height (this resets the context transform too),
  // then apply DPR scale once — safe to call every resize.
  [bgCanvas, grainCanvas].forEach(c => {
    c.width  = Math.round(w * dpr);
    c.height = Math.round(h * dpr);
    c.style.width  = `${w}px`;
    c.style.height = `${h}px`;
    const ctx = c.getContext('2d');
    // Setting .width resets the transform, so scale is always applied fresh
    if (ctx) ctx.scale(dpr, dpr);
  });

  // eyesCanvas: full-viewport so massive demonic corona fills entire screen
  const dprE = Math.min(window.devicePixelRatio || 1, 2);
  eyesCanvas.width        = Math.round(w * dprE);
  eyesCanvas.height       = Math.round(h * dprE);
  eyesCanvas.style.width  = w + 'px';
  eyesCanvas.style.height = h + 'px';
  const eyeCtx = eyesCanvas.getContext('2d');
  if (eyeCtx) { eyeCtx.setTransform(1,0,0,1,0,0); eyeCtx.scale(dprE, dprE); }

  if (particles) particles.resize(w, h);
  if (smoke)     smoke.resize(w, h);
  if (grain)     grain.resize(w, h);
  if (eyes)      eyes.resize(w, h);
}

/* ═══════════════════════════════════════════════════════════
   MAIN ANIMATION LOOP
   ═══════════════════════════════════════════════════════════ */
function tick(timestamp) {
  if (!startTime) startTime = timestamp;
  const elapsed = (timestamp - startTime) / 1000;  // seconds

  /* ── Clear background canvas ─────────────────────────── */
  const w = window.innerWidth;
  const h = window.innerHeight;
  bgCtx.clearRect(0, 0, w, h);

  /* ── Fill base background with slight purple tint ─────── */
  const bgAlpha = 0.02 + ambientGlow * 0.04;
  bgCtx.fillStyle = `rgba(20,5,40,${bgAlpha})`;
  bgCtx.fillRect(0, 0, w, h);

  /* ── Drive scene transitions ─────────────────────────── */
  driveTimeline(elapsed, timestamp);

  /* ── Draw order: smoke → rays → particles ─────────────── */
  smoke.update(timestamp, smokeOpacity);

  if (raysOpacity > 0) {
    rays.draw(bgCtx, w * 0.5, h * 0.5 - h * 0.05, Math.min(w, h) * 0.6, timestamp, raysOpacity);
  }

  particles.update(timestamp, particleOpacity);

  /* ── Film grain (every frame for dynamic noise) ──────── */
  grain.update();

  /* ── Ambient purple center glow (grows in Scene 4) ────── */
  if (ambientGlow > 0) {
    const grd = bgCtx.createRadialGradient(w * 0.5, h * 0.48, 0, w * 0.5, h * 0.48, w * 0.4);
    grd.addColorStop(0,   `rgba(138,43,226,${ambientGlow * 0.12})`);
    grd.addColorStop(0.5, `rgba(88,28,135,${ambientGlow * 0.06})`);
    grd.addColorStop(1,   'rgba(7,7,11,0)');
    bgCtx.fillStyle = grd;
    bgCtx.fillRect(0, 0, w, h);
  }

  /* ── Eyes layer ──────────────────────────────────────── */
  eyes.update(timestamp, eyesOpacity);

  /* ── Load bar progress ───────────────────────────────── */
  if (flags.barActive) {
    barProgress += (barTarget - barProgress) * 0.04;
    barProgress  = Math.min(barProgress, barTarget);
    loadFill.style.width  = `${barProgress}%`;
    loadPct.textContent   = `${Math.round(barProgress)}%`;
  }

  raf = requestAnimationFrame(tick);
}

/* ═══════════════════════════════════════════════════════════
   SCENE TIMELINE DRIVER
   All timing in seconds, called every frame.
   ═══════════════════════════════════════════════════════════ */
function driveTimeline(t, timestamp) {

  /* ── SCENE 1: 0.0 – 2.0s ─────────────────────────────
     Dark atmosphere: smoke + particles slowly fade in.     */
  smokeOpacity    = smoothstep(0, 1.2, t);
  particleOpacity = smoothstep(0.3, 2.0, t);

  /* ── SCENE 2: 2.0 – 4.0s ────────────────────────────
     Eyes appear.                                           */
  if (t >= 2.0 && !flags.eyesFadeIn) {
    flags.eyesFadeIn = true;
    eyesCont.style.opacity = '1';
    eyesCont.style.transition = 'opacity 0.8s ease';
  }
  if (t >= 2.0) {
    eyesOpacity = smoothstep(2.0, 3.0, t);
  }

  // Concentrate smoke toward eyes
  if (t >= 2.0 && t < 4.5) {
    const w = window.innerWidth;
    const h = window.innerHeight;
    smoke.concentrateAt(w * 0.5, h * 0.5, 0.5);
  }

  // Blink once at ~3.4s
  if (t >= 3.4 && !flags.eyesBlink) {
    flags.eyesBlink = true;
    eyes.blink(() => {
      // After blink: dissolve into particles at 3.8s
      setTimeout(() => {
        if (!flags.eyesDissolve) {
          flags.eyesDissolve = true;
          eyes.dissolve(() => {
            // Eyes done — hide container
            eyesCont.style.opacity = '0';
          });
        }
      }, 400);
    });
  }

  /* ── SCENE 3: 4.0 – 6.0s ─────────────────────────────
     "DIESYT" forms letter by letter.                      */
  if (t >= 4.0 && !flags.logoReveal) {
    flags.logoReveal = true;
    // Show logo container
    logoCont.style.opacity    = '1';
    logoCont.style.transition = 'opacity 0.3s ease';

    // Stagger letter reveals
    letters.forEach((el, i) => {
      const delay = 200 + i * 180; // 200ms base + 180ms per letter
      setTimeout(() => {
        el.classList.add('visible');
        // RGB glitch on each letter 80ms after visible
        setTimeout(() => {
          el.classList.add('glitch');
          setTimeout(() => el.classList.remove('glitch'), 200);
        }, 80);
      }, delay);
    });
  }

  // Fade eyes out as logo comes in
  if (t >= 4.0) {
    eyesOpacity = Math.max(0, 1 - smoothstep(4.0, 5.0, t) * 1.5);
  }

  // Logo opacity fades in
  if (t >= 4.0) {
    logoOpacity = smoothstep(4.0, 5.2, t);
  }

  // Ambient glow starts growing
  if (t >= 4.5) {
    ambientGlow = smoothstep(4.5, 7.0, t);
  }

  /* ── SCENE 4: 6.0 – 8.0s ─────────────────────────────
     "STORE" fades in. Scanner line. Chromatic aberration. */
  if (t >= 6.0 && !flags.storeReveal) {
    flags.storeReveal = true;
    logoSub.classList.add('visible');
  }

  // Light rays ramp up
  if (t >= 6.0) {
    raysOpacity = smoothstep(6.0, 7.5, t);
  }

  // Scanner line traverses once at 6.4s
  if (t >= 6.4 && !flags.scannerRun) {
    flags.scannerRun = true;
    runScannerLine();
  }

  // Chromatic aberration on logo wrap at 6.8s
  if (t >= 6.8 && !flags.chromAberration) {
    flags.chromAberration = true;
    flashChromaticAberration(logoWrap, 500);
    // Bloom pulse
    logoBloom.style.opacity = '1';
    setTimeout(() => { logoBloom.style.opacity = '0'; }, 600);
  }

  /* ── SCENE 5: 8.0 – 10.0s ────────────────────────────
     Status text cycling + loading bar.                    */
  if (t >= 8.0 && !flags.statusShow) {
    flags.statusShow = true;
    statusCont.classList.add('visible');
    flags.barActive = true;
    startStatusCycle();
  }

  // Bar target grows with time
  if (t >= 8.0) {
    const barT = smoothstep(8.0, 9.8, t);
    barTarget = barT * 100;
  }

  // ACCESS GRANTED at 9.5s
  if (t >= 9.5 && !flags.accessGranted) {
    flags.accessGranted = true;
    setStatus('ACCESS GRANTED');
    barTarget = 100;
    // Pulse logo
    logoMain.classList.add('logo-pulse');
    logoBloom.style.opacity = '1';
    setTimeout(() => { logoBloom.style.opacity = '0'; logoMain.classList.remove('logo-pulse'); }, 1000);
  }

  // Fade to homepage at 10.2s
  if (t >= 10.2 && !flags.fadeOut) {
    flags.fadeOut = true;
    fadeToHomepage();
  }
}

/* ═══════════════════════════════════════════════════════════
   SCANNER LINE
   Animates a horizontal highlight bar from top to bottom
   of the logo area over 600ms.
   ═══════════════════════════════════════════════════════════ */
function runScannerLine() {
  const logoRect = logoWrap.getBoundingClientRect();
  const loaderRect = loaderEl.getBoundingClientRect();

  const totalH = logoRect.height + 20;
  const startY = 0;

  scanLine.style.opacity   = '1';
  scanLine.style.top       = `${startY}px`;
  scanLine.style.transition = 'none';

  // Force reflow
  void scanLine.offsetHeight;

  scanLine.style.transition = `top 0.65s cubic-bezier(0.4, 0, 0.2, 1),
                                opacity 0.2s ease`;
  scanLine.style.top        = `${totalH}px`;

  setTimeout(() => {
    scanLine.style.opacity = '0';
  }, 600);
}

/* ═══════════════════════════════════════════════════════════
   STATUS TEXT CYCLE
   Fades through the STATUS_MESSAGES array.
   ═══════════════════════════════════════════════════════════ */
function startStatusCycle() {
  setStatus(STATUS_MESSAGES[0]);

  const intervals = [0, 400, 850, 1300, 1700]; // ms offsets per message
  STATUS_MESSAGES.forEach((msg, i) => {
    if (i === 0) return;
    setTimeout(() => setStatus(msg), intervals[i]);
  });
}

function setStatus(msg) {
  statusText.classList.remove('visible');
  setTimeout(() => {
    statusText.textContent = msg;
    statusText.classList.add('visible');
  }, 200);
}

/* ═══════════════════════════════════════════════════════════
   FADE TO HOMEPAGE
   ═══════════════════════════════════════════════════════════ */
function fadeToHomepage() {
  cancelAnimationFrame(raf);

  loaderEl.classList.add('fade-out');

  // Reveal homepage simultaneously
  homepage.removeAttribute('aria-hidden');
  homepage.classList.add('visible');

  // Remove loader from DOM after transition
  setTimeout(() => {
    loaderEl.style.display = 'none';
  }, 1400);
}

/* ═══════════════════════════════════════════════════════════
   UTILITY — Smooth-step interpolation
   ═══════════════════════════════════════════════════════════ */
function smoothstep(edge0, edge1, x) {
  const t = Math.max(0, Math.min(1, (x - edge0) / (edge1 - edge0)));
  return t * t * (3 - 2 * t);
}

/* ── Kick everything off on DOMContentLoaded ─────────────── */
document.addEventListener('DOMContentLoaded', init);
