/*
脚本功能：统计接口和场景用例总数
字段说明：
	 case_type：用例类型   sys_project：系统项目  total_qty：用例总数
*/

SELECT
	'apicase' AS '用例类型',
	CONCAT(p.name,'-',substring_index(substring_index(d.module_path,'/',2),'/',-1)) AS '系统项目',
    f.total_qty AS '用例总数'
FROM metersphere.project p
JOIN metersphere.api_module m ON p.id=m.project_id
JOIN metersphere.api_definition d ON m.id=d.module_id
JOIN (
	/*查询接口用例总数*/
    SELECT Project_id, api_definition_id, COUNT(1) total_qty
	FROM metersphere.api_test_case
	WHERE status<>'Trash'
	GROUP BY Project_id, api_definition_id
) f ON d.id=f.api_definition_id WHERE d.module_path NOT LIKE '%未规划%'

UNION ALL

SELECT
	'scenariocase' AS '用例类型',
	CONCAT(p.name,'-',substring_index(substring_index(f.module_path,'/',2),'/',-1)) AS '系统项目',
    f.total_qty AS '用例总数'
FROM metersphere.project p 
JOIN metersphere.api_scenario_module m ON p.id=m.project_id
JOIN (
	/*查询场景用例总数*/
    SELECT project_id, api_scenario_module_id, module_path, COUNT(1) total_qty 
	FROM metersphere.api_scenario
	WHERE status<>'Trash'
	GROUP BY project_id, api_scenario_module_id, module_path 
) f ON m.id=f.api_scenario_module_id WHERE f.module_path NOT LIKE '%未规划%'
