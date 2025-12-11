package se.kth.iv1351.jdbcintro.model;

import se.kth.iv1351.jdbcintro.integration.UniversityDAO;
import se.kth.iv1351.jdbcintro.model.DTO.CourseCostDTO;
import se.kth.iv1351.jdbcintro.model.DTO.ActivityDTO;
import se.kth.iv1351.jdbcintro.model.DTO.CourseConfigDTO;
import java.sql.SQLException;
import java.util.List;

/**
 * Domain model representing a Course with business logic.
 */
public class Course {
    private static final int MAX_COURSES_PER_PERIOD = 4;

    private final String courseCode;
    private final UniversityDAO universityDAO;

    public Course(String courseCode, UniversityDAO universityDAO) {
        this.courseCode = courseCode;
        this.universityDAO = universityDAO;
    }

    /**
     * Requirement 1: Compute teaching cost.
     */
    public CourseCostDTO getCourseCost(String courseCode) throws SQLException {
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

        universityDAO.commit();

        return new CourseCostDTO(courseCode, studyPeriodName, plannedTotal, actualTotal);
    }

    /**
     * Requirement 2: Register students and recalculate costs.
     */
    public CourseCostDTO registerStudents(String courseCode) throws Exception {
        try {
            universityDAO.updateStudentCount(courseCode);
            CourseConfigDTO config = universityDAO.readCourseConfig(courseCode);

            // Business Logic Formulas
            double newExamHours = 32 + (0.725 * config.getNumStudents());
            double newAdminHours = (2 * config.getHp()) + 28 + (0.2 * config.getNumStudents());

            universityDAO.updateActivityHours(courseCode, "Grading", newExamHours);
            universityDAO.updateActivityHours(courseCode, "Course Admin", newAdminHours);

            universityDAO.commit();
            return getCourseCost(courseCode);

        } catch (Exception e) {
            rollbackSafely();
            throw new Exception("Transaction failed: " + e.getMessage());
        }
    }

    /**
     * Requirement 3: Allocate teacher to a course instance.
     * Enforces Business Rule: Teacher cannot have > 4 courses in one period.
     */
    public void allocateTeacher(String teacherName, String courseCode) throws Exception {
        try {
            int teacherId = universityDAO.readTeacherId(teacherName);
            int instanceId = universityDAO.readCourseInstanceId(courseCode);
            String period = universityDAO.readStudyPeriod(instanceId);

            // Business Rule Validation
            validateTeacherAllocation(teacherId, teacherName, period);

            universityDAO.createAllocation(teacherId, instanceId);
            universityDAO.commit();

        } catch (Exception e) {
            rollbackSafely();
            throw e;
        }
    }

    /**
     * Business Rule: Validate teacher workload before allocation.
     */
    private void validateTeacherAllocation(int teacherId, String teacherName, String period) throws Exception {
        int currentLoad = universityDAO.readTeacherCourseCount(teacherId, period);
        if (currentLoad >= MAX_COURSES_PER_PERIOD) {
            throw new Exception("Allocation Rejected: " + teacherName +
                    " already has " + currentLoad + " courses in " + period +
                    " (Max allowed: " + MAX_COURSES_PER_PERIOD + ")");
        }
    }

    /**
     * Deallocate teacher from this course.
     */
    public void deallocateTeacher(String teacherName, String courseCode) throws Exception {
        try {
            int teacherId = universityDAO.readTeacherId(teacherName);
            int instanceId = universityDAO.readCourseInstanceId(courseCode);
            universityDAO.deleteAllocation(teacherId, instanceId);
            universityDAO.commit();
        } catch (Exception e) {
            rollbackSafely();
            throw e;
        }
    }

    /**
     * Add 'Exercise' activity and allocate a teacher to it.
     */
    public CourseCostDTO addExerciseActivity(String courseCode, String teacherName) throws Exception {
        try {
            int activityId = universityDAO.readActivityId("Exercise");
            if (activityId == -1) {
                activityId = universityDAO.createActivity("Exercise", 1.5);
            }

            int instanceId = universityDAO.readCourseInstanceId(courseCode);
            int teacherId = universityDAO.readTeacherId(teacherName);
            int constantsId = universityDAO.readConstantsId();

            int plannedActivityId = universityDAO.createPlannedActivity(20, activityId, instanceId, constantsId);
            universityDAO.createEmployeePlannedAllocation(plannedActivityId, teacherId, 20);

            universityDAO.commit();
            return this.getCourseCost(courseCode);

        } catch (Exception e) {
            rollbackSafely();
            throw new Exception("Failed to add Exercise activity: " + e.getMessage());
        }
    }

    /**
     * Helper method to safely rollback transactions.
     */
    private void rollbackSafely() {
        universityDAO.rollback();
    }
}
