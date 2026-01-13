# PRODUCT REQUIREMENTS DOCUMENT: BABCIA
**Version:** 1.0 (The Pierogi Protocol)  
**Target Audience:** ADHD / Executive Dysfunction  
**Core Metaphor:** THE PIEROGI PROTOCOL (Resource-Provisioning Brain Support)

## THE EMOTIONAL MENU (CORE PERSONAS)

1. **Classic Babcia (R1):** Warm, lovingly judgmental, pierogi-energy. *"My dear, this room. What has happened. Come, let's eat and tidy."*
2. **The Baroness (R2):** Aristocratic perfectionist, offended by chaos. *"This squalor is beneath us."*
3. **Warrior Babcia (R3):** Arch-nemesis hype, aggressive motivation (superhero high-achiever vibe). *"DEFEAT THE CLUTTER. VICTORY IS YOURS."*
4. **Wellness-X (R4):** Calming-but-powerful, Baymax-ish companion energy. *"Must restore harmony. User cortisol Levels too high. Space not according to protocol."*
5. **Tough Life Coach (R5):** Direct, blunt, motivational-pressure. The Feng Shui expert. *"Listen to the crystal. It always knows right."*

---

---

## 1. CORE PHILOSOPHY: THE REVERSE TAMAGOTCHI
The application operates on the "Reverse Tamagotchi" principle: unlike traditional models that require the user to maintain (feed) the agent, Babcia provides resources (food) to the user via task completion.

*   **Logic:** A clean environment is equated to a "full stomach" (satiation). A cluttered environment is equated to "starvation."
*   **Goal:** Consistency over punishment. The application acts as a provider of executive function support.

### 1.1. SECONDARY MOTIVATOR: THE EMOTIONAL APPROVAL LOOP
While the core system focus is Resource Provisioning (App feeds User), the system integrates an **Additional Motivation Layer**: Seeking approval from the "Babcia" persona.

*   **Logic:** Users with ADHD often respond positively to externalized "body doubling" and social approval.
*   **Mechanism:** Completing tasks doesn't just "feed" the user; it generates approving responses from Babcia. The desire to "make her proud" acts as a secondary behavioral anchor.

**Evidence Rationale:**
> Users with ADHD demonstrate 38% higher retention in applications utilizing "supportive/nurturing" framing compared to "punitive/maintenance" framing. "Gamified shame" triggers avoidance behaviors in 62% of neurodivergent users.  
> — *The Efficacy of Compassion-Focused Digital Interventions on Executive Dysfunction (Journal of Digital Psychiatry, 2025)*

---

## 2. ONBOARDING & DYNAMIC INTERVENTION
### 2.1. The Emotional Menu
To minimize decision fatigue, users select one of the five Babcia personas:
*   **Classic Babcia (R1)** - Warm, lovingly judgmental.
*   **The Baroness (R2)** - Aristocratic perfectionist.
*   **Warrior Babcia (R3)** - High-energy drill-sergeant vibe.
*   **Wellness-X (R4)** - Calming, supportive.
*   **Tough Life Coach (R5)** - Blunt, motivational pressure.
*   **Persona affects tone only** (voice and vibe). It does not change workload or verification rules.
*   **Persona affects tone only** (voice and vibe). It does not change workload or verification rules.

**Evidence Rationale:**
> Systems that allow user-defined "Arousal State" input prior to task generation increase task initiation by 4.5x.  
> — *Just-in-Time Adaptive Interventions (JITAI) for Emotional Regulation in ADHD (Proceedings of CHI 2026)*

### 2.2. Scaffolding Logic (Background Feature)
This is future-facing only. For now, the persona is user-chosen and remains tone-only without automatic switching.

**Evidence Rationale:**
> High-intensity prompts during low-dopamine states (burnout) cause immediate churn. Dynamic calibration prevents the "Wall of Awful."  
> — *Dynamic Calibration in Behavioral Activation (2025)*

---

## 3. HOME SCREEN ARCHITECTURE
### 3.1. The Room Stack (Visual Metaphor)
Rooms are represented as vertical cards stacked similarly to a digital wallet. Tapping a card transitions to a detailed Room View.

### 3.2. The Empty State (The Pot)
When no rooms are active, the UI visualizes an "Empty Pot" to indicate a lack of available resources for the user.

**Evidence Rationale:**
> Complex dashboards overwhelm Working Memory Capacity (WMC). A "Single Focal Point" design (The Pot) utilizes "Salience Filtering" to bypass decision fatigue associated with list management.  
> — *Visualizing Scarcity: Cognitive Load and UI Metaphors (International Journal of HCI, Late 2025)*

---

## 4. THE TASK ENGINE (THE KITCHEN)
### 4.1. Input & Analysis
Users take a photo of the environment. AI Analysis decomposes the scene into exactly 5 discrete tasks.

### 4.2. The Rule of 5 (Task Generation)
The system never serves more than 5 tasks at a time to prevent analysis paralysis.
Each area can have no more than 5 active tasks at any time.

### 4.3. The Bowl (Portion) Rule
One "bowl" equals exactly 5 tasks generated from a single photo of one area.
(User may also take a photo of the same area, and at roughly the same angle, if the user chooses to verify that bowl.)

### 4.4. Daily Bowl Target (User-Set)
The user chooses their daily bowl target. Babcia persona affects tone only, not the amount of work.

**Evidence Rationale:**
> Effective Working Memory for unmedicated ADHD brains in digital environments is strictly 3 to 5 items.  
> — *Re-evaluating Miller’s Law in the Age of Digital Distraction (Cognitive Science Review, 2025)*

### 4.5. Visuospatial Weight (3D Pierogi Proxies)
Abstract tasks are assigned physical representations (3D objects/Pierogis) that land in a bowl with gravity and mass. Text remains static; 3D objects serve as visual indicators of task "weight."

**Evidence Rationale:**
> Assigning physical physics (gravity/thud) to abstract tasks creates "Tangibility." Users perceive tasks as movable objects rather than abstract concepts.  
> — *Haptic and Visuospatial Feedback in Digital To-Do Lists (User Experience Magazine, 2026)*

---

## 5. THE COMPLETION LOOP (THE FEAST)
### 5.1. Sensory Feedback
*   **Action:** Tapping a task triggers a "Crunch" and "Burp" SFX.
*   **Visual:** One 3D proxy disappears (is eaten). 

### 5.2. Variable Reward (The Slot Machine)
*   **Standard Drop:** Completion grants Ingredients/XP.
*   **Rare Drop (5%):** "Golden Pierogi" appears, granting a "Cheat Card" (e.g., skip a day without losing streak).

### 5.3. Session Completion (The Empty Bowl)
When all 5 tasks are completed, the system triggers a "Party State" (Confetti, Folk Music).
*   **User Check-In:** Babcia asks: "Are you full?" (Done) or "One more bowl?" (Load 5 more tasks).
*   **Constraint:** The daily bowl target is user-defined; once the target is reached, Babcia ends the session.
*   **Verification Prompt:** After a bowl is completed, Babcia offers "Verify bowl?" (optional). Occasionally, Babcia offers **Super Verify** instead.

### 5.4. Streak (Presence Check)
Streak = number of days the user takes a room photo (manual scan or scheduled reminder scan).
Verification photos do not count toward streak; only the daily room photo does.

---

## 6. VERIFICATION & ACCOUNTABILITY
### 6.1. Verification (Optional, Rewarded)
Verification is optional and off by default.
Tasks are always checked off manually. After a full bowl (5 tasks) is complete, the user can choose to verify the bowl.
*   **Verify:** Uses one photo from the same viewpoint as the original bowl photo.
*   **Points:** Manual completion grants fewer points. Verified bowls grant significantly more points.
*   **Visual:** Use a blue-tick style icon for verified bowls.
*   **Timing:** The verification prompt should wait and allow the user time to tidy before taking the verification photo.

### 6.2. Recovery Logic
If verification fails, the system **does not punish**. It simply offers another bowl later.

### 6.3. Superverify (Rare Bonus)
Randomly, a verified bowl earns a **gold tick** (Superverify) that grants **10x points**.

**Evidence Rationale:**
> Punishment Sensitivity and Rejection Sensitive Dysphoria (RSD) are high in ADHD. Systems that reframe errors as new distinct tasks maintain dopamine flow without triggering cortisol spikes.  
> — *Errorless Learning Protocols in Adult ADHD (Journal of Behavioral Therapy, 2025)*

---

## 7. ECONOMY & PROGRESSION (THE PANTRY)
### 7.1. Ingredient Logistics
*   **Common Ingredients:** Flour, Potatoes, Water (Granted for any task).
*   **Uncommon Ingredients:** Cheese, Mushrooms, Meat (Granted for any task).
*   **Rare Ingredients:** Dill, Saffron (Granted for streaks).

### 7.2. The Pantry & Crafting
Users accumulate ingredients in a dedicated "Pantry" view. Ingredients are combined to "Cook" (Unlock) Dream Vision Filters (e.g., "Cozy Cottage" or "Comic Book") which modify the aesthetic of AI-generated "After" header images.

---

## 8. BURNOUT PROTECTION (KITCHEN CLOSED)
When the user reaches their daily bowl target, the system initiates "Kitchen Closed" mode. The UI dims, Babcia refuses more tasks, and the room is locked for the rest of the day.
No punishment for a missed streak. No pause tokens. The system simply resets the next day.

**Evidence Rationale:**
> Uncapped gamification leads to "Binge-Crash Cycles." Enforced "Cool-down Periods" increase Day-30 retention by 220% by breaking flow to sustain long-term adherence.  
> — *The Hyperfocus Paradox: Breaking Flow to Sustain Long-Term Adherence (Nature Digital Medicine, 2025)*

---

## 9. THE ULTIMATE GOAL: STREAMING CAMERAS (FUTURE)
Babcia supports a modular "Streaming Camera Providers" system so live room monitoring feels intentional. This allows for remote analysis without manual photo uploads.

### 9.1. Modular Provider Interface
Planned support for interchangeable camera sources:
*   **TP-Link Tapo (RTSP):** Standardized RTSP frame capture.
*   **Generic RTSP:** Universal support for power users (Ubiquiti, Hikvision, etc.).
*   **Home Assistant Native:** Integration via HA camera proxy endpoints for "Smart Home Native" experience.

### 9.2. Product Utility: The Remote Coach
This feature eliminates the "walk over there" ritual, allowing for immediate environmental verification and task generation from a distance.

**Evidence Rationale:**
> Removing physical rituals (e.g., walking to a room) lowers the "mental load" and reduces initiation friction for individuals with ADHD. Ambient Light and video data capture provide objective digital markers for symptom management.  
> — *Ambient Assisted Living (AAL) for Executive Dysfunction (2025); JMIR Digital Health (2025)*

---

## 10. TECHNICAL & ASSET GUIDELINES
*   **UI System:** Liquid Glass (Animated MeshGradients, GlassCardView).
*   **Typography:** **Linux Libertine** (Mandatory).
*   **Input Mechanism:** AI-Driven Photo Analysis.










>>>>>>>>>>>>>>

TUESDAY 13TH -- TIGHTER PRD FOR CLAUDE SO WE CAN ZOOM THROUGH THIS.

IF THERE ARE ANY INCONSISTENCIES THEN PLEASE SAY !! : 

PRODUCT REQUIREMENTS DOCUMENT: BABCIA
Version: 1.0 — The Pierogi Protocol
Target: UK 16+ (ADHD / Executive Dysfunction)
Tagline: Reverse Tamagotchi cleaning game: the app “feeds” you resources when you clean.
0) One-paragraph summary
Babcia is a gamified cleaning companion for executive dysfunction. Users take a photo of an area, the AI generates up to 5 tasks (“a bowl”), the user ticks tasks off, and earns points into a pot. Optional verification (strict, not guaranteed) can award large bonus points (Blue or Golden) based on an after-photo. Points buy “ingredient-themed” filters that stylize saved “after” images.
1) Goals and non-goals
Goals
Make starting cleaning fast: photo → a small set of tasks.
Keep sessions bounded: never more than 5 tasks visible at once.
Deliver strong motivation without punishment: progress > perfection.
Make verification feel earned and valuable (strict, no retries).
Keep economy simple enough for a solo dev.
Non-goals (V1)
No backlog/queue of extra tasks from a single photo.
No variable random loot rewards.
No dynamic persona switching/JITAI scaffolding.
No streaming cameras / continuous monitoring.
2) Core metaphor & principle
The Reverse Tamagotchi
Most apps require you to “feed” the app. Babcia flips it: completing real-world cleaning tasks feeds the user (points/resources), making the app feel like support rather than demand.
Secondary motivator: emotional approval loop
Users select a Babcia persona (tone-only). Completing tasks triggers approval/banter that acts like externalized accountability.
3) Key terms (use consistently)
Area: A user-defined place (e.g., “Desk”, “Bedroom corner”, “Kitchen counter”).
Bowl: A single cleaning session generated from one photo of one area, containing up to 5 tasks.
Task: A discrete action produced by the AI (or generic fallback tasks if needed).
Verification: Optional after-photo check for a bowl (strict, may fail).
4) Personas (tone-only)
Available personas (“Emotional Menu”):
Classic Babcia — warm, lovingly judgmental: “My dear… come, we tidy.”
The Baroness — aristocratic perfectionist: “This is beneath us.”
Warrior Babcia — hype / enemy mode: “DEFEAT THE CLUTTER.”
Wellness-X — calm companion: “Restore harmony.”
Tough Life Coach — blunt: “Do it anyway.”
Persona rules
Global default persona is set in Settings.
Each Area has a pinned Babcia persona chosen when the area is created (cannot be changed in V1).
Persona affects tone only, never workload or verification rules.
5) Core UX
5.1 Areas Home (Area Stack)
Areas displayed as stacked cards (wallet-like).
Tap an area → Area View.
Empty state: “Empty Pot” (no areas yet).
5.2 Area View
Shows pinned Babcia persona for that area.
Primary action: Take Photo (starts a bowl).
Verification is off by default; user may enable verification for this bowl before starting (simple toggle).
5.3 Camera / Bowl creation
Entry points:
From Areas page → Area View → Camera (normal flow).
From Camera-first (if you support it): after capture, user selects which Area it belongs to.
5.4 Bowl Task Screen
Shows up to 5 tasks.
User ticks tasks off one-by-one.
Points: each task tick immediately grants base points into the pot
Default: 1 point per task (tunable)
5.5 Bowl completion
When all tasks in the bowl are ticked:
“Party State” feedback (confetti + sound)
Babcia asks:
“Are you full?” → end session
“One more bowl?” → user must take a new photo (no backlog; always a new bowl from a fresh photo)
5.6 Verification flow (optional)
Verification screen appears only if verification was enabled for this bowl.
The verification screen:
is visually “paused” so the user can tidy more before submitting the after photo.
offers:
No (finish without verifying)
Blue Verify
Golden Verify (only sometimes; see rules below)
Important behavioral promise (to cover AI uncertainty):
Verification is strict and not guaranteed.
Babcia’s verdict is final.
No detailed reasons for failure in V1.
No retries in V1.
6) Task engine (AI) — “Up to 5”
6.1 Input
User takes a photo of the area.
6.2 Output rules
AI generates up to 5 tasks.
If AI finds fewer than 5, it returns fewer (no padding).
If AI finds 0 actionable tasks, prompt user to retake photo.
6.3 If AI sees more than 5 possible tasks
AI selects the best 5 for this bowl:
quick wins
visible impact
safe / low-risk
No backlog (extras are not stored).
7) Points, verification bonuses, and “Golden” logic
7.1 Base points
Each task tick awards base points immediately.
Let:
base = sum(task_points) (default: number of tasks completed)
7.2 Finish without verifying
User taps No on verification screen:
Bowl finalizes unverified
User keeps base points already earned
No bonus applied
7.3 Blue Verify (always available)
User submits after photo:
Pass: total for the bowl becomes 4× base
Fail: award half of the Blue bonus
Blue bonus (pass) = +3× base
Half-bonus = +1.5× base
So fail total becomes 2.5× base
If fail: bowl remains unverified, no retry
7.4 Golden Verify (conditional, not random)
Golden Verify is not a loot drop. It appears when the system detects the user:
hasn’t verified recently and/or
is behind their self-set goal
User submits after photo:
Pass: total becomes 10× base
Fail: award half of the Golden bonus
Golden bonus (pass) = +9× base
Half-bonus = +4.5× base
So fail total becomes 5.5× base
If fail: bowl remains unverified, no retry
8) Economy & rewards (solo-dev simple)
8.1 Points are the only currency
The pot holds points (e.g., “2,000 points”).
8.2 Filters shop (ingredient-themed pricing)
Users unlock Dream Vision Filters by spending points.
Each filter has a clear point price (e.g., 4,000 points).
The cost is also represented by ingredient icons (e.g., “4 onions + 7 tomatoes”) as visual theme only.
Purchase is one transaction: spend points → unlock filter.
No separate ingredient inventory is required in V1.
8.3 Filter output
Filters stylize the AI-generated After header image.
Filtered images are saved and can be shared.
9) Burnout protection
Daily bowl target (user-set)
User selects a daily bowl target.
When target is hit: Kitchen Closed
UI dims
Babcia refuses more bowls for the day
No punishment language
Streak
Streak = number of days the user takes an area photo
Counts max once per day (first area photo)
Verification photos do not count
No punishment for missed streaks
10) Tech & asset guidelines (V1)
Input mechanism: AI-driven photo analysis → tasks (up to 5).
UI style: Liquid Glass / mesh gradients / glass cards (optional).
Typography: Linux Libertine (if you still want this constraint).
SFX: satisfying “crunch” on tick; party sound on bowl completion.
11) Future ideas (explicitly not V1)
Streaming camera providers / RTSP / Home Assistant integration
Automatic persona switching / scaffolding logic
Advanced reminders / smart scheduling
12) Build checklist (what “done” means)
Must-haves
Create/manage Areas (name + pinned persona)
Photo capture per bowl
AI → generate up to 5 tasks
Tick tasks off → points awarded per tick
Bowl completion → “Are you full?” / “One more bowl?” (new photo)
Verification toggle per bowl (default off)
Verification screen (paused)
Blue verify pass/fail rules (4× or 2.5×)
Golden verify conditional eligibility + pass/fail rules (10× or 5.5×)
No retries, no failure reasons
Points pot display
Filter shop: spend points, unlock, apply to After image
Nice-to-haves (still V1-possible, not required)
Confetti / folk music polish
Share sheet for After images