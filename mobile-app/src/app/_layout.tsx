import '@/global.css';

import { useEffect } from 'react';
import { DarkTheme, Stack, ThemeProvider } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useFonts } from 'expo-font';
import * as SplashScreen from 'expo-splash-screen';
import {
  Fredoka_600SemiBold,
  Fredoka_700Bold,
} from '@expo-google-fonts/fredoka';
import {
  Nunito_400Regular,
  Nunito_500Medium,
  Nunito_600SemiBold,
} from '@expo-google-fonts/nunito';

import { Palette } from '@/theme';

SplashScreen.preventAutoHideAsync();

const streakDarkTheme = {
  ...DarkTheme,
  colors: {
    ...DarkTheme.colors,
    background: Palette.bgPrimary,
    card: Palette.bgSecondary,
    text: Palette.textPrimary,
    border: 'rgba(168, 85, 247, 0.15)',
    notification: Palette.orange,
    primary: Palette.orange,
  },
};

export default function RootLayout() {
  const [fontsLoaded] = useFonts({
    Fredoka_600SemiBold,
    Fredoka_700Bold,
    Nunito_400Regular,
    Nunito_500Medium,
    Nunito_600SemiBold,
  });

  useEffect(() => {
    if (fontsLoaded) {
      SplashScreen.hideAsync();
    }
  }, [fontsLoaded]);

  if (!fontsLoaded) {
    return null;
  }

  return (
    <ThemeProvider value={streakDarkTheme}>
      <StatusBar style="light" />
      <Stack screenOptions={{ headerShown: false }}>
        <Stack.Screen name="(tabs)" />
      </Stack>
    </ThemeProvider>
  );
}
