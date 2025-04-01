--Count and Percent of Total Students by Major
SELECT 
	Major,
	Count(StudentID) AS Count_Students,
	Round(Cast(Count(*) * 100.0 / (SELECT Count(*) FROM Students) AS FLOAT), 2) AS Percent_of_Total_Students
FROM Students
GROUP BY Major
ORDER BY Percent_of_Total_Students DESC;


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


--Which Students Are Performing Well or Could Use Some Improvement (Is GPA greater than 3.0?)
SELECT 
	s.StudentID,
	Major,
	Round(GPA, 2) AS GPA,
	StudyHoursPerWeek,
	iif(GPA > 3.0, 'Performing Well', 'Needs Improvement') AS PerformanceCategory
FROM Students s
JOIN Academic_Performance ap ON s.StudentID = ap.StudentId;


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


--Average Attendance Rate and Number of Study Hours per Week for Students With Different GPA's
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


--GPA's of the Top 10 Students per Major
WITH RankedStudentsTop AS (
	SELECT 
		s.StudentID,
        Major,
        GPA,
        Row_number() OVER (PARTITION BY Major ORDER BY GPA DESC) AS TopRank
    FROM Students s
	JOIN Academic_Performance ap ON s.StudentID = ap.StudentID)

SELECT 
	StudentID,
	Major,
	Round(GPA, 2) AS GPA,
	TopRank
FROM RankedStudentstop
WHERE TopRank <= 10;


--GPA's of the Bottom 10 Students per Major
WITH RankedStudentsBottom AS (
	SELECT 
		s.StudentID,
        Major,
        GPA,
        Row_number() OVER (PARTITION BY Major ORDER BY GPA ASC) AS BottomRank
    FROM Students s
	JOIN Academic_Performance ap ON s.StudentID = ap.StudentID)

SELECT 
	StudentID,
    Major,
    Round(GPA, 2) AS GPA,
    BottomRank
FROM RankedStudentsBottom
WHERE BottomRank <= 10;