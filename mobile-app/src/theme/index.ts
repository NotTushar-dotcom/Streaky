import { useColorScheme } from '@/hooks/use-color-scheme';

export const Colors = {
  light: {
    background: '#F7F7F2',
    surface: '#FFFFFF',
    text: '#171717',
    textMuted: '#6B7280',
    tint: '#2F7D59',
    border: '#E5E7EB',
  },
  dark: {
    background: '#101412',
    surface: '#171C19',
    text: '#F9FAFB',
    textMuted: '#A1A1AA',
    tint: '#78D99E',
    border: '#2B332F',
  },
} as const;

export const Spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
} as const;

export const Typography = {
  body: {
    fontSize: 16,
    lineHeight: 24,
  },
  title: {
    fontSize: 32,
    lineHeight: 40,
  },
} as const;

export type ThemeName = keyof typeof Colors;
export type ThemeColors = typeof Colors.light;

export function useThemeColors() {
  const colorScheme = useColorScheme();
  const themeName: ThemeName = colorScheme === 'dark' ? 'dark' : 'light';

  return Colors[themeName];
}
