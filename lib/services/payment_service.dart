import 'package:supabase_flutter/supabase_flutter.dart';
import 'blockchain_service.dart';

class PaymentService {
  final _supabase = Supabase.instance.client;

  /// Processes a specialist fee and logs it to Supabase and Blockchain
  Future<Map<String, dynamic>?> processSpecialistPayment({
    required String userId,
    required String specialistId,
    required double amount,
    required String serviceType,
  }) async {
    try {
      final paymentData = {
        'user_id': userId,
        'specialist_id': specialistId,
        'amount': amount,
        'service_type': serviceType,
        'status': 'success',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // 1. Log to Supabase Database
      await _supabase.from('payments').insert(paymentData);

      // 2. Hash and Anchor to Blockchain (Polygon)
      final recordHash = BlockchainService.generateRecordHash(paymentData);
      final txHash = await BlockchainService.anchorToBlockchain(recordHash);

      return {
        'status': 'success',
        'record_hash': recordHash,
        'blockchain_tx': txHash,
      };
    } catch (e) {
      print('Payment Error: $e');
      return null;
    }
  }
}
