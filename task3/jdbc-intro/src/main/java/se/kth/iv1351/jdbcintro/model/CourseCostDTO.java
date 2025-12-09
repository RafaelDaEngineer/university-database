package se.kth.iv1351.jdbcintro.model;

/**
 * Data Transfer Object (DTO) for Course Cost information. 
 * "dumb" container used to move data between layers.
 */
public class CourseCostDTO {
    private final String courseCode;
    private final String studyPeriod;
    private final double plannedCost;
    private final double actualCost;

    public CourseCostDTO(String courseCode, String studyPeriod, double plannedCost, double actualCost) {
        this.courseCode = courseCode;
        this.studyPeriod = studyPeriod;
        this.plannedCost = plannedCost;
        this.actualCost = actualCost;
    }

    public String getCourseCode() { return courseCode; }
    public String getStudyPeriod() { return studyPeriod; }
    public double getPlannedCost() { return plannedCost; }
    public double getActualCost() { return actualCost; }

    @Override
    public String toString() {
        return String.format(
            "-----------------------------------------\n" +
            " Course Code  : %s\n" +
            " Study Period : %s\n" +
            " Planned Cost : %.2f SEK\n" +
            " Actual Cost  : %.2f SEK\n" +
            "-----------------------------------------",
            courseCode, studyPeriod, plannedCost, actualCost
        );
    }
}