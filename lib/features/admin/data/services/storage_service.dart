import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for uploading images to Supabase Storage buckets.
///
/// Supported buckets:
/// - 'tournament-logos'
/// - 'team-logos'
/// - 'player-photos'
class StorageService {
  final SupabaseStorageClient _storage;

  StorageService(this._storage);

  /// Upload an image to the specified [bucket] at the given [path].
  ///
  /// Returns the public URL of the uploaded image, or null if the upload fails.
  Future<String?> uploadImage(
    String bucket,
    String path,
    Uint8List bytes,
  ) async {
    try {
      await _storage.from(bucket).uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'image/png',
        ),
      );
      final publicUrl = _storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      return null;
    }
  }
}

/// Provider for the StorageService.
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(Supabase.instance.client.storage);
});
