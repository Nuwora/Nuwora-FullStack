const MS_PER_DAY = 24 * 60 * 60 * 1000;

/** Truncates a date to a UTC calendar day (midnight UTC). */
export function utcDayStart(date: Date): Date {
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
}

export function utcDaysBetween(a: Date, b: Date): number {
  return Math.round((utcDayStart(b).getTime() - utcDayStart(a).getTime()) / MS_PER_DAY);
}

export function isSameUTCDay(a: Date, b: Date): boolean {
  return utcDaysBetween(a, b) === 0;
}
