import { StyleSheet, Text, TextProps } from 'react-native';

import { Typography, useThemeColors } from '@/theme';

type AppTextProps = TextProps & {
  color?: 'default' | 'muted';
  variant?: 'body' | 'title';
};

export function AppText({ color = 'default', style, variant = 'body', ...props }: AppTextProps) {
  const colors = useThemeColors();

  return (
    <Text
      style={[
        styles[variant],
        { color: color === 'muted' ? colors.textMuted : colors.text },
        style,
      ]}
      {...props}
    />
  );
}

const styles = StyleSheet.create({
  body: {
    fontSize: Typography.body.fontSize,
    lineHeight: Typography.body.lineHeight,
    fontWeight: '500',
  },
  title: {
    fontSize: Typography.title.fontSize,
    lineHeight: Typography.title.lineHeight,
    fontWeight: '700',
  },
});
