import { type PropsWithChildren } from 'react';
import { StyleSheet, View, type ViewStyle } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';

import { BorderRadius, Palette, Spacing, withOpacity } from '@/theme';

interface GradientCardProps extends PropsWithChildren {
  /** Category accent color — tints the border and shadow */
  accentColor?: string;
  style?: ViewStyle;
}

export function GradientCard({ children, accentColor, style }: GradientCardProps) {
  return (
    <View
      style={[
        styles.shadow,
        accentColor ? { shadowColor: accentColor } : undefined,
      ]}
    >
      <LinearGradient
        colors={[Palette.bgSecondary, Palette.bgTertiary]}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={[
          styles.card,
          accentColor
            ? { borderColor: withOpacity(accentColor, 0.2) }
            : undefined,
          style,
        ]}
      >
        {children}
      </LinearGradient>
    </View>
  );
}

const styles = StyleSheet.create({
  shadow: {
    shadowColor: Palette.purple,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 12,
    elevation: 8,
  },
  card: {
    borderRadius: BorderRadius.xl,
    padding: Spacing.xl,
    borderWidth: 1,
    borderColor: 'rgba(168, 85, 247, 0.12)',
    overflow: 'hidden',
  },
});
