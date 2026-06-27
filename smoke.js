/* ═══════════════════════════════════════════════════════════
   smoke.js — Layered volumetric fog / smoke system
   Uses multiple large soft blobs with independent slow drift
   to simulate procedural volumetric light scattering.
   Drawn on bgCanvas underneath particles.
   ═══════════════════════════════════════════════════════════ */

'use strict';

class SmokeSystem {
  /**
   * @param {CanvasRenderingContext2D} ctx
   * @param {number} layerCount  — number of smoke blobs (8–14 recommended)
   */
  constructor(ctx, layerCount = 12) {
    this.ctx    = ctx;
    this.layers = [];
    this.width  = ctx.canvas.width;
    this.height = ctx.canvas.height;
    this._init(layerCount);
  }

  /* ── Initialise smoke blobs ────────────────────────────── */
  _init(count) {
    for (let i = 0; i < count; i++) {
      this.layers.push(this._makeBlob(true));
    }
  }

  /* ── Create a single smoke blob ────────────────────────── */
  _makeBlob(scatter = false) {
    const w = this.width;
    const h = this.height;

    // Radius: very large so blobs overlap naturally
    const radius = w * (0.22 + Math.random() * 0.35);

    // Position — bias toward vertical center & horizontal center
    const x = scatter
      ? Math.random() * w
      : w * 0.5 + (Math.random() - 0.5) * w * 0.85;
    const y = scatter
      ? Math.random() * h
      : h * 0.45 + (Math.random() - 0.5) * h * 0.7;

    // Purple hue with slight variation
    const hue = 265 + (Math.random() - 0.5) * 30;
    const sat = 50  + Math.random() * 50;
    const lum = 15  + Math.random() * 20;

    // Very low alpha — multiple overlapping blobs build density
    const alphaMax = 0.025 + Math.random() * 0.055;

    return {
      x, y,
      radius,
      // Drift velocity (extremely slow)
      vx:          (Math.random() - 0.5) * 0.08,
      vy:          (Math.random() - 0.5) * 0.04,
      // Independent sine wobble
      wobbleFreq:  0.00015 + Math.random() * 0.0003,
      wobbleAmp:   12      + Math.random() * 20,
      wobblePhase: Math.random() * Math.PI * 2,
      // Scale breathe
      scaleFreq:   0.0002 + Math.random() * 0.0003,
      scaleAmp:    0.04   + Math.random() * 0.08,
      scalePhase:  Math.random() * Math.PI * 2,
      // Colour
      hue, sat, lum,
      alphaMax,
      alpha: scatter ? alphaMax * Math.random() : 0,
      fadeIn: !scatter,
    };
  }

  /* ── Resize ──────────────────────────────────────────────── */
  resize(w, h) {
    this.width  = w;
    this.height = h;
    // Redistribute existing blobs proportionally
    this.layers.forEach(b => {
      b.x = (b.x / this.width)  * w;
      b.y = (b.y / this.height) * h;
    });
  }

  /* ── Update + draw smoke ─────────────────────────────────── */
  update(timestamp, globalOpacity = 1) {
    const ctx = this.ctx;
    const w   = this.width;
    const h   = this.height;

    for (let i = 0; i < this.layers.length; i++) {
      const b = this.layers[i];

      // Drift
      const wobble = Math.sin(timestamp * b.wobbleFreq + b.wobblePhase) * b.wobbleAmp;
      b.x += b.vx + wobble * 0.005;
      b.y += b.vy;

      // Breathe scale
      const scaleOffset = Math.sin(timestamp * b.scaleFreq + b.scalePhase) * b.scaleAmp;
      const r = b.radius * (1 + scaleOffset);

      // Fade in on first entry
      if (b.fadeIn) {
        b.alpha = Math.min(b.alpha + 0.0002, b.alphaMax);
        if (b.alpha >= b.alphaMax) b.fadeIn = false;
      }

      // Wrap horizontally with fade-out at edges so blobs don't just cut
      const margin = r;
      if (b.x < -margin) b.x = w + margin;
      if (b.x > w + margin) b.x = -margin;
      if (b.y < -margin) b.y = h + margin;
      if (b.y > h + margin) b.y = -margin;

      const finalAlpha = b.alpha * globalOpacity;
      if (finalAlpha < 0.003) continue;

      ctx.save();
      ctx.globalAlpha = finalAlpha;

      // Radial gradient — softest possible smoke blob
      const grd = ctx.createRadialGradient(b.x, b.y, 0, b.x, b.y, r);
      grd.addColorStop(0,   `hsla(${b.hue},${b.sat}%,${b.lum + 8}%,1)`);
      grd.addColorStop(0.4, `hsla(${b.hue},${b.sat}%,${b.lum}%,0.6)`);
      grd.addColorStop(1,   `hsla(${b.hue},${b.sat}%,${b.lum}%,0)`);

      ctx.fillStyle = grd;
      ctx.beginPath();
      ctx.arc(b.x, b.y, r, 0, Math.PI * 2);
      ctx.fill();
      ctx.restore();
    }
  }

  /* ── Increase smoke density at a target position (eye reveal) */
  concentrateAt(cx, cy, intensity = 1) {
    // Gently pull all blobs toward cx/cy over time
    this.layers.forEach(b => {
      const dx = cx - b.x;
      const dy = cy - b.y;
      b.vx += dx * 0.000008 * intensity;
      b.vy += dy * 0.000005 * intensity;
      // Clamp velocity
      const speed = Math.sqrt(b.vx * b.vx + b.vy * b.vy);
      if (speed > 0.15) {
        b.vx = (b.vx / speed) * 0.15;
        b.vy = (b.vy / speed) * 0.15;
      }
    });
  }
}

// Export to global scope
window.SmokeSystem = SmokeSystem;
