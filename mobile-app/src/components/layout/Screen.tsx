import { type PropsWithChildren } from 'react';
import { ScrollView, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { Palette, Spacing } from '@/theme';

interface ScreenProps extends PropsWithChildren {
  /** Enable vertical scrolling for content-heavy screens */
  scrollable?: boolean;
}

export function Screen({ children, scrollable = false }: ScreenProps) {
  return (
    <SafeAreaView style={styles.safeArea}>
      {scrollable ? (
        <ScrollView
          style={styles.scrollView}
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          {children}
        </ScrollView>
      ) : (
        <View style={styles.content}>{children}</View>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: Palette.bgPrimary,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    gap: Spacing.xl,
    paddingHorizontal: Spacing.xl,
    paddingTop: Spacing.lg,
    paddingBottom: Spacing.xxxl + 20,
  },
  content: {
    flex: 1,
    gap: Spacing.md,
    paddingHorizontal: Spacing.xl,
    paddingVertical: Spacing.lg,
  },
});
