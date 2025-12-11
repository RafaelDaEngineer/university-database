package se.kth.iv1351.jdbcintro.controller;

import se.kth.iv1351.jdbcintro.integration.UniversityDAO;
import se.kth.iv1351.jdbcintro.model.Course;
import se.kth.iv1351.jdbcintro.model.DTO.CourseCostDTO;

public class Controller {
    private final UniversityDAO universityDAO;

    public Controller(UniversityDAO universityDAO) {
        this.universityDAO = universityDAO;
    }

    /**
     * Task 1: Get course cost
     */
    public CourseCostDTO getCourseCost(String courseCode) throws Exception {
        Course course = new Course(courseCode, universityDAO);
        return course.getCourseCost(courseCode);
    }

    /**
     * Task 2: Register students
     */
    public CourseCostDTO registerStudents(String courseCode) throws Exception {
        Course course = new Course(courseCode, universityDAO);
        return course.registerStudents(courseCode);
    }

    /**
     * Task 3: Allocate teacher
     */
    public void allocateTeacher(String teacherName, String courseCode) throws Exception {
        Course course = new Course(courseCode, universityDAO);
        course.allocateTeacher(teacherName, courseCode);
    }

    /**
     * Task 3: Deallocate teacher
     */
    public void deallocateTeacher(String teacherName, String courseCode) throws Exception {
        Course course = new Course(courseCode, universityDAO);
        course.deallocateTeacher(teacherName, courseCode);
    }

    /**
     * Task 4: Add exercise activity
     */
    public CourseCostDTO addExerciseActivity(String courseCode, String teacherName) throws Exception {
        Course course = new Course(courseCode, universityDAO);
        return course.addExerciseActivity(courseCode, teacherName);
    }
}
