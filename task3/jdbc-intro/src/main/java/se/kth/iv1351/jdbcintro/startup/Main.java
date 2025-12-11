package se.kth.iv1351.jdbcintro.startup;

import se.kth.iv1351.jdbcintro.controller.Controller;
import se.kth.iv1351.jdbcintro.integration.DBHandler;
import se.kth.iv1351.jdbcintro.integration.UniversityDAO;
import se.kth.iv1351.jdbcintro.view.BlockingInterpreter;

/**
 * Startup layer - creates all components
 */
public class Main {
    public static void main(String[] args) {
        try {
            DBHandler dbHandler = new DBHandler();
            UniversityDAO universityDAO = new UniversityDAO(dbHandler.getConnection());

            Controller controller = new Controller(universityDAO);

            new BlockingInterpreter(controller).handleCmds();

        } catch (Exception e) {
            System.err.println("Failed to start application: " + e.getMessage());
            e.printStackTrace();
        }
    }
}