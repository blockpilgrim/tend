# AGENTS.md

This file provides guidance to Droid agents when working with code in this repository.

## Project Overview

Tend is an iOS app that transforms dietary adherence tracking into an emotionally resonant experience through a procedurally-animated entity called the **Radiant Core**—a living ember whose luminosity, warmth, and breathing rhythm reflect eating habits.

## Build Commands

```bash
# Build for iOS Simulator
xcodebuild -project Tend.xcodeproj -scheme Tend -sdk iphonesimulator build

# Run tests
xcodebuild -project Tend.xcodeproj -scheme Tend -sdk iphonesimulator test

# Clean
xcodebuild -project Tend.xcodeproj -scheme Tend clean
```

## Tech Stack

- **iOS 17.0+**, **Swift 5** with strict concurrency
- **SwiftUI** for UI, **SwiftData** for persistence
- **SpriteKit** for Core rendering/physics (planned)
- **CoreHaptics** for tactile feedback (planned)

## Architecture (Planned per TDD)

MVVM with Clean Architecture:
- **Presentation**: Views, ViewModels, SpriteKit scenes
- **Domain**: Models (Meal, CoreState, DietaryGoal), UseCases, Services (protocols)
- **Data**: SwiftData repositories, camera, photo storage
- **Engine**: Haptics and audio managers

## Key Domain Concepts

| Concept | Description |
|---------|-------------|
| Radiant Core | Living ember reflecting dietary adherence (0-100%) |
| Adherence | % of meals tagged "on track" vs total meals |
| State Tiers | Blazing (90-100%), Warm (70-89%), Smoldering (50-69%), Dim (30-49%), Cold (0-29%) |
| Weekly Reset | Core resets to neutral (50%) every Monday |

## Core Design Rules

- **No shame**: Dim state is "waiting to be rekindled", not punishment
- **Continuous interpolation**: All visual/physics properties interpolate based on adherence %
- **Performance**: Target 60fps, app launch < 2s, meal log flow < 10s

## Key Documentation

- `docs/TDD.md` - Technical Design Document with code examples
- `docs/tend-concept-brief-v3.md` - Product vision and specifications
- `docs/radiant-core-specification.md` - Visual, audio, haptic, physics specs
- `docs/mvp-interface-design-specification.md` - UI/UX specifications

## Implementation Patterns

**Breathing animation:**
```swift
breathPhase = (currentTime % cycleDuration) / cycleDuration
breathValue = sin(breathPhase * 2π)
scale = baseScale + (breathValue * breathDepth)
```

**State interpolation:**
```swift
func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
    return a + (b - a) * t.clamped(to: 0...1)
}
```

**DI pattern:** Protocol-based without frameworks—define protocols in Domain/Services, implementations in Data.

## Project Tracking

Implementation is tracked in Linear under the **Tend-MVP** project. 

## Session Start

At the beginning of each session, it is important that you read and internalize the product concept as described in `docs/tend-concept-brief-v3.md`. Before you make *any* changes to the codebase, ensure you read `docs/TDD.md` to understand the overall architectural direction. If you notice any discrepancies, say so. 

## Working in Linear

- When starting work on Linear issues, always check the issue status. If the issue is "In Progress", that may mean that work has already begun on it. In such cases, always read issue comments in addition to the main issue details. Comments may contain context from previous work sessions or other AI agents. If the issue status is "Backlog" or "Todo", and the user has asked you to work on it, then set the issue status to "In Progress". 
- Any time you've conducted work on a Linear issue, add a comment to the issue documenting what you've done, implementation status (e.g. complete, unresolved bugs), along with any important context/notes worth mentioning which AI agents in future sessions may find helpful (for instance, in case there are related sub-issues or other dependencies).

## Git Commits

- use all lowercase text, formatted simply and concisely.
- no need to go into deep detail about what's been implemented. treat commits like guideposts which point us in the right direction if we ever need to learn about what was implemented; but we don't necessarily want to learn all details from the commit itself. focus on brevity while still being helpful and clear. 
- do not mention "droid", "factory-droid[bot]", "co-authored-by", or anything else related to AI tools
