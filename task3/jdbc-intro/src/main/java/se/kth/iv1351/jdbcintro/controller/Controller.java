package se.kth.iv1351.jdbcintro.controller;

import se.kth.iv1351.jdbcintro.integration.DBHandler;
import se.kth.iv1351.jdbcintro.integration.UniversityDAO;
import se.kth.iv1351.jdbcintro.model.CourseCostDTO;
import java.sql.SQLException;

public class Controller {
    private final DBHandler dbHandler;
    private final UniversityDAO universityDAO;

    public Controller() throws SQLException, ClassNotFoundException {
        // controller constructor creates db handler and connection to db
        this.dbHandler = new DBHandler();
        this.universityDAO = new UniversityDAO(dbHandler.getConnection());
    }

    /**
     * Requirement 1: Compute teaching cost.
     * @param courseCode The course code to look up.
     * @return The CourseCostDTO object or null if not found.
     */
    public CourseCostDTO getCourseCost(String courseCode) {
        try {
            // No transaction commit needed for a simple read, 
            // but we must handle errors gracefully.
            return universityDAO.findCourseCosts(courseCode);
        } catch (SQLException e) {
            System.err.println("Could not retrieve course cost: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
}