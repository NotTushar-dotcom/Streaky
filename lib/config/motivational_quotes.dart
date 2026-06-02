import 'dart:math';

/// Motivational quotes for the home screen.
class MotivationalQuotes {
  MotivationalQuotes._();

  static final _random = Random();

  static const List<String> quotes = [
    "Consistency is the mother of mastery. 🔥",
    "Small steps every day lead to massive results.",
    "You don't have to be extreme, just consistent.",
    "The secret of your future is hidden in your daily routine.",
    "It's not about motivation. It's about discipline.",
    "One day or day one. You decide. 💪",
    "Don't break the chain. Keep going!",
    "Progress, not perfection.",
    "Your only limit is you.",
    "The best time to start was yesterday. The next best is now.",
    "Streaks don't lie. Your effort shows. 🌟",
    "Champions are built through daily dedication.",
    "Every check-in is a vote for your future self.",
    "You're closer than you think. Don't stop now.",
    "Discipline is choosing between what you want now and what you want most.",
    "Success is the sum of small efforts repeated daily.",
    "The pain of discipline is nothing compared to the pain of regret.",
    "Don't count the days, make the days count.",
    "Consistency breeds confidence. Keep at it!",
    "You already started. That's more than most people do. 🚀",
    "Today's effort is tomorrow's result.",
    "Be patient with yourself. Growth takes time.",
    "Each day you show up, you level up. ⚡",
    "Greatness is a lot of small things done well.",
    "The streak is proof you're stronger than your excuses.",
    "Winners are not people who never fail, they're people who never quit.",
    "Your future self will thank you for showing up today.",
    "Momentum is everything. Keep the flame alive! 🔥",
    "Hard choices, easy life. Easy choices, hard life.",
    "You don't need motivation when you have a system.",
  ];

  /// Get a random quote.
  static String get random => quotes[_random.nextInt(quotes.length)];

  /// Get the quote for today (consistent within a day).
  static String get today {
    final now = DateTime.now();
    final dayIndex = (now.year * 366 + now.month * 31 + now.day) % quotes.length;
    return quotes[dayIndex];
  }
}
