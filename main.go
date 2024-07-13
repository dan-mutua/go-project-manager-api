package main
func main() {
	store := NewStore(db)
	api := NewAPIServer(":3000", nil)
}