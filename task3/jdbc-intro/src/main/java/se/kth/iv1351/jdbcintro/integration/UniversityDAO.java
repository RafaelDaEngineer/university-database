// SQL only allowed in here to keep high cohesion!! (but no logic?)

package se.kth.iv1351.jdbcintro.integration;

// import se.kth.iv1351.jdbcintro.model.CourseCostDTO; // Removed

// java.sql is the java db connectivity stuff
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.ArrayList;
import se.kth.iv1351.jdbcintro.model.ActivityDTO;

public class UniversityDAO {
    private final Connection connection;
    private PreparedStatement avgSalaryStmt;
    private PreparedStatement plannedStmt;
    private PreparedStatement allocatedStmt;

    public UniversityDAO(Connection connection) throws SQLException {
        this.connection = connection;
        prepareStatements();
    }

    private void prepareStatements() throws SQLException {
        // 1. avg salary (business rule)
        avgSalaryStmt = connection.prepareStatement("SELECT AVG(salary) as val FROM salary_info");

        // 2. Get Planned Activities (hours & factor)
        String plannedSql = "SELECT pa.planned_hours, ta.factor, cl.course_code, sp.study_period_name " +
                "FROM course_instance ci " +
                "JOIN course_layout cl ON ci.course_id = cl.course_id " +
                "JOIN course_study cs ON ci.instance_id = cs.instance_id " +
                "JOIN study_period sp ON cs.study_period_id = sp.study_period_id " +
                "JOIN planned_activity pa ON ci.instance_id = pa.instance_id " +
                "JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id " +
                "WHERE cl.course_code = ? AND ci.study_year = '2025'";
        plannedStmt = connection.prepareStatement(plannedSql);

        // 3. Get Allocated Activities (hours, factor, salary)
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
        // allocatedStmt is a prepared statement for later use
    }

    public double getAverageSalary() throws SQLException {
        try (ResultSet rs = avgSalaryStmt.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble("val");
            }
            return 0;
        }
    }

    public List<ActivityDTO> findPlannedActivities(String courseCode)
            throws SQLException {
        plannedStmt.setString(1, courseCode);
        List<ActivityDTO> list = new ArrayList<>();
        try (ResultSet rs = plannedStmt.executeQuery()) {
            while (rs.next()) {
                // For planned, we don't know the allocated hours or specific salary, so 0 them.
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

    public List<ActivityDTO> findAllocatedActivities(String courseCode)
            throws SQLException {
        allocatedStmt.setString(1, courseCode);
        List<ActivityDTO> list = new ArrayList<>();
        try (ResultSet rs = allocatedStmt.executeQuery()) {
            while (rs.next()) {
                // For allocated, we care about allocated_hours, factor, and salary.
                list.add(new ActivityDTO(
                        null, null, 0, // courseCode/studyPeriod not needed here or can be fetched
                        rs.getDouble("allocated_hours"),
                        rs.getDouble("factor"),
                        rs.getDouble("salary")));
            }
        }
        return list;
    }
}