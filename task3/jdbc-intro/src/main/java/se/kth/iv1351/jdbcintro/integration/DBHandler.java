package se.kth.iv1351.jdbcintro.integration;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBHandler {
    // replace the empty string with pw if set
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/university_db";
    private static final String DB_USER = "aryan";
    private static final String DB_PASS = ""; 

    private Connection connection;

    public DBHandler() throws ClassNotFoundException, SQLException {
        // force loading of the driver (ensure compatibility with older environments and stuff)
        Class.forName("org.postgresql.Driver");
        connect();
    }

    private void connect() throws SQLException {
        connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        // FOR TASK 3: Turn off autocommit to handle transactions manually
        connection.setAutoCommit(false); 
    }

    public Connection getConnection() {
        return connection;
    }
}