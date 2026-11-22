-- SQLite adaptation of Mirac Duman's IS4S761 university database coursework.
-- All demonstration records are fictional.
CREATE TABLE Courses (
 Course_ID TEXT NOT NULL,
 Course_Name TEXT NOT NULL,
 Level TEXT NOT NULL,
 Start_Date TEXT NOT NULL,
 Duration_Months INTEGER NOT NULL,
 CONSTRAINT Courses_CourseID_pk PRIMARY KEY(Course_ID)
);
CREATE TABLE Tutors (
 Tutor_ID TEXT NOT NULL,
 Tutor_Name TEXT NOT NULL,
 Email TEXT NOT NULL,
 Hire_Date TEXT NOT NULL,
 Salary INTEGER NOT NULL,
 CONSTRAINT Tutors_TutorID_pk PRIMARY KEY(Tutor_ID)
);
CREATE TABLE Modules (
 Module_ID TEXT NOT NULL,
 Module_Code TEXT NOT NULL,
 Module_Title TEXT NOT NULL,
 Credits INTEGER NOT NULL,
 Term TEXT NOT NULL,
 Is_Optional INTEGER NOT NULL,
 Tutor_ID TEXT NOT NULL,
 CONSTRAINT Modules_ModuleID_pk PRIMARY KEY(Module_ID),
 CONSTRAINT Modules_TutorID_fk FOREIGN KEY(Tutor_ID) REFERENCES Tutors(Tutor_ID),
 CONSTRAINT Modules_IsOptional_ck CHECK (Is_Optional IN(0,1))
);
CREATE TABLE Students (
 Student_ID TEXT NOT NULL,
 Student_No TEXT NOT NULL,
 First_Name TEXT NOT NULL,
 Last_Name TEXT NOT NULL,
 Enrol_Year INTEGER NOT NULL,
 Fee_Status TEXT NOT NULL,
 Course_ID TEXT NOT NULL,
 CONSTRAINT Students_StudentID_pk PRIMARY KEY(Student_ID),
 CONSTRAINT Students_CourseID_fk FOREIGN KEY(Course_ID) REFERENCES Courses(Course_ID)
);
CREATE TABLE Course_Module (
 Course_ID TEXT NOT NULL,
 Module_ID TEXT NOT NULL,
 CONSTRAINT CourseModule_pk PRIMARY KEY(Course_ID,Module_ID),
 CONSTRAINT CourseModule_CourseID_fk FOREIGN KEY(Course_ID) REFERENCES Courses(Course_ID),
 CONSTRAINT CourseModule_ModuleID_fk FOREIGN KEY(Module_ID) REFERENCES Modules(Module_ID)
);
CREATE TABLE Enrolment (
 Student_ID TEXT NOT NULL,
 Module_ID TEXT NOT NULL,
 Mark INTEGER,
 Grade TEXT,
 CONSTRAINT Enrolment_pk PRIMARY KEY(Student_ID,Module_ID),
 CONSTRAINT Enrolment_StudentID_fk FOREIGN KEY(Student_ID) REFERENCES Students(Student_ID),
 CONSTRAINT Enrolment_ModuleID_fk FOREIGN KEY(Module_ID) REFERENCES Modules(Module_ID)
);
