import { Screen } from '@/components/layout/Screen';
import { AppText } from '@/components/ui/AppText';

export default function ProfileScreen() {
  return (
    <Screen>
      <AppText variant="h1">Profile</AppText>
      <AppText color="muted">Your profile and preferences will live here.</AppText>
    </Screen>
  );
}
