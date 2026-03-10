package crypto

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"

	"github.com/tuneinsight/lattigo/v6/core/rlwe"
	"github.com/tuneinsight/lattigo/v6/schemes/bgv"
)

var secretKey = []byte("super_secret_encryption_key_1234")

// FHE context variables
var (
	fheParams    bgv.Parameters
	fheEncoder   *bgv.Encoder
	fheEncryptor *rlwe.Encryptor
	fheDecryptor *rlwe.Decryptor
)

// InitFHE initializes the BGV/BFV scheme for encrypting AES keys.
func InitFHE() {
	var err error
	// BGV parameters: 128-bit security
	fheParams, err = bgv.NewParametersFromLiteral(bgv.ExampleParameters128BitLogN14LogQP438)
	if err != nil {
		panic(fmt.Sprintf("Failed to generate BGV parameters: %v", err))
	}

	// Key generator
	kgen := bgv.NewKeyGenerator(fheParams)
	sk, pk := kgen.GenKeyPairNew()

	// Encoder, Encryptor, Decryptor
	fheEncoder = bgv.NewEncoder(fheParams)
	fheEncryptor = bgv.NewEncryptor(fheParams, pk)
	fheDecryptor = bgv.NewDecryptor(fheParams, sk)
}

// EncryptKeyFHE encrypts an AES key using the BGV scheme.
func EncryptKeyFHE(aesKey []byte) ([]byte, error) {
	if fheEncoder == nil {
		InitFHE()
	}

	// Convert bytes to uint64 array for BGV encoding.
	// AES-256 key is 32 bytes = 256 bits. We can fit each byte in a slot.
	values := make([]uint64, fheParams.MaxSlots())
	for i, b := range aesKey {
		values[i] = uint64(b)
	}

	// Encode
	plaintext := bgv.NewPlaintext(fheParams, fheParams.MaxLevel())
	if err := fheEncoder.Encode(values, plaintext); err != nil {
		return nil, fmt.Errorf("failed to encode AES key: %v", err)
	}

	// Encrypt
	ciphertext, err := fheEncryptor.EncryptNew(plaintext)
	if err != nil {
		return nil, fmt.Errorf("failed to encrypt AES key with FHE: %v", err)
	}

	// Serialize ciphertext to bytes
	var buf bytes.Buffer
	_, err = ciphertext.WriteTo(&buf)
	if err != nil {
		return nil, fmt.Errorf("failed to serialize FHE ciphertext: %v", err)
	}

	return buf.Bytes(), nil
}

// DecryptKeyFHE decrypts an AES key encrypted with the BGV scheme.
func DecryptKeyFHE(encryptedKeyBytes []byte) ([]byte, error) {
	if fheDecryptor == nil {
		return nil, fmt.Errorf("FHE not initialized")
	}

	// Deserialize ciphertext
	ciphertext := new(rlwe.Ciphertext)
	if _, err := ciphertext.ReadFrom(bytes.NewReader(encryptedKeyBytes)); err != nil {
		return nil, fmt.Errorf("failed to deserialize FHE ciphertext: %v", err)
	}

	// Decrypt
	plaintext := fheDecryptor.DecryptNew(ciphertext)

	// Decode
	values := make([]uint64, fheParams.MaxSlots())
	if err := fheEncoder.Decode(plaintext, values); err != nil {
		return nil, fmt.Errorf("failed to decode FHE plaintext: %v", err)
	}

	// Recover AES key bytes
	// We expect a 32-byte key (AES-256)
	aesKey := make([]byte, 32)
	for i := 0; i < 32; i++ {
		aesKey[i] = byte(values[i])
	}

	return aesKey, nil
}

// EncryptWithKey encrypts data using AES-256 GCM with a provided key.
func EncryptWithKey(plaintext []byte, key []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}

	nonce := make([]byte, gcm.NonceSize())
	if _, err = io.ReadFull(rand.Reader, nonce); err != nil {
		return nil, err
	}

	ciphertext := gcm.Seal(nonce, nonce, plaintext, nil)
	return ciphertext, nil
}

// DecryptWithKey decrypts AES-256 GCM data with a provided key.
func DecryptWithKey(ciphertext []byte, key []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}

	nonceSize := gcm.NonceSize()
	if len(ciphertext) < nonceSize {
		return nil, fmt.Errorf("ciphertext too short")
	}

	nonce, ciphertext := ciphertext[:nonceSize], ciphertext[nonceSize:]
	plaintext, err := gcm.Open(nil, nonce, ciphertext, nil)
	if err != nil {
		return nil, err
	}

	return plaintext, nil
}

// Legacy Encrypt using the fixed secret key
func Encrypt(plaintext []byte) (string, error) {
	ciphertext, err := EncryptWithKey(plaintext, secretKey)
	if err != nil {
		return "", err
	}
	return hex.EncodeToString(ciphertext), nil
}

// Legacy Decrypt using the fixed secret key
func Decrypt(encryptedHex string) ([]byte, error) {
	ciphertext, err := hex.DecodeString(encryptedHex)
	if err != nil {
		return nil, err
	}
	return DecryptWithKey(ciphertext, secretKey)
}

// HashData generates a SHA256 signature of data for blockchain anchoring
func HashData(data string) string {
	h := sha256.New()
	h.Write([]byte(data))
	return hex.EncodeToString(h.Sum(nil))
}
