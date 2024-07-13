package main

import "database/sql"


type store interface {
	//user
	createUser() error
}


type Storage 	struct {
	db *sql.DB
}

func NewStore(db*sql.DB) *Storage {
	return &Storage{db: db}
}


func (s *Storage) createUser() error {

	return nil
}