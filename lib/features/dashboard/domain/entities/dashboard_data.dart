// Domain entities for the dashboard feature

class DashboardData {
  final int dayStreak;
  final int weeklyPoints;
  final int weeklyPointsDelta;
  final String focusTime;
  final String nextAlarmTime;
  final String highlightTitle;
  final String highlightDate;
  final int tasksDone;
  final int tasksTotal;
  final String newsTitle;
  final String newsCategory;
  final String workspaceName;
  final int activeProjects;
  final int newDocuments;
  final List<String> workspaceAvatars;

  const DashboardData({
    required this.dayStreak,
    required this.weeklyPoints,
    required this.weeklyPointsDelta,
    required this.focusTime,
    required this.nextAlarmTime,
    required this.highlightTitle,
    required this.highlightDate,
    required this.tasksDone,
    required this.tasksTotal,
    required this.newsTitle,
    required this.newsCategory,
    required this.workspaceName,
    required this.activeProjects,
    required this.newDocuments,
    required this.workspaceAvatars,
  });
}
