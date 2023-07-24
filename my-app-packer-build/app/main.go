package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	_ "github.com/lib/pq"
)

func main() {
	var host = os.Getenv("DB_HOST")
	var port = 5432
	var user = os.Getenv("DB_USER")
	var password = os.Getenv("DB_PASSWORD")
	var dbname = "myappdb"

	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbname)
	db, err := sql.Open("postgres", psqlInfo)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		panic(err)
	}
	log.Print("Successfully connected to database server!")

	_, err = db.Exec("DROP TABLE IF EXISTS example;")

	if err != nil {
		log.Fatal(err)
	}
	log.Print("Created table!")

	_, err = db.Exec("CREATE TABLE example (messageno int, username varchar(255), message varchar(255) )")

	if err != nil {
		log.Fatal(err)
	}
	log.Print("Created table!")

	_, err = db.Exec("INSERT INTO example (messageno, username, message) VALUES (1, 'Steven', 'Hello Solution Series Attendees');" +
		"INSERT INTO example (messageno, username, message) VALUES (2, 'Steven', 'This message is being read from the database');")

	if err != nil {
		log.Fatal(err)
	}
	log.Print("Created DB Records!")

	log.Print("Starting up web app!")

	http.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
		fmt.Fprintf(w, "Connecting to database at "+host+"\n\nReading Messages from the database:\n\n%s\n\n%s", getMessage(1, db), getMessage(2, db))
	})

	// One can use generate_cert.go in crypto/tls to generate cert.pem and key.pem.
	log.Printf("About to listen on 8443.")
	err = http.ListenAndServeTLS(":8443", "/opt/webapp/cert.pem", "/opt/webapp/key.pem", nil)
	log.Fatal(err)
}

func getMessage(index int, db *sql.DB) string {
	sqlStatement := "SELECT username, message FROM example WHERE messageno = $1"
	var username string
	var message string
	row := db.QueryRow(sqlStatement, index)

	switch err := row.Scan(&username, &message); err {
	case sql.ErrNoRows:
		return "No rows were returned!"
	case nil:
		return username + " says: \n\t" + message
	default:
		return "Error!"
	}
}
