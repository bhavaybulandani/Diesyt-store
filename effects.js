/* ═══════════════════════════════════════════════════════════
   effects.js — Film grain, eye rendering, light rays,
                chromatic aberration helpers
   ═══════════════════════════════════════════════════════════ */

'use strict';

/* ══════════════════════════════════════════════════════════
   FILM GRAIN
   Writes random noise onto grainCanvas each frame to simulate
   analogue film grain / sensor noise.
   ══════════════════════════════════════════════════════════ */
class FilmGrain {
  /**
   * @param {HTMLCanvasElement} canvas  — grainCanvas
   */
  constructor(canvas) {
    this.canvas  = canvas;
    this.ctx     = canvas.getContext('2d');
    this.pattern = null;
    this._patternCanvas = document.createElement('canvas');
    this._patternCanvas.width  = 200;
    this._patternCanvas.height = 200;
    this._patCtx = this._patternCanvas.getContext('2d');
  }

  /* Generate one frame of grain */
  update() {
    const pw  = this._patternCanvas.width;
    const ph  = this._patternCanvas.height;
    const img = this._patCtx.createImageData(pw, ph);
    const d   = img.data;

    // Fill with monochrome noise
    for (let i = 0; i < d.length; i += 4) {
      const v = (Math.random() * 255) | 0;
      d[i]   = v;
      d[i+1] = v;
      d[i+2] = v;
      d[i+3] = 255;
    }

    this._patCtx.putImageData(img, 0, 0);

    // Tile across the grain canvas
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    const pat = this.ctx.createPattern(this._patternCanvas, 'repeat');
    if (pat) {
      this.ctx.fillStyle = pat;
      this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
    }
  }

  resize(w, h) {
    this.canvas.width  = w;
    this.canvas.height = h;
    // Re-acquire context after resize clears it
    this.ctx = this.canvas.getContext('2d');
  }
}

/* ══════════════════════════════════════════════════════════
   EYES RENDERER
   Draws a pair of dramatic glowing purple eyes on eyesCanvas.
   Animated: iris pulse, pupil tracking, blink, dissolve.
   ══════════════════════════════════════════════════════════ */
class EyesRenderer {
  /**
   * @param {HTMLCanvasElement} canvas — eyesCanvas
   */
  constructor(canvas) {
    this.canvas   = canvas;
    this.ctx      = canvas.getContext('2d');
    this.phase    = 'idle'; // idle | blink | dissolve
    this.blinkT   = 0;      // 0→1 blink animation t
    this.dissolveT = 0;     // 0→1 dissolve progress
    this.particles = [];    // dissolution particles seeded from eye pixels
    this._blinkStarted = false;
    this._dissolveCB   = null;

    // Cached canvas dims (set by resize)
    this.w = canvas.width;
    this.h = canvas.height;

    this._buildDissolveParticles();
  }

  resize(w, h) {
    this.canvas.width  = w;
    this.canvas.height = h;
    this.w = w;
    this.h = h;
    this._buildDissolveParticles();
  }

  /* Pre-compute the particle positions for the dissolve effect */
  _buildDissolveParticles() {
    this.particles = [];
    const w = this.w;
    const h = this.h;
    const count = 280;

    for (let i = 0; i < count; i++) {
      // Cluster around the two eye positions
      const eye   = i < count / 2 ? 0 : 1;
      const eyeX  = eye === 0 ? w * 0.32 : w * 0.68;
      const eyeY  = h * 0.5;

      this.particles.push({
        x:      eyeX + (Math.random() - 0.5) * w * 0.18,
        y:      eyeY + (Math.random() - 0.5) * h * 0.3,
        vx:     (Math.random() - 0.5) * 1.8,
        vy:     -0.4 - Math.random() * 1.2,
        radius: 0.8 + Math.random() * 2.5,
        alpha:  1,
        hue:    270 + (Math.random() - 0.5) * 30,
        delay:  Math.random() * 0.3,
      });
    }
  }

  /* ── Trigger blink animation ─────────────────────────── */
  blink(onComplete) {
    this.phase       = 'blink';
    this.blinkT      = 0;
    this._blinkDone  = false;
    this._blinkCB    = onComplete || null;
  }

  /* ── Trigger dissolve (eyes → particles) ─────────────── */
  dissolve(onComplete) {
    this.phase      = 'dissolve';
    this.dissolveT  = 0;
    this._dissolveCB = onComplete || null;
  }

  /* ── Draw one eye (called twice, mirrored) ────────────── */
  _drawEye(ctx, cx, cy, w, h, pulseScale, blinkLid) {
    ctx.save();
    ctx.translate(cx, cy);

    const ew = w;   // eye width
    const eh = h;   // eye height

    // Outer diffuse glow (multiple layers for depth)
    for (let g = 4; g >= 1; g--) {
      const grd = ctx.createRadialGradient(0, 0, 0, 0, 0, ew * 1.4 * g * 0.4 * pulseScale);
      const alphaFactor = [0, 0.07, 0.12, 0.18, 0.28][g];
      grd.addColorStop(0, `rgba(168,85,247,${alphaFactor})`);
      grd.addColorStop(1, 'rgba(168,85,247,0)');
      ctx.fillStyle = grd;
      ctx.beginPath();
      ctx.ellipse(0, 0, ew * 1.6 * g * 0.3 * pulseScale, eh * 1.6 * g * 0.3 * pulseScale, 0, 0, Math.PI * 2);
      ctx.fill();
    }

    // Eye shape clip — classic almond shape
    ctx.save();
    ctx.beginPath();
    // Upper lid (influenced by blink)
    const lidOffset = blinkLid * eh;
    ctx.moveTo(-ew, 0);
    ctx.bezierCurveTo(-ew * 0.6, -eh + lidOffset, ew * 0.6, -eh + lidOffset, ew, 0);
    // Lower lid
    ctx.bezierCurveTo(ew * 0.6, eh * 0.85, -ew * 0.6, eh * 0.85, -ew, 0);
    ctx.closePath();
    ctx.clip();

    // Iris base — deep purple
    const irisGrd = ctx.createRadialGradient(0, 0, 0, 0, 0, ew * 0.55 * pulseScale);
    irisGrd.addColorStop(0,   'rgba(220,180,255,1)');
    irisGrd.addColorStop(0.15,'rgba(192,132,252,1)');
    irisGrd.addColorStop(0.5, 'rgba(138, 43,226,1)');
    irisGrd.addColorStop(0.75,'rgba( 88, 18,180,1)');
    irisGrd.addColorStop(1,   'rgba( 40,  5, 80,0)');
    ctx.fillStyle = irisGrd;
    ctx.beginPath();
    ctx.ellipse(0, 0, ew * 0.55 * pulseScale, ew * 0.55 * pulseScale, 0, 0, Math.PI * 2);
    ctx.fill();

    // Pupil — pure black core
    ctx.fillStyle = '#000';
    ctx.beginPath();
    ctx.ellipse(0, 0, ew * 0.18 * pulseScale, ew * 0.22 * pulseScale, 0, 0, Math.PI * 2);
    ctx.fill();

    // Specular highlight
    ctx.fillStyle = 'rgba(255,255,255,0.85)';
    ctx.beginPath();
    ctx.ellipse(-ew * 0.12, -ew * 0.14, ew * 0.05, ew * 0.07, -0.5, 0, Math.PI * 2);
    ctx.fill();

    // Inner iris ring glow
    ctx.strokeStyle = 'rgba(192,132,252,0.9)';
    ctx.lineWidth   = 1.5;
    ctx.shadowColor = 'rgba(168,85,247,1)';
    ctx.shadowBlur  = 8;
    ctx.beginPath();
    ctx.ellipse(0, 0, ew * 0.42 * pulseScale, ew * 0.42 * pulseScale, 0, 0, Math.PI * 2);
    ctx.stroke();

    // Eye whites (very dark, just barely visible)
    const whiteGrd = ctx.createLinearGradient(-ew, 0, ew, 0);
    whiteGrd.addColorStop(0, 'rgba(20,10,40,0.95)');
    whiteGrd.addColorStop(0.3,'rgba(12,5,25,0.5)');
    whiteGrd.addColorStop(0.7,'rgba(12,5,25,0.5)');
    whiteGrd.addColorStop(1, 'rgba(20,10,40,0.95)');
    ctx.fillStyle = whiteGrd;
    ctx.fillRect(-ew, -eh, ew * 2, eh * 2);

    ctx.restore(); // un-clip

    // Upper lash shadow
    ctx.save();
    ctx.fillStyle = 'rgba(7,7,11,0.6)';
    ctx.beginPath();
    ctx.moveTo(-ew, 0);
    ctx.bezierCurveTo(-ew * 0.6, -eh * 0.4 + lidOffset, ew * 0.6, -eh * 0.4 + lidOffset, ew, 0);
    ctx.lineTo(ew, -eh * 2);
    ctx.lineTo(-ew, -eh * 2);
    ctx.closePath();
    ctx.fill();
    ctx.restore();

    ctx.restore();
  }

  /* ── Master update + draw ────────────────────────────── */
  update(timestamp, opacity) {
    const ctx = this.ctx;
    const w   = this.w;
    const h   = this.h;

    ctx.clearRect(0, 0, w, h);

    if (opacity <= 0) return;

    // Eye geometry — responsive
    const eyeW  = w * 0.16;
    const eyeH  = eyeW * 0.38;
    const eyeY  = h * 0.5;
    const leftX = w * 0.32;
    const rightX = w * 0.68;

    // Pulse scale (gentle breath)
    const pulse = 1 + Math.sin(timestamp * 0.0014) * 0.025;

    // Blink lid value (0 = open, 1 = fully closed)
    let blinkLid = 0;
    if (this.phase === 'blink') {
      this.blinkT += 0.022;
      // Half-cosine blink: close → open
      if (this.blinkT < 1) {
        blinkLid = this.blinkT < 0.5
          ? this.blinkT * 2            // close phase
          : (1 - this.blinkT) * 2;    // open phase
      } else {
        this.phase = 'idle';
        blinkLid   = 0;
        if (this._blinkCB) { this._blinkCB(); this._blinkCB = null; }
      }
    }

    ctx.save();
    ctx.globalAlpha = opacity;

    if (this.phase !== 'dissolve') {
      // Normal eye rendering
      this._drawEye(ctx, leftX,  eyeY, eyeW, eyeH, pulse, blinkLid);
      this._drawEye(ctx, rightX, eyeY, eyeW, eyeH, pulse, blinkLid);
    } else {
      // Dissolve: eyes fade out, particles fly upward
      this.dissolveT += 0.008;
      const eyeAlpha = Math.max(0, 1 - this.dissolveT * 2.5);

      if (eyeAlpha > 0) {
        ctx.globalAlpha = opacity * eyeAlpha;
        this._drawEye(ctx, leftX,  eyeY, eyeW, eyeH, pulse, 0);
        this._drawEye(ctx, rightX, eyeY, eyeW, eyeH, pulse, 0);
      }

      // Draw dissolution particles
      for (const p of this.particles) {
        const t = Math.max(0, this.dissolveT - p.delay);
        if (t <= 0) continue;
        p.x      += p.vx;
        p.y      += p.vy;
        p.vy     -= 0.012; // gentle upward acceleration
        p.alpha   = Math.max(0, 1 - t * 1.8);

        ctx.save();
        ctx.globalAlpha = opacity * p.alpha;
        const grd = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, p.radius * 2);
        grd.addColorStop(0, `hsla(${p.hue},80%,70%,1)`);
        grd.addColorStop(1, `hsla(${p.hue},80%,70%,0)`);
        ctx.fillStyle = grd;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.radius * 2, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
      }

      if (this.dissolveT > 1.2 && this._dissolveCB) {
        this._dissolveCB();
        this._dissolveCB = null;
      }
    }

    ctx.restore();
  }
}

/* ══════════════════════════════════════════════════════════
   LIGHT RAYS
   Soft radial rays behind the logo — drawn on bgCanvas.
   ══════════════════════════════════════════════════════════ */
class LightRays {
  constructor() {
    this.opacity = 0;
    this.rayData = Array.from({ length: 9 }, (_, i) => ({
      angle:  (i / 9) * Math.PI * 2 + (Math.random() - 0.5) * 0.4,
      width:  0.04 + Math.random() * 0.06,
      length: 0.35 + Math.random() * 0.25,
      phase:  Math.random() * Math.PI * 2,
      speed:  0.0002 + Math.random() * 0.0003,
    }));
  }

  draw(ctx, cx, cy, maxRadius, timestamp, opacity) {
    if (opacity <= 0) return;

    for (const r of this.rayData) {
      const angle = r.angle + Math.sin(timestamp * r.speed + r.phase) * 0.15;
      const len   = maxRadius * r.length;
      const hw    = r.width; // half-width in radians

      ctx.save();
      ctx.globalAlpha = opacity * 0.18;

      const x1 = cx + Math.cos(angle - hw) * 20;
      const y1 = cy + Math.sin(angle - hw) * 20;
      const x2 = cx + Math.cos(angle) * len;
      const y2 = cy + Math.sin(angle) * len;
      const x3 = cx + Math.cos(angle + hw) * 20;
      const y3 = cy + Math.sin(angle + hw) * 20;

      const grd = ctx.createLinearGradient(cx, cy, x2, y2);
      grd.addColorStop(0,   'rgba(168,85,247,0.6)');
      grd.addColorStop(0.5, 'rgba(138,43,226,0.2)');
      grd.addColorStop(1,   'rgba(138,43,226,0)');

      ctx.fillStyle = grd;
      ctx.beginPath();
      ctx.moveTo(cx, cy);
      ctx.lineTo(x1, y1);
      ctx.lineTo(x2, y2);
      ctx.lineTo(x3, y3);
      ctx.closePath();
      ctx.fill();
      ctx.restore();
    }
  }
}

/* ══════════════════════════════════════════════════════════
   CHROMATIC ABERRATION
   Offsets the logo container's children in RGB channels
   by applying CSS filter + transform in alternating passes.
   Triggered as a transient CSS class.
   ══════════════════════════════════════════════════════════ */
function flashChromaticAberration(element, duration = 600) {
  // Push offset via CSS custom properties on a temporary class
  const style = document.createElement('style');
  const id    = `ca_${Date.now()}`;
  style.textContent = `
    .${id} {
      position: relative;
    }
    .${id}::before,
    .${id}::after {
      content: attr(data-text);
      position: absolute;
      inset: 0;
      pointer-events: none;
    }
    .${id}::before {
      color: rgba(255,0,0,0.25);
      transform: translateX(-2px);
      filter: blur(0.5px);
    }
    .${id}::after {
      color: rgba(0,255,255,0.25);
      transform: translateX(2px);
      filter: blur(0.5px);
    }
  `;
  document.head.appendChild(style);
  element.classList.add(id);

  setTimeout(() => {
    element.classList.remove(id);
    document.head.removeChild(style);
  }, duration);
}

// Export to global scope
window.FilmGrain           = FilmGrain;
window.EyesRenderer        = EyesRenderer;
window.LightRays           = LightRays;
window.flashChromaticAberration = flashChromaticAberration;
