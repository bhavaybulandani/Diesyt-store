/* ═══════════════════════════════════════════════════════════
   effects.js — Film grain, DEMONIC eye rendering, light rays,
                chromatic aberration helpers
   ═══════════════════════════════════════════════════════════ */

'use strict';

/* ══════════════════════════════════════════════════════════
   FILM GRAIN
   ══════════════════════════════════════════════════════════ */
class FilmGrain {
  constructor(canvas) {
    this.canvas  = canvas;
    this.ctx     = canvas.getContext('2d');
    this._patternCanvas = document.createElement('canvas');
    this._patternCanvas.width  = 200;
    this._patternCanvas.height = 200;
    this._patCtx = this._patternCanvas.getContext('2d');
  }

  update() {
    const pw  = this._patternCanvas.width;
    const ph  = this._patternCanvas.height;
    const img = this._patCtx.createImageData(pw, ph);
    const d   = img.data;
    for (let i = 0; i < d.length; i += 4) {
      const v = (Math.random() * 255) | 0;
      d[i] = d[i+1] = d[i+2] = v;
      d[i+3] = 255;
    }
    this._patCtx.putImageData(img, 0, 0);
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
    this.ctx = this.canvas.getContext('2d');
  }
}

/* ══════════════════════════════════════════════════════════
   DEMONIC EYES RENDERER
   
   Based on reference: Sharp angular slit eyes, pure energy,
   no eyeball — just glowing purple-white cracks in darkness.
   
   Structure per eye:
   1. Massive outer energy corona (huge radial glow)
   2. Purple smoke tendrils radiating from eye edges  
   3. Sharp almond slit shape — angular, cat/demon style
   4. Bright white-hot core fading to purple at edges
   5. Vertical slit pupil (pure darkness, narrow blade)
   6. Inner corona bleed — white center bleeds purple outward
   7. Energy crack lines at corners of the eye
   ══════════════════════════════════════════════════════════ */
class EyesRenderer {
  constructor(canvas) {
    this.canvas    = canvas;
    this.ctx       = canvas.getContext('2d');
    this.phase     = 'idle';    // idle | blink | dissolve
    this.blinkT    = 0;
    this.dissolveT = 0;
    this.particles = [];
    this._blinkCB    = null;
    this._dissolveCB = null;

    this.w = canvas.width;
    this.h = canvas.height;

    // Energy tendril data — randomised once, animated per frame
    this._tendrils = this._buildTendrils();
    this._buildDissolveParticles();
  }

  /* ── Build energy tendril paths around each eye ──────── */
  _buildTendrils() {
    const tendrils = [];
    // 8 tendrils per eye, 2 eyes
    for (let eye = 0; eye < 2; eye++) {
      for (let i = 0; i < 10; i++) {
        // Angle spread: tendrils fan outward from eye corners
        const baseAngle = (i / 10) * Math.PI * 2;
        tendrils.push({
          eye,
          angle:     baseAngle,
          length:    0.3 + Math.random() * 0.5,   // relative to eye half-width
          wobble:    (Math.random() - 0.5) * 0.8,
          wobbleSpd: 0.0008 + Math.random() * 0.0015,
          wobblePhs: Math.random() * Math.PI * 2,
          width:     0.5 + Math.random() * 1.2,
          alpha:     0.15 + Math.random() * 0.35,
          segments:  4 + Math.floor(Math.random() * 3),
        });
      }
    }
    return tendrils;
  }

  /* ── Dissolution particles spawned from eye positions ─── */
  _buildDissolveParticles() {
    this.particles = [];
    const w = this.w;
    const h = this.h;
    const count = 320;

    for (let i = 0; i < count; i++) {
      const eye  = i < count / 2 ? 0 : 1;
      const eyeX = eye === 0 ? w * 0.30 : w * 0.70;
      const eyeY = h * 0.50;

      // Particles spawn densely in the eye slit shape
      const sAngle = (Math.random() - 0.5) * 0.6;
      const sRadius = Math.random() * w * 0.12;

      this.particles.push({
        x:      eyeX + Math.cos(sAngle) * sRadius,
        y:      eyeY + Math.sin(sAngle) * sRadius * 0.25,
        vx:     (Math.random() - 0.5) * 2.2,
        vy:     -0.8 - Math.random() * 2.0,
        radius: 0.6 + Math.random() * 3.0,
        alpha:  1,
        hue:    260 + (Math.random() - 0.5) * 40,
        sat:    70  + Math.random() * 30,
        lum:    55  + Math.random() * 40,
        delay:  Math.random() * 0.25,
        glow:   Math.random() > 0.5,
      });
    }
  }

  resize(w, h) {
    // Store logical dims — canvas pixel dims are set by main.js with DPR
    this.w = w;
    this.h = h;
    // Re-acquire context (canvas dims already set by main.js)
    this.ctx = this.canvas.getContext('2d');
    this._tendrils = this._buildTendrils();
    this._buildDissolveParticles();
  }

  blink(onComplete) {
    this.phase      = 'blink';
    this.blinkT     = 0;
    this._blinkCB   = onComplete || null;
  }

  dissolve(onComplete) {
    this.phase       = 'dissolve';
    this.dissolveT   = 0;
    this._dissolveCB = onComplete || null;
    // Re-seed particles for fresh dissolve
    this._buildDissolveParticles();
  }

  /* ══════════════════════════════════════════════════════
     CORE EYE DRAW — The demonic slit eye
     cx, cy  : center position
     ew      : half-width of the eye
     pulse   : breathing scale factor (1.0 ± 0.03)
     blinkT  : 0=open, 1=fully closed (lid comes DOWN)
     ts      : timestamp for tendril animation
     eyeIdx  : 0=left, 1=right
     ══════════════════════════════════════════════════════ */
  _drawDemonicEye(ctx, cx, cy, ew, pulse, blinkT, ts, eyeIdx) {

    const eh    = ew * 0.28;          // eye half-height — very flat, sharp
    const ps    = pulse;

    /* ── 1. Massive outer energy corona ──────────────────── */
    // Multiple layered radial glows — largest first
    const coronaSizes  = [4.5, 3.0, 2.0, 1.3, 0.85];
    const coronaAlphas = [0.04, 0.08, 0.14, 0.22, 0.35];
    const coronaColors = [
      [88, 28, 200],    // deep violet
      [110, 40, 220],   // mid purple
      [138, 43, 226],   // purple
      [168, 85, 247],   // bright purple
      [210, 160, 255],  // light lavender
    ];

    for (let g = 0; g < coronaSizes.length; g++) {
      const r   = ew * coronaSizes[g] * ps;
      const [cr, cg, cb] = coronaColors[g];
      const grd = ctx.createRadialGradient(cx, cy, 0, cx, cy, r);
      grd.addColorStop(0,   `rgba(${cr},${cg},${cb},${coronaAlphas[g]})`);
      grd.addColorStop(0.6, `rgba(${cr},${cg},${cb},${coronaAlphas[g] * 0.4})`);
      grd.addColorStop(1,   `rgba(${cr},${cg},${cb},0)`);
      ctx.fillStyle = grd;
      ctx.beginPath();
      // Slightly elliptical corona — wider than tall
      ctx.ellipse(cx, cy, r, r * 0.65, 0, 0, Math.PI * 2);
      ctx.fill();
    }

    /* ── 2. Energy tendrils from eye corners ─────────────── */
    const myTendrils = this._tendrils.filter(t => t.eye === eyeIdx);
    for (const t of myTendrils) {
      const wobA   = Math.sin(ts * t.wobbleSpd + t.wobblePhs) * t.wobble;
      const angle  = t.angle + wobA;
      const tLen   = ew * t.length * ps;
      const sx     = cx + Math.cos(t.angle) * ew * 0.7;
      const sy     = cy + Math.sin(t.angle) * eh * 0.5;

      ctx.save();
      ctx.globalAlpha *= t.alpha * 0.7;
      ctx.strokeStyle = 'rgba(168,85,247,0.9)';
      ctx.lineWidth   = t.width;
      ctx.shadowColor = 'rgba(168,85,247,1)';
      ctx.shadowBlur  = 6;
      ctx.lineCap     = 'round';

      // Multi-segment lightning-style tendril
      ctx.beginPath();
      ctx.moveTo(sx, sy);
      let px = sx, py = sy;
      const segLen = tLen / t.segments;
      for (let s = 0; s < t.segments; s++) {
        const frac  = (s + 1) / t.segments;
        const kink  = (Math.random() - 0.5) * ew * 0.08 * (1 - frac);
        const nx    = sx + Math.cos(angle) * segLen * (s + 1) + kink;
        const ny    = sy + Math.sin(angle) * segLen * (s + 1) * 0.5 + kink * 0.3;
        ctx.lineTo(nx, ny);
        px = nx; py = ny;
      }
      ctx.stroke();
      ctx.restore();
    }

    /* ── 3. Eye slit clip region ─────────────────────────── */
    // The slit is a VERY sharp angular almond:
    // - Top edge: comes to a sharp angular V peak at center
    // - Bottom edge: gentle curve
    // - Both taper to sharp points at left & right corners
    ctx.save();

    // Blink: upper lid descends (blinkT goes 0→1→0)
    const lidDrop = blinkT * eh * 2.2;

    ctx.beginPath();
    // Start at left corner
    ctx.moveTo(cx - ew * ps, cy);

    // Upper left edge — angular, blade-like
    ctx.lineTo(cx - ew * ps * 0.45, cy - eh * ps * 0.85 + lidDrop);
    // Top center — sharp peak
    ctx.lineTo(cx,                   cy - eh * ps * 1.0  + lidDrop);
    // Upper right edge
    ctx.lineTo(cx + ew * ps * 0.45, cy - eh * ps * 0.85 + lidDrop);
    // Right corner
    ctx.lineTo(cx + ew * ps, cy);

    // Lower right edge — slight curve
    ctx.quadraticCurveTo(
      cx + ew * ps * 0.5, cy + eh * ps * 0.75,
      cx,                  cy + eh * ps * 0.7
    );
    // Lower left edge
    ctx.quadraticCurveTo(
      cx - ew * ps * 0.5, cy + eh * ps * 0.75,
      cx - ew * ps, cy
    );
    ctx.closePath();
    ctx.clip();

    /* ── 4. Interior eye fill: white-hot core → purple edge ─ */
    // Full fill — bright purple base
    const eyeBaseFill = ctx.createRadialGradient(cx, cy, 0, cx, cy, ew * 0.9 * ps);
    eyeBaseFill.addColorStop(0,    'rgba(255,245,255,1)');   // near-white hot center
    eyeBaseFill.addColorStop(0.12, 'rgba(230,190,255,1)');   // soft white-purple
    eyeBaseFill.addColorStop(0.30, 'rgba(192,100,255,1)');   // vivid purple
    eyeBaseFill.addColorStop(0.55, 'rgba(138, 43,226,1)');   // deep purple
    eyeBaseFill.addColorStop(0.80, 'rgba( 80, 20,160,1)');   // dark violet
    eyeBaseFill.addColorStop(1,    'rgba( 30,  5, 60,1)');   // near black edge
    ctx.fillStyle = eyeBaseFill;
    ctx.fillRect(cx - ew * 2, cy - eh * 3, ew * 4, eh * 6);

    /* ── 5. Vertical slit pupil — angular blade shape ─────── */
    const slitW = ew * 0.055 * ps;
    const slitH = eh * 1.55  * ps;
    ctx.save();

    // Diamond/blade slit shape
    ctx.beginPath();
    ctx.moveTo(cx,          cy - slitH);
    ctx.lineTo(cx + slitW,  cy);
    ctx.lineTo(cx,          cy + slitH);
    ctx.lineTo(cx - slitW,  cy);
    ctx.closePath();

    // Slit is pure black with a tiny purple inner glow at edges
    const slitGrd = ctx.createRadialGradient(cx, cy, 0, cx, cy, slitW * 2);
    slitGrd.addColorStop(0,   'rgba(0,0,0,1)');
    slitGrd.addColorStop(0.7, 'rgba(0,0,0,1)');
    slitGrd.addColorStop(1,   'rgba(60,0,100,0.8)');
    ctx.fillStyle = slitGrd;
    ctx.fill();
    ctx.restore();

    /* ── 6. Inner iris detail rings (visible around slit) ─── */
    // Subtle concentric light rings inside the eye
    for (let ring = 0; ring < 3; ring++) {
      const rr = ew * (0.25 + ring * 0.18) * ps;
      const ringAlpha = 0.25 - ring * 0.06;
      ctx.strokeStyle = `rgba(210,160,255,${ringAlpha})`;
      ctx.lineWidth = 0.6;
      ctx.shadowColor = 'rgba(168,85,247,0.8)';
      ctx.shadowBlur  = 4;
      ctx.beginPath();
      ctx.ellipse(cx, cy, rr, rr * 0.4, 0, 0, Math.PI * 2);
      ctx.stroke();
    }

    /* ── 7. White-hot center bleed through slit ─────────── */
    // A bright horizontal streak — the "burning" core of the slit
    const burnGrd = ctx.createLinearGradient(cx - ew * 0.4 * ps, cy, cx + ew * 0.4 * ps, cy);
    burnGrd.addColorStop(0,   'rgba(255,255,255,0)');
    burnGrd.addColorStop(0.35,'rgba(255,240,255,0.6)');
    burnGrd.addColorStop(0.5, 'rgba(255,255,255,0.95)');
    burnGrd.addColorStop(0.65,'rgba(255,240,255,0.6)');
    burnGrd.addColorStop(1,   'rgba(255,255,255,0)');
    ctx.fillStyle = burnGrd;
    ctx.fillRect(cx - ew * 0.5 * ps, cy - eh * 0.18 * ps, ew * ps, eh * 0.36 * ps);

    ctx.restore(); // un-clip eye slit

    /* ── 8. Post-clip: corner crack sparks ───────────────── */
    // Bright flare points at the sharp eye corners
    const corners = [
      { x: cx - ew * ps, y: cy },
      { x: cx + ew * ps, y: cy },
    ];
    for (const corner of corners) {
      const cGrd = ctx.createRadialGradient(corner.x, corner.y, 0, corner.x, corner.y, ew * 0.25 * ps);
      cGrd.addColorStop(0,   'rgba(255,255,255,0.9)');
      cGrd.addColorStop(0.2, 'rgba(210,160,255,0.6)');
      cGrd.addColorStop(0.5, 'rgba(138, 43,226,0.3)');
      cGrd.addColorStop(1,   'rgba(138, 43,226,0)');
      ctx.fillStyle = cGrd;
      ctx.beginPath();
      ctx.ellipse(corner.x, corner.y, ew * 0.22 * ps, ew * 0.12 * ps, 0, 0, Math.PI * 2);
      ctx.fill();
    }

    /* ── 9. Top lid shadow (dark overlay above slit line) ─── */
    // After opening clip, paint darkness above the eye center
    // to emphasize the dramatic upper shadow
    const shadowGrd = ctx.createLinearGradient(cx, cy - eh * 1.2, cx, cy - eh * 0.1);
    shadowGrd.addColorStop(0,   'rgba(7,7,11,0.75)');
    shadowGrd.addColorStop(0.5, 'rgba(7,7,11,0.4)');
    shadowGrd.addColorStop(1,   'rgba(7,7,11,0)');
    ctx.fillStyle = shadowGrd;
    ctx.fillRect(cx - ew * 1.1, cy - eh * 1.5, ew * 2.2, eh * 1.5);
  }

  /* ── Master update + draw ────────────────────────────── */
  update(timestamp, opacity) {
    const ctx = this.ctx;
    const w   = this.w;
    const h   = this.h;

    ctx.clearRect(0, 0, w, h);
    if (opacity <= 0) return;

    // Eye geometry
    const ew   = w * 0.185;          // half-width — large, dominant
    const eyeY = h * 0.50;
    const leftX  = w * 0.30;
    const rightX = w * 0.70;

    // Gentle pulse breathe
    const pulse = 1 + Math.sin(timestamp * 0.0013) * 0.028;

    // Slow secondary intensity pulse (energy surge feel)
    const surge = 0.5 + 0.5 * Math.abs(Math.sin(timestamp * 0.0009));

    // Blink: lid travels down 0→1→0
    let blinkT = 0;
    if (this.phase === 'blink') {
      this.blinkT += 0.018;
      if (this.blinkT < 1) {
        blinkT = this.blinkT < 0.5
          ? this.blinkT * 2
          : (1 - this.blinkT) * 2;
        blinkT = blinkT * blinkT * (3 - 2 * blinkT); // smooth-step
      } else {
        this.phase = 'idle';
        blinkT = 0;
        if (this._blinkCB) { this._blinkCB(); this._blinkCB = null; }
      }
    }

    ctx.save();
    ctx.globalAlpha = opacity;

    if (this.phase !== 'dissolve') {
      // Draw both demonic eyes
      ctx.save();
      // Subtle surge brightness modulation on the canvas
      ctx.globalAlpha = opacity * (0.85 + surge * 0.15);
      this._drawDemonicEye(ctx, leftX,  eyeY, ew, pulse, blinkT, timestamp, 0);
      this._drawDemonicEye(ctx, rightX, eyeY, ew, pulse, blinkT, timestamp, 1);
      ctx.restore();

    } else {
      // ── Dissolve phase ──────────────────────────────────
      this.dissolveT += 0.007;
      const eyeAlpha = Math.max(0, 1 - this.dissolveT * 2.2);

      if (eyeAlpha > 0.01) {
        ctx.save();
        ctx.globalAlpha = opacity * eyeAlpha;
        this._drawDemonicEye(ctx, leftX,  eyeY, ew, pulse, 0, timestamp, 0);
        this._drawDemonicEye(ctx, rightX, eyeY, ew, pulse, 0, timestamp, 1);
        ctx.restore();
      }

      // Dissolution sparks scatter upward then drift
      for (const p of this.particles) {
        const t = Math.max(0, this.dissolveT - p.delay);
        if (t <= 0) continue;

        p.x  += p.vx * 0.98;
        p.y  += p.vy;
        p.vy -= 0.018;           // upward acceleration
        p.vx *= 0.994;
        p.alpha = Math.max(0, 1 - t * 1.6);

        if (p.alpha < 0.005) continue;

        ctx.save();
        ctx.globalAlpha = opacity * p.alpha;

        if (p.glow) {
          // Glowing spark with halo
          const gr = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, p.radius * 3.5);
          gr.addColorStop(0, `hsla(${p.hue},${p.sat}%,${p.lum + 20}%,1)`);
          gr.addColorStop(0.4, `hsla(${p.hue},${p.sat}%,${p.lum}%,0.5)`);
          gr.addColorStop(1, `hsla(${p.hue},${p.sat}%,${p.lum}%,0)`);
          ctx.fillStyle = gr;
          ctx.beginPath();
          ctx.arc(p.x, p.y, p.radius * 3.5, 0, Math.PI * 2);
          ctx.fill();
        }

        // Core spark dot
        ctx.fillStyle = `hsla(${p.hue},${p.sat}%,${p.lum + 15}%,1)`;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
      }

      if (this.dissolveT > 1.4 && this._dissolveCB) {
        this._dissolveCB();
        this._dissolveCB = null;
      }
    }

    ctx.restore();
  }
}

/* ══════════════════════════════════════════════════════════
   LIGHT RAYS behind logo
   ══════════════════════════════════════════════════════════ */
class LightRays {
  constructor() {
    this.rayData = Array.from({ length: 10 }, (_, i) => ({
      angle:  (i / 10) * Math.PI * 2 + (Math.random() - 0.5) * 0.5,
      width:  0.04 + Math.random() * 0.07,
      length: 0.3  + Math.random() * 0.3,
      phase:  Math.random() * Math.PI * 2,
      speed:  0.00015 + Math.random() * 0.0003,
    }));
  }

  draw(ctx, cx, cy, maxRadius, timestamp, opacity) {
    if (opacity <= 0) return;
    for (const r of this.rayData) {
      const angle = r.angle + Math.sin(timestamp * r.speed + r.phase) * 0.18;
      const len   = maxRadius * r.length;
      const hw    = r.width;

      ctx.save();
      ctx.globalAlpha = opacity * 0.15;

      const x2 = cx + Math.cos(angle) * len;
      const y2 = cy + Math.sin(angle) * len;

      const grd = ctx.createLinearGradient(cx, cy, x2, y2);
      grd.addColorStop(0,   'rgba(168,85,247,0.7)');
      grd.addColorStop(0.4, 'rgba(138,43,226,0.25)');
      grd.addColorStop(1,   'rgba(138,43,226,0)');

      ctx.fillStyle = grd;
      ctx.beginPath();
      ctx.moveTo(cx, cy);
      ctx.lineTo(
        cx + Math.cos(angle - hw) * 22,
        cy + Math.sin(angle - hw) * 22
      );
      ctx.lineTo(x2, y2);
      ctx.lineTo(
        cx + Math.cos(angle + hw) * 22,
        cy + Math.sin(angle + hw) * 22
      );
      ctx.closePath();
      ctx.fill();
      ctx.restore();
    }
  }
}

/* ══════════════════════════════════════════════════════════
   CHROMATIC ABERRATION — brief flash on logo
   ══════════════════════════════════════════════════════════ */
function flashChromaticAberration(element, duration = 600) {
  const style = document.createElement('style');
  const id    = `ca_${Date.now()}`;
  style.textContent = `
    .${id} { filter: none; animation: _ca_${id} ${duration}ms steps(3) forwards; }
    @keyframes _ca_${id} {
      0%   { filter: drop-shadow(-3px 0 rgba(255,0,128,0.6)) drop-shadow(3px 0 rgba(0,255,255,0.6)); }
      33%  { filter: drop-shadow(2px 0 rgba(255,0,0,0.4))   drop-shadow(-2px 0 rgba(0,200,255,0.4)); }
      66%  { filter: drop-shadow(-1px 0 rgba(180,0,255,0.5)) drop-shadow(1px 0 rgba(0,255,200,0.5)); }
      100% { filter: none; }
    }
  `;
  document.head.appendChild(style);
  element.classList.add(id);
  setTimeout(() => {
    element.classList.remove(id);
    document.head.removeChild(style);
  }, duration + 100);
}

// Export to global scope
window.FilmGrain                = FilmGrain;
window.EyesRenderer             = EyesRenderer;
window.LightRays                = LightRays;
window.flashChromaticAberration = flashChromaticAberration;
