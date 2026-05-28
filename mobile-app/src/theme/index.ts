import { useColorScheme } from '@/hooks/use-color-scheme';

// ─── Streaky Color Palette ──────────────────────────────────────────────────────

export const Palette = {
  // Backgrounds
  bgPrimary: '#0F0B1E',
  bgSecondary: '#1A1333',
  bgTertiary: '#251D45',

  // Primary (fire / streak psychology)
  orange: '#FF8C42',
  orangeGlow: '#FFB347',
  amber: '#FFCF56',

  // Secondary
  purple: '#A855F7',
  purpleLight: '#C084FC',
  purpleDark: '#7C3AED',

  // Accents
  cyan: '#22D3EE',
  lime: '#A3E635',
  pink: '#F472B6',

  // Semantic
  success: '#4ADE80',
  warning: '#FBBF24',
  error: '#F87171',

  // Text
  textPrimary: '#F8FAFC',
  textSecondary: '#94A3B8',
  textAccent: '#FFB347',
} as const;

// ─── Category Themes ────────────────────────────────────────────────────────────

export type StreakCategory = 'coding' | 'gym' | 'reading' | 'meditation' | 'content';

export const CategoryThemes: Record<StreakCategory, { color: string; gradient: [string, string] }> = {
  coding: { color: '#22D3EE', gradient: ['#22D3EE', '#0891B2'] },
  gym: { color: '#F472B6', gradient: ['#F472B6', '#DB2777'] },
  reading: { color: '#A855F7', gradient: ['#A855F7', '#7C3AED'] },
  meditation: { color: '#4ADE80', gradient: ['#4ADE80', '#16A34A'] },
  content: { color: '#FFB347', gradient: ['#FFB347', '#FF8C42'] },
};

// ─── Backward-Compatible Theme (used by Screen, etc.) ───────────────────────────

export const Colors = {
  light: {
    background: Palette.bgPrimary,
    surface: Palette.bgSecondary,
    text: Palette.textPrimary,
    textMuted: Palette.textSecondary,
    tint: Palette.orange,
    border: 'rgba(168, 85, 247, 0.15)',
  },
  dark: {
    background: Palette.bgPrimary,
    surface: Palette.bgSecondary,
    text: Palette.textPrimary,
    textMuted: Palette.textSecondary,
    tint: Palette.orange,
    border: 'rgba(168, 85, 247, 0.15)',
  },
} as const;

// ─── Spacing ────────────────────────────────────────────────────────────────────

export const Spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  xxxl: 32,
} as const;

// ─── Border Radii ───────────────────────────────────────────────────────────────

export const BorderRadius = {
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  full: 9999,
} as const;

// ─── Typography ─────────────────────────────────────────────────────────────────

export const Typography = {
  hero: { fontSize: 28, lineHeight: 36 },
  h1: { fontSize: 22, lineHeight: 30 },
  h2: { fontSize: 18, lineHeight: 24 },
  body: { fontSize: 15, lineHeight: 22 },
  caption: { fontSize: 13, lineHeight: 18 },
  counter: { fontSize: 28, lineHeight: 34 },
} as const;

export const FontFamily = {
  heading: 'Fredoka_700Bold',
  headingSemiBold: 'Fredoka_600SemiBold',
  body: 'Nunito_500Medium',
  bodyRegular: 'Nunito_400Regular',
  bodySemiBold: 'Nunito_600SemiBold',
} as const;

// ─── Utilities ──────────────────────────────────────────────────────────────────

/** Append hex opacity: withOpacity('#FF0000', 0.5) → '#FF000080' */
export function withOpacity(hex: string, opacity: number): string {
  const alpha = Math.round(opacity * 255)
    .toString(16)
    .padStart(2, '0');
  return `${hex}${alpha}`;
}

// ─── Theme Hook ─────────────────────────────────────────────────────────────────

export type ThemeName = keyof typeof Colors;
export type ThemeColors = (typeof Colors)['dark'];

export function useThemeColors(): ThemeColors {
  const colorScheme = useColorScheme();
  const themeName: ThemeName = colorScheme === 'dark' ? 'dark' : 'light';
  return Colors[themeName];
}
