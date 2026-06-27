/* ═══════════════════════════════════════════════════════════
   particles.js — Floating dust particle system
   300+ particles with organic, randomised motion.
   Drawn on the shared bgCanvas via the ParticleSystem class.
   ═══════════════════════════════════════════════════════════ */

'use strict';

class ParticleSystem {
  /**
   * @param {CanvasRenderingContext2D} ctx  — 2D context of bgCanvas
   * @param {number} count                  — number of particles to spawn
   */
  constructor(ctx, count = 320) {
    this.ctx     = ctx;
    this.count   = count;
    this.pool    = [];
    this.width   = ctx.canvas.width;
    this.height  = ctx.canvas.height;
    this._init();
  }

  /* ── Spawn all particles ──────────────────────────────── */
  _init() {
    for (let i = 0; i < this.count; i++) {
      this.pool.push(this._spawn(true));
    }
  }

  /* ── Create a single particle with randomised properties ─ */
  _spawn(anywhere = false) {
    const w = this.width;
    const h = this.height;

    // Bias particles toward center-bottom where logo sits
    const cx = w * 0.5 + (Math.random() - 0.5) * w * 0.9;
    const cy = anywhere
      ? Math.random() * h
      : h + Math.random() * 40;

    // Size spectrum: micro dust → medium glitter
    const radius = Math.random() < 0.7
      ? 0.4 + Math.random() * 1.2   // tiny majority
      : 1.5 + Math.random() * 2.5;  // occasional larger specks

    // Purple-tinted colour with slight hue spread
    const hue  = 270 + (Math.random() - 0.5) * 40;
    const sat  = 60  + Math.random() * 40;
    const lum  = 60  + Math.random() * 35;
    const aMax = 0.08 + Math.random() * 0.55;

    return {
      x:      cx,
      y:      cy,
      radius: radius,
      vx:     (Math.random() - 0.5) * 0.25,  // very slow lateral drift
      vy:     -(0.08 + Math.random() * 0.35), // upward drift
      alpha:  0,
      alphaTarget: aMax,
      alphaMax:    aMax,
      // Perlin-like wobble per particle via independent sine phases
      wobbleFreq:  0.0005 + Math.random() * 0.001,
      wobbleAmp:   0.08  + Math.random() * 0.25,
      wobblePhase: Math.random() * Math.PI * 2,
      // Fade-in / fade-out cycle timing (ms)
      fadeInSpeed:  0.004 + Math.random() * 0.006,
      fadeOutStart: 0.55  + Math.random() * 0.35, // when alpha starts dropping
      // Colour
      hue, sat, lum,
      dead: false,
    };
  }

  /* ── Resize handler ────────────────────────────────────── */
  resize(w, h) {
    this.width  = w;
    this.height = h;
  }

  /* ── Update + draw all particles ──────────────────────── */
  update(timestamp, globalOpacity = 1) {
    const ctx = this.ctx;
    const w   = this.width;
    const h   = this.height;

    for (let i = 0; i < this.pool.length; i++) {
      const p = this.pool[i];

      // Wobble horizontal drift
      const wobble = Math.sin(timestamp * p.wobbleFreq + p.wobblePhase) * p.wobbleAmp;
      p.x += p.vx + wobble * 0.02;
      p.y += p.vy;

      // Alpha lifecycle: fade in → hold → fade out → recycle
      if (p.alpha < p.alphaTarget) {
        p.alpha = Math.min(p.alpha + p.fadeInSpeed, p.alphaTarget);
      }
      // Determine lifecycle position (0→1) based on y travel from bottom
      const lifeRatio = 1 - (p.y / h);
      if (lifeRatio > p.fadeOutStart) {
        const fadeProgress = (lifeRatio - p.fadeOutStart) / (1 - p.fadeOutStart);
        p.alpha = p.alphaMax * Math.max(0, 1 - fadeProgress);
      }

      // Off-screen → recycle
      if (p.y < -10 || p.x < -20 || p.x > w + 20 || p.alpha <= 0.001) {
        this.pool[i] = this._spawn(false);
        continue;
      }

      // Draw
      const finalAlpha = p.alpha * globalOpacity;
      if (finalAlpha < 0.004) continue;

      ctx.save();
      ctx.globalAlpha = finalAlpha;

      // Radial glow for larger particles
      if (p.radius > 1.5) {
        const grd = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, p.radius * 3.5);
        grd.addColorStop(0, `hsla(${p.hue},${p.sat}%,${p.lum}%,1)`);
        grd.addColorStop(1, `hsla(${p.hue},${p.sat}%,${p.lum}%,0)`);
        ctx.fillStyle = grd;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.radius * 3.5, 0, Math.PI * 2);
        ctx.fill();
      }

      // Core dot
      ctx.fillStyle = `hsla(${p.hue},${p.sat}%,${p.lum}%,1)`;
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
      ctx.fill();

      ctx.restore();
    }
  }
}

// Export to global scope for main.js
window.ParticleSystem = ParticleSystem;
