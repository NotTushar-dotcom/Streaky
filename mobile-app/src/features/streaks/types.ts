import type { StreakCategory } from '@/theme';

export interface Streak {
  id: string;
  name: string;
  emoji: string;
  category: StreakCategory;
  currentStreak: number;
  bestStreak: number;
  isCompletedToday: boolean;
  /** 7 booleans for Mon–Sun of the current week */
  weekHistory: boolean[];
  targetDescription: string;
}
