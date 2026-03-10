package database

import (
	"log"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var DB *gorm.DB

// InitDatabase initializes the local SQLite database
func InitDatabase() {
	var err error

	// Create or open the encryption.db sqlite file
	DB, err = gorm.Open(sqlite.Open("encryption.db"), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to SQLite database:", err)
	}

	// Auto-migrate our schemas
	DB.AutoMigrate(&User{})
	DB.AutoMigrate(&FileRecord{})

	log.Println("Database connection successfully established.")
}
