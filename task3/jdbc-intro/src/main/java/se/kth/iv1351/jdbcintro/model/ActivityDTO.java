package se.kth.iv1351.jdbcintro.model;

/**
 * Represents raw activity data fetched from the database.
 * Used by the Controller to calculate costs.
 */
public class ActivityDTO {
    private final String courseCode;
    private final String studyPeriod;
    private final double plannedHours;
    private final double allocatedHours;
    private final double factor;
    private final double monthlySalary;

    public ActivityDTO(String courseCode, String studyPeriod, double plannedHours, double allocatedHours, double factor,
            double monthlySalary) {
        this.courseCode = courseCode;
        this.studyPeriod = studyPeriod;
        this.plannedHours = plannedHours;
        this.allocatedHours = allocatedHours;
        this.factor = factor;
        this.monthlySalary = monthlySalary;
    }

    public String getCourseCode() {
        return courseCode;
    }

    public String getStudyPeriod() {
        return studyPeriod;
    }

    public double getPlannedHours() {
        return plannedHours;
    }

    public double getAllocatedHours() {
        return allocatedHours;
    }

    public double getFactor() {
        return factor;
    }

    public double getMonthlySalary() {
        return monthlySalary;
    }
}
