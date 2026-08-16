export function aiInsightFor(streakCount: number, xpProgress: number): string {
  if (streakCount === 0) {
    return 'Start today with one short exercise to build your streak.';
  }
  if (xpProgress >= 0.8) {
    return "You're close to leveling up — one more session will get you there.";
  }
  return 'Complete one short focus session to keep your momentum.';
}

export function weeklySummaryFor(streakCount: number, averageOverallScore: number | null): string {
  if (averageOverallScore === null) {
    return 'Log a few sessions this week and your personalized summary will appear here.';
  }
  if (streakCount >= 3) {
    return 'Your consistency improved this week. Keep sessions short and frequent.';
  }
  return 'Your scores held steady this week. A daily short session can build momentum.';
}
