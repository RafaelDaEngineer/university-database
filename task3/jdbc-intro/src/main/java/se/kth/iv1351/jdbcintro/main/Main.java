package se.kth.iv1351.jdbcintro.main;

import se.kth.iv1351.jdbcintro.controller.Controller;
import se.kth.iv1351.jdbcintro.view.BlockingInterpreter;

public class Main {
    public static void main(String[] args) {
        try {
            // 1. Initialize Controller (which initializes DB connection)
            Controller contr = new Controller();
            
            // 2. Start the View
            new BlockingInterpreter(contr).handleCmds();

        } catch (Exception e) {
            System.out.println("Application failed to start.");
            e.printStackTrace();
        }
    }
}