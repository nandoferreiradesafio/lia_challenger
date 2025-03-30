with
	students as (
		select
			id as pk_student
			, course_id as fk_course
			, name as name_student
			, enrolled_at
		from students
	)

	, courses as (
		select
			id as pk_course
			, school_id as fk_school
			, name as name_course
			, price as price_course
		from courses
	)

	, schools as (
		select
			id as pk_school
			, name as name_school
		from schools
	)

	, general_join as (
		select
			students.pk_student
			, courses.pk_course
			, schools.pk_school
			, students.name_student
			, courses.name_course
			, schools.name_school
			, courses.price_course
			, students.enrolled_at
		from students
		left join courses
			on courses.pk_course = students.fk_course
		left join schools
			on schools.pk_school = courses.fk_school	
	)

select
	name_school
	, enrolled_at
	, count(*) as qtd_total_alunos
	, sum(price_course) as vlr_total_matriculas
from general_join
where name_school ilike "data%"
group by name_school, enrolled_at
order by enrolled_at desc