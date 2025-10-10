import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobi_party_link/core/services/job_icon_service.dart';

/// 직업 아이콘을 표시하는 위젯
///
/// 로컬 캐시된 PNG 파일을 표시, 없으면 fallback 아이콘 표시
class JobIconWidget extends StatelessWidget {
  const JobIconWidget({
    super.key,
    required this.jobId,
    this.size = 32.0,
    this.backgroundColor,
    this.fallbackIcon = Icons.person_rounded,
    this.fallbackIconColor = Colors.white,
  });

  final String? jobId;
  final double size;
  final Color? backgroundColor;
  final IconData fallbackIcon;
  final Color fallbackIconColor;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF76769A)
            : Theme.of(context).primaryColor);

    // jobId가 없으면 fallback 아이콘 표시
    if (jobId == null || jobId!.isEmpty) {
      return _buildFallbackIcon(bgColor);
    }

    return FutureBuilder<String?>(
      future: JobIconService.getLocalIconPath(jobId!),
      builder: (context, snapshot) {
        // 로컬 파일 경로가 있으면 로컬 PNG 사용
        if (snapshot.hasData && snapshot.data != null) {
          final localPath = snapshot.data!;

          return ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: Image.file(
              File(localPath),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('❌ PNG 로드 실패: jobId=$jobId, error=$error');
                return _buildFallbackIcon(bgColor);
              },
            ),
          );
        }

        // 로딩 중이거나 파일이 없으면 fallback 아이콘
        return _buildFallbackIcon(bgColor);
      },
    );
  }

  Widget _buildFallbackIcon(Color bgColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        fallbackIcon,
        color: fallbackIconColor,
        size: size * 0.55,
      ),
    );
  }
}
