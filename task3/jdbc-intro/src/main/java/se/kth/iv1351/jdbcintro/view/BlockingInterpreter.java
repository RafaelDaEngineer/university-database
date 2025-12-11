package se.kth.iv1351.jdbcintro.view;

import se.kth.iv1351.jdbcintro.controller.Controller;
import se.kth.iv1351.jdbcintro.model.DTO.CourseCostDTO;
import java.util.Scanner;

public class BlockingInterpreter {
    private final Controller controller;
    private final Scanner scanner = new Scanner(System.in);

    public BlockingInterpreter(Controller controller) {
        this.controller = controller;
    }

    public void handleCmds() {
        System.out.println("------------------------------------------------");
        System.out.println("UNIVERSITY DB INTERFACE");
        System.out.println("1. Check Course Cost (Task 1)");
        System.out.println("2. Register 100 Students (Task 2)");
        System.out.println("3. Allocate Teacher (Task 3)");
        System.out.println("4. Add 'Exercise' Activity (Task 4)");
        System.out.println("5. Deallocate Teacher (Task 3)");
        System.out.println("q. Quit");
        System.out.println("------------------------------------------------");

        while (true) {
            System.out.print("> ");
            String cmd = scanner.nextLine();

            switch (cmd) {
                case "1":
                    checkCost();
                    break;
                case "2":
                    registerStudents();
                    break;
                case "3":
                    allocateTeacher();
                    break;
                case "4":
                    addExercise();
                    break;
                case "5":
                    deallocateTeacher();
                    break;
                case "q":
                    return;
                default:
                    System.out.println("Unknown command.");
            }
        }
    }

    private void checkCost() {
        System.out.print("Enter Course Code (e.g. IV1351): ");
        String code = scanner.nextLine();
        try {
            CourseCostDTO result = controller.getCourseCost(code);
            printCost(result);
        } catch (Exception e) {
            System.out.println("Operation failed: " + e.getMessage());
        }
    }

    private void registerStudents() {
        System.out.print("Enter Course Code to add 100 students (e.g. IV1351): ");
        String code = scanner.nextLine();
        try {
            System.out.println("Processing transaction...");
            CourseCostDTO result = controller.registerStudents(code);
            System.out.println("SUCCESS! Students added and costs recalculated.");
            printCost(result);
        } catch (Exception e) {
            System.out.println("TRANSACTION FAILED: " + e.getMessage());
        }
    }

    private void allocateTeacher() {
        System.out.print("Enter Teacher First Name (e.g. Paris): ");
        String name = scanner.nextLine();
        System.out.print("Enter Course Code (e.g. DD1337): ");
        String code = scanner.nextLine();

        try {
            controller.allocateTeacher(name, code);
            System.out.println("SUCCESS! " + name + " assigned to " + code + ".");
        } catch (Exception e) {
            System.out.println("ALLOCATION FAILED: " + e.getMessage());
        }
    }

    private void deallocateTeacher() {
        System.out.print("Enter Teacher First Name (e.g. Paris): ");
        String name = scanner.nextLine();
        System.out.print("Enter Course Code (e.g. DD1337): ");
        String code = scanner.nextLine();

        try {
            controller.deallocateTeacher(name, code);
            System.out.println("SUCCESS! " + name + " removed from " + code + ".");
        } catch (Exception e) {
            System.out.println("DEALLOCATION FAILED: " + e.getMessage());
        }
    }

    private void addExercise() {
        System.out.print("Enter Teacher First Name (e.g. Paris): ");
        String name = scanner.nextLine();
        System.out.print("Enter Course Code (e.g. IV1351): ");
        String code = scanner.nextLine();

        try {
            System.out.println("Processing transaction...");
            CourseCostDTO result = controller.addExerciseActivity(code, name);
            System.out.println("SUCCESS! 'Exercise' added to " + code + " and assigned to " + name + ".");
            printCost(result);
        } catch (Exception e) {
            System.out.println("OPERATION FAILED: " + e.getMessage());
        }
    }

    private void printCost(CourseCostDTO result) {
        if (result != null) {
            System.out.println("-----------------------------------------");
            System.out.println(" Course Code  : " + result.getCourseCode());
            System.out.println(" Study Period : " + result.getStudyPeriod());
            System.out.printf(" Planned Cost : %.2f SEK\n", result.getPlannedCost());
            System.out.printf(" Actual Cost  : %.2f SEK\n", result.getActualCost());
            System.out.println("-----------------------------------------");
        } else {
            System.out.println("Course not found or no data for year 2025.");
        }
    }
}
