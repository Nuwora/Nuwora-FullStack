import { Goal } from '@prisma/client';

/** The `/me` response uses the Swift domain's display labels, not the wire-format identifiers. */
const GOAL_DISPLAY_LABELS: Record<Goal, string> = {
  focus: 'Focus',
  stress_relief: 'Stress Relief',
  memory: 'Memory',
  resilience: 'Resilience',
};

export function goalDisplayLabel(goal: Goal): string {
  return GOAL_DISPLAY_LABELS[goal];
}
