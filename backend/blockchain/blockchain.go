package blockchain

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"time"

	"encription-backend/database"
	"gorm.io/gorm"
)

// Block represents a single block in the blockchain
type Block struct {
	gorm.Model
	Index        int
	Timestamp    string
	DataHash     string // Hash of the encrypted data
	PreviousHash string
	Hash         string
}

// Blockchain represents the chain of blocks
type Blockchain struct {
	Chain []Block
}

// Global variable representing our naive in-memory blockchain
var AppChain *Blockchain

func init() {
	AppChain = &Blockchain{}
	// Note: We don't automatically create the Genesis block here anymore.
	// We wait for the main application to initialize the DB and call InitChain().
}

// InitChain loads existing blocks from the DB or creates a Genesis block
func (bc *Blockchain) InitChain() {
	// Auto migrate the schema
	database.DB.AutoMigrate(&Block{})

	// Load existing blocks from database into memory
	var blocks []Block
	database.DB.Order("id asc").Find(&blocks)

	if len(blocks) == 0 {
		fmt.Println("[BLOCKCHAIN] No blocks found in DB. Creating Genesis Block...")
		bc.CreateGenesisBlock()
	} else {
		fmt.Printf("[BLOCKCHAIN] Loaded %d existing blocks from database.\n", len(blocks))
		bc.Chain = blocks
	}
}

// calculateHash generates a SHA256 hash for a block
func calculateHash(b Block) string {
	record := string(rune(b.Index)) + b.Timestamp + b.DataHash + b.PreviousHash
	h := sha256.New()
	h.Write([]byte(record))
	hashed := h.Sum(nil)
	return hex.EncodeToString(hashed)
}

// CreateGenesisBlock initializes the chain with the first block
func (bc *Blockchain) CreateGenesisBlock() {
	genesisBlock := Block{
		Index:        0,
		Timestamp:    time.Now().String(),
		DataHash:     "GenesisBlock",
		PreviousHash: "",
	}
	genesisBlock.Hash = calculateHash(genesisBlock)
	bc.Chain = append(bc.Chain, genesisBlock)

	// Save Genesis block to database
	database.DB.Create(&genesisBlock)
}

// AddBlock adds a new block to the chain securely logging an encryption event
func (bc *Blockchain) AddBlock(encryptedDataHash string) Block {
	prevBlock := bc.Chain[len(bc.Chain)-1]
	newBlock := Block{
		Index:        prevBlock.Index + 1,
		Timestamp:    time.Now().String(),
		DataHash:     encryptedDataHash,
		PreviousHash: prevBlock.Hash,
	}
	newBlock.Hash = calculateHash(newBlock)
	bc.Chain = append(bc.Chain, newBlock)
	
	// Save block to database
	database.DB.Create(&newBlock)

	fmt.Printf("[BLOCKCHAIN] Added new block to DB! Index: %d, Hash: %s\n", newBlock.Index, newBlock.Hash)
	return newBlock
}
