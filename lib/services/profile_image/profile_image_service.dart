import 'package:financy_control/core/data/data_result.dart';
import 'package:image_picker/image_picker.dart';

/// Service responsible for persisting and retrieving the user's profile image.
/// For this implementation we store a Base64 (compressed) string inside the
/// Firestore user document under the `avatarBase64` field.
abstract class ProfileImageService {
  /// Compresses (if needed) and saves the picked image (XFile) as a Base64
  /// string in the current user's Firestore document. Returns the stored
  /// Base64 string on success.
  Future<DataResult<String>> saveAvatar(XFile file);

  /// Loads the stored Base64 avatar for the current user. Returns failure if
  /// no user is logged in or if the field does not exist.
  Future<DataResult<String>> loadAvatar();
}
