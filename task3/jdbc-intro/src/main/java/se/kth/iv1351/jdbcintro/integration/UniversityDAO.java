// only file that's allowed to touch the db. statements (java.sql.PreparedStatement) are prepared here

package se.kth.iv1351.jdbcintro.integration;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.ArrayList;
import se.kth.iv1351.jdbcintro.model.ActivityDTO;
import se.kth.iv1351.jdbcintro.model.CourseConfigDTO;

public class UniversityDAO {
    private final Connection connection;
    
    // Statements (Task 1 & 2)
    private PreparedStatement avgSalaryStmt;
    private PreparedStatement plannedStmt;
    private PreparedStatement allocatedStmt;
    private PreparedStatement updateStudentsStmt;
    private PreparedStatement getConfigStmt;
    private PreparedStatement updateActivityStmt;

    // Statements (Task 3: Allocations)
    private PreparedStatement findPersonStmt;
    private PreparedStatement findInstanceStmt;
    private PreparedStatement findPeriodStmt;
    private PreparedStatement countCoursesStmt;
    private PreparedStatement createAllocationStmt;
    private PreparedStatement deleteAllocationStmt; // Added for completeness

    public UniversityDAO(Connection connection) throws SQLException {
        this.connection = connection;
        prepareStatements();
    }

    private void prepareStatements() throws SQLException {
        // READ STATEMENTS (Task 1)
        avgSalaryStmt = connection.prepareStatement("SELECT AVG(salary) as val FROM salary_info");

        String plannedSql = "SELECT pa.planned_hours, ta.factor, cl.course_code, sp.study_period_name " +
                "FROM course_instance ci " +
                "JOIN course_layout cl ON ci.course_id = cl.course_id " +
                "JOIN course_study cs ON ci.instance_id = cs.instance_id " +
                "JOIN study_period sp ON cs.study_period_id = sp.study_period_id " +
                "JOIN planned_activity pa ON ci.instance_id = pa.instance_id " +
                "JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id " +
                "WHERE cl.course_code = ? AND ci.study_year = '2025'";
        plannedStmt = connection.prepareStatement(plannedSql);

        String allocatedSql = "SELECT ep.allocated_hours, ta.factor, si.salary " +
                "FROM course_instance ci " +
                "JOIN course_layout cl ON ci.course_id = cl.course_id " +
                "JOIN planned_activity pa ON ci.instance_id = pa.instance_id " +
                "JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id " +
                "JOIN employee_planned ep ON pa.planned_activity_id = ep.planned_activity_id " +
                "JOIN employee e ON ep.employment_id = e.employment_id " +
                "JOIN salary_info si ON e.salary_id = si.salary_id " +
                "WHERE cl.course_code = ? AND ci.study_year = '2025'";
        allocatedStmt = connection.prepareStatement(allocatedSql);

        // WRITE STATEMENTS (Task 2)

        // 1. Update Student Count (+100)
        String updateStudentsSql = "UPDATE course_instance SET num_students = num_students + 100 " +
                "WHERE course_id = (SELECT course_id FROM course_layout WHERE course_code = ?) " +
                "AND study_year = '2025'";
        updateStudentsStmt = connection.prepareStatement(updateStudentsSql);

        // 2. Read HP and Students (for formula calculation)
        String getConfigSql = "SELECT ci.num_students, cl.hp FROM course_instance ci " +
                "JOIN course_layout cl ON ci.course_id = cl.course_id " +
                "WHERE cl.course_code = ? AND ci.study_year = '2025'"; // locking handled by previous UPDATE or explicit if needed
        getConfigStmt = connection.prepareStatement(getConfigSql);

        // 3. update activity hours (grading/admin)
        String updateActivitySql = "UPDATE planned_activity SET planned_hours = ? " +
                "WHERE instance_id = ( " +
                "   SELECT ci.instance_id FROM course_instance ci " +
                "   JOIN course_layout cl ON ci.course_id = cl.course_id " +
                "   WHERE cl.course_code = ? AND ci.study_year = '2025' " +
                ") " +
                "AND teaching_activity_id = (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name = ?)";
        updateActivityStmt = connection.prepareStatement(updateActivitySql);

        // --- NEW STATEMENTS (Task 3) ---
        
        // 1. Find Teacher ID by First Name (Simplification for CLI)
        findPersonStmt = connection.prepareStatement(
            "SELECT e.employment_id FROM employee e " +
            "JOIN person p ON e.person_id = p.person_id " +
            "WHERE p.first_name = ?");

        // 2. Find Instance ID by Course Code
        findInstanceStmt = connection.prepareStatement(
            "SELECT ci.instance_id FROM course_instance ci " +
            "JOIN course_layout cl ON ci.course_id = cl.course_id " +
            "WHERE cl.course_code = ? AND ci.study_year = '2025'");

        // 3. Find Study Period for an Instance
        findPeriodStmt = connection.prepareStatement(
            "SELECT sp.study_period_name FROM course_study cs " +
            "JOIN study_period sp ON cs.study_period_id = sp.study_period_id " +
            "WHERE cs.instance_id = ?");

        // 4. Count courses for a teacher in a specific period
        // '::study_period_enum' to cast the string parameter
        countCoursesStmt = connection.prepareStatement(
            "SELECT COUNT(*) as course_count FROM employee_course ec " +
            "JOIN course_study cs ON ec.instance_id = cs.instance_id " +
            "JOIN study_period sp ON cs.study_period_id = sp.study_period_id " +
            "WHERE ec.employment_id = ? AND sp.study_period_name = ?::study_period_enum");

        // 5. Create Allocation
        createAllocationStmt = connection.prepareStatement(
            "INSERT INTO employee_course (employment_id, instance_id) VALUES (?, ?)");
            
        // 6. Delete Allocation
        deleteAllocationStmt = connection.prepareStatement(
            "DELETE FROM employee_course WHERE employment_id = ? AND instance_id = ?");
    }

    // --- READ METHODS ---

    public double getAverageSalary() throws SQLException {
        try (ResultSet rs = avgSalaryStmt.executeQuery()) {
            if (rs.next()) return rs.getDouble("val");
            return 0;
        }
    }

    public List<ActivityDTO> findPlannedActivities(String courseCode) throws SQLException {
        plannedStmt.setString(1, courseCode);
        List<ActivityDTO> list = new ArrayList<>();
        try (ResultSet rs = plannedStmt.executeQuery()) {
            while (rs.next()) {
                list.add(new ActivityDTO(
                        rs.getString("course_code"),
                        rs.getString("study_period_name"),
                        rs.getDouble("planned_hours"),
                        0,
                        rs.getDouble("factor"),
                        0));
            }
        }
        return list;
    }

    public List<ActivityDTO> findAllocatedActivities(String courseCode) throws SQLException {
        allocatedStmt.setString(1, courseCode);
        List<ActivityDTO> list = new ArrayList<>();
        try (ResultSet rs = allocatedStmt.executeQuery()) {
            while (rs.next()) {
                list.add(new ActivityDTO(
                        null, null, 0,
                        rs.getDouble("allocated_hours"),
                        rs.getDouble("factor"),
                        rs.getDouble("salary")));
            }
        }
        return list;
    }
    
    // --- TASK 3 HELPERS ---
    
    public int findTeacherId(String firstName) throws SQLException {
        findPersonStmt.setString(1, firstName);
        try (ResultSet rs = findPersonStmt.executeQuery()) {
            if (rs.next()) return rs.getInt("employment_id");
            throw new SQLException("Teacher not found: " + firstName);
        }
    }
    
    public int findCourseInstanceId(String courseCode) throws SQLException {
        findInstanceStmt.setString(1, courseCode);
        try (ResultSet rs = findInstanceStmt.executeQuery()) {
            if (rs.next()) return rs.getInt("instance_id");
            throw new SQLException("Course instance not found: " + courseCode);
        }
    }
    
    public String findStudyPeriod(int instanceId) throws SQLException {
        findPeriodStmt.setInt(1, instanceId);
        try (ResultSet rs = findPeriodStmt.executeQuery()) {
            if (rs.next()) return rs.getString("study_period_name");
            throw new SQLException("Study period not found for instance: " + instanceId);
        }
    }
    
    public int countTeacherCourses(int employmentId, String period) throws SQLException {
        countCoursesStmt.setInt(1, employmentId);
        countCoursesStmt.setString(2, period);
        try (ResultSet rs = countCoursesStmt.executeQuery()) {
            if (rs.next()) return rs.getInt("course_count");
            return 0;
        }
    }

    // --- WRITE METHODS (task 2) ---

    public void addStudents(String courseCode) throws SQLException {
        updateStudentsStmt.setString(1, courseCode);
        int rows = updateStudentsStmt.executeUpdate();
        if (rows == 0) {
            throw new SQLException("Course not found for update: " + courseCode);
        }
    }

    public CourseConfigDTO getCourseConfig(String courseCode) throws SQLException {
        getConfigStmt.setString(1, courseCode);
        try (ResultSet rs = getConfigStmt.executeQuery()) {
            if (rs.next()) {
                return new CourseConfigDTO(rs.getInt("num_students"), rs.getDouble("hp"));
            }
            throw new SQLException("Course config could not be read for: " + courseCode);
        }
    }

    public void updateActivityHours(String courseCode, String activityName, double newHours) throws SQLException {
        updateActivityStmt.setDouble(1, newHours);
        updateActivityStmt.setString(2, courseCode);
        updateActivityStmt.setString(3, activityName);
        updateActivityStmt.executeUpdate();
    }
    
    public void createAllocation(int employmentId, int instanceId) throws SQLException {
        createAllocationStmt.setInt(1, employmentId);
        createAllocationStmt.setInt(2, instanceId);
        createAllocationStmt.executeUpdate();
    }

    public void deleteAllocation(int employmentId, int instanceId) throws SQLException {
        deleteAllocationStmt.setInt(1, employmentId);
        deleteAllocationStmt.setInt(2, instanceId);
        deleteAllocationStmt.executeUpdate();
    }
}