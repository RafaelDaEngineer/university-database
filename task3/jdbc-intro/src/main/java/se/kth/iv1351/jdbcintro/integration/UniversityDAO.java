// SQL only allowed in here!! (but no logic?)

package se.kth.iv1351.jdbcintro.integration;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UniversityDAO {
    private Connection connection;

    public UniversityDAO(Connection connection) {
        this.connection = connection;
    }

    /**
     * TEST METHOD: Just to check if we can read from the DB.
     */
    public void testConnection() throws SQLException {
        String query = "SELECT count(*) FROM person"; // A simple query
        try (PreparedStatement stmt = connection.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                System.out.println("Connection Successful! Total people in DB: " + rs.getInt(1));
            }
        } catch (SQLException e) {
            System.err.println("Database error: " + e.getMessage());
            throw e; // Re-throw to let controller handle it
        }
    }
}