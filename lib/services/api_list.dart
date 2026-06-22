/// API paths only — base URL lives in dio_client.dart (apiBaseUrl).
/// Only endpoints the in-scope (core inspection) flows actually call.
class APIList {
  const APIList._();

  // --- Auth ---
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String refresh = '/auth/refresh';

  // --- Vehicle + inspection setup ---
  static const String vehicleModels = '/admin/vehicles/models';
  static const String initializeInspection = '/dynamic-inspections/initialize';
  static const String ulipVehicleDetails = '/ulip/vehicle-details';

  // --- Media + submit ---
  static const String uploadMedia = '/inspection/upload-image';
  static const String submitInspection = '/dynamic-inspections';
  static String updateInspection(Object id) => '/inspections/$id';

  // --- Lists / stats ---
  static const String inspectionHistory = '/dynamic-inspections';
  static const String myHistory = '/dynamic-inspections/my-history';
  static const String inspectionStats = '/dynamic-inspections/stats';

  // --- Attendance / leaves ---
  static const String inspectorLeaves = '/inspector/leaves';
  static String cancelLeave(Object id) => '/inspector/leaves/$id';
  static const String adminLeaves = '/admin/leaves';
  static String approveLeave(Object id) => '/admin/leaves/$id/approve';
  static String rejectLeave(Object id) => '/admin/leaves/$id/reject';
  static const String adminAttendance = '/admin/attendance';
}
