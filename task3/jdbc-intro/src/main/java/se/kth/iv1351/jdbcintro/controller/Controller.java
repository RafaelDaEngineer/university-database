package se.kth.iv1351.jdbcintro.controller;

import se.kth.iv1351.jdbcintro.integration.DBHandler;
import se.kth.iv1351.jdbcintro.integration.UniversityDAO;
import se.kth.iv1351.jdbcintro.model.CourseCostDTO;
import java.sql.SQLException;
import java.util.List;
import se.kth.iv1351.jdbcintro.model.ActivityDTO;

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
     * Use Business Logic here to combine raw data.
     * 
     * @param courseCode The course code to look up.
     * @return The CourseCostDTO object or null if not found.
     * @throws SQLException If database value retrieval fails. View should handle
     *                      this.
     */
    public CourseCostDTO getCourseCost(String courseCode) throws SQLException {
        // 1. Get Average Salary for Planned Calculations
        double avgSalary = universityDAO.getAverageSalary();

        // 2. Get Planned Activities
        List<ActivityDTO> plannedActs = universityDAO
                .findPlannedActivities(courseCode);

        if (plannedActs.isEmpty()) {
            return null; // found nothing
        }

        // 3. Calculate Planned Cost: SUM(hours * factor * avgSalary) / 160
        double plannedTotal = 0;
        String studyPeriodName = "";

        for (ActivityDTO act : plannedActs) {
            plannedTotal += (act.getPlannedHours() * act.getFactor() * avgSalary) / 160.0;
            if (act.getStudyPeriod() != null) {
                studyPeriodName = act.getStudyPeriod();
            }
        }

        // 4. Get Allocated/Actual Activities
        List<ActivityDTO> allocatedActs = universityDAO
                .findAllocatedActivities(courseCode);

        // 5. Calculate Actual Cost: SUM(hours * factor * specificSalary) / 160
        double actualTotal = 0;
        for (ActivityDTO act : allocatedActs) {
            actualTotal += (act.getAllocatedHours() * act.getFactor() * act.getMonthlySalary()) / 160.0;
        }

        return new CourseCostDTO(courseCode, studyPeriodName, plannedTotal, actualTotal);
    }
}