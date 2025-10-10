import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobi_party_link/core/services/permission_service.dart';

part 'permission_provider.freezed.dart';

@freezed
class PermissionState with _$PermissionState {
  const factory PermissionState({
    @Default(false) bool isNotificationGranted,
    @Default(false) bool isExactAlarmGranted,
    @Default(false) bool areAllPermissionsGranted,
  }) = _PermissionState;
}

class PermissionNotifier extends StateNotifier<PermissionState> {

  PermissionNotifier(this._permissionService) : super(const PermissionState()) {
    checkPermissions();
  }
  final PermissionService _permissionService;

  Future<void> checkPermissions() async {
    final isNotificationGranted =
        await _permissionService.checkNotificationPermission();
    final isExactAlarmGranted =
        await _permissionService.checkExactAlarmPermission();

    state = state.copyWith(
      isNotificationGranted: isNotificationGranted,
      isExactAlarmGranted: isExactAlarmGranted,
      areAllPermissionsGranted: isNotificationGranted && isExactAlarmGranted,
    );
  }

  Future<bool> requestPermissions() async {
    final notificationGranted =
        await _permissionService.requestNotificationPermission();
    final exactAlarmGranted =
        await _permissionService.requestExactAlarmPermission();
    await checkPermissions(); // 요청 후 상태 업데이트
    return notificationGranted && exactAlarmGranted;
  }
}

final permissionProvider =
    StateNotifierProvider<PermissionNotifier, PermissionState>((ref) {
  return PermissionNotifier(ref.read(permissionService));
});

final permissionService = Provider((ref) => PermissionService());
