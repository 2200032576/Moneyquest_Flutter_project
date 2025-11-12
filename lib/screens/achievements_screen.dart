import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        final allAchievements = [
          AchievementInfo(
            id: 'streak_7',
            title: '7-Day Streak',
            description: 'Log expenses for 7 consecutive days',
            icon: '🔥',
            requirement: 7,
          ),
          AchievementInfo(
            id: 'expense_50',
            title: 'Tracking Master',
            description: 'Log 50 expenses',
            icon: '📊',
            requirement: 50,
          ),
          AchievementInfo(
            id: 'level_5',
            title: 'Level 5 Achiever',
            description: 'Reach Level 5',
            icon: '⭐',
            requirement: 5,
          ),
          AchievementInfo(
            id: 'budget_master',
            title: 'Budget Master',
            description: 'Stay within budget for a month',
            icon: '💰',
            requirement: 1,
          ),
        ];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Progress Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stars, color: Colors.amber[600], size: 40),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level ${provider.userLevel}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${provider.userXP} / ${provider.userLevel * 100} XP',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: provider.userXP / (provider.userLevel * 100),
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(Colors.amber[600]),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${((provider.userXP / (provider.userLevel * 100)) * 100).toStringAsFixed(1)}% to next level',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Achievements',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock badges by reaching financial milestones',
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 16),

            // Achievements List
            ...allAchievements.map((achievementInfo) {
              final unlocked = provider.achievements
                  .any((a) => a.id == achievementInfo.id);
              final unlockedAchievement = unlocked
                  ? provider.achievements
                      .firstWhere((a) => a.id == achievementInfo.id)
                  : null;

              return AchievementCard(
                achievementInfo: achievementInfo,
                unlocked: unlocked,
                unlockedAt: unlockedAchievement?.unlockedAt,
              );
            }).toList(),

            const SizedBox(height: 24),

            // Stats Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Stats',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _StatRow(
                      icon: Icons.emoji_events,
                      label: 'Achievements Unlocked',
                      value: '${provider.achievements.length}/4',
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 12),
                    _StatRow(
                      icon: Icons.receipt_long,
                      label: 'Total Expenses Logged',
                      value: provider.expenses.length.toString(),
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _StatRow(
                      icon: Icons.calendar_today,
                      label: 'Days Active',
                      value: _calculateActiveDays(provider.expenses).toString(),
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int _calculateActiveDays(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;
    final dates = expenses.map((e) => 
      DateTime(e.date.year, e.date.month, e.date.day)
    ).toSet();
    return dates.length;
  }
}

class AchievementInfo {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int requirement;

  AchievementInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requirement,
  });
}

class AchievementCard extends StatelessWidget {
  final AchievementInfo achievementInfo;
  final bool unlocked;
  final DateTime? unlockedAt;

  const AchievementCard({
    super.key,
    required this.achievementInfo,
    required this.unlocked,
    this.unlockedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: unlocked ? Colors.amber[50] : null,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: unlocked
                ? Colors.amber[100]
                : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              achievementInfo.icon,
              style: TextStyle(
                fontSize: 24,
                color: unlocked ? null : Colors.grey[400],
              ),
            ),
          ),
        ),
        title: Text(
          achievementInfo.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: unlocked ? Colors.amber[900] : Colors.grey[700],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievementInfo.description,
              style: TextStyle(
                color: unlocked ? Colors.amber[800] : Colors.grey[600],
              ),
            ),
            if (unlocked && unlockedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Unlocked ${DateFormat('MMM dd, yyyy').format(unlockedAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        trailing: unlocked
            ? Icon(Icons.check_circle, color: Colors.amber[700])
            : Icon(Icons.lock_outline, color: Colors.grey[400]),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          radius: 20,
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}