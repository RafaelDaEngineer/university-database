# MVC Refactor Walkthrough

I have refactored the application to strictly follow the MVC and Layer patterns as requested.

## 1. Integration Layer (DAO) - Logic Removed
The `UniversityDAO` no longer contains business logic (like cost formulas or complex aggregations). It now strictly fetches raw data.

```java
// OLD: Complex Logic in SQL
// "COALESCE(SUM(DISTINCT pa.planned_hours * ta.factor * (SELECT val FROM AvgSalary)), 0) / 160..."

// NEW: Simple Reads
// Only fetches columns. No SUM, no Multiplication, no Logic.
public double getAverageSalary() { ... }
public List<ActivityDTO> findPlannedActivities(String code) { ... }
public List<ActivityDTO> findAllocatedActivities(String code) { ... }
```

## 2. Controller Layer - Business Logic Added
The `Controller` now orchestrates the calculation. It acts as the brain, combining raw data from the DAO.

```java
// Controller.java
public CourseCostDTO getCourseCost(String courseCode) {
    // 1. Fetch Data
    double avgSalary = universityDAO.getAverageSalary();
    List<ActivityDTO> activities = universityDAO.findPlannedActivities(courseCode);
    
    // 2. Perform Logic (Java instead of SQL)
    // The "Logic" (Math) is now visible in the Java code, not hidden in SQL strings.
    double plannedTotal = 0;
    for (ActivityDTO act : activities) {
         plannedTotal += (act.getPlannedHours() * act.getFactor() * avgSalary) / 160.0;
    }
    // ... return DTO
}
```

## 3. View Layer - Formatting Added
The `BlockingInterpreter` (View) is now responsible for how the data looks. The Controller just returns the object; it doesn't print errors.

```java
// BlockingInterpreter.java
try {
    CourseCostDTO result = controller.getCourseCost(code);
    System.out.println(" Course Code  : " + result.getCourseCode());
    // ...
} catch (Exception e) {
    System.out.println("Operation failed: " + e.getMessage());
}
```

## 4. Model Layer - Pure Data
`CourseCostDTO` is now a dumb data carrier with no `toString` formatting logic. A new `ActivityDTO` was added to help transfer raw data.

## Verification
- **MVC Rules**: 
  - View code is ONLY in `BlockingInterpreter`.
  - Business Logic is ONLY in `Controller`.
  - Database access is ONLY in `UniversityDAO`.
- **Logic**: The cost calculation formula (`hours * factor * salary / 160`) is preserved but moved to Java.
