package main

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"

	"encription-backend/blockchain"
	"encription-backend/crypto"
	"encription-backend/database"

	"golang.org/x/crypto/bcrypt"
)

type AuthRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type AuthResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
}

type EncryptRequest struct {
	Data string `json:"data"`
}

type EncryptResponse struct {
	EncryptedData   string           `json:"encryptedData"`
	BlockchainEntry blockchain.Block `json:"blockchainEntry"`
	Message         string           `json:"message"`
}

func enableCors(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
	(*w).Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
	(*w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
}

func registerHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req AuthRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Bad request", http.StatusBadRequest)
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		http.Error(w, "Failed to hash password", http.StatusInternalServerError)
		return
	}

	user := database.User{
		Email:    req.Email,
		Password: string(hashedPassword),
	}

	// Create user in DB
	if err := database.DB.Create(&user).Error; err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusConflict) // Usually means email exists
		json.NewEncoder(w).Encode(AuthResponse{Success: false, Message: "Email already exists"})
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(AuthResponse{Success: true, Message: "User registered successfully"})
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req AuthRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Bad request", http.StatusBadRequest)
		return
	}

	var user database.User
	if err := database.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(AuthResponse{Success: false, Message: "Invalid email or password"})
		return
	}

	// Compare password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(AuthResponse{Success: false, Message: "Invalid email or password"})
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(AuthResponse{Success: true, Message: "Login successful"})
}

func encryptHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req EncryptRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Bad request", http.StatusBadRequest)
		return
	}

	if req.Data == "" {
		http.Error(w, "Data is empty", http.StatusBadRequest)
		return
	}

	// 1. Encrypt Data
	encryptedHex, err := crypto.Encrypt([]byte(req.Data))
	if err != nil {
		http.Error(w, "Encryption failed", http.StatusInternalServerError)
		return
	}

	// 2. Hash encrypted data for blockchain ledger anchoring
	dataHash := crypto.HashData(encryptedHex)

	// 3. Add to Blockchain
	block := blockchain.AppChain.AddBlock(dataHash)

	// 4. Return response to Flutter App
	resp := EncryptResponse{
		EncryptedData:   encryptedHex,
		BlockchainEntry: block,
		Message:         "Data successfully encrypted and secured on the blockchain ledger.",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func encryptFileHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Max 100 MB upload limit
	err := r.ParseMultipartForm(100 << 20)
	if err != nil {
		http.Error(w, "File upload too large", http.StatusBadRequest)
		return
	}

	file, handler, err := r.FormFile("file")
	if err != nil {
		http.Error(w, "Error retrieving file", http.StatusBadRequest)
		return
	}
	defer file.Close()

	fileBytes, err := io.ReadAll(file)
	if err != nil {
		http.Error(w, "Error reading file", http.StatusInternalServerError)
		return
	}

	// 1. Generate AES key
	aesKey := make([]byte, 32)
	if _, err := rand.Read(aesKey); err != nil {
		http.Error(w, "Failed to generate keys", http.StatusInternalServerError)
		return
	}

	// 2. Encrypt AES Key with FHE
	fheEncryptedKey, err := crypto.EncryptKeyFHE(aesKey)
	if err != nil {
		http.Error(w, "FHE encryption failed", http.StatusInternalServerError)
		return
	}

	// 3. Encrypt file with AES
	encryptedData, err := crypto.EncryptWithKey(fileBytes, aesKey)
	if err != nil {
		http.Error(w, "File encryption failed", http.StatusInternalServerError)
		return
	}

	// 4. Save encrypted data to disk
	uploadsDir := "uploads"
	os.MkdirAll(uploadsDir, os.ModePerm)

	// Create safe filename
	fileIdHex := hex.EncodeToString(aesKey[:8]) // Just to get a uniqueish ID
	encryptedPath := filepath.Join(uploadsDir, fileIdHex+"_"+handler.Filename+".enc")

	if err := os.WriteFile(encryptedPath, encryptedData, 0644); err != nil {
		http.Error(w, "Failed to save encrypted file", http.StatusInternalServerError)
		return
	}

	// 5. Hash for blockchain
	dataHash := crypto.HashData(hex.EncodeToString(encryptedData[:100])) // Just hash first 100 bytes for speed simulation

	// 6. DB Record
	fileRecord := database.FileRecord{
		Filename:          handler.Filename,
		MimeType:          handler.Header.Get("Content-Type"),
		Size:              handler.Size,
		EncryptedFilePath: encryptedPath,
		FHEEncryptedKey:   fheEncryptedKey,
		DataHash:          dataHash,
	}
	database.DB.Create(&fileRecord)

	// 7. Add to Blockchain
	block := blockchain.AppChain.AddBlock(dataHash)

	resp := EncryptResponse{
		EncryptedData:   "File encrypted and saved to disk",
		BlockchainEntry: block,
		Message:         "File successfully secured with FHE and Blockchain.",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func getFilesHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	var files []database.FileRecord
	database.DB.Find(&files)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(files)
}

func decryptFileHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	idStr := r.URL.Query().Get("id")
	if idStr == "" {
		http.Error(w, "Missing file ID", http.StatusBadRequest)
		return
	}

	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		http.Error(w, "Invalid file ID", http.StatusBadRequest)
		return
	}

	var fileRecord database.FileRecord
	if err := database.DB.First(&fileRecord, id).Error; err != nil {
		http.Error(w, "File not found", http.StatusNotFound)
		return
	}

	// 1. Read encrypted file
	encryptedData, err := os.ReadFile(fileRecord.EncryptedFilePath)
	if err != nil {
		http.Error(w, "Failed to read encrypted file", http.StatusInternalServerError)
		return
	}

	// 2. Decrypt AES key with FHE
	aesKey, err := crypto.DecryptKeyFHE(fileRecord.FHEEncryptedKey)
	if err != nil {
		http.Error(w, "FHE decryption failed", http.StatusInternalServerError)
		return
	}

	// 3. Decrypt file data
	decryptedData, err := crypto.DecryptWithKey(encryptedData, aesKey)
	if err != nil {
		http.Error(w, "File decryption failed", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Disposition", "attachment; filename="+fileRecord.Filename)
	w.Header().Set("Content-Type", fileRecord.MimeType)
	w.Header().Set("Content-Length", strconv.Itoa(len(decryptedData)))
	w.Write(decryptedData)
}

func getChainHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(blockchain.AppChain.Chain)
}

func main() {
	// 1. Initialize DB and Blockchain
	database.InitDatabase()
	blockchain.AppChain.InitChain()

	// 2. Start HTTP Server
	http.HandleFunc("/register", registerHandler)
	http.HandleFunc("/login", loginHandler)
	http.HandleFunc("/encrypt", encryptHandler)
	http.HandleFunc("/encrypt/file", encryptFileHandler) // New endpoint
	http.HandleFunc("/files", getFilesHandler)           // New endpoint
	http.HandleFunc("/decrypt/file", decryptFileHandler) // New endpoint
	http.HandleFunc("/chain", getChainHandler)

	port := "8080"
	log.Printf("Starting secure Go Blockchain Backend on port %s...", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
