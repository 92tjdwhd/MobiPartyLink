import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobi_party_link/core/services/permission_service.dart';

part 'permission_provider.freezed.dart';

@freezed
class PermissionState with _$PermissionState {
  const factory PermissionState({
    @Default(false) bool isNotificationGranted,
    @Default(false) bool areAllPermissionsGranted,
  }) = _PermissionState;
}

class PermissionNotifier extends StateNotifier<PermissionState> {
  final PermissionService _permissionService;

  PermissionNotifier(this._permissionService) : super(const PermissionState()) {
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    final isNotificationGranted =
        await _permissionService.checkNotificationPermission();
    state = state.copyWith(
      isNotificationGranted: isNotificationGranted,
      areAllPermissionsGranted: isNotificationGranted, // 현재는 알림만 체크
    );
  }

  Future<bool> requestPermissions() async {
    final granted = await _permissionService.requestNotificationPermission();
    await checkPermissions(); // 요청 후 상태 업데이트
    return granted;
  }
}

final permissionProvider =
    StateNotifierProvider<PermissionNotifier, PermissionState>((ref) {
  return PermissionNotifier(ref.read(permissionService));
});

final permissionService = Provider((ref) => PermissionService());
