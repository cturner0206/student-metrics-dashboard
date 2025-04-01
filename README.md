# Project 2: Student Metrics Dashboard 
![Image Alt](https://github.com/cturner0206/student-metrics-dashboard/blob/7abdc93106118661896d2236f31a0baf98cbf2e5/Dashboard1.png)
![Image Alt](https://github.com/cturner0206/student-metrics-dashboard/blob/7abdc93106118661896d2236f31a0baf98cbf2e5/Dashboard2.png)
![Image Alt](https://github.com/cturner0206/student-metrics-dashboard/blob/7abdc93106118661896d2236f31a0baf98cbf2e5/Dashboard3.png)



# Table of Contents 
- [Project Overview](#project-overview)
- [Data Source](#data-source)
- [Loading Data into SSMS ](#loading-data-into-ssms)
- [Creating the Queries](#creating-the-queries)
- [Process of Building the Report](#process-of-building-the-report)
- [Findings](#findings)
- [Recommendations](#recommendations)


# Project Overview

The primary goal of this project was to identify and analyze the various factors that affect student GPA. To do this, I used SQL queries to calculate averages, distributions, and other relevant data and imported the queries into PowerBI to create an interactive dashboard. The dashboard aims to provide insights to help educators and administrators make informed decisions to enhance student performance.

# Data Source
The data used for this project comes from the `student_performance_data.csv` and `student_performance_data1.csv` files. The original dataset file had both files combined, but I split it up to segment the data based on student data and academic performance metrics. 


# Loading Data into SSMS  

Loading the data into Microsoft SQL Server Management Studio involved the following steps:

- Created new Student_Data database.
- Imported `student_performance_data.csv` and `student_performance_data1.csv` files in SQL Server Management Studio as two separate tables.
- Chose relevant data types for the different columns in both tables
   - StudentID was used as the PK in the Students table and PK/FK in the Academic_Performance table to maintain data integrity
   - Set everything to not include nulls
        > **Note:** I saw there were no null values to begin with in the dataset, as there are only 500 rows
   - Ran SELECT statements to review the data in the two tables
      
![Image Alt](https://github.com/cturner0206/student-metrics-dashboard/blob/7abdc93106118661896d2236f31a0baf98cbf2e5/Table1.png)
![Image Alt](https://github.com/cturner0206/student-metrics-dashboard/blob/7abdc93106118661896d2236f31a0baf98cbf2e5/Table2.png)





# Creating the Queries

## **Query Brainstorm:**  

To be able to create relevant queries that would allow for an end user to gain meaningful insights, I first had a brainstorming session to: 

1. Identifying Relevant Data Points that can affect GPA:
- Attendance rate: How do housing location, extracurricular activity participation, and having a part-time job outside of school affect attendance rates and GPA?
- Major: Does the difficulty of a major affect overall GPA or attendance rates? Ex: Engineering vs Arts.
- Effort: Total study hours per week and attendance rate affect GPA. 
- Assistance: Does receiving financial aid affect GPA or attendance?
- Demographics: Age and Gender affect on GPA.
- Distribution: How many students are in each GPA range, who are performing well, top 10 and bottom 10 students by major.
  
2. Deciding on visuals
- I believe that simple matrices, cards, bar charts, and tables would be the most effective visuals for this dashboard as they are easy to read while conveying all the data appropriately. 
- Slicers by major and by student performance will allow for further filtering and analysis.
- There won't be any time series analysis or visuals, as there wasn't any time data provided in the dataset. 

## **Data Cleaning:**  
  The only cleaning involved rounding and casting values in the queries themselves, with nothing done beforehand.

## **SQL Used:**
   - Group By and Where clauses
   - Aggregate functions: Avg, Sum, Count
   - Joins
   - Round, Cast
   - Conditional: Case, IIF
   - Subqueries
   - CTE's
   - Window functions: row_number()


## **All Queries**
  
```sql
--Count and Percent of Total Students by Major
SELECT
    Major,
    Count(StudentID) AS Count_Students,
    Round(Cast(Count(*) * 100.0 / (SELECT Count(*) FROM Students) AS FLOAT), 2) AS Percent_of_Total_Students
FROM Students
GROUP BY Major
ORDER BY Percent_of_Total_Students DESC;
```
```sql
--General Averages per Major
SELECT
    Major,
    Avg(Age) AS Avg_Age,
    Round(Avg(Gpa), 2) AS Avg_Gpa,
    Round(Avg(AttendanceRate), 2) / 100 AS Avg_Attendance,
    Avg(StudyHoursPerWeek) AS Avg_Study_Hours
FROM Students s
JOIN Academic_Performance ap ON s.Studentid = ap.Studentid
GROUP BY Major
ORDER BY Avg_Gpa DESC;
```
```sql
--Students Who Have a Higher GPA Than the Overall Average
SELECT
    s.StudentID,
    Gender,
    Age,
    Major,
    Round(GPA, 2) AS GPA
FROM Students AS s
JOIN Academic_Performance ap ON s.StudentID = ap.StudentID
WHERE GPA > (SELECT Avg(GPA) FROM Academic_Performance)
ORDER BY GPA DESC;
```
```sql
--Which Students Are Performing Well or Could Use Some Improvement (Is GPA greater than 3.0?)
SELECT
    s.StudentID,
    Major,
    Round(GPA, 2) AS GPA,
    StudyHoursPerWeek,
    iif(GPA > 3.0, 'Performing Well', 'Needs Improvement') AS PerformanceCategory
FROM Students s
JOIN Academic_Performance ap ON s.StudentID = ap.StudentId;
```
```sql
--Attendance Rate and GPA by Gender and Financial Aid
SELECT 
    s.Major,
    s.Gender,
    s.FinAid,
    Count(s.StudentID) AS Total_Students,
    Sum(CASE WHEN s.FinAid = 'Yes' THEN 1 ELSE 0 END) AS Students_With_FinAid,
    Round(Cast(Sum(CASE WHEN s.FinAid = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS FLOAT), 2) AS Percent_With_FinAid,
    Round(Avg(ap.GPA), 2) AS Avg_GPA,
    Round(Avg(ap.AttendanceRate), 2) / 100 AS Avg_Attendance_Rate
FROM Students s
JOIN Academic_Performance ap ON s.StudentID = ap.StudentId
GROUP BY s.Gender, s.Major, s.FinAid
ORDER BY s.Major;
```
```sql
--Part-Time Job vs Attendance Rate and GPA
SELECT
    s.PartTimeJob,
    Count(s.StudentID) as Count_Students,
    s.Major,
    Round(Avg(ap.GPA), 2) AS Avg_GPA,
    Round(Avg(ap.AttendanceRate), 2) / 100 AS Avg_Attendance_Rate
FROM Academic_Performance ap
JOIN Students s ON ap.StudentID = s.StudentID
GROUP BY s.PartTimeJob, s.Major
ORDER BY Major;
```
```sql
--Extra Curricular Activities vs Attendance Rate and GPA
SELECT
    s.ExtraCurricularActivities,
    Count(s.StudentID) as Count_Students,
    s.Major,
    Round(Avg(ap.GPA), 2) AS Avg_GPA,
    Round(Avg(ap.AttendanceRate), 2) / 100 AS Avg_Attendance_Rate
FROM Academic_Performance ap
JOIN Students s ON ap.StudentID = s.StudentID
GROUP BY s.ExtraCurricularActivities, s.Major
ORDER BY Major;
```
```sql
--Different Housing Situations vs Attendance Rate and GPA
SELECT
    s.Housing,
    Count(s.StudentID) as Count_Students,
    s.Major,
    Round(Avg(ap.GPA), 2) AS Avg_GPA,
    Round(Avg(ap.AttendanceRate), 2) / 100 AS Avg_Attendance_Rate 
FROM Academic_Performance ap
JOIN Students s ON ap.StudentID = s.StudentID
GROUP BY s.Housing, s.Major
ORDER BY Major;
```
```sql
--Average Attendance Rate and Number of Study Hours per Week for Students With Different GPAs
WITH GPA_Range AS (
SELECT
    ap.StudentID,
    ap.StudyHoursPerWeek,
    ap.AttendanceRate,
    s.Major,
    CASE
      WHEN ap.GPA < 1 THEN '< 1.0'
      WHEN ap.GPA >= 1 AND ap.GPA < 1.5 THEN '1.0 - 1.4'
      WHEN ap.GPA >= 1.5 AND ap.GPA < 2 THEN '1.5 - 1.9'
      WHEN ap.GPA >= 2 AND ap.GPA < 2.5 THEN '2.0 - 2.4'
      WHEN ap.GPA >= 2.5 AND ap.GPA < 3 THEN '2.5 - 2.9'
      WHEN ap.GPA >= 3 AND ap.GPA < 3.5 THEN '3.0 - 3.4'
      WHEN ap.GPA >= 3.5 AND ap.GPA < 4 THEN '3.5 - 3.9'
      ELSE '4.0'
    END AS GPA_Rating
FROM Academic_Performance ap
JOIN Students s ON ap.StudentID = s.StudentID
)

SELECT
    Major,
    GPA_Rating,
    COUNT(StudentID) AS Count_Students,
    ROUND(AVG(AttendanceRate), 2) / 100 AS Avg_AttendanceRate,
    AVG(StudyHoursPerWeek) AS Avg_StudyHoursPerWeek
FROM GPA_Range
GROUP BY Major, GPA_Rating
ORDER BY Major, GPA_Rating;
```
```sql
--GPAs of the Top 10 Students per Major
WITH RankedStudentsTop AS (
SELECT
    s.StudentID,
    Major,
    GPA,
    Row_number() OVER (PARTITION BY Major ORDER BY GPA DESC) AS TopRank
FROM Students s
JOIN Academic_Performance ap ON s.StudentID = ap.StudentID
)

SELECT
    StudentID,
    Major,
    Round(GPA, 2) AS GPA,
    TopRank
FROM RankedStudentstop
WHERE TopRank <= 10;
```
```sql
--GPAs of the Bottom 10 Students per Major
WITH RankedStudentsBottom AS (
SELECT
    s.StudentID,
    Major,
    GPA,
    Row_number() OVER (PARTITION BY Major ORDER BY GPA ASC) AS BottomRank
FROM Students s
JOIN Academic_Performance ap ON s.StudentID = ap.StudentID
)

SELECT
    StudentID,
    Major,
    Round(GPA, 2) AS GPA,
    BottomRank
FROM RankedStudentsBottom
WHERE BottomRank <= 10;
```


# Process of Building the Report

### Steps in Creating the Report:

### 1. **Importing the Data:**  
Imported all of the different SQL queries and both of the CSV files into Power BI. 

### 2. **Connect Tables in Model View:**  
The fact tables in the report consisted of two different CSV files (student data and academic performance metrics).
 > **Note:** One fact table in Power BI is the Students table from the SSMS database while the other is a SQL query that takes the averages of all of the columns that were in the Academic Performance table in SSMS.

Used a STAR schema and established relationships between the SQL query tables and the fact tables.
![Image Alt](https://github.com/cturner0206/student-metrics-dashboard/blob/7abdc93106118661896d2236f31a0baf98cbf2e5/Model.png)

### 3. **Building the Different Visuals and Adding Pages** 

   - Decided to have the main page of the dashboard be more of an overview, while having an additional attendance rate and GPA page that would have additional data. 
   - Created cards, bar charts, tables, and matrices from the SQL queries.
   - Altered the color palette and segmented the visuals using boxes.
   - Applied conditional formatting to improve visual clarity on some visuals. 
   - Created slicers for selecting between majors and for selecting between student performance on the additional GPA page.
   - Created buttons to navigate between the different pages. When on the overview page, clicking on the arrows on the average attendance rate and average GPA by major bar charts swaps to the additional metrics pages respectively. When on the additional pages, you can go back to the overview page by clicking on the back button on the top bar.
   - Added buttons to clear all slicers.




# Findings

## GPA 

- **Business** has the highest average GPA at **3.25**.
- **Engineering** has the lowest average GPA at **2.88**, while **Science** follows closely with an average GPA of **2.96**. This difference is likely due to the challenging nature of these majors.
- **Across all majors**, GPA distribution follows a bell curve, with students in higher GPA ranges reporting higher study hours per week and better attendance rates.
- **Gender** and **financial aid status** do not significantly affect average GPA across all majors.
- **Top-performing Engineering students** (those with a GPA of **3.5+**) report the highest average study hours per week, ranging from **27-30 hours** out of all majors. 

## Attendance Rate 

- **Engineering** students have the highest average attendance rate at **74.1%**.
- **Science** students have the lowest average attendance rate at **70.9%**.
- **Arts**, **Education**, and **Science** majors tend to have a higher average attendance rate for students who receive **financial aid** (1%-3% higher).
- **Education** and **Engineering** majors show higher attendance rates among students who **do not receive financial aid** (1% higher).
- Students who live **on-campus** have the highest average attendance rate at **76.5%**, compared to those who **commute** (71.5%) or live **off-campus** (69.9%).
- Students without a **part-time job** tend to have a higher average attendance rate (75.1%) and a higher average GPA (3.23) compared to those with a **part-time job** whose attendance rate is **70.5%** and average GPA is **2.97**.
- Students who **do not participate in extracurricular activities** have a slightly higher average attendance rate (73.3%) compared to those who do (71.9%). However, both groups have an average GPA of **3.10** across all majors. 
- There is a slight **gender difference** in attendance rates. **Males** generally have a **1%-3%** lower attendance rate across most majors compared to females, except in **Education**, where males have a **2.4% higher** attendance rate.

## Other

- **Science** majors make up only **16%** of the student population, which is notably lower compared to other majors, which range from **19.4% to 22.8%**.


# Recommendations

**Focus on Increasing Study Hours, Especially in Challenging Majors (Engineering, Science)**
- Should encourage students, particularly in challenging majors like Engineering and Science, to increase their weekly study hours as top-performing Engineering students (with a GPA of 3.5+) report the highest study hours, suggesting a positive correlation between study time and GPA.
  
**Address the Impact of Part-Time Jobs on GPA and Attendance**
- Students with part-time jobs tend to have lower attendance rates and GPAs. Offering flexible academic support or altering the workload expectations for these students might alleviate some of the stressors associated with balancing work and school.
  
**Increase On-Campus Living**
- Since students who live on-campus have higher attendance rates and GPAs, the university could encourage more students to live on-campus, provide more on-campus living arrangements, or offer incentives to improve the attendance rates of off-campus or commuter students.
  
**Provide Academic Counseling and Study Skills Resources**
- Given there are many students with lower GPA ranges who have many study hours, offering additional academic counseling on topics like time management and effective studying techniques could improve GPAs for struggling students. 


