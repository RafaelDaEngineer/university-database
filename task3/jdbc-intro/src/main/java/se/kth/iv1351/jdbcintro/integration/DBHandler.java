package se.kth.iv1351.jdbcintro.integration;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBHandler {
    // Based on your screenshot, your DB is 'university_db' and user is 'aryan'
    // Local postgres usually has no password, or it matches the username. 
    // If you have a password, replace the empty string "" with it.
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/university_db";
    private static final String DB_USER = "aryan";
    private static final String DB_PASS = ""; 

    private Connection connection;

    public DBHandler() throws ClassNotFoundException, SQLException {
        // Force loading of the driver (standard practice for this course)
        Class.forName("org.postgresql.Driver");
        connect();
    }

    private void connect() throws SQLException {
        connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        // CRITICAL FOR TASK 3: Turn off autocommit to handle transactions manually
        connection.setAutoCommit(false); 
    }

    public Connection getConnection() {
        return connection;
    }
}