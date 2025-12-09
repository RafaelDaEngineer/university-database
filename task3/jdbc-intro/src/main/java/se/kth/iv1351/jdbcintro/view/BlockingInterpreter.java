package se.kth.iv1351.jdbcintro.view;

import se.kth.iv1351.jdbcintro.controller.Controller;
import se.kth.iv1351.jdbcintro.model.CourseCostDTO;
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
        System.out.println("q. Quit");
        System.out.println("------------------------------------------------");

        while (true) {
            System.out.print("> ");
            String cmd = scanner.nextLine();

            switch (cmd) {
                case "1":
                    System.out.print("Enter Course Code (e.g. IV1351): ");
                    String code = scanner.nextLine();
                    try {
                        CourseCostDTO result = controller.getCourseCost(code);
                        if (result != null) {
                            // View Logic: Formatting the output
                            System.out.println("-----------------------------------------");
                            System.out.println(" Course Code  : " + result.getCourseCode());
                            System.out.println(" Study Period : " + result.getStudyPeriod());
                            System.out.printf(" Planned Cost : %.2f SEK\n", result.getPlannedCost());
                            System.out.printf(" Actual Cost  : %.2f SEK\n", result.getActualCost());
                            System.out.println("-----------------------------------------");
                        } else {
                            System.out.println("Course not found or no data for year 2025.");
                        }
                    } catch (Exception e) {
                        System.out.println("Operation failed: " + e.getMessage());
                        // e.printStackTrace(); // debug only
                    }
                    break;
                case "q":
                    return;
                default:
                    System.out.println("Unknown command.");
            }
        }
    }
}