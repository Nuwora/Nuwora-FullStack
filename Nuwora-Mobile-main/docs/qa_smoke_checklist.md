# Nuwora Mobile - Pre-Backend Smoke Checklist

## Onboarding
- Welcome step rejects invalid name/age and allows valid input.
- Goals step requires at least one goal.
- Finishing onboarding transitions to main tabs.

## Tabs
- Home opens with loading state, then loaded/empty/error feedback.
- Coach opens, loads history, can send message, and shows action feedback.
- Mind Gym opens, loads plan, supports start/complete flow and feedback.
- Insights opens, supports period switch and loaded/empty/error feedback.
- Profile opens, loads summary cards and settings/corporate links.

## Offline/Online
- Going offline shows cached-data warning toast.
- Reconnect shows update toast and sync feedback state.

## Settings Persistence
- Theme selection persists after app relaunch.
- Reminder toggle persists after app relaunch.
- Reminder time persists after app relaunch.
