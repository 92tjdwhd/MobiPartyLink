import 'package:flutter/material.dart';
import 'package:mobi_party_link/core/theme/app_theme.dart';
import 'package:mobi_party_link/core/utils/party_utils.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';

class PartyCard extends StatelessWidget {
  final PartyEntity party;
  final bool showShareButton;
  final VoidCallback? onTap;
  final VoidCallback? onShare;

  const PartyCard({
    super.key,
    required this.party,
    this.showShareButton = false,
    this.onTap,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                _buildStatusChips(),
                const SizedBox(height: 12),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            party.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (showShareButton)
          IconButton(
            onPressed: onShare,
            icon: const Icon(
              Icons.share,
              color: AppTheme.primaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildStatusChip(
          PartyUtils.getStatusText(party.status),
          _getStatusColor(party.status),
        ),
        _buildInfoChip(
          PartyUtils.getDifficultyText(party.difficulty),
          Colors.blue,
        ),
        _buildInfoChip(
          '${party.maxMembers}인',
          Colors.green,
        ),
        if (party.requireJobCategory) ...[
          _buildInfoChip(
            '직업제한',
            Colors.purple,
          ),
        ],
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        const Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          _formatDateTime(party.startTime),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        Text(
          '${party.members.length}/${party.maxMembers}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.people,
          size: 16,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor(PartyStatus status) {
    switch (status) {
      case PartyStatus.pending:
        return Colors.orange;
      case PartyStatus.ongoing:
        return Colors.green;
      case PartyStatus.ended:
        return Colors.grey;
      case PartyStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
