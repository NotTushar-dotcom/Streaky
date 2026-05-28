import { Pressable, StyleSheet, Text } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';

import { BorderRadius, FontFamily, Palette } from '@/theme';

interface CheckInButtonProps {
  isCompleted: boolean;
  onPress: () => void;
}

export function CheckInButton({ isCompleted, onPress }: CheckInButtonProps) {
  if (isCompleted) {
    return (
      <Pressable
        onPress={onPress}
        style={({ pressed }) => [
          styles.button,
          styles.completedButton,
          pressed && styles.pressed,
        ]}
      >
        <Text style={styles.completedText}>✓ Done!</Text>
      </Pressable>
    );
  }

  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [pressed && styles.pressed]}
    >
      <LinearGradient
        colors={[Palette.orange, Palette.orangeGlow]}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 0 }}
        style={[styles.button]}
      >
        <Text style={styles.uncheckedText}>Check In 🔥</Text>
      </LinearGradient>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  button: {
    paddingVertical: 10,
    paddingHorizontal: 28,
    borderRadius: BorderRadius.full,
    alignItems: 'center',
    justifyContent: 'center',
  },
  pressed: {
    transform: [{ scale: 0.95 }],
    opacity: 0.9,
  },
  uncheckedText: {
    fontSize: 15,
    fontFamily: FontFamily.heading,
    color: '#FFFFFF',
    letterSpacing: 0.5,
  },
  completedButton: {
    backgroundColor: 'rgba(74, 222, 128, 0.15)',
    borderWidth: 1.5,
    borderColor: Palette.success,
  },
  completedText: {
    fontSize: 15,
    fontFamily: FontFamily.heading,
    color: Palette.success,
    letterSpacing: 0.5,
  },
});
