-- Employee & Project Analytics Portfolio Project

-- 1. Employees with their department names
SELECT e.emp_id, e.emp_name, d.dept_name, e.salary
FROM employees AS e
INNER JOIN departments AS d
    ON e.dept_id = d.dept_id
ORDER BY d.dept_name, e.emp_name;

-- 2. Department headcount and salary analysis
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    SUM(e.salary) AS total_salary,
    AVG(e.salary) AS average_salary
FROM departments AS d
LEFT JOIN employees AS e
    ON e.dept_id = d.dept_id
GROUP BY d.dept_name
ORDER BY total_salary DESC;

-- 3. Employees assigned to each project
SELECT
    p.project_name,
    COUNT(ep.emp_id) AS assigned_employee_count
FROM projects AS p
LEFT JOIN employee_projects AS ep
    ON p.project_id = ep.project_id
GROUP BY p.project_name
ORDER BY assigned_employee_count DESC, p.project_name;

-- 4. Employees earning above their department average
SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name,
    e.salary
FROM employees AS e
INNER JOIN departments AS d
    ON e.dept_id = d.dept_id
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees AS e2
    WHERE e2.dept_id = e.dept_id
)
ORDER BY d.dept_name, e.salary DESC;

-- 5. Department with the highest total salary
WITH department_totals AS (
    SELECT
        d.dept_name,
        COUNT(e.emp_id) AS employee_count,
        SUM(e.salary) AS total_salary
    FROM employees AS e
    INNER JOIN departments AS d
        ON e.dept_id = d.dept_id
    GROUP BY d.dept_name
),
ranked_departments AS (
    SELECT
        dept_name,
        employee_count,
        total_salary,
        DENSE_RANK() OVER (ORDER BY total_salary DESC) AS salary_rank
    FROM department_totals
)
SELECT dept_name, employee_count, total_salary
FROM ranked_departments
WHERE salary_rank = 1;

-- 6. Highest-paid employee in each department
WITH ranked_employees AS (
    SELECT
        d.dept_name,
        e.emp_name,
        e.salary,
        DENSE_RANK() OVER (
            PARTITION BY e.dept_id
            ORDER BY e.salary DESC
        ) AS salary_rank
    FROM employees AS e
    INNER JOIN departments AS d
        ON e.dept_id = d.dept_id
)
SELECT dept_name, emp_name, salary
FROM ranked_employees
WHERE salary_rank = 1
ORDER BY dept_name, emp_name;

-- 7. Employees not assigned to any project
SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name
FROM employees AS e
INNER JOIN departments AS d
    ON e.dept_id = d.dept_id
LEFT JOIN employee_projects AS ep
    ON e.emp_id = ep.emp_id
WHERE ep.emp_id IS NULL
ORDER BY e.emp_name;s