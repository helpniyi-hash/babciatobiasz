# Project State

## 2026-01-12 14:18 (local)
- Added a running project state log (this file).
- Planning Areas page rebuild with a custom internal ScalingHeaderScrollView.
- Target: Areas page gets stretchy hero header + bottom search bar; hero image is Baroness headshot (neutral) for now and swappable later.

## 2026-01-12 14:27 (local)
- Added internal ScalingHeaderScrollView (stretchy/sticky header with snap + progress tracking + refresh support).
- Areas page now uses ScalingHeaderScrollView with Baroness headshot hero image and pinned bottom search bar.
- Removed top search UI on Areas (search is now always visible at bottom).

## 2026-01-12 15:34 (local)
- Added icon checklist file at /Users/Shared/Developer/BabciaTobiasz/ICON_CHECKLIST.md with Babcia-specific icon meanings and specs.
- Confirmed hero image asset for Areas header: R2_Baroness_Headshot_Neutral.

## 2026-01-12 17:13 (local)
- Fixed ScalingHeaderScrollView stretch behavior: header now expands on pull-down (no clipping) and sticks on scroll-up.
- Added conditional clipping only when collapsing to avoid cutting the hero during pull-down.

## 2026-01-12 19:05 (local)
- Locked decisions: A1/B1/C1. Areas will reuse the Weather page layout; Habits view becomes Gallery placeholder; Babcia stays centered placeholder; update handoff before making code changes.

## 2026-01-12 19:05 (local)
- Implemented A1/B1/C1 wiring: Areas now uses Weather layout via AreasView with a hero image card; Gallery uses HabitListView as placeholder; Home remains WeatherView.

## 2026-01-13 01:46 (local)
- Locked dream image spec: master 1200x1600 portrait. Added DreamRoom_Test_1200x1600 asset and wired it into the Areas hero card.
- Added DSGrid.heroCardHeight token (260) to support full-bleed hero height in a consistent, design-system-friendly way.
