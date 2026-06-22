import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../themes/carspy_colors.dart';

enum TaskPriority { urgent, standard }

class AssignedTask {
  const AssignedTask({
    required this.id,
    required this.vehicleName,
    required this.location,
    required this.timeSlot,
    required this.priority,
    this.isCompleted = false,
  });

  final String id;
  final String vehicleName;
  final String location;
  final String timeSlot;
  final TaskPriority priority;
  final bool isCompleted;
}

const _mockTasks = [
  AssignedTask(
    id: '1',
    vehicleName: '2022 Tesla Model 3',
    location: 'Downtown Charging Station, Lot B',
    timeSlot: 'Today, 10:00 AM - 11:30 AM',
    priority: TaskPriority.urgent,
  ),
  AssignedTask(
    id: '2',
    vehicleName: '2019 Ford F-150',
    location: 'Northside Depot, Bay 4',
    timeSlot: 'Today, 1:00 PM - 2:00 PM',
    priority: TaskPriority.standard,
  ),
  AssignedTask(
    id: '3',
    vehicleName: '2021 Toyota Camry',
    location: 'Airport Rental Lot, Sector C',
    timeSlot: 'Tomorrow, 9:00 AM - 10:00 AM',
    priority: TaskPriority.standard,
  ),
];

const _initialCompletedTasks = [
  AssignedTask(
    id: '4',
    vehicleName: '2020 Honda Civic',
    location: 'West Side Garage, Level 2',
    timeSlot: 'Yesterday, 2:00 PM - 3:00 PM',
    priority: TaskPriority.standard,
    isCompleted: true,
  ),
  AssignedTask(
    id: '5',
    vehicleName: '2023 BMW X5',
    location: 'Central Hub, Bay 1',
    timeSlot: 'Yesterday, 11:00 AM - 12:30 PM',
    priority: TaskPriority.urgent,
    isCompleted: true,
  ),
];

class WorkAssignedScreen extends StatefulWidget {
  const WorkAssignedScreen({super.key});

  @override
  State<WorkAssignedScreen> createState() => _WorkAssignedScreenState();
}

class _WorkAssignedScreenState extends State<WorkAssignedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<AssignedTask> _assignedTasks = List.from(_mockTasks);
  final List<AssignedTask> _completedTasks = List.from(_initialCompletedTasks);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onAccept(AssignedTask task) {
    setState(() {
      _assignedTasks.removeWhere((t) => t.id == task.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accepted: ${task.vehicleName}'),
        backgroundColor: CarSpyColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  void _onReject(AssignedTask task) {
    setState(() {
      _assignedTasks.removeWhere((t) => t.id == task.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rejected: ${task.vehicleName}'),
        backgroundColor: CarSpyColors.rejected,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CarSpyColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'CarSpy',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: CarSpyColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _HeaderSection(pendingCount: _assignedTasks.length),
          _TabBar(controller: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TaskList(
                  tasks: _assignedTasks,
                  onAccept: _onAccept,
                  onReject: _onReject,
                ),
                _TaskList(
                  tasks: _completedTasks,
                  showActions: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: CarSpyColors.surface,
            child: Icon(
              Icons.person,
              color: CarSpyColors.onSurfaceVariant,
              size: 28.r,
            ),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Work Tasks',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: CarSpyColors.onSurface,
                ),
              ),
              Text(
                '$pendingCount Pending Inspections',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: CarSpyColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller,
        indicatorColor: CarSpyColors.primary,
        indicatorWeight: 2.5,
        labelColor: CarSpyColors.primary,
        unselectedLabelColor: CarSpyColors.onSurfaceVariant,
        labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'Assigned'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.tasks,
    this.onAccept,
    this.onReject,
    this.showActions = true,
  });

  final List<AssignedTask> tasks;
  final void Function(AssignedTask)? onAccept;
  final void Function(AssignedTask)? onReject;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 56.r,
              color: CarSpyColors.outlineVariant,
            ),
            SizedBox(height: 12.h),
            Text(
              'No tasks here',
              style: TextStyle(
                fontSize: 16.sp,
                color: CarSpyColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      itemCount: tasks.length,
      itemBuilder: (context, index) => _TaskCard(
        task: tasks[index],
        onAccept: onAccept,
        onReject: onReject,
        showActions: showActions,
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    this.onAccept,
    this.onReject,
    this.showActions = true,
  });

  final AssignedTask task;
  final void Function(AssignedTask)? onAccept;
  final void Function(AssignedTask)? onReject;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.vehicleName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: CarSpyColors.onSurface,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                _PriorityBadge(priority: task.priority),
              ],
            ),
            SizedBox(height: 10.h),
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: task.location,
            ),
            SizedBox(height: 6.h),
            _InfoRow(
              icon: Icons.access_time_rounded,
              text: task.timeSlot,
            ),
            if (showActions) ...[
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Reject',
                      icon: Icons.close,
                      onTap: () => onReject?.call(task),
                      filled: false,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _ActionButton(
                      label: 'Accept',
                      icon: Icons.check,
                      onTap: () => onAccept?.call(task),
                      filled: true,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final isUrgent = priority == TaskPriority.urgent;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isUrgent ? const Color(0xFFEEF2FF) : const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        isUrgent ? 'Urgent' : 'Standard',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color:
              isUrgent ? CarSpyColors.primary : CarSpyColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.r, color: CarSpyColors.onSurfaceVariant),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: CarSpyColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.filled,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: filled ? CarSpyColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: filled
              ? null
              : Border.all(color: CarSpyColors.outlineVariant, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.r,
              color: filled ? Colors.white : CarSpyColors.onSurface,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : CarSpyColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
