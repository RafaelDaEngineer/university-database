// SQL only allowed in here to keep high cohesion!! (but no logic?)

package se.kth.iv1351.jdbcintro.integration;

import se.kth.iv1351.jdbcintro.model.CourseCostDTO;
// java.sql is the java db connectivity stuff
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UniversityDAO {
    // final cause connection to db will never change
    private final Connection connection;
    private PreparedStatement findCourseCostStmt;

    public UniversityDAO(Connection connection) throws SQLException {
        this.connection = connection;
        // runs prepareStatements once when app starts to prepare the "form"
        prepareStatements();
    }

    private void prepareStatements() throws SQLException {
        // calculate costs for the CURRENT YEAR ('2025' in your dummy data)
        // PLANNED: Sum(planned_hours * factor) * Average Salary
        // ACTUAL: Sum(allocated_hours * factor * individual_salary)
 
        // divide salary by 160 (monthly hours) to get an hourly rate.
        String sql = "WITH AvgSalary AS (SELECT AVG(salary) as val FROM salary_info), " +
                "     CourseInfo AS ( " +
                "         SELECT ci.instance_id, cl.course_code, sp.study_period_name " +
                "         FROM course_instance ci " +
                "         JOIN course_layout cl ON ci.course_id = cl.course_id " +
                "         JOIN course_study cs ON ci.instance_id = cs.instance_id " +
                "         JOIN study_period sp ON cs.study_period_id = sp.study_period_id " +
                "         WHERE cl.course_code = ? AND ci.study_year = '2025' " +
                "     ) " +
                "SELECT " +
                "    ci.course_code, " +
                "    ci.study_period_name, " +
                // PLANNED: (Hours * Factor * AvgMonthlySalary) / 160
                "    COALESCE(SUM(DISTINCT pa.planned_hours * ta.factor * (SELECT val FROM AvgSalary)), 0) / 160 as planned_total, "
                +
                // ACTUAL: (Hours * Factor * SpecificMonthlySalary) / 160
                "    COALESCE(SUM(ep.allocated_hours * ta.factor * si.salary), 0) / 160 as actual_total " +
                "FROM CourseInfo ci " +
                "LEFT JOIN planned_activity pa ON ci.instance_id = pa.instance_id " +
                "LEFT JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id " +
                "LEFT JOIN employee_planned ep ON pa.planned_activity_id = ep.planned_activity_id " +
                "LEFT JOIN employee e ON ep.employment_id = e.employment_id " +
                "LEFT JOIN salary_info si ON e.salary_id = si.salary_id " +
                "GROUP BY ci.course_code, ci.study_period_name";
        findCourseCostStmt = connection.prepareStatement(sql);
    }

    /**
     * Finds the planned and actual costs for a course instance.
     * 
     * @param courseCode The code of the course (e.g., "IV1351")
     * @return A CourseCostDTO object containing the costs, or null if not found.
     */
    public CourseCostDTO findCourseCosts(String courseCode) throws SQLException {
        // at questionmark nr "1" insert "courseCode"
        findCourseCostStmt.setString(1, courseCode);

        try (ResultSet rs = findCourseCostStmt.executeQuery()) {
            if (rs.next()) {
                return new CourseCostDTO(
                        rs.getString("course_code"),
                        rs.getString("study_period_name"),
                        rs.getDouble("planned_total"),
                        rs.getDouble("actual_total"));
            }
            return null; // Course not found
        }
    }
}