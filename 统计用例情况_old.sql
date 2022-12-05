/*
脚本功能：统计接口和场景用例
字段说明：
	 case_type：用例类型   sys_project：系统项目  opertation_time：操作日期
	create_qty：新增用例数  create_qty：更新用例数
*/

SELECT
	'apicase' AS '用例类型',
	CONCAT(p.name,'-',substring_index(substring_index(d.module_path,'/',2),'/',-1)) AS '系统项目',
	f.case_date AS '操作日期', 
    f.create_qty AS '新增用例数',
    f.update_qty AS '更新用例数'
FROM metersphere.project p
JOIN metersphere.api_module m ON p.id=m.project_id
JOIN metersphere.api_definition d ON m.id=d.module_id
JOIN (
	SELECT 
	IFNULL(c.Project_id, u.Project_id) AS Project_id,
	IFNULL(c.api_definition_id, u.api_definition_id) AS api_definition_id,
	IFNULL(c.create_date, u.update_date) AS case_date, 
	IFNULL(c.create_qty, 0) AS create_qty, 
    IFNULL(u.update_qty, 0) AS update_qty
	FROM (
		SELECT Project_id, api_definition_id, FROM_UNIXTIME(create_time/1000, '%Y-%m-%d') AS create_date, COUNT(1) create_qty 
		FROM metersphere.api_test_case
		WHERE status<>'Trash'
		GROUP BY Project_id, api_definition_id, FROM_UNIXTIME(create_time/1000, '%Y-%m-%d')
	) c LEFT JOIN (
		SELECT Project_id, api_definition_id, FROM_UNIXTIME(update_time/1000, '%Y-%m-%d') AS update_date, COUNT(1) update_qty 
		FROM metersphere.api_test_case
		WHERE status<>'Trash'
		GROUP BY Project_id, api_definition_id, FROM_UNIXTIME(update_time/1000, '%Y-%m-%d')
	) u ON c.Project_id=u.Project_id AND c.create_date=u.update_date AND c.api_definition_id=u.api_definition_id

	UNION

	SELECT 
		IFNULL(c.Project_id, u.Project_id) AS Project_id,
		IFNULL(c.api_definition_id, u.api_definition_id) AS api_definition_id,
		IFNULL(c.create_date, u.update_date) AS case_date, 
		IFNULL(c.create_qty, 0) AS create_qty, 
        IFNULL(u.update_qty, 0) AS update_qty
	FROM (
		SELECT Project_id, api_definition_id, FROM_UNIXTIME(create_time/1000, '%Y-%m-%d') AS create_date, COUNT(1) create_qty 
		FROM metersphere.api_test_case
		WHERE status<>'Trash'
		GROUP BY Project_id, api_definition_id, FROM_UNIXTIME(create_time/1000, '%Y-%m-%d')
	) c RIGHT JOIN (
		SELECT Project_id, api_definition_id, FROM_UNIXTIME(update_time/1000, '%Y-%m-%d') AS update_date, COUNT(1) update_qty 
		FROM metersphere.api_test_case
		WHERE status<>'Trash'
		GROUP BY Project_id, api_definition_id, FROM_UNIXTIME(update_time/1000, '%Y-%m-%d')
	) u ON c.Project_id=u.Project_id AND c.create_date=u.update_date AND c.api_definition_id=u.api_definition_id
) f ON d.id=f.api_definition_id WHERE d.module_path NOT LIKE '%未规划%'

UNION ALL

SELECT
	'scenariocase' AS '用例类型',
	CONCAT(p.name,'-',substring_index(substring_index(f.module_path,'/',2),'/',-1)) AS '业务系统-项目',
	f.case_date AS '操作日期', 
    f.create_qty AS '新增用例数',
    f.update_qty AS '更新用例数'
FROM metersphere.project p 
JOIN metersphere.api_scenario_module m ON p.id=m.project_id
JOIN (
	SELECT 
	IFNULL(c.project_id, u.project_id) AS Project_id,
	IFNULL(c.api_scenario_module_id, u.api_scenario_module_id) AS api_scenario_module_id,
	IFNULL(c.create_date, u.update_date) AS case_date, 
	IFNULL(c.create_qty, 0) AS create_qty, IFNULL(u.update_qty, 0) AS update_qty,
    IFNULL(c.module_path, u.module_path) AS module_path
	FROM (
		SELECT project_id, api_scenario_module_id, module_path, FROM_UNIXTIME(create_time/1000, '%Y-%m-%d') AS create_date, COUNT(1) create_qty 
		FROM metersphere.api_scenario
		WHERE status<>'Trash'
		GROUP BY project_id, api_scenario_module_id, module_path, FROM_UNIXTIME(create_time/1000, '%Y-%m-%d')
	) c LEFT JOIN (
		SELECT project_id, api_scenario_module_id, module_path, FROM_UNIXTIME(update_time/1000, '%Y-%m-%d') AS update_date, COUNT(1) update_qty 
		FROM metersphere.api_scenario
		WHERE status<>'Trash'
		GROUP BY project_id, api_scenario_module_id, module_path, FROM_UNIXTIME(update_time/1000, '%Y-%m-%d')
	) u ON c.project_id=u.project_id AND c.create_date=u.update_date AND c.api_scenario_module_id=u.api_scenario_module_id AND c.module_path=u.module_path

	UNION

	SELECT 
		IFNULL(c.project_id, u.project_id) AS project_id,
		IFNULL(c.api_scenario_module_id, u.api_scenario_module_id) AS api_definition_id,
		IFNULL(c.create_date, u.update_date) AS case_date, 
		IFNULL(c.create_qty, 0) AS create_qty, 
        IFNULL(u.update_qty, 0) AS update_qty,
        IFNULL(c.module_path, u.module_path) AS module_path
	FROM (
		SELECT project_id, api_scenario_module_id, module_path, FROM_UNIXTIME(create_time/1000, '%Y-%m-%d') AS create_date, COUNT(1) create_qty 
		FROM metersphere.api_scenario
		WHERE status<>'Trash'
		GROUP BY project_id, api_scenario_module_id, module_path, FROM_UNIXTIME(create_time/1000, '%Y-%m-%d')
	) c RIGHT JOIN (
		SELECT project_id, api_scenario_module_id, module_path, FROM_UNIXTIME(update_time/1000, '%Y-%m-%d') AS update_date, COUNT(1) update_qty 
		FROM metersphere.api_scenario
		WHERE status<>'Trash'
		GROUP BY project_id, api_scenario_module_id, module_path, FROM_UNIXTIME(update_time/1000, '%Y-%m-%d')
	) u ON c.project_id=u.project_id AND c.create_date=u.update_date AND c.api_scenario_module_id=u.api_scenario_module_id AND c.module_path=u.module_path
) f ON m.id=f.api_scenario_module_id WHERE f.module_path NOT LIKE '%未规划%'
