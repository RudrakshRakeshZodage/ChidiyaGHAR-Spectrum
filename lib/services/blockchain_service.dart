import 'dart:convert';
import 'package:crypto/crypto.dart';

class BlockchainService {
  /// Simple utility to "verify" health records using SHA-256 hashing.
  /// In a real app, this hash would be sent to a smart contract on a blockchain like Polygon or Ethereum.
  static String generateRecordHash(Map<String, dynamic> record) {
    final String jsonString = jsonEncode(record);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyDataIntegrity(Map<String, dynamic> record, String storedHash) {
    final newHash = generateRecordHash(record);
    return newHash == storedHash;
  }
}
