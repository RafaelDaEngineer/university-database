package se.kth.iv1351.jdbcintro.main;

import se.kth.iv1351.jdbcintro.integration.DBHandler;
import se.kth.iv1351.jdbcintro.integration.UniversityDAO;
import java.sql.SQLException;

public class Main {
    public static void main(String[] args) {
        try {
            // 1. Initialize Connection
            DBHandler dbHandler = new DBHandler();
            
            // 2. Create DAO
            UniversityDAO dao = new UniversityDAO(dbHandler.getConnection());
            
            // 3. Test Connection
            System.out.println("Attempting to connect to university_db...");
            dao.testConnection();

        } catch (ClassNotFoundException | SQLException e) {
            System.out.println("Startup failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}