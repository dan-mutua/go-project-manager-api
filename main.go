package main


func main() {
	cfg := PostgreSQLConfig{
		Host:     "localhost",
		Port:     5432,
		User:     "youruser",
		Password: "yourpassword",
		DBName:   "yourdbname",
		SSLMode:  "disable",
	}

	storage := NewPostgreSQLStorage(cfg)
	defer storage.db.Close()
}