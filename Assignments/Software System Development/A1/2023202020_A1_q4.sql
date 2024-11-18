create table UpdatedEmpSkills (
emp_no int, 
curr_salary int, 
increment float, 
new_salary int, 
skill_level varchar(100)
);
select * from Employee;
select * from UpdatedEmpSkills;

create table UpdatedEmpSkills (
emp_no int, 
curr_salary int, 
increment float, 
new_salary float, 
skill_level varchar(100)
);

DELIMITER //
create procedure emp() 
begin 
declare emp_no_p int;
declare curr_sal_p int;
declare new_sal_p float;  
declare certificate_count int;
declare course_count int;
declare inc float;
declare skill_level_p varchar(100);
declare done int default 0; 

declare cursor_emp cursor for select emp_no, emp_salary FROM Employee WHERE emp_joining_date <= '2022-07-31';

declare continue handler for not found set done = 1;

open cursor_emp;
read_loop: loop
fetch cursor_emp into emp_no_p, curr_sal_p;
if done then
leave read_loop;
end if;

select count(course_id) into course_count from CourseCompletions where emp_no = emp_no_p;
select count(cert_id) into certificate_count from CertificateCompletions where emp_no = emp_no_p;

if course_count >= 10 and certificate_count >= 8 then set skill_level_p = 'Expert';
elseif course_count >= 6 and certificate_count >= 6 then set skill_level_p = 'Advanced';
elseif course_count >= 4 and certificate_count >= 4 then set skill_level_p = 'Intermediate';
elseif course_count >= 2 and certificate_count >= 2 then set skill_level_p = 'Beginner';
else set skill_level_p = NULL;
end if;

if skill_level_p = 'Expert' then set inc = 0.25;
elseif skill_level_p = 'Advanced' then set inc = 0.20;
elseif skill_level_p = 'Intermediate' then set inc = 0.15;
elseif skill_level_p = 'Beginner' then set inc = 0.10;
else set inc = 0;  -- Changed from v_increment_percent to inc
end if;

set new_sal_p = curr_sal_p * (1 + inc);

if skill_level_p is not null then
insert into UpdatedEmpSkills (emp_no, curr_salary, increment, new_salary, skill_level) values (emp_no_p, curr_sal_p,  curr_sal_p*inc, new_sal_p, skill_level_p);
end if;
end loop;
close cursor_emp;
end //
DELIMITER ;

CALL UpdateEmployeeSkills();

SELECT * FROM UpdatedEmpSkills;
