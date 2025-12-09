package se.kth.iv1351.jdbcintro.controller;

import se.kth.iv1351.jdbcintro.integration.DBHandler;
import se.kth.iv1351.jdbcintro.integration.UniversityDAO;
import se.kth.iv1351.jdbcintro.model.CourseCostDTO;
import se.kth.iv1351.jdbcintro.model.ActivityDTO;
import se.kth.iv1351.jdbcintro.model.CourseConfigDTO;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public class Controller {
    private final DBHandler dbHandler;
    private final UniversityDAO universityDAO;
    private final Connection connection;

    public Controller() throws SQLException, ClassNotFoundException {
        this.dbHandler = new DBHandler();
        this.connection = dbHandler.getConnection();
        // pass connection to the DAO
        this.universityDAO = new UniversityDAO(connection);
    }

    /**
     * Requirement 1: Compute teaching cost.
     */
    public CourseCostDTO getCourseCost(String courseCode) throws SQLException {
        // Logic for 1: (Hours * Factor * Salary) / 160
        
        double avgSalary = universityDAO.getAverageSalary();
        List<ActivityDTO> plannedActs = universityDAO.findPlannedActivities(courseCode);

        if (plannedActs.isEmpty()) return null;

        double plannedTotal = 0;
        String studyPeriodName = "";

        for (ActivityDTO act : plannedActs) {
            plannedTotal += (act.getPlannedHours() * act.getFactor() * avgSalary) / 160.0;
            if (act.getStudyPeriod() != null) studyPeriodName = act.getStudyPeriod();
        }

        List<ActivityDTO> allocatedActs = universityDAO.findAllocatedActivities(courseCode);
        double actualTotal = 0;
        for (ActivityDTO act : allocatedActs) {
            actualTotal += (act.getAllocatedHours() * act.getFactor() * act.getMonthlySalary()) / 160.0;
        }

        return new CourseCostDTO(courseCode, studyPeriodName, plannedTotal, actualTotal);
    }

    /**
     * Requirement 2: Register students and recalculate costs.
     * Transactional: Updates students -> Updates dependent activities -> Commits.
     * @param courseCode The course to update.
     * @return The new cost DTO after update.
     */
    public CourseCostDTO registerStudents(String courseCode) throws Exception {
        try {
            // 1. Modify: Add 100 students
            universityDAO.addStudents(courseCode);

            // 2. get new config to apply formulas
            CourseConfigDTO config = universityDAO.getCourseConfig(courseCode);

            // 3. Business Logic Formulas
            // Exam = 32 + 0.725 * Students
            double newExamHours = 32 + (0.725 * config.getNumStudents());
            // Admin = 2 * HP + 28 + 0.2 * Students
            double newAdminHours = (2 * config.getHp()) + 28 + (0.2 * config.getNumStudents());

            // 4. save calculated hours to DB
            universityDAO.updateActivityHours(courseCode, "Grading", newExamHours);
            universityDAO.updateActivityHours(courseCode, "Course Admin", newAdminHours);

            // 5. commit transaction
            connection.commit();

            // 6. return new costs
            return getCourseCost(courseCode);

        } catch (Exception e) {
            // ROLLBACK on any failure to ensure consistent state
            try {
                connection.rollback();
            } catch (SQLException rollbackEx) {
                System.err.println("Rollback failed: " + rollbackEx.getMessage());
            }
            throw new Exception("Transaction failed, changes rolled back. Reason: " + e.getMessage());
        }
    }
}