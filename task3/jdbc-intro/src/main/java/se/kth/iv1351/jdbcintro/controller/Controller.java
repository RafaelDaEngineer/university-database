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
    
    private static final int MAX_COURSES_PER_PERIOD = 4;

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

        double avgSalary = universityDAO.readAverageSalary();
        List<ActivityDTO> plannedActs = universityDAO.readPlannedActivities(courseCode);

        if (plannedActs.isEmpty()) return null;

        double plannedTotal = 0;
        String studyPeriodName = "";

        for (ActivityDTO act : plannedActs) {
            plannedTotal += (act.getPlannedHours() * act.getFactor() * avgSalary) / 160.0;
            if (act.getStudyPeriod() != null) studyPeriodName = act.getStudyPeriod();
        }

        List<ActivityDTO> allocatedActs = universityDAO.readAllocatedActivities(courseCode);
        double actualTotal = 0;
        for (ActivityDTO act : allocatedActs) {
            actualTotal += (act.getAllocatedHours() * act.getFactor() * act.getMonthlySalary()) / 160.0;
        }

        // explicitly commit the read-only transaction (release locks)
        connection.commit();

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
            universityDAO.updateStudentCount(courseCode);

            // 2. get new config to apply formulas
            CourseConfigDTO config = universityDAO.readCourseConfig(courseCode);

            // 3. Business Logic Formulas
            // Exam = 32 + 0.725 * Students
            double newExamHours = 32 + (0.725 * config.getNumStudents());
            // Admin = 2 * HP + 28 + 0.2 * Students
            double newAdminHours = (2 * config.getHp()) + 28 + (0.2 * config.getNumStudents());

            // 4. save calculated hours to DB
            universityDAO.updateActivityHours(courseCode, "Grading", newExamHours);
            universityDAO.updateActivityHours(courseCode, "Course Admin", newAdminHours);

            // 5. commit transaction (save changes to db and release locks)
            connection.commit();

            // 6. return new costs (available in db after the transaction are committed)
            return getCourseCost(courseCode);
            
        } catch (Exception e) {
            try { connection.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            throw new Exception("Transaction failed: " + e.getMessage());
        }
    }

    /**
     * Requirement 3: Allocate teacher to a course instance.
     * Enforces Business Rule: Teacher cannot have > 4 courses in one period.
     */
    public void allocateTeacher(String teacherName, String courseCode) throws Exception {
        try {
            // 1. Resolve IDs (Read)
            int teacherId = universityDAO.readTeacherId(teacherName);
            int instanceId = universityDAO.readCourseInstanceId(courseCode);
            String period = universityDAO.readStudyPeriod(instanceId);

            // 2. Check Business Rule (Logic in Controller)
            int currentLoad = universityDAO.readTeacherCourseCount(teacherId, period);

            if (currentLoad >= MAX_COURSES_PER_PERIOD) {
                throw new Exception("Allocation Rejected: " + teacherName + 
                                    " already has " + currentLoad + " courses in " + period + 
                                    " (Max allowed: " + MAX_COURSES_PER_PERIOD + ")");
            }

            // 3. Create Allocation (Write)
            universityDAO.createAllocation(teacherId, instanceId);

            // 4. Commit
            connection.commit();

        } catch (Exception e) {
            try { connection.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            // Re-throw the clean error message to the View
            throw e; 
        }
    }

    /**
     * 'Exercise' activity and allocate a teacher to it.
     */
    public CourseCostDTO addExerciseActivity(String courseCode, String teacherName) throws Exception {
        try {
            // 1. Check if 'Exercise' exists. If not, create it.
            int activityId = universityDAO.readActivityId("Exercise");
            if (activityId == -1) {
                // Factor 1.5 for Exercise
                activityId = universityDAO.createActivity("Exercise", 1.5);
            }

            // 2. Resolve Course Instance & Teacher IDs
            int instanceId = universityDAO.readCourseInstanceId(courseCode);
            int teacherId = universityDAO.readTeacherId(teacherName);
            int constantsId = universityDAO.readConstantsId();

            // 3. Add 'Exercise' to the Course (Planned Activity)
            // (default 20 hours for Exercise)
            int plannedActivityId = universityDAO.createPlannedActivity(20, activityId, instanceId, constantsId);

            // 4. Allocate the Teacher to this specific activity (Employee Planned)
            universityDAO.createEmployeePlannedAllocation(plannedActivityId, teacherId, 20);

            // 5. Commit Transaction
            connection.commit();

            // 6. Return updated stats
            return getCourseCost(courseCode);

        } catch (Exception e) {
            try { connection.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            throw new Exception("Failed to add Exercise activity: " + e.getMessage());
        }
    }
}