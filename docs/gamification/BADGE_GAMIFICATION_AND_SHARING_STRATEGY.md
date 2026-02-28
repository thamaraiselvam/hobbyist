# Badge Gamification + Viral Sharing Strategy

## 1) Goal
Design a **Duolingo-style badge moment** that rewards user effort, prompts share consent at the right time, and produces a beautiful social card with an app install link.

## 2) Product Principles
1. **Earned, not spammy**: badges should unlock from meaningful progress, not trivial actions.
2. **Positive reinforcement**: celebrate consistency and recovery (not just perfection).
3. **One-tap sharing**: users should be able to share in <10 seconds from unlock.
4. **Designed for dark UI**: visuals must match Hobbyist's current purple-first dark theme.
5. **Attribution-ready**: every shared image carries app name + install URL/QR.

## 3) Badge Taxonomy

### Streak Badges (core retention)
- `spark_streak_3` — 3-day streak
- `ember_streak_7` — 7-day streak
- `flame_streak_30` — 30-day streak
- `constellation_streak_90` — 90-day streak

### Completion Badges (habit depth)
- `precision_week` — 100% completion for 7 days
- `marathon_month` — >=85% completion for 30 days

### Recovery Badges (healthy behavior)
- `bounce_back` — user returns within 72 hours after missing streak

### Growth Badges (portfolio expansion)
- `skill_gardener` — maintain 3 active hobbies for 21 days

## 4) Unlock Criteria (recommended logic)

### Event inputs
- Daily completion ratio per hobby
- Day-level activity marker (`active_day`)
- Consecutive-day streak
- Rolling windows: 7d/30d/90d
- Hobby activity count in rolling windows

### Quality guardrails
- Ignore accidental opens: a day counts only if at least one task is completed.
- Prevent farm behavior: cap unlock checks to 1 full evaluation per day.
- Cooldown for repeat celebration screens: no more than 1 celebratory modal / 24h.

### Suggested thresholds
- Precision-based badges require >=4 active days in the 7-day window to avoid edge-case gaming.
- Monthly consistency badges require at least 20 active days in the 30-day window.

## 5) When to Prompt Share Consent

Prompt immediately when all are true:
1. Badge is newly unlocked.
2. User has completed the current session interaction (no interruption mid-checklist).
3. User has seen at least one prior success toast in the app (avoid overwhelming first-time users).

### Prompt copy
- Title: **"You unlocked Flame Streak! 🔥"**
- Body: **"Share your progress card with friends and inspire their streak too."**
- CTA primary: **"Share"**
- CTA secondary: **"Not now"**
- Opt-in footer: **"Include app install link"** (default ON)

## 6) Share Card Specification

### Layout blocks
1. **Top**: Badge icon + badge name
2. **Middle**: User stat highlight (e.g., "30-day streak")
3. **Bottom**: App logo + CTA text + install link/QR

### Mandatory metadata on card
- App name: `Hobbyist`
- Tagline: `Build consistency, one day at a time`
- Install URL: `https://hobbyist.app/install` (replace with production URL)
- Optional referral token query param for attribution

### Visual style (aligned with app)
- Background gradient: `#1A1625 -> #2A2238`
- Accent: `#6C3FFF`, `#8B5CF6`
- Text: `#FFFFFF`, secondary `#CFC6FF`
- Shape language: rounded cards, soft glow, no harsh outlines

## 7) Badge Release Progression

### Phase 1 (ship now)
- 3, 7, 30-day streak
- Weekly precision
- Share flow with image export + native share sheet

### Phase 2
- Recovery + portfolio badges
- Dynamic card themes by badge rarity
- Referral attribution in shared links

### Phase 3
- Seasonal limited badges
- Team challenges / friend streak battles

## 8) Anti-cheat and fairness
- Use server-trusted timestamps when sync is available.
- If offline edits are detected (clock jumps >24h), mark for delayed verification.
- Prevent duplicate unlock by storing immutable unlock event IDs.

## 9) Success Metrics
- Badge unlock rate (DAU-normalized)
- Share prompt acceptance rate
- Share completion rate
- Install conversion from shared links
- D7 retention lift for users receiving at least one badge

## 10) Design Notes for Top-tier Feel
- Use micro-animations: soft pulse, particle sparkle, and depth blur under badge medal.
- Keep text hierarchy strong: 1 hero number, 1 supporting sentence.
- Ensure templates are export-safe for 1:1 and 9:16 social crops.
- Keep visual density low to remain readable in WhatsApp/Instagram compression.
