# The Radiant Core: Full Specification

**Companion document to Tend Concept Brief v3.0**  
**January 2026**

---

## 1. Concept Overview

### What It Is

The Radiant Core is a living ember—an abstracted, elemental form that represents the user's inner metabolic fire. It is not a literal coal or a fantasy creature, but something more fundamental: **vital energy given visible form.**

Smooth and organic in shape, it resembles something you might find in nature—a river stone, a seed, a heart worn smooth by time. But it glows from within. Light escapes through delicate veins across its surface. And most importantly: **it breathes.**

### The Central Metaphor

Your body is a furnace. Food is fuel. The quality of that fuel—and how you burn it—determines everything: your energy, your clarity, your radiance, your longevity.

The Radiant Core externalizes this invisible process. When you eat well, your furnace burns clean and bright. When you don't, it dims and struggles. The Core makes the invisible visible—not through numbers, but through light, warmth, and breath.

### Why Breath?

Breath is the most primal indicator of life. Before we check for a pulse, we check for breathing. The rhythm of breath reflects our state: deep and slow when calm and healthy, shallow and rapid when stressed or unwell.

By giving the Core a breathing rhythm that responds to dietary adherence, we create an almost biofeedback-like connection. Users may find themselves unconsciously syncing their own breath to the Core's rhythm. The Core becomes a meditation object as much as a gamification mechanic.

---

## 2. Visual Design

### Form Language

**Shape:** Asymmetrical but balanced. Organic, not geometric. The silhouette suggests:

- A river stone, smoothed by millennia of flowing water
- A seed containing dormant life
- A heart, abstracted beyond anatomy
- A drop of molten glass, frozen mid-form

The shape should feel **holdable**—something you'd pick up on a beach and slip into your pocket.

**Size:** Approximately 15-20% of screen width. Large enough to appreciate detail; small enough to feel intimate.

### Surface Topology

- Primarily smooth with subtle undulations
- Crossed by **striations**—thin channels where inner light escapes (like veins in a leaf held to the sun, bands in polished agate, or capillaries carrying light)
- The striations are not cracks (which imply damage) but natural channels (which imply structure, life, flow)

### Materiality

- Semi-translucent, like amber or frosted glass
- Exhibits **subsurface scattering**: light enters the surface, diffuses, and exits elsewhere, creating depth and inner luminosity
- Subtle texture—not mirror-smooth, but soft, almost skin-like

### The Inner Core

Visible through the translucent surface is a concentrated point of light—the furnace within the furnace. This inner core:

- Sits slightly off-center (more organic, less mechanical)
- Pulses gently with the breathing rhythm
- Is the brightest point; all other light emanates from it
- Shifts position subtly, as if floating in viscous liquid

### Visual Layers (Rendering Order)

1. **Background glow** — Soft, diffuse halo around the entire form
2. **Outer surface** — The translucent shell with striations
3. **Subsurface light** — Diffuse glow between surface and core
4. **Inner core** — The bright central point
5. **Striation highlights** — Light escaping through surface channels
6. **Particle layer** — Sparks, embers, smoke (state-dependent)
7. **Heat distortion** — Subtle refraction effect above the Core (when Radiant)

---

## 3. The State Spectrum

The Core exists on a continuous spectrum between two poles: **RADIANT ← → DIM**

This is not binary. The Core can be "mostly Radiant with a hint of fatigue" or "Dim but showing signs of rekindling." Every visual and physical property interpolates smoothly along this spectrum.

---

### Radiant State (Target / Aligned)

*Triggered by: High adherence percentage, caloric targets met*

**The feeling:** A well-fed fire. Clean-burning fuel. Vitality, clarity, power.

#### Visual Properties

| Element | Radiant Appearance |
|---------|-------------------|
| Inner core | Bright white-gold, intense, sharply defined |
| Subsurface glow | Rich golden-orange, fills the form |
| Surface | Warm-tinted, highly translucent, luminous |
| Striations | Bright gold channels, clearly visible, pulsing with light |
| Overall color temp | Warm (2800K-3500K equivalent) |
| Glow radius | Large, soft-edged halo extends well beyond form |

#### Breathing Properties

| Attribute | Value |
|-----------|-------|
| Rate | Slow: 4-6 breaths per minute (meditative range) |
| Depth | Deep: 8-12% scale change between inhale/exhale |
| Rhythm | Smooth, sinusoidal, consistent |
| Character | Restful, satisfied, effortless |

#### Particle Effects

| Type | Behavior |
|------|----------|
| Sparks | Tiny golden-white points rise gently upward. 10-20 active. Lifespan: 1-2 sec. |
| Embers | Occasional larger particles drift up and fade. Warm orange. |
| Heat shimmer | Subtle refractive distortion above the Core, like air over hot pavement. |
| Light rays | Faint god-rays emanate from striations, especially during peak inhale. |

#### Physics Properties

| Property | Value | Feel |
|----------|-------|------|
| Gravity multiplier | 0.3-0.5 | Buoyant—heat rises. Floats gently upward. |
| Restitution | 0.7-0.8 | Lively bounce, but not frantic. |
| Damping | 0.1-0.2 | Moves freely, minimal resistance. |
| Response speed | Fast | Reacts immediately to touch, feels eager. |

---

### Dim State (Deviation / Drifted)

*Triggered by: Low adherence percentage, caloric targets exceeded*

**The feeling:** A fire burning low. Needs tending. Not dead—dormant. Waiting to be rekindled.

#### Visual Properties

| Element | Dim Appearance |
|---------|---------------|
| Inner core | Deep amber/burnt orange, diffuse edges, weak |
| Subsurface glow | Dim, muddy amber with grey undertones |
| Surface | Cool-tinted, more opaque, clouded |
| Striations | Barely visible, occasional faint pulse |
| Overall color temp | Cool (1800K-2200K equivalent) |
| Glow radius | Small, tight, barely extends beyond form |

#### Breathing Properties

| Attribute | Value |
|-----------|-------|
| Rate | Fast: 12-18 breaths per minute (stressed range) |
| Depth | Shallow: 2-4% scale change |
| Rhythm | Irregular, occasionally skips or catches |
| Character | Labored, strained, effortful |

#### Particle Effects

| Type | Behavior |
|------|----------|
| Smoke wisps | Thin, grey-amber wisps drift upward slowly, dissipating quickly. 3-5 active. |
| Falling ash | Occasional dark particles fall downward and settle. |
| Weak sparks | Rare, dim, fall instead of rise. |
| Heat shimmer | None. Air is still. |

#### Physics Properties

| Property | Value | Feel |
|----------|-------|------|
| Gravity multiplier | 1.5-2.0 | Heavy—sinks, settles at bottom of screen. |
| Restitution | 0.2-0.3 | Thuds, minimal bounce. |
| Damping | 0.6-0.8 | Moves through resistance, sluggish. |
| Response speed | Slow | Delayed reaction to touch, feels tired. |

---

### Intermediate States

At 50% adherence, the Core exhibits middle values: moderate warm glow (amber-gold), gentle hover at mid-screen, regular but not deep breathing (8-10 breaths/minute), some sparks rise while some fall, responsive but not eager.

The interpolation should be **non-linear** for certain properties (breathing rate, color temperature, gravity) to create more perceptible differences in the middle ranges.

---

## 4. The Breathing System

The breath is the Core's heartbeat. It should feel autonomous—the Core breathes whether you're watching or not, whether you're touching it or not. It is alive.

### Breath Cycle Anatomy

One complete breath consists of:

**INHALE (40% of cycle)**
- Expansion: Core grows slightly larger
- Brightening: Inner light intensifies
- Lift: Subtle upward drift
- Particle burst: Sparks emit on peak

**EXHALE (50% of cycle)**
- Contraction: Core returns to base size
- Softening: Inner light dims slightly
- Settle: Subtle downward drift
- Particle fade: Active sparks begin to die

**PAUSE (10% of cycle)**
- Stillness: Moment of rest before next inhale
- Pause is shorter or absent when Dim

### Breath Parameters by State

| Parameter | Radiant | Dim |
|-----------|---------|-----|
| Cycle duration | 10-15 sec | 3-5 sec |
| Scale range | ±6-8% | ±2-3% |
| Brightness range | ±15-20% | ±5-8% |
| Pause duration | 1-1.5 sec | 0-0.3 sec |
| Vertical drift | ±3-5% screen height | ±0.5-1% |
| Rhythm variance | Low (steady) | High (irregular) |

### Breathing Irregularity (Dim State)

When Dim, the breath becomes imperfect:

- **Occasional catch:** Inhale stutters momentarily before completing
- **Skipped breaths:** Rare moments where the cycle pauses too long
- **Shallow patches:** 2-3 breaths in a row that barely register
- **Recovery sighs:** Occasional deeper breath, as if trying to recover

These should be subtle—the Core isn't dying, it's struggling. It creates concern, not alarm.

### User Interaction with Breath

The breath continues regardless of user interaction, but:

- **Tap during inhale:** Slight additional expansion, brighter spark burst (encouraging)
- **Tap during exhale:** Breath cycle resets gently, as if startled awake
- **Hold:** Breath slows slightly, as if calmed by presence (only when Radiant)
- **Rapid taps (Dim):** No effect—the Core is too tired to respond to stimulation

---

## 5. Color System

### Palette Philosophy

The Core's colors should feel **elemental, not digital.** Reference points:

- Molten metal in a crucible
- Sunset through amber glass
- The heart of a candle flame
- Bioluminescent deep-sea creatures

**Avoid:** Neon/fluorescent tones, pure white (too clinical), saturated red (too aggressive/alarming)

### Radiant Palette

| Element | Color | Hex |
|---------|-------|-----|
| Inner core (peak) | White-gold | #FFF8E7 |
| Inner core (base) | Warm gold | #FFD93D |
| Subsurface glow | Deep gold | #F5A623 |
| Surface tint | Amber | #D4915D |
| Striation light | Bright gold | #FFE566 |
| Outer halo | Soft peach | #FFE4C9 |

### Dim Palette

| Element | Color | Hex |
|---------|-------|-----|
| Inner core (peak) | Burnt orange | #B85C2C |
| Inner core (base) | Deep amber | #8B4513 |
| Subsurface glow | Muddy amber | #6B4423 |
| Surface tint | Grey-brown | #4A3C31 |
| Striation light | Faint rust | #7A5C4A |
| Outer halo | Dim umber | #3D3229 |

### Color Transitions

State changes should not be instantaneous:

- **Kindling (Dim → Radiant):** Warmth spreads from inner core outward, like a fire catching. Duration: 2-3 seconds.
- **Banking (Radiant → Dim):** Light recedes from edges inward, like embers fading. Duration: 3-4 seconds (slower—loss is felt more).

---

## 6. Sound Design

Sound is essential to the Core's aliveness but should be unobtrusive—ambient rather than attention-demanding.

### Ambient Soundscape

**Radiant state:**
- Low, warm drone (like a distant furnace or singing bowl)
- Subtle crackling undertones (fire, but gentle)
- Soft shimmer on particle emissions
- Overall: Comforting, present, alive

**Dim state:**
- Quieter, lower drone
- Crackle is sparse, intermittent
- Occasional faint hiss (like steam, struggle)
- Overall: Subdued but still present—not silent

### Breath Sounds

The breath cycle has a subtle audio signature:

- **Inhale:** Soft, low whoosh—like a gentle bellows, not a human breath
- **Exhale:** Softer still, almost inaudible settle
- **Radiant:** Breath sounds are smooth, satisfying
- **Dim:** Breath sounds are thinner, occasionally catch or wheeze

### State Transition Sounds

- **Kindling (improvement):** Rising tone, soft chime, crackling intensifies—satisfying, rewarding
- **Banking (decline):** Falling tone, soft settling sound, crackle fades—not punishing, just... quieter

### Interaction Sounds

| Interaction | Sound |
|-------------|-------|
| Tap | Soft, warm "tok"—like tapping glass with something warm inside |
| Swipe | Whoosh proportional to speed; warmer when Radiant, duller when Dim |
| Bounce (wall) | Radiant: Resonant ping. Dim: Muffled thud. |
| Hold | Subtle intensification of ambient drone |

### Audio Implementation Notes

- All sounds should be **non-fatiguing**—users may have the app open for extended periods
- Offer a **silent mode** that retains haptics but removes audio
- Sound should be **spatialized** if device supports it—the Core exists in space

---

## 7. Haptic Design

Haptics make the Core tangible. Users should feel its warmth, its weight, its life.

### Breath Haptics

A continuous, subtle pulse synchronized to the breathing cycle:

- **Inhale:** Gentle crescendo of vibration
- **Exhale:** Decrescendo to near-stillness
- **Radiant:** Fuller, warmer haptic texture
- **Dim:** Thinner, weaker pulses

This creates an almost ASMR-like quality—the phone pulses gently in your hand, alive.

### Interaction Haptics

| Interaction | Haptic |
|-------------|--------|
| Tap (Radiant) | Crisp, warm tap—like touching something alive |
| Tap (Dim) | Softer, duller tap—less responsive |
| Hold | Increasing warmth (sustained gentle vibration) |
| Swipe | Light confirmation at gesture start |
| Wall bounce (Radiant) | Sharp, satisfying tick |
| Wall bounce (Dim) | Heavy, dull thud |
| State kindle | Rising, warming vibration |
| State bank | Falling, cooling vibration |

### Haptic Philosophy

The Core should feel **warm when Radiant, cool when Dim.** This is achieved through:

- **Radiant:** Higher-frequency, crisper haptic patterns (perceptually "warmer")
- **Dim:** Lower-frequency, softer patterns (perceptually "cooler")

CoreHaptics on iOS allows for precise control of these textures.

---

## 8. Physics Behavior

### The Feel

The Core has **presence.** It's not a balloon or a bubble—it has mass, it has weight. But that weight is modulated by its state:

- **Radiant:** Light and buoyant—heat rises, and so does the Core
- **Dim:** Heavy and grounded—without vitality, gravity wins

### Physics Parameters

| Property | Radiant | Dim | Notes |
|----------|---------|-----|-------|
| Mass | 1.0 | 1.0 | Constant—same Core |
| Gravity scale | 0.3 | 2.0 | Key differentiator |
| Restitution | 0.8 | 0.25 | Bounce vs. thud |
| Linear damping | 0.1 | 0.7 | Glide vs. slog |
| Angular damping | 0.2 | 0.8 | Spin vs. stop |

### Natural Motion

When not being interacted with:

- **Radiant:** Drifts gently upward, meanders, occasionally orbits or figure-eights. Playful but not frenetic.
- **Dim:** Sinks to bottom of screen, rolls slowly to lowest point, rocks slightly with breath but doesn't rise.

### Boundary Behavior

The screen edges are boundaries:

- **Radiant:** Bounces off with a crisp reflection, retains most energy. Wall collisions emit sparks.
- **Dim:** Bumps against walls with minimal bounce, loses energy quickly. Wall collisions produce no particles.

### Breathing Influence on Physics

The breath cycle subtly affects physics:

- **Inhale:** Slight upward impulse (even when Dim, though weaker)
- **Exhale:** Slight downward settle
- This creates a gentle oscillation even when the Core is "at rest"

---

## 9. Touch Interactions

| Gesture | Response (Radiant) | Response (Dim) |
|---------|-------------------|----------------|
| Tap | Impulse toward finger, sparks, bright pulse | Weak impulse, minimal response, faint glow |
| Swipe | Flings with momentum, trails sparks | Sluggish movement, quickly slows |
| Hold | Orbits finger gently, haptic warmth, breathing slows | Drifts slowly toward finger, weak haptic |
| Drag | Follows smoothly with lag, glows brighter | Follows reluctantly, heavy, no glow increase |
| Release | Drifts with inertia, returns to natural motion | Falls immediately, settles |

### Shake Gesture

If the device is shaken:

- **Radiant:** Core tumbles joyfully, sparks fly everywhere, haptic celebration
- **Dim:** Core tumbles sluggishly, few particles, dull haptics

### Edge Cases

- **Rapid repeated taps:** Radiant Core becomes playfully overstimulated. Dim Core shows no cumulative effect.
- **Screen flip/rotation:** Core responds to new gravity direction with state-appropriate speed.
- **App backgrounded:** Breathing continues in low-power mode so Core is alive when you return.

---

## 10. State Transitions

### What Triggers Transitions

| Event | Effect |
|-------|--------|
| Meal logged as "On track" | Shift toward Radiant (percentage-based) |
| Meal logged as "Off track" | Shift toward Dim (percentage-based) |
| Caloric target met (end of day) | Bonus shift toward Radiant (+10-15%) |
| Caloric target exceeded (end of day) | Penalty shift toward Dim (-10-15%) |
| New week begins (Monday) | Reset toward neutral (50%) baseline |

### Kindling (Improvement)

1. Inner core brightens first (hope begins inside)
2. Light spreads outward through striations
3. Surface clarifies, becomes more translucent
4. Glow radius expands
5. Breathing deepens and slows
6. Particles shift from falling/smoke to rising/sparks
7. Subtle lift—Core rises slightly in frame

*Duration: 2-3 seconds. Sound: Rising warmth, crackling intensifies. Haptic: Warming crescendo.*

### Banking (Decline)

1. Outer glow contracts first (edges fail before center)
2. Surface clouds slightly
3. Striations dim
4. Inner core weakens
5. Breathing shallows and speeds
6. Particles shift from sparks to smoke/ash
7. Subtle fall—Core sinks slightly

*Duration: 3-4 seconds (slower—loss is felt more). Sound: Cooling, quieting. Haptic: Cooling diminuendo.*

### Emotional Design of Transitions

**Critical:** The Dim state should never feel like punishment. The Core isn't angry, isn't judging, isn't dying. It is simply **waiting**. Like embers banked for the night, it can be rekindled tomorrow.

The transition to Dim should evoke:

- "Oh, my little Core is tired"
- "I should take better care of it"
- "I'll do better tomorrow"

**NOT:**

- "I failed"
- "The app is judging me"
- "Why bother, it's ruined"

This is achieved through:

- Slow, gentle transitions (not jarring)
- Continued signs of life (breathing never stops)
- Warm colors even when dim (not cold or grey)
- Sound that quiets rather than alarms
- Physics that slow rather than punish

---

## 11. Technical Implementation

### Recommended Approach (MVP)

**Framework:** SpriteKit (2D) with layered sprites and blend modes

- **Core shape:** Textured sprite with normal map for depth illusion
- **Inner core:** Additive-blended glow sprite
- **Striations:** Animated texture overlay
- **Particles:** SKEmitterNode
- **Glow:** Gaussian blur on bright elements

**Future Enhancement:** SceneKit/RealityKit for actual 3D mesh with subsurface scattering shader

### Breathing Implementation

```
breathPhase = (currentTime % cycleDuration) / cycleDuration
breathValue = sin(breathPhase * 2π)  // -1 to 1
scale = baseScale + (breathValue * breathDepth)
brightness = baseBrightness + (breathValue * brightnessRange)
```

Add noise/irregularity for Dim state:

```
if state < 0.5:
    irregularity = perlinNoise(time * 2) * (0.5 - state)
    breathValue += irregularity
```

### State Interpolation

All visual/physics properties interpolated based on adherence percentage:

```
currentGravity = lerp(radiantGravity, dimGravity, 1 - adherencePercent)
currentHue = lerpColor(radiantHue, dimHue, 1 - adherencePercent)
breathRate = lerp(radiantBreathRate, dimBreathRate, 1 - adherencePercent)
```

Use easing functions for non-linear feel where needed.

### Performance Considerations

- Particle count scales with state (fewer when Dim = lower GPU load)
- Breathing animation uses simple sine wave (minimal CPU)
- Blur/glow can be pre-rendered at lower resolution
- Consider reducing animation fidelity when app backgrounded
- Target 60fps on iPhone 12 and newer; 30fps acceptable on older devices

---

## 12. Summary: The Core as Mirror

The Radiant Core succeeds because it is not a game character or a virtual pet. It is a **mirror.**

| User's Body | The Core |
|-------------|----------|
| Metabolism | Inner fire |
| Cellular energy | Luminosity |
| Circulation/vitality | Warmth |
| Respiratory function | Breathing |
| Fatigue/depletion | Dimness/heaviness |
| Health/radiance | Brightness/buoyancy |

When users look at their Core, they should feel, on some level: *"That's me in there."*

The breathing seals this connection. It's the most universal sign of life, and by giving the Core a breath that reflects dietary choices, we create a bridge between the abstract (nutrition data) and the visceral (a living thing in your hands, pulsing gently, waiting to be kindled).

---

*End of Specification*
