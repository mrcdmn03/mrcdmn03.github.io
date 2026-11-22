-- Analytical queries from the author's IS4S761 submitted coursework.

-- Query 1: Student enrolment by course
SELECT C.Course_ID,
       C.Course_Name,
       COUNT(S.Student_ID) AS NoOfStudents
FROM Courses C, Students S
WHERE S.Course_ID = C.Course_ID
GROUP BY C.Course_ID, C.Course_Name
ORDER BY NoOfStudents DESC;

-- Query 2: Participation and performance in modules with three or more students
SELECT M.Module_Code,
       M.Module_Title,
       COUNT(E.Student_ID) AS NumStudents,
       AVG(E.Mark) AS AvgMark
FROM Modules M, Enrolment E
WHERE E.Module_ID = M.Module_ID
GROUP BY M.Module_Code, M.Module_Title
HAVING COUNT(E.Student_ID) >= 3
ORDER BY AvgMark DESC;

-- Query 3: Tutor workload and average student grades
SELECT T.Tutor_Name,
       COUNT(DISTINCT M.Module_ID) AS ModulesTaught,
       AVG(E.Mark) AS AvgMarkAcrossModules
FROM Tutors T, Modules M, Enrolment E
WHERE M.Tutor_ID = T.Tutor_ID
  AND E.Module_ID = M.Module_ID
GROUP BY T.Tutor_Name
ORDER BY AvgMarkAcrossModules DESC;

-- Query 4: Modules shared by two or more courses
SELECT M.Module_Code,
       M.Module_Title,
       COUNT(DISTINCT CM.Course_ID) AS NumCourses
FROM Modules M, Course_Module CM
WHERE CM.Module_ID = M.Module_ID
GROUP BY M.Module_Code, M.Module_Title
HAVING COUNT(DISTINCT CM.Course_ID) >= 2
ORDER BY NumCourses DESC, M.Module_Code;

-- Query 5: Optional modules without any enrolled students
SELECT M.Module_Code,
       M.Module_Title
FROM Modules M
WHERE M.Is_Optional = 1
  AND M.Module_ID NOT IN (SELECT DISTINCT Module_ID FROM Enrolment);
