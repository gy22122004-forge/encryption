import 'dart:convert';
import 'package:http/http.dart' as http;

class BlockchainEntry {
  final int index;
  final String timestamp;
  final String dataHash;
  final String previousHash;
  final String hash;

  BlockchainEntry({
    required this.index,
    required this.timestamp,
    required this.dataHash,
    required this.previousHash,
    required this.hash,
  });

  factory BlockchainEntry.fromJson(Map<String, dynamic> json) {
    return BlockchainEntry(
      index: json['Index'],
      timestamp: json['Timestamp'],
      dataHash: json['DataHash'],
      previousHash: json['PreviousHash'],
      hash: json['Hash'],
    );
  }
}

class EncryptResponse {
  final String encryptedData;
  final BlockchainEntry blockchainEntry;
  final String message;

  EncryptResponse({
    required this.encryptedData,
    required this.blockchainEntry,
    required this.message,
  });

  factory EncryptResponse.fromJson(Map<String, dynamic> json) {
    return EncryptResponse(
      encryptedData: json['encryptedData'],
      blockchainEntry: BlockchainEntry.fromJson(json['blockchainEntry']),
      message: json['message'],
    );
  }
}

class AuthResponse {
  final bool success;
  final String message;

  AuthResponse({required this.success, required this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(success: json['success'], message: json['message']);
  }
}

class BlockchainEncryptionService {
  // Use localhost for local Go backend. If Android emulator use 10.0.2.2
  static const String baseUrl = 'http://localhost:8080';

  Future<EncryptResponse> encryptData(String data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/encrypt'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': data}),
      );

      if (response.statusCode == 200) {
        return EncryptResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to encrypt data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Encryption error: $e');
    }
  }

  Future<EncryptResponse> encryptFile(
    List<int> fileBytes,
    String filename,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/encrypt/file'),
      );
      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: filename),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return EncryptResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to encrypt file: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('File encryption error: $e');
    }
  }

  Future<List<int>> decryptFile(int fileId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/decrypt/file?id=$fileId'),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to decrypt file: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('File decryption error: $e');
    }
  }

  Future<List<dynamic>> getFiles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/files'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get files: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get files error: $e');
    }
  }

  Future<List<BlockchainEntry>> getChain() async {
    try {
      // Simulated blockchain data
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        BlockchainEntry(
          index: 0,
          timestamp: DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          dataHash: 'genesis_data',
          previousHash: '0',
          hash: 'genesis_hash',
        ),
      ];
    } catch (e) {
      throw Exception('Simulated getChain error: $e');
    }
  }

  Future<AuthResponse> register(String email, String password) async {
    try {
      // Simulated for testing since Go backend is not running
      await Future.delayed(const Duration(seconds: 1));
      return AuthResponse(
        success: true,
        message: 'Simulated registration successful',
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      // Simulated for testing since Go backend is not running
      await Future.delayed(const Duration(seconds: 1));

      if (email.isNotEmpty && password.isNotEmpty) {
        return AuthResponse(
          success: true,
          message: 'Simulated login successful',
        );
      } else {
        return AuthResponse(success: false, message: 'Invalid credentials');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
