import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FigmaIntegration {
  static const String _baseUrl = 'https://api.figma.com/v1';
  final String _accessToken;
  final String _fileId;

  FigmaIntegration({
    required String accessToken,
    required String fileId,
  })  : _accessToken = accessToken,
        _fileId = fileId;

  /// Figma 파일 정보 가져오기
  Future<Map<String, dynamic>> getFileInfo() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/files/$_fileId'),
      headers: {
        'X-Figma-Token': _accessToken,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load file: ${response.statusCode}');
    }
  }

  /// 특정 노드 정보 가져오기
  Future<Map<String, dynamic>> getNodeInfo(String nodeId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/files/$_fileId/nodes?ids=$nodeId'),
      headers: {
        'X-Figma-Token': _accessToken,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load node: ${response.statusCode}');
    }
  }

  /// 이미지로 내보내기
  Future<String> exportImage(String nodeId, {String format = 'PNG'}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/images/$_fileId?ids=$nodeId&format=$format'),
      headers: {
        'X-Figma-Token': _accessToken,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['images'][nodeId];
    } else {
      throw Exception('Failed to export image: ${response.statusCode}');
    }
  }
}

/// 사용 예시
void main() async {
  // TODO: 실제 토큰과 파일 ID로 교체
  const accessToken = 'YOUR_FIGMA_ACCESS_TOKEN';
  const fileId = 'YOUR_FIGMA_FILE_ID';

  final figma = FigmaIntegration(
    accessToken: accessToken,
    fileId: fileId,
  );

  try {
    // 파일 정보 가져오기
    final fileInfo = await figma.getFileInfo();
    print('File name: ${fileInfo['name']}');

    // 특정 노드 정보 가져오기 (예: 메인 화면)
    final nodeInfo = await figma.getNodeInfo('NODE_ID_HERE');
    print('Node info: $nodeInfo');

    // 이미지 내보내기
    final imageUrl = await figma.exportImage('NODE_ID_HERE');
    print('Image URL: $imageUrl');
  } catch (e) {
    print('Error: $e');
  }
}
