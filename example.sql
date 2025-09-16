SELECT 
    department
    , COUNT(*) as employee_count
    , AVG(salary) as avg_salary
    , MAX(salary) as max_salary
FROM 'example_data/example.csv'
GROUP BY department
ORDER BY avg_salary DESC;
