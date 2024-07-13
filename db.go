package main

import (
	"database/sql"
	"fmt"
	"log"
)

type PostgreSQLConfig struct {
	Host     string
	Port     int
	User     string
	Password string
	DBName   string
	SSLMode  string
}

func (cfg PostgreSQLConfig) FormatDSN() string {
	return fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=%s",
		cfg.Host, cfg.Port, cfg.User, cfg.Password, cfg.DBName, cfg.SSLMode)
}

type PostgreSQLStorage struct {
	db *sql.DB
}

func NewPostgreSQLStorage(cfg PostgreSQLConfig) *PostgreSQLStorage {
	dsn := cfg.FormatDSN()
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		log.Fatal(err)
	}

	err = db.Ping()
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Connected to PostgreSQL!")

	return &PostgreSQLStorage{db: db}
}

