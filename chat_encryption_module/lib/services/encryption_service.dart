import 'package:crypton/crypton.dart';

/// Core service for RSA encryption and decryption operations.
///
/// Uses the Crypton package to handle RSA 2048-bit encryption.
/// Messages are encrypted in chunks of 245 bytes due to RSA limitations.
class EncryptionService {
  /// Default chunk size for encryption (plaintext)
  static const int encryptionChunkSize = 245;

  /// Default chunk size for decryption (ciphertext)
  static const int decryptionChunkSize = 344;

  /// Generate a new RSA key pair.
  ///
  /// Returns an [RSAKeypair] with public and private keys.
  RSAKeypair generateKeyPair() {
    return RSAKeypair.fromRandom();
  }

  /// Encrypt content using a public key.
  ///
  /// Splits content into chunks to handle RSA message size limitations.
  ///
  /// Parameters:
  ///   - [content]: The plaintext to encrypt
  ///   - [publicKey]: The RSA public key to use
  ///
  /// Returns: The encrypted content as a string
  String encrypt({
    required String content,
    required RSAPublicKey publicKey,
  }) {
    final List<String> encryptedChunks = [];

    // Split content into chunks
    for (int i = 0; i < content.length; i += encryptionChunkSize) {
      final end = (i + encryptionChunkSize < content.length)
          ? i + encryptionChunkSize
          : content.length;

      final chunk = content.substring(i, end);
      final encryptedChunk = publicKey.encrypt(chunk);
      encryptedChunks.add(encryptedChunk);
    }

    // Join chunks with delimiter
    return encryptedChunks.join('|');
  }

  /// Decrypt content using a private key.
  ///
  /// Handles decryption of chunked encrypted content.
  ///
  /// Parameters:
  ///   - [content]: The encrypted content (chunks joined with |)
  ///   - [privateKey]: The RSA private key to use
  ///
  /// Returns: The decrypted plaintext
  String decrypt({
    required String content,
    required RSAPrivateKey privateKey,
  }) {
    final List<String> decryptedChunks = [];

    // Split by chunk delimiter
    final chunks = content.split('|');

    for (final chunk in chunks) {
      if (chunk.isNotEmpty) {
        final decryptedChunk = privateKey.decrypt(chunk);
        decryptedChunks.add(decryptedChunk);
      }
    }

    // Join all chunks
    return decryptedChunks.join('');
  }

  /// Convert a string representation of a public key back to [RSAPublicKey].
  ///
  /// Parameters:
  ///   - [keyString]: The public key as a string
  ///
  /// Returns: The [RSAPublicKey] object
  RSAPublicKey stringToPublicKey(String keyString) {
    return RSAPublicKey.fromString(keyString);
  }

  /// Convert a string representation of a private key back to [RSAPrivateKey].
  ///
  /// Parameters:
  ///   - [keyString]: The private key as a string
  ///
  /// Returns: The [RSAPrivateKey] object
  RSAPrivateKey stringToPrivateKey(String keyString) {
    return RSAPrivateKey.fromString(keyString);
  }

  /// Encrypt using a string representation of a public key.
  ///
  /// Helper method that combines key conversion and encryption.
  ///
  /// Parameters:
  ///   - [content]: The plaintext to encrypt
  ///   - [publicKeyString]: The public key as a string
  ///
  /// Returns: The encrypted content
  String encryptWithStringKey({
    required String content,
    required String publicKeyString,
  }) {
    final publicKey = stringToPublicKey(publicKeyString);
    return encrypt(content: content, publicKey: publicKey);
  }

  /// Decrypt using a string representation of a private key.
  ///
  /// Helper method that combines key conversion and decryption.
  ///
  /// Parameters:
  ///   - [content]: The encrypted content
  ///   - [privateKeyString]: The private key as a string
  ///
  /// Returns: The decrypted plaintext
  String decryptWithStringKey({
    required String content,
    required String privateKeyString,
  }) {
    final privateKey = stringToPrivateKey(privateKeyString);
    return decrypt(content: content, privateKey: privateKey);
  }

  /// Validate if a string is a valid public key.
  ///
  /// Parameters:
  ///   - [keyString]: The key string to validate
  ///
  /// Returns: true if valid, false otherwise
  bool isValidPublicKey(String keyString) {
    try {
      stringToPublicKey(keyString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validate if a string is a valid private key.
  ///
  /// Parameters:
  ///   - [keyString]: The key string to validate
  ///
  /// Returns: true if valid, false otherwise
  bool isValidPrivateKey(String keyString) {
    try {
      stringToPrivateKey(keyString);
      return true;
    } catch (e) {
      return false;
    }
  }
}
