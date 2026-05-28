import { Screen } from '@/components/layout/Screen';
import { AppText } from '@/components/ui/AppText';

export default function StreaksScreen() {
  return (
    <Screen>
      <AppText variant="title">Streaks</AppText>
      <AppText color="muted">Your streak list will live here.</AppText>
    </Screen>
  );
}
