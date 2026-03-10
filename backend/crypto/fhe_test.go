package crypto

import (
	"crypto/rand"
	"testing"
)

func TestHybridEncryption(t *testing.T) {
	InitFHE() // Initialize Lattigo FHE

	plaintext := []byte("This is a highly secret message that needs hybrid FHE encryption!")

	// 1. Generate AES key
	aesKey := make([]byte, 32)
	rand.Read(aesKey)

	// 2. Encrypt AES Key with FHE
	fheEncryptedKey, err := EncryptKeyFHE(aesKey)
	if err != nil {
		t.Fatalf("Failed to encrypt key with FHE: %v", err)
	}

	// 3. Encrypt data with AES
	encryptedData, err := EncryptWithKey(plaintext, aesKey)
	if err != nil {
		t.Fatalf("Failed to encrypt data with AES: %v", err)
	}

	// 4. Decrypt AES Key with FHE
	decryptedAesKey, err := DecryptKeyFHE(fheEncryptedKey)
	if err != nil {
		t.Fatalf("Failed to decrypt key with FHE: %v", err)
	}

	// 5. Decrypt data with AES
	decryptedData, err := DecryptWithKey(encryptedData, decryptedAesKey)
	if err != nil {
		t.Fatalf("Failed to decrypt data with AES: %v", err)
	}

	if string(decryptedData) != string(plaintext) {
		t.Fatalf("Decrypted data does not match original. Got %s, want %s", string(decryptedData), string(plaintext))
	}

	t.Log("Hybrid FHE + AES encryption and decryption successful!")
}
