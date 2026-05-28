import { Screen } from '@/components/layout/Screen';
import { AppText } from '@/components/ui/AppText';

export default function ProgressScreen() {
  return (
    <Screen>
      <AppText variant="h1">Progress</AppText>
      <AppText color="muted">Your progress insights will live here.</AppText>
    </Screen>
  );
}
