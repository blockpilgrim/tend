# Radiant Core — wow-factor iteration ideas

**Purpose:** capture iterative animation/rendering ideas to make the Radiant Core feel more alive, rewarding, and “admire-worthy,” while staying aligned with the Concept Brief and Radiant Core Specification.

**Last updated:** 2026-01-14

---

## Current implementation (ground truth)

### Render stack (SpriteKit)

The Core is fully procedural today (no `.sks` particle files, no `SKShader`, no `SKLightNode`).

**Scene / orchestration**
- `Tend/Presentation/Core/SpriteKit/RadiantCoreScene.swift`
  - Owns: `CoreNode`, `BreathingController`, `ParticleManager`, `PhysicsManager`
  - Drives update loop and touch → impulse / tap flash / particle bursts

**Core visuals**
- `Tend/Presentation/Core/SpriteKit/CoreNode.swift`
  - Textures generated at runtime via `CoreTextureGenerator`
  - Visual layers (bottom → top):
    1. `backgroundGlow` (`.add`)
    2. `subsurfaceGlow` inside `SKEffectNode` (`.add`, rasterized)
    3. `outerSurface` (`.alpha`)
    4. `innerCore` (`.add`) with subtle drift
    5. `striationOverlay` (`.add`)

**Particles**
- `Tend/Presentation/Core/SpriteKit/ParticleManager.swift`
  - Programmatic `SKEmitterNode`s: `sparkEmitter`, `emberEmitter`, `smokeEmitter`, `ashEmitter`
  - Burst helper: `emitSparkBurst(...)` (used for taps/collisions)

**Procedural textures**
- `Tend/Presentation/Core/SpriteKit/CoreTextureGenerator.swift`
  - Glow: radial gradient
  - Surface: slightly irregular ellipse + radial gradient
  - Inner core: concentrated radial gradient
  - Striations: ~7 random curved strokes (static)
  - Particles: small radial gradient dot

### Notes from ROI-210

ROI-210 focused on visibility/clarity across the full state range and called out additive blending on dark colors/backgrounds as a visibility risk. It’s marked **Done** and the code now enforces baseline alpha in `CoreNode.applyBreath(...)` to keep the Core readable even when dim.

---

## Design guardrails (from Concept + Spec)

- **No shame:** dim should feel “waiting,” not punitive.
- **Elemental / non-digital:** avoid neon, avoid clinical pure-white, avoid aggressive saturated red.
- **Three time-scales of motion:** breath (slow) + internal flow (medium) + micro-events (fast/rare).
- **Apex should be “new behavior,” not just brighter.**

---

## Iteration 1 (proposed): make radiant states “admire-worthy” + add meal-log reward

### Goals

1. Make inner core and striations feel *active* and *structured* (solar / volcanic) rather than static sprites.
2. Add a celebratory meal-log “energy event” with distinct on/off-track variants.
3. Add a true “apex” reward when:
   - core adherence is **1.0** AND
   - **today has >1 meal logged** (first meal doesn’t qualify; second can).

### Bundle A — Inner core: convection / granulation layer (medium-timescale life)

**What:** Add one additional additive layer near the inner core that looks like slow convection cells (sun granulation / molten glass flow).

**How (SpriteKit-feasible):**
- Add `innerConvection` (`SKSpriteNode`) using a new procedural texture generator method (e.g. `generateGranulationTexture(size:seed:)`).
- Animate via slow rotation + subtle scale drift + alpha modulation, plus slight parallax with the existing `innerCore` drift.

**Why it helps:** gives “something to look at” in high radiant states even when the user isn’t interacting.

### Bundle B — Striations: traveling “light wave” + inhale synchronization

**What:** Make striations feel like channels carrying energy instead of a static overlay.

**How:**
- Add a striation highlight pass that is *not uniform*:
  - Option 1 (no shaders): `SKCropNode` where the mask is the existing striation texture, and the content is a moving gradient band (sweep). The band movement is driven by breath phase (faster at high adherence).
  - Option 2 (with shader): `SKShader` on the striation sprite to modulate alpha along a moving noise/wave.
- Trigger a subtle “pulse” on inhale peak (tie into `BreathingController.didPeakInhale`).

**Why it helps:** “energy transport” reads as more geological/solar and more alive than static veins.

### Bundle C — Particles: variety + rhythm (less “dot spray”)

**What:** make particles feel less generic by introducing shape variety and breath-timed micro-events.

**How:**
- Add a second spark emitter using an elongated “streak” texture (small tapered line) for occasional higher-energy sparks.
- On inhale peak, emit a small burst (state-scaled), so radiant breathing feels like it *powers* the surrounding air.

### Bundle D — Meal logging reward (celebratory, with on/off variants)

**On track (celebratory):**
- “Match-strike”: quick flash/overshoot + expanding halo ring + inward-spiraling sparks that settle.

**Off track (still feedback, not shame):**
- Softer, brief “cool puff”: warm smoke wisp + a dim ripple that dissipates quickly.

**Implementation note:** this likely requires a one-shot “VFX event” channel from SwiftUI → `RadiantCoreScene` (separate from steady state interpolation).

### Bundle E — Apex (1.0 adherence + >1 meal today)

**Persistent apex layer (while eligible):**
- A thin additive “corona crown” around the core that breathes with inhale.

**Entrance event (when eligibility flips false → true):**
- A larger “apex ignition” burst (stronger than standard on-track), plus a brief ray bloom.

**Eligibility definition (per product direction):**
- `isApexEligible = (coreState.adherencePercentage >= 0.999) && (adherenceStats.todayCount.total > 1)`

---

## Iteration backlog (later ideas to consider)

### Rendering / materiality
- **Heat shimmer/refraction above the Core** (spec layer 7): mild distortion sprite or shader-based refraction.
- **Normal-mapped surface + `SKLightNode`**: add depth/specular response (more “geological / glassy” material).
- **Rim light / fresnel**: thin edge highlight that increases in radiant states.
- **Subsurface scattering illusion**: multi-layer offset glows + directional light shift tied to inner core drift.

### Apex / reward design
- **Coronal loops** (rare): arc ribbons that appear and retract (solar flare language).
- **Apex-only “breath rays”**: subtle god-rays at peak inhale only.
- **Streak logic:** escalate apex intensity if perfect adherence continues (e.g., 3rd+ meal today).

### Particles
- **Directional sparks** that inherit core velocity on collisions (more physics coherence).
- **Ember “floaters”**: larger particles that drift with gentle turbulence.
- **Color temperature jitter**: tiny warm-cool flicker on particles, especially near apex.

### Interaction / feedback
- **Apex tap response**: sharper flash + ring + brief corona expansion.
- **Meal-log audio + haptics** tuned for celebratory vs gentle feedback.

### Tooling / iteration speed
- Add a small “tuning panel” (debug-only) for live editing of emitter rates/alphas.

---

## QA / acceptance criteria (for wow passes)

- In radiant states, I can watch the Core for 5–10 seconds and see *layered life* (not just brightness).
- Striations read as **channels of energy** (traveling wave / pulse), not static lines.
- Meal logging produces immediate, celebratory feedback distinct from steady state transitions.
- Apex eligibility is clearly perceivable and feels *qualitatively different* (not just brighter).
- Dim states remain warm/compassionate (no harsh “punishment” visuals).
