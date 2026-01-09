# Tend: User Journey Documentation

**Companion document to Concept Brief v3.0**
**January 2026**

---

## 1. Overview

This document maps the key user journeys in Tend, from first launch through established daily use. It identifies critical moments, emotional beats, and edge cases that must be handled thoughtfully.

### Journey Types Covered

1. **First-Time User Experience (FTUE)** — Download to first meaningful interaction
2. **Daily Loop** — The core usage pattern for returning users
3. **Weekly Cycle** — How the experience evolves over a week
4. **Recovery Journey** — Coming back after poor adherence or absence
5. **Upgrade Journey** — Free to Premium conversion
6. **Edge Cases** — Handling unusual scenarios

---

## 2. First-Time User Experience (FTUE)

### Goal

Get the user from app launch to emotional investment in their Core in under 2 minutes—ideally under 60 seconds.

### Journey Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ STAGE        │ ACTION                    │ EMOTIONAL BEAT                   │
├─────────────────────────────────────────────────────────────────────────────┤
│ Discovery    │ User downloads app        │ Curiosity: "What is this?"       │
│              │ (App Store, word of       │                                  │
│              │ mouth, social)            │                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│ Launch       │ Opens app for first time  │ Anticipation: "Show me"          │
├─────────────────────────────────────────────────────────────────────────────┤
│ Welcome      │ Sees welcome screen       │ Understanding: "Ah, it's a       │
│              │ with value prop           │ different kind of diet app"      │
├─────────────────────────────────────────────────────────────────────────────┤
│ Selection    │ Chooses dietary goal      │ Commitment: "This is my goal"    │
├─────────────────────────────────────────────────────────────────────────────┤
│ Introduction │ Meets the Core            │ Intrigue: "It's... alive?"       │
├─────────────────────────────────────────────────────────────────────────────┤
│ First Touch  │ Taps/interacts with Core  │ Delight: "It responds to me!"    │
│              │                           │ ← THIS IS THE "AHA" MOMENT       │
├─────────────────────────────────────────────────────────────────────────────┤
│ Prompt       │ Prompted to log first     │ Motivation: "Let's see what      │
│              │ meal                       │ happens"                         │
├─────────────────────────────────────────────────────────────────────────────┤
│ First Log    │ Captures photo, tags      │ Satisfaction: "That was easy"    │
│              │ on/off track              │                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│ First        │ Watches Core respond      │ Connection: "My choices affect   │
│ Response     │ to their meal             │ it" ← REINFORCEMENT BEGINS       │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Critical Moments

#### The "Aha" Moment
**When:** User first interacts with the Core (tap, swipe)
**What happens:** Core responds with movement, particles, haptic feedback
**Why it matters:** This is the moment the Core stops being a graphic and becomes a *thing*—something with presence, something that responds
**Design requirement:** This interaction must feel *exceptional*. Haptics, visuals, and physics must work in concert.

#### First State Change
**When:** User logs their first meal and Core responds
**What happens:** Core shifts toward Radiant (if on track) or stays neutral/shifts toward Dim (if off track)
**Why it matters:** Establishes the core loop—my choices affect its state
**Design requirement:** The transition animation must be unmissable but not jarring. Sound + haptics + visual must align.

### Detailed FTUE Flow

#### Screen 1: Welcome (5-10 seconds)

**User sees:**
- Tend wordmark/logo
- Tagline: "Tend to your fire"
- Brief value prop (2-3 sentences)
- "Get Started" CTA

**User does:**
- Reads (or skims)
- Taps "Get Started"

**Notes:**
- No account creation yet—defer friction
- Keep copy short; intrigue > explanation

---

#### Screen 2: Diet Selection (10-20 seconds)

**User sees:**
- Question: "What's your dietary goal?"
- Grid of preset options (8 choices)
- "Custom goal" option

**User does:**
- Scans options
- Taps their choice (single selection)
- Taps "Continue"

**Notes:**
- Selection should feel easy, not overwhelming
- No explanation of what each diet means—users know their goal
- Custom option opens text field for free-form input

---

#### Screen 3: Meet Your Core (15-30 seconds)

**User sees:**
- The Core, at neutral state, breathing gently
- Introductory copy: "This is your Core..."
- Invitation to interact: "Try tapping it"

**User does:**
- Watches the Core breathe (even passive observation is engaging)
- Taps or swipes the Core
- Experiences the response (movement, sparks, haptics)

**Notes:**
- This screen should not feel like a tutorial—it should feel like a moment
- Copy should be minimal; let the Core speak for itself
- After any interaction, "Continue" button appears

---

#### Screen 4: First Log Prompt (5-10 seconds)

**User sees:**
- Completion message: "You're all set"
- Prompt to log first meal
- Primary CTA: "Log First Meal"
- Secondary: "I'll do it later"

**User does:**
- Taps "Log First Meal" (happy path)
- OR taps "I'll do it later" (deferred)

**Notes:**
- Don't force the first log—some users need to finish onboarding mentally before engaging
- If deferred, Core view shows gentle reminder in status area

---

#### First Meal Log (15-30 seconds)

**User does:**
1. Camera opens
2. Takes photo of meal (or taps "describe in text")
3. Sees confirmation screen with photo
4. Reads question: "Was this meal on track with your [diet] diet?"
5. Taps "On track" or "Off track"

**Notes:**
- Entire flow should be under 30 seconds
- After tagging, modal dismisses with subtle animation
- User lands on Core view

---

#### First Core Response (5-10 seconds)

**User sees:**
- Core animates state transition
  - If "On track": Kindling animation (brightens, rises, breathing deepens)
  - If "Off track": Subtle banking (dims slightly from neutral)
- Status text updates: "1 of 1 meals on track today"

**User feels:**
- Satisfaction (if on track): "I'm feeding it well"
- Gentle acknowledgment (if off track): "It's okay, I can do better next meal"

**Notes:**
- The first "on track" meal should feel rewarding
- The first "off track" meal should NOT feel punishing—the Core is waiting, not dying

---

### FTUE Success Metrics

| Metric | Target |
|--------|--------|
| Time: Launch → Core view | < 60 seconds |
| Time: Launch → First meal logged | < 2 minutes |
| FTUE completion rate | > 80% |
| Users who log first meal same day | > 50% |
| Users who return next day | > 40% |

---

## 3. Daily Loop

### Goal

Make meal logging a lightweight, rewarding habit that takes < 30 seconds per meal.

### Typical Daily Journey

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ TIME         │ ACTION                    │ EXPERIENCE                       │
├─────────────────────────────────────────────────────────────────────────────┤
│ Morning      │ Opens app (check-in)      │ Sees Core at current state       │
│              │                           │ (carried from previous day/week) │
├─────────────────────────────────────────────────────────────────────────────┤
│ Breakfast    │ Logs meal                 │ Core responds                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ Mid-day      │ Quick check (optional)    │ Watches Core breathe; maybe      │
│              │                           │ fidget interaction               │
├─────────────────────────────────────────────────────────────────────────────┤
│ Lunch        │ Logs meal                 │ Core responds; status updates    │
├─────────────────────────────────────────────────────────────────────────────┤
│ Snack        │ Logs snack (optional)     │ Every meal counts                │
├─────────────────────────────────────────────────────────────────────────────┤
│ Dinner       │ Logs meal                 │ Core responds; sees daily        │
│              │                           │ progress solidify                │
├─────────────────────────────────────────────────────────────────────────────┤
│ Evening      │ Opens app (check-in)      │ Reflects on day; Core state      │
│              │                           │ reflects their choices           │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Meal Logging Flow (Returning User)

**Duration:** 10-20 seconds per meal

1. **Open app** → Lands on Core view (last-used tab)
2. **Tap "Log Meal"** → Camera opens immediately
3. **Capture photo** → One tap
4. **Tag adherence** → "On track" or "Off track"
5. **Watch response** → Core animates, status updates
6. **Done** → User can close app or continue interacting

### Daily Emotional Arc

| Meals Logged | If Mostly On Track | If Mixed | If Mostly Off Track |
|--------------|-------------------|----------|---------------------|
| 1 of N | Core brightens; hopeful start | Neutral acknowledgment | Gentle dim; "I can recover" |
| 2 of N | Building momentum | Middle ground | Still recoverable |
| 3 of N | Core approaching Radiant | Tension: "Which way will it go?" | Core noticeably Dim |
| 4 of N | Full Radiant state; satisfaction | Resolution in either direction | Dim but still alive; "Tomorrow" |

### Check-In Behavior (Non-Logging)

Many users will open the app just to look at their Core—not to log.

**What they're doing:**
- Checking Core state
- Fidget interactions (tap, swipe, hold)
- Emotional regulation (the Core is calming)

**Design implication:**
- The Core view must be satisfying even without action
- Breathing, particles, and ambient sound create a "living screensaver" quality

---

## 4. Weekly Cycle

### Goal

Create a rhythm that matches how people think about eating: weekly cycles with fresh starts.

### Weekly Journey Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ DAY          │ CORE STATE                │ USER EXPERIENCE                  │
├─────────────────────────────────────────────────────────────────────────────┤
│ Monday       │ Reset to neutral (50%)    │ Fresh start; clean slate         │
│ (Start)      │                           │ "New week, new chance"           │
├─────────────────────────────────────────────────────────────────────────────┤
│ Tue-Thu      │ Accumulating based on     │ Building momentum (or awareness  │
│              │ meal adherence            │ of drift)                        │
├─────────────────────────────────────────────────────────────────────────────┤
│ Friday       │ Reflects week so far      │ Often a decision point: "Do I    │
│              │                           │ indulge this weekend?"           │
├─────────────────────────────────────────────────────────────────────────────┤
│ Sat-Sun      │ Weekend choices affect    │ Some users relax; Core may dim   │
│              │ final weekly state        │ Others maintain; Core stays warm │
├─────────────────────────────────────────────────────────────────────────────┤
│ Sunday       │ Week's final state        │ Reflection: "How did I do?"      │
│ (End)        │                           │ Anticipation: "Reset tomorrow"   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Monday Reset Experience

**What happens:**
- Core transitions to neutral state (50% position)
- Breathing normalizes
- Weekly adherence counter resets

**How it feels:**
- Not punishing (even if last week was poor)
- Fresh start, but with memory (user knows their patterns)

**Design notes:**
- Consider a subtle "new week" indicator on first Monday open
- The reset animation should feel like rekindling, not rebooting

---

## 5. Recovery Journey

### Scenario: User Had a Bad Day/Week

**Context:** User logged multiple "off track" meals. Core is Dim.

#### Recovery Principles

1. **No shame.** The Dim state is tired, not angry
2. **One meal matters.** The next on-track meal creates visible improvement
3. **Monday is always coming.** Weekly reset provides guaranteed fresh start

#### Recovery Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ MOMENT              │ CORE STATE      │ USER THINKING                       │
├─────────────────────────────────────────────────────────────────────────────┤
│ Opens app after     │ Dim, sluggish,  │ "Ugh, I didn't do well"             │
│ bad day             │ shallow breath  │ But: Core is still there, waiting   │
├─────────────────────────────────────────────────────────────────────────────┤
│ Interacts with Core │ Responds        │ "It's tired but it's alive"         │
│                     │ slowly, weakly  │                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│ Logs on-track meal  │ Kindling begins │ "Oh! It's responding!"              │
│                     │ Subtle brighten │ Immediate positive feedback         │
├─────────────────────────────────────────────────────────────────────────────┤
│ Subsequent on-track │ Continues       │ "I can bring it back"               │
│ meals               │ improving       │ Motivation to continue              │
├─────────────────────────────────────────────────────────────────────────────┤
│ Monday arrives      │ Reset to        │ "Clean slate"                       │
│                     │ neutral         │                                     │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Scenario: User Hasn't Opened App in Days

**Context:** User downloaded, maybe logged a few meals, then went silent.

#### Re-engagement Flow

1. **User opens app** → Lands on Core view
2. **Core is at weekly baseline** (neutral if new week, last state if same week)
3. **Status shows:** "No meals logged in X days" (non-judgmental)
4. **Core breathes, waits** → It hasn't abandoned them

**Design notes:**
- No pop-ups, alerts, or guilt trips on return
- The Core's presence is the only "nudge"
- If push notifications are added (post-MVP), they should be warm, not nagging

---

## 6. Upgrade Journey (Free → Premium)

### Trigger Points

Users are most likely to consider upgrading when:

1. **They're engaged with the Core** — Already invested in the experience
2. **They want more data** — Asking "how many calories was that?"
3. **They hit a plateau** — Adherence is good but weight isn't changing (need calorie insight)

### Upgrade Flow

#### Discovery

**Location:** Progress view, subtle banner or card
**Message:** "Want to track calories without counting? Try Premium."
**Tone:** Informational, not pushy

#### Paywall Screen

**User sees:**
- Current plan (Free) vs. Premium comparison
- Premium features highlighted:
  - AI calorie estimation from photos
  - Calorie target tracking
  - Caloric modifier on Core state
  - Detailed nutrition insights
- Pricing and trial info (if applicable)
- "Upgrade" CTA

#### Post-Upgrade Onboarding

1. **Enter metrics** — Height, weight, age, sex, activity level
2. **See calculated target** — "Based on your info, we recommend 1,850 cal/day"
3. **Adjust if desired** — Manual override option
4. **Confirmation** — "AI calorie tracking is now active"

**Notes:**
- Keep this under 2 minutes
- Don't require all fields if user is impatient (smart defaults)

---

## 7. Edge Cases & Alternative Paths

### Edge Case: User Wants to Change Diet Mid-Week

**Path:**
1. Go to Progress view
2. Tap current diet → Diet selection sheet opens
3. Select new diet
4. Confirmation: "Your goal is now [new diet]. Your Core state stays the same."

**Notes:**
- Changing diet does NOT reset the Core—it's about adherence to whatever goal they set, not the goal itself

---

### Edge Case: User Logs Meal Without Photo

**Path:**
1. Tap "Log Meal"
2. Tap "Or describe in text"
3. Text input sheet opens
4. User types description (e.g., "salad with chicken")
5. Taps "Done"
6. Goes to confirmation: "On track" / "Off track"

**Notes:**
- Text entry is equally valid; some meals don't need photos
- Meal history shows text description instead of thumbnail

---

### Edge Case: User Tries to Log Same Meal Twice

**Handling:**
- No restriction in MVP—trust the user
- Meal history shows all logged items; user can review
- Consider: edit/delete meal in future version

---

### Edge Case: User Opens App at Midnight (Day Boundary)

**Handling:**
- Day boundary is midnight local time
- If user logs meal at 11:59 PM, it counts for current day
- If user logs at 12:01 AM, it counts for new day
- Weekly reset occurs at midnight Monday

---

### Edge Case: First Day Ever is Not Monday

**Handling:**
- Core starts at neutral (50%) regardless of day
- First week may be partial (e.g., start on Thursday, reset on Monday)
- This is fine—user learns the weekly rhythm

---

### Edge Case: User Never Logs "Off Track"

**Possibility:** User only logs meals they feel good about, skips logging "off track" meals

**Handling:**
- This is acceptable—the app doesn't surveil
- Their Core reflects logged meals only
- If they want honest feedback, they need honest logging
- No intervention in MVP; observe this pattern in analytics

---

## 8. Key Moments Summary

| Moment | What Happens | Why It Matters |
|--------|--------------|----------------|
| **First touch** | Core responds to tap | User realizes it's "alive" |
| **First meal logged** | Core state changes | Establishes core loop |
| **First Radiant state** | Core glows fully | Peak satisfaction; goal achieved |
| **First Dim state** | Core is tired but waiting | Teaches non-shame failure mode |
| **First recovery** | Dim Core rekindles | Shows recovery is possible |
| **First Monday reset** | Fresh start | Teaches weekly rhythm |
| **First check-in (no log)** | Just watching Core breathe | App becomes a comfort object |
| **First "off track" followed by "on track"** | Core stabilizes | Teaches balance, not perfection |

---

## 9. Success Metrics by Journey

| Journey | Metric | Target |
|---------|--------|--------|
| FTUE | Completion rate | > 80% |
| FTUE | First meal logged (same session) | > 40% |
| Daily Loop | Meals logged per active day | 2-4 |
| Daily Loop | Days active per week | 4+ |
| Weekly Cycle | Week-over-week retention | > 60% |
| Recovery | Return rate after 3+ day absence | > 30% |
| Upgrade | Free → Premium conversion (month 1) | 5-10% |

---

*End of Document*
