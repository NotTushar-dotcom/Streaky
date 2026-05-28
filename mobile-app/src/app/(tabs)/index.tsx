import { Screen } from '@/components/layout/Screen';
import { AppText } from '@/components/ui/AppText';

export default function TodayScreen() {
  return (
    <Screen>
      <AppText variant="title">Today</AppText>
      <AppText color="muted">Your daily streak view will live here.</AppText>
    </Screen>
  );
}
