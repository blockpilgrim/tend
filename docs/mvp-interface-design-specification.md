# Tend: MVP Interface Design Specification

**Companion document to Concept Brief v3.0**
**January 2026**

---

## 1. Overview

This document specifies the user interface for Tend's MVP. The design philosophy is **Core-centric**: the Radiant Core is the emotional and visual center of the app, with all other UI elements designed to support—not compete with—that experience.

### Design Principles

1. **Minimal chrome.** The Core dominates the viewport. UI elements are subtle, contextual, and recede when not needed.
2. **Warmth over clinical.** Colors, typography, and interactions should feel organic and inviting—not like a medical or fitness app.
3. **Immediate feedback.** Every action produces visible, satisfying response.
4. **No shame.** Error states, empty states, and "poor performance" views never scold or guilt.

---

## 2. Navigation Model

### Structure

The app uses a **bottom tab bar** with two primary destinations:

| Tab | Label | Icon Concept | Purpose |
|-----|-------|--------------|---------|
| 1 | Core | Flame/ember | Primary view; Core interaction + meal logging |
| 2 | Progress | Chart/calendar | Adherence data, meal history, diet settings |

### Navigation Behavior

- Tab bar is **persistent** across both views
- Tab bar uses **subtle styling**—not visually dominant
- Active tab indicated by filled icon + subtle highlight
- Tab bar **hides during meal logging flow** (full-screen camera/confirmation)

### Auxiliary Screens (Modal/Push)

| Screen | Access Point | Presentation |
|--------|--------------|--------------|
| Settings | Gear icon in Progress view header | Push navigation |
| Meal Logging | "Log Meal" button on Core view | Full-screen modal |
| Onboarding | App launch (first run only) | Full-screen flow |
| Paywall/Upgrade | CTA in Progress view or Settings | Modal sheet |

---

## 3. Screen Specifications

### 3.1 Core View (Tab 1 — Home)

**Purpose:** Primary interaction space. Users spend most of their time here, watching and interacting with the Core.

#### Layout

```
┌─────────────────────────────────────┐
│  [subtle status area]               │
│                                     │
│                                     │
│                                     │
│         ┌─────────────┐             │
│         │             │             │
│         │  RADIANT    │             │
│         │   CORE      │             │
│         │             │             │
│         └─────────────┘             │
│                                     │
│                                     │
│    "3 of 4 meals on track today"    │
│                                     │
│         [ + Log Meal ]              │
│                                     │
├─────────────────────────────────────┤
│    [Core]           [Progress]      │
└─────────────────────────────────────┘
```

#### Elements

| Element | Specification |
|---------|---------------|
| **Core canvas** | 70-80% of viewport height. Full-width. The Core floats/drifts within this space. Dark, warm background (not pure black—subtle gradient or texture). |
| **Status indicator** | Small, unobtrusive text below Core. Shows today's adherence in human terms: "3 of 4 meals on track today" or "No meals logged yet." Not a percentage—that's for the Progress view. |
| **Log Meal button** | Primary CTA. Floating button, bottom-center, above tab bar. Warm accent color. Icon: camera or plus sign. |
| **Background** | Dark with subtle warmth. Consider very faint radial gradient emanating from Core position. Should feel like looking into a warm, dark space. |

#### States

| State | Behavior |
|-------|----------|
| **Default** | Core visible at current state. Status text shows today's adherence. |
| **No meals logged today** | Core at weekly baseline. Status: "No meals logged yet today." |
| **First day of week (Monday)** | Core at neutral (50%). Status: "New week begins." |
| **App backgrounded → reopened** | Core resumes breathing animation seamlessly. |

#### Interactions

- **Tap/swipe/hold on Core:** Fidget interactions per Core Specification
- **Tap Log Meal button:** Opens meal logging flow (modal)
- **Tap Progress tab:** Navigates to Progress view

---

### 3.2 Progress View (Tab 2)

**Purpose:** Data view for users who want to see adherence metrics, review meal history, and manage their dietary goal.

#### Layout

```
┌─────────────────────────────────────┐
│  Progress                    [gear] │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────────┐│
│  │  THIS WEEK        78%           ││
│  │  ████████████░░░░               ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │  Today    Yesterday   This Week ││
│  │   75%        100%        78%    ││
│  │  (3/4)       (4/4)     (18/23)  ││
│  └─────────────────────────────────┘│
│                                     │
│  ─────── Meal History ───────       │
│                                     │
│  ┌─────────────────────────────────┐│
│  │ [img] Lunch        On track     ││
│  │       Today, 12:34 PM           ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ [img] Breakfast    Off track    ││
│  │       Today, 8:15 AM            ││
│  └─────────────────────────────────┘│
│  ...                                │
│                                     │
│  ─────── Your Diet ───────          │
│                                     │
│  ┌─────────────────────────────────┐│
│  │  Mediterranean         [change] ││
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│    [Core]           [Progress]      │
└─────────────────────────────────────┘
```

#### Elements

| Element | Specification |
|---------|---------------|
| **Header** | "Progress" title, left-aligned. Gear icon (settings access) right-aligned. |
| **Weekly summary card** | Prominent card showing current week's adherence percentage with visual progress bar. This is the "headline" metric. |
| **Time period stats** | Three columns: Today, Yesterday, This Week. Each shows percentage and fraction (e.g., "75% (3/4)"). |
| **Meal history** | Scrollable list of logged meals, newest first. Each row: thumbnail (if photo), meal description or "Photo logged", on/off track badge, timestamp. |
| **Diet selection** | Card showing current dietary goal with "change" affordance. Tapping opens diet selection sheet. |

#### Premium Elements (if subscribed)

| Element | Specification |
|---------|---------------|
| **Calorie summary** | Card showing daily calories consumed vs. target. Progress bar or ring visualization. |
| **Protein summary** | Similar format for protein if relevant. |
| **Trends** | Weekly/monthly calorie trends (future enhancement). |

#### States

| State | Behavior |
|-------|----------|
| **No meals logged (ever)** | Empty state with encouraging message: "Log your first meal to start tracking." Meal history section shows illustration + prompt. |
| **No meals logged today** | Today shows "—" or "No meals yet." History shows previous days' meals. |
| **Free tier** | Calorie/protein sections not shown. Optional subtle upgrade prompt. |

---

### 3.3 Meal Logging Flow

**Purpose:** Capture meal and tag adherence. Should be fast—under 10 seconds for the common case.

#### Flow Structure

```
[Core View]
    → tap "Log Meal"
    → [Capture Screen]
    → capture photo (or tap text entry)
    → [Confirmation Screen]
    → tap "On track" or "Off track"
    → [Core View with animation]
```

#### Screen: Capture

```
┌─────────────────────────────────────┐
│                              [X]    │
│                                     │
│  ┌─────────────────────────────────┐│
│  │                                 ││
│  │                                 ││
│  │         CAMERA                  ││
│  │         VIEWFINDER              ││
│  │                                 ││
│  │                                 ││
│  └─────────────────────────────────┘│
│                                     │
│            ( ○ )                    │
│         [capture]                   │
│                                     │
│     "Or describe in text"           │
│                                     │
└─────────────────────────────────────┘
```

| Element | Specification |
|---------|---------------|
| **Camera viewfinder** | Full-width, ~60% height. Live camera preview. |
| **Capture button** | Large, centered shutter button. Warm accent color. |
| **Text entry option** | Subtle link below capture button: "Or describe in text." Tapping opens text input sheet. |
| **Close button** | X in top-right corner. Dismisses flow, returns to Core view. |

#### Screen: Confirmation

```
┌─────────────────────────────────────┐
│  [back]                      [X]    │
│                                     │
│  ┌─────────────────────────────────┐│
│  │                                 ││
│  │         CAPTURED                ││
│  │         PHOTO                   ││
│  │                                 ││
│  └─────────────────────────────────┘│
│                                     │
│     Was this meal on track with     │
│     your Mediterranean diet?        │
│                                     │
│  ┌─────────────────────────────────┐│
│  │         On track                ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │         Off track               ││
│  └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

| Element | Specification |
|---------|---------------|
| **Photo preview** | The captured image, displayed prominently. |
| **Question text** | Contextual: "Was this meal on track with your [diet name] diet?" If custom diet, use their custom text. |
| **On track button** | Primary style. Warm color (gold/amber). |
| **Off track button** | Secondary style. Neutral/muted color. Not red—no shame connotation. |
| **Back button** | Returns to capture screen (retake photo). |
| **Close button** | Dismisses entire flow. |

#### After Confirmation

1. Modal dismisses
2. User returns to Core view
3. Core immediately animates state transition (kindling or banking)
4. Status text updates to reflect new adherence
5. Subtle success indication (haptic, optional brief toast)

---

### 3.4 Settings Screen

**Purpose:** Account management, preferences, and app configuration.

#### Sections

| Section | Contents |
|---------|----------|
| **Account** | Email/account info, sign out |
| **Preferences** | Sound on/off, haptics on/off |
| **Subscription** | Current plan, manage subscription, upgrade CTA (if free) |
| **Support** | Help/FAQ, contact support, privacy policy, terms |
| **About** | App version, credits |

---

### 3.5 Onboarding Flow

**Purpose:** Welcome new users, capture dietary goal, introduce the Core.

#### Screens (Free Tier)

**Screen 1: Welcome**
```
┌─────────────────────────────────────┐
│                                     │
│         [Tend logo/wordmark]        │
│                                     │
│         Tend to your fire.          │
│                                     │
│  A living ember that glows when     │
│  you eat well and dims when you     │
│  don't. No spreadsheets. No shame.  │
│  Just something alive.              │
│                                     │
│         [Get Started]               │
│                                     │
└─────────────────────────────────────┘
```

**Screen 2: Select Diet**
```
┌─────────────────────────────────────┐
│                                     │
│      What's your dietary goal?      │
│                                     │
│  ┌───────────────┐ ┌───────────────┐│
│  │   Keto /      │ │  Vegetarian   ││
│  │   Low-carb    │ │               ││
│  └───────────────┘ └───────────────┘│
│  ┌───────────────┐ ┌───────────────┐│
│  │   Vegan       │ │ Mediterranean ││
│  └───────────────┘ └───────────────┘│
│  ┌───────────────┐ ┌───────────────┐│
│  │   Whole30 /   │ │  Low sugar    ││
│  │   Paleo       │ │               ││
│  └───────────────┘ └───────────────┘│
│  ┌───────────────┐ ┌───────────────┐│
│  │ High protein  │ │ Whole foods   ││
│  └───────────────┘ └───────────────┘│
│  ┌─────────────────────────────────┐│
│  │         Custom goal...          ││
│  └─────────────────────────────────┘│
│                                     │
│           [Continue]                │
│                                     │
└─────────────────────────────────────┘
```

**Screen 3: Meet Your Core**
```
┌─────────────────────────────────────┐
│                                     │
│         This is your Core.          │
│                                     │
│         ┌─────────────┐             │
│         │   RADIANT   │             │
│         │    CORE     │             │
│         │  (neutral)  │             │
│         └─────────────┘             │
│                                     │
│   It reflects your inner vitality.  │
│   Eat well, and watch it glow.      │
│   Drift, and it dims—waiting        │
│   to be rekindled.                  │
│                                     │
│         [Try tapping it]            │
│                                     │
└─────────────────────────────────────┘
```

- User can tap/interact with Core
- After interaction, "Continue" button appears

**Screen 4: First Log Prompt**
```
┌─────────────────────────────────────┐
│                                     │
│         You're all set.             │
│                                     │
│    Log your next meal to see your   │
│    Core respond.                    │
│                                     │
│         [Log First Meal]            │
│                                     │
│         "I'll do it later"          │
│                                     │
└─────────────────────────────────────┘
```

#### Target Duration

Under 60 seconds from launch to Core view.

#### Paid Tier Onboarding (Upgrade Flow)

When user upgrades, additional screens:

1. **Enter metrics** — Height, weight, age, sex, activity level
2. **Calorie target** — Calculated automatically with option to adjust
3. **AI features intro** — Brief explanation of photo calorie estimation

---

## 4. Component Specifications

### 4.1 Colors

| Token | Use | Value (Light) | Notes |
|-------|-----|---------------|-------|
| `background-primary` | Core view background | Near-black with warm undertone | `#1A1612` or similar |
| `background-secondary` | Progress view, cards | Dark warm gray | `#2A2520` |
| `accent-primary` | CTAs, active states | Warm gold/amber | `#F5A623` |
| `accent-secondary` | Secondary buttons | Muted warm gray | `#8B7355` |
| `text-primary` | Primary text | Off-white | `#F5F0EB` |
| `text-secondary` | Secondary text, captions | Warm gray | `#A89B8C` |
| `success` | "On track" indicator | Soft gold (not green) | `#D4A855` |
| `neutral` | "Off track" indicator | Muted taupe (not red) | `#7A6E62` |

### 4.2 Typography

| Style | Use | Spec |
|-------|-----|------|
| **Title** | Screen headers | 24pt, semibold |
| **Headline** | Card titles, metrics | 20pt, medium |
| **Body** | Primary content | 16pt, regular |
| **Caption** | Secondary info, timestamps | 14pt, regular |
| **Button** | CTAs | 16pt, semibold |

Font: System default (SF Pro on iOS) for readability. Consider a warmer display font for titles in future iteration.

### 4.3 Buttons

| Type | Use | Style |
|------|-----|-------|
| **Primary** | Main CTAs (Log Meal, Continue) | Filled, accent-primary background, rounded corners (12pt), padding 16x48 |
| **Secondary** | Alternative actions | Outlined or ghost, muted color |
| **Destructive** | N/A in MVP | Avoid if possible |

### 4.4 Cards

- Background: `background-secondary`
- Corner radius: 16pt
- Padding: 16pt internal
- Shadow: Subtle, warm-tinted (not pure black)

---

## 5. Key Transitions

| Transition | Specification |
|------------|---------------|
| **Tab switch** | Cross-fade, 200ms |
| **Modal present (meal logging)** | Slide up from bottom, 300ms |
| **Modal dismiss** | Slide down, 250ms |
| **Core state change** | Per Core Specification (2-4 seconds) |
| **Screen push (settings)** | Standard iOS push |

---

## 6. Accessibility Considerations

- **VoiceOver:** All interactive elements labeled. Core state announced on focus ("Your Core is currently warm, 78% adherence this week").
- **Dynamic Type:** Support standard accessibility text sizes.
- **Reduce Motion:** Provide option to reduce Core animation complexity for users with vestibular sensitivities.
- **Color contrast:** Ensure text meets WCAG AA against backgrounds.

---

## 7. Empty & Error States

### Empty States

| State | Location | Message |
|-------|----------|---------|
| No meals logged (ever) | Progress view, meal history | "Log your first meal to start tracking your progress." + illustration |
| No meals logged today | Core view status | "No meals logged yet today." |
| No meals this week | Progress weekly summary | "Start logging to see your weekly progress." |

### Error States

| Error | Handling |
|-------|----------|
| Camera permission denied | Show prompt with instructions to enable in Settings |
| Network error (if applicable) | Graceful degradation; local-first where possible |
| AI estimation failed (Premium) | "Couldn't estimate calories. You can enter manually or skip." |

---

*End of Specification*
