import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/data/repositories/attendance_repository.dart';
import 'package:inspektor/services/api/api_result.dart';

import '../../support/fake_http.dart';

void main() {
  test('getInspectorLeaves parses leaves + pagination', () async {
    final repo = AttendanceRepository(apiWrapperWith((_) => (
          status: 200,
          body: {
            'data': {
              'leaves': [
                {
                  'id': 1,
                  'leave_date': '2026-06-25',
                  'status': 'pending',
                  'reason': 'sick',
                },
              ],
              'pagination': {'current_page': 1, 'last_page': 2},
            },
          },
        )));
    final r = await repo.getInspectorLeaves(1);
    expect(r, isA<ApiSuccess<LeavePage>>());
    final page = (r as ApiSuccess<LeavePage>).data;
    expect(page.items.single.isPending, true);
    expect(page.items.single.reason, 'sick');
    expect(page.pagination.hasMore, true);
  });

  test('getAdminAttendance parses records with nested inspector', () async {
    final repo = AttendanceRepository(apiWrapperWith((_) => (
          status: 200,
          body: {
            'data': {
              'attendance': [
                {
                  'id': 1,
                  'type': 'working',
                  'inspector': {'name': 'Insp One', 'email': 'a@b.c'},
                  'check_in': '2026-06-22T09:00:00Z',
                },
              ],
            },
          },
        )));
    final r = await repo.getAdminAttendance(1);
    expect(r, isA<ApiSuccess<AttendancePage>>());
    final rec = (r as ApiSuccess<AttendancePage>).data.items.single;
    expect(rec.inspectorName, 'Insp One');
    expect(rec.isWorking, true);
  });

  test('approveLeave surfaces conflicting bookings', () async {
    final repo = AttendanceRepository(apiWrapperWith((_) => (
          status: 200,
          body: {
            'success': true,
            'conflicting_bookings': ['ORD-1', 'ORD-2'],
          },
        )));
    final r = await repo.approveLeave(7, 'ok');
    expect(r, isA<ApiSuccess<LeaveDecision>>());
    expect((r as ApiSuccess<LeaveDecision>).data.conflictingBookings,
        ['ORD-1', 'ORD-2']);
  });
}
