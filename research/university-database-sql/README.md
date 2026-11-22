# University Department Database — SQL & Data Modelling

**Principles of Computing (IS4S761) | MSc Data Science coursework | 2025**

An academic project covering **relational database design**, **primary and foreign keys**, **many-to-many relationships**, **referential integrity**, and **SQL reporting**. Adapted from my coursework submission for a fictional university computing department.

## What I built
Six related tables: Courses, Tutors, Modules, Students, Course_Module and Enrolment, with composite keys and an optional-module CHECK constraint. The database models courses, student enrolments, tutor assignments and student grades. Five reporting queries answer business questions about course sizes, module performance, teaching workload, shared modules and unfilled optional modules.

## ER diagram

```mermaid
erDiagram
    COURSES ||--o{ STUDENTS : "has"
    COURSES ||--o{ COURSE_MODULE : "offers"
    MODULES ||--o{ COURSE_MODULE : "included in"
    TUTORS ||--o{ MODULES : "teaches"
    STUDENTS ||--o{ ENROLMENT : "takes"
    MODULES ||--o{ ENROLMENT : "enrolments"
```

## Run the project

Python 3.10+ is enough: **no database server or external packages** are required.

From the portfolio repository root:

```bash
python3 research/university-database-sql/run_queries.py
python3 -m unittest discover -s research/university-database-sql/tests -v
```

Or, if this project was downloaded separately, run `python3 run_queries.py` and `python3 -m unittest discover -s tests -v` from this folder.

## Files

- `sql/01_schema.sql` — schema, keys and integrity constraints
- `sql/02_seed.sql` — anonymised, fictional sample records
- `sql/03_analysis_queries.sql` — five analytical queries extracted from the coursework
- `run_queries.py` — runnable SQLite demonstration
- `tests/test_database.py` — automated checks of key constraints and selected results
- `sample_results.json` — sample query output

## Selected outputs
- **Computer Science:** 4 enrolled students; Cyber Security and ICT: 3 each.
- **Database Systems:** 10 enrolled, 9 graded; average mark approximately **64.78**.
- **Big Data Analytics (BDA707):** optional module with no enrolments.

## Technical provenance
The coursework report originally used Oracle SQL, including `VARCHAR2`, `NUMBER` and `TO_DATE`. The SQL files in this repository are **adapted for SQLite portability**, not a claim that SQLite was used during the original assignment. All sample staff and student names, email addresses and identifying student numbers were replaced. The Python runner, automated tests and README were added during portfolio preparation.

University lecture slides, instructor solutions and the original assessment brief have **not** been published. This is a teaching case study, not a real university database.
