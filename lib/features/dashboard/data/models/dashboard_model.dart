import 'package:elevate/features/dashboard/domain/entities/dashboard_data.dart';

class DashboardModel extends DashboardData {
  const DashboardModel({
    required super.dayStreak,
    required super.weeklyPoints,
    required super.weeklyPointsDelta,
    required super.focusTime,
    required super.nextAlarmTime,
    required super.highlightTitle,
    required super.highlightDate,
    required super.tasksDone,
    required super.tasksTotal,
    required super.newsTitle,
    required super.newsCategory,
    required super.workspaceName,
    required super.activeProjects,
    required super.newDocuments,
    required super.workspaceAvatars,
  });

  factory DashboardModel.mock() {
    return const DashboardModel(
      dayStreak: 12,
      weeklyPoints: 82,
      weeklyPointsDelta: 7,
      focusTime: '3h 20m',
      nextAlarmTime: '6:45 AM',
      highlightTitle: 'Submit ML\nAssignment',
      highlightDate: '09/06/2026',
      tasksDone: 5,
      tasksTotal: 6,
      newsTitle: 'Stay Updated with\nCurrent Events',
      newsCategory: 'NEWS',
      workspaceName: 'Project Portal',
      activeProjects: 3,
      newDocuments: 5,
      workspaceAvatars: ['A', 'B', 'C', 'D', 'E'],
    );
  }
}
