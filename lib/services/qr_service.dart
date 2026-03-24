import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/pickup.dart';

class QRService {
  /// Generates a SHA-256 hash as per FR-R-013: 
  /// encoding pickup_id + resident_id + ward_id + timestamp
  static String generatePickupHash(Pickup pickup) {
    // We use createdAt as the timestamp for consistency, 
    // or we could use the scheduled date.
    final timestamp = pickup.createdAt.millisecondsSinceEpoch.toString();
    final data = '${pickup.id}:${pickup.userId}:${pickup.wardNumber}:$timestamp';
    
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    
    return digest.toString();
  }

  /// Validates a scanned hash against a pickup
  static bool validateHash(String scannedHash, Pickup pickup) {
    final expectedHash = generatePickupHash(pickup);
    return scannedHash == expectedHash;
  }
}
