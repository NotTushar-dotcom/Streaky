import { Text, type TextProps, type TextStyle } from 'react-native';

import { FontFamily, Palette, Typography } from '@/theme';

type AppTextVariant = 'hero' | 'h1' | 'h2' | 'body' | 'caption' | 'counter';
type AppTextColor = 'primary' | 'secondary' | 'accent' | 'success' | 'default' | 'muted';

interface AppTextProps extends TextProps {
  variant?: AppTextVariant;
  color?: AppTextColor;
}

const variantStyles: Record<AppTextVariant, TextStyle> = {
  hero: {
    fontSize: Typography.hero.fontSize,
    lineHeight: Typography.hero.lineHeight,
    fontFamily: FontFamily.heading,
  },
  h1: {
    fontSize: Typography.h1.fontSize,
    lineHeight: Typography.h1.lineHeight,
    fontFamily: FontFamily.headingSemiBold,
  },
  h2: {
    fontSize: Typography.h2.fontSize,
    lineHeight: Typography.h2.lineHeight,
    fontFamily: FontFamily.headingSemiBold,
  },
  body: {
    fontSize: Typography.body.fontSize,
    lineHeight: Typography.body.lineHeight,
    fontFamily: FontFamily.body,
  },
  caption: {
    fontSize: Typography.caption.fontSize,
    lineHeight: Typography.caption.lineHeight,
    fontFamily: FontFamily.bodyRegular,
  },
  counter: {
    fontSize: Typography.counter.fontSize,
    lineHeight: Typography.counter.lineHeight,
    fontFamily: FontFamily.heading,
  },
};

const colorMap: Record<AppTextColor, string> = {
  primary: Palette.textPrimary,
  default: Palette.textPrimary,
  secondary: Palette.textSecondary,
  muted: Palette.textSecondary,
  accent: Palette.textAccent,
  success: Palette.success,
};

export function AppText({
  variant = 'body',
  color = 'primary',
  style,
  ...props
}: AppTextProps) {
  return (
    <Text
      style={[variantStyles[variant], { color: colorMap[color] }, style]}
      {...props}
    />
  );
}
