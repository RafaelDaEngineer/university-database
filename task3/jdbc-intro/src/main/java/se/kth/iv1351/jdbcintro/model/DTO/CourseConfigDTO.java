package se.kth.iv1351.jdbcintro.model.DTO;

/**
 * DTO to transfer configuration data (#students and HP)
 * required for calculating dependent activity hours.
 * (like a snapshot of the course instance)
 */
public class CourseConfigDTO {
    private final int numStudents;
    private final double hp;

    public CourseConfigDTO(int numStudents, double hp) {
        this.numStudents = numStudents;
        this.hp = hp;
    }

    public int getNumStudents() {
        return numStudents;
    }

    public double getHp() {
        return hp;
    }
}