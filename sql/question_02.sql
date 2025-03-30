with
	departamento as (
		select
			cod_dep as pk_departamento
			, nome as nome_departamento
			, endereco as endereco_departamento
		from departamento
	)

	, dependente as (
		select
			matr as fk_dependente
			, nome
			, endereco
		from dependente
	)

	, desconto as (
		select
			cod_desc as pk_desconto
			, nome as nome_desconto
			, tipo as tipo_desconto
			, valor as valor_desconto
		from desconto
	)

	, emp_desc as (
		select
			cod_desc as fk_desconto
			, matr as fk_matr
		from emp_desc
	)

	, join_desc as (
		select
			desconto.pk_desconto
			, emp_desc.fk_matr
			, desconto.nome_desconto 
			, desconto.tipo_desconto 
			, desconto.valor_desconto
		from desconto
		left join emp_desc
			on emp_desc.fk_desconto = desconto.pk_desconto
	)

	, divisao as (
		select
			cod_divisao as pk_divisao
			, cod_dep as fk_departamento
			, nome as nome_divisao
			, endereco as endereco_divisao
		from divisao
	)

	, vencimento as (
		select
			cod_venc as pk_vencimento
			, nome as nome_vencimento
			, tipo as tipo_vencimento
			, valor as valor_vencimento
		from vencimento
	)

	, emp_venc as (
		select
			cod_venc as fk_vencimento
			, matr as fk_matr
		from emp_venc
	)

	, join_venc as (
		select
			vencimento.pk_vencimento
			, emp_venc.fk_matr
			, vencimento.nome_vencimento
			, vencimento.tipo_vencimento
			, vencimento.valor_vencimento
		from vencimento
		left join emp_venc
			on emp_venc.fk_vencimento = vencimento.pk_vencimento
	)

	, join_general_divisao as (
		select
			divisao.pk_divisao
			, departamento.pk_departamento
			, divisao.nome_divisao
			, departamento.nome_departamento
			, departamento.endereco_departamento
		from divisao
		left join departamento
			on departamento.pk_departamento = divisao.fk_departamento
	)

	, empregado as (
		select
			matr as pk_matr
			, lotacao_div as fk_divisao
			, gerencia_div
			, gerencia_cod_dep
			, nome as nome_funcionario
			, endereco
			, lotacao
			, data_lotacao
		from empregado
	)

	, data_transformation as (
		select
			e.pk_matr
			, jd.pk_desconto
			, jv.pk_vencimento
			, jgd.pk_divisao
			, jgd.pk_departamento
			, e.nome_funcionario
			, e.endereco
			, e.lotacao
			, jd.nome_desconto
			, jd.tipo_desconto
			, coalesce(jd.valor_desconto, 0) as valor_desconto
			, jv.nome_vencimento
			, jv.tipo_vencimento
			, jv.valor_vencimento
			, jgd.nome_divisao
			, jgd.nome_departamento
			, e.data_lotacao
		from empregado e
		left join join_desc jd
			on jd.fk_matr = e.pk_matr
		left join join_venc jv
			on jv.fk_matr = e.pk_matr
		left join join_general_divisao jgd
			on jgd.pk_divisao = e.fk_divisao
	)

	, salarios_pro_funcionario as (
		select
			pk_matr
			, pk_departamento
			, nome_departamento
			, sum(valor_vencimento) as total_salario_liquido
			, sum(valor_desconto) as total_descontos
			, sum(valor_vencimento - valor_desconto) as total_salario_bruto
		from data_transformation
		group by pk_matr, pk_departamento, nome_departamento
	)

	, aggregation_data as (
		select
			nome_departamento
			, count(*) qtd_funcionarios
			, round(avg(total_salario_liquido),2) as media_salarial
			, max(total_salario_liquido) as maior_salario
			, min(total_salario_liquido) as menor_salario
		from salarios_pro_funcionario
		group by nome_departamento
	)

select *
from aggregation_data
order by media_salarial desc;