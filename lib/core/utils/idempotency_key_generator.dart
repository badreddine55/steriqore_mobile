import 'package:uuid/uuid.dart';

class IdempotencyKeyGenerator {
  static const _uuid = Uuid();

  /// Generates a unique UUID v4 client-side per scan attempt
  static String generate() {
    return _uuid.v4();
  }
}
