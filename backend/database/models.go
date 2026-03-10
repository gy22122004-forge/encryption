package database

import (
	"gorm.io/gorm"
)

// User represents an authenticated user in the system
type User struct {
	gorm.Model
	Email    string `gorm:"uniqueIndex;not null"`
	Password string `gorm:"not null"` // This should be securely hashed in production
}

// FileRecord stores the metadata and the FHE-encrypted AES key for uploaded files
type FileRecord struct {
	gorm.Model
	Filename          string
	MimeType          string
	Size              int64
	EncryptedFilePath string
	FHEEncryptedKey   []byte // The FHE-encrypted AES key
	DataHash          string // The SHA256 hash of the AES-encrypted data, for blockchain
}
