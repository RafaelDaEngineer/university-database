package se.kth.iv1351.jdbcintro.integration;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBHandler {
    // replace the empty string with pw if set
    // Change to match own DB setup if needed
    // Current setup for our dockerized Postgres:
    private static final String DB_HOST = "localhost";  // or "127.0.0.1"
    private static final String DB_PORT = "5433";       // or "5433" if mapped differently
    private static final String DB_NAME = "university_db";
    private static final String DB_USER = "postgres";
    private static final String DB_PASS = "postgres";   // Your container password

    private static final String DB_URL =
            "jdbc:postgresql://" + DB_HOST + ":" + DB_PORT + "/" + DB_NAME;

    private Connection connection;

    public DBHandler() throws ClassNotFoundException, SQLException {
        // force loading of the driver (ensure compatibility with older environments and stuff)
        Class.forName("org.postgresql.Driver");
        connect();
    }

    private void connect() throws SQLException {
        connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        connection.setAutoCommit(false); 
    }

    public Connection getConnection() {
        return connection;
    }
}