/*
脚本功能：统计接口自动化实现情况，如下内容：
	1）接口总数
	2）需实现数
	3）接口用例接口覆盖数
字段说明：
	sys_pro：系统项目   pro_module：项目模块
       api_tags：接口模块     api_name：接口名称  api_method：接口方法  api_path：接口地址  api_status：接口状态
	autoQty：需实现数      hasCase：以实现数      apiQty：接口总数
*/

/*查询接口用例中接口覆盖数，已经统计接口总数和需实现数*/

SELECT
	CONCAT(p.name,'-',substring_index(substring_index(d.module_path,'/',2),'/',-1)) AS '系统项目',
	substring_index(substring_index(d.module_path,'/',-2),'/',1) AS '项目模块',
    m.name AS '接口模块',
    d.name AS '接口名称',
	d.method AS '接口方法',
	d.path AS '接口地址',
    
    CASE WHEN IFNULL(e.request_url, f.request_url)!='' OR d.tags='["AT"]' THEN 
		CASE WHEN d.status='Prepare' THEN '未开始' 
			 WHEN d.status='Underway' THEN '进行中' 
             WHEN d.status='Completed' THEN '已完成' 
		END ELSE '-' 
	END AS '接口状态',
	CASE WHEN d.tags='["AT"]' THEN 1 ELSE 0 END AS '需实现数',
	CASE WHEN (e.caseQty>0 OR f.caseQty>0) AND d.status='Completed' THEN 1 ELSE 0 END AS '已实现数', 
	1 AS '接口总数'
FROM metersphere.project p
JOIN metersphere.api_module m ON p.id=m.project_id
JOIN metersphere.api_definition d ON m.id=d.module_id
LEFT JOIN (
	SELECT 
		api_definition_id, 
        COUNT(1) caseQty,
        FROM_UNIXTIME(create_time/1000, '%Y-%m-%d'),
        REPLACE(JSON_EXTRACT(c.request, '$.method'),'"','') AS request_method,
		REPLACE(REPLACE(JSON_EXTRACT(c.request, '$.path'),'"',''),'//','/') AS request_url
	FROM metersphere.api_test_case c
	WHERE c.status<>'Trash' 
	GROUP BY api_definition_id
) e ON e.api_definition_id=d.id
LEFT JOIN (
	/*查询场景用例中接口覆盖数*/
	SELECT DISTINCT
		substring_index(substring_index(replace(JSON_EXTRACT(CONCAT(url,'}'),'$.url'),'"',''),'/',3),'/',-1) AS module,
		replace(JSON_EXTRACT(CONCAT(url,'}'),'$.method'),'"','') AS request_method,
		replace(replace(JSON_EXTRACT(CONCAT(url,'}'),'$.url'),'"',''),' ','') AS request_url,
		1 caseQty
	FROM(
		SELECT
			p.name AS systemcode,
			substring_index(substring_index(s.module_path,'/',2),'/',-1) AS project,
			replace(replace(replace(substring_index(substring_index(s.use_url,'},',t.help_topic_id+1),'},',-1),'[',''),'}]',''),'//','/') AS url
		FROM metersphere.project p 
		JOIN metersphere.api_scenario_module m ON p.id=m.project_id
		JOIN metersphere.api_scenario s ON m.id=s.api_scenario_module_id
		JOIN mysql.help_topic t ON t.help_topic_id < (length(s.use_url) - length(replace(s.use_url,'},','}'))+1)
		WHERE s.status<>'Trash'	AND s.use_url<>'[]'
	)u
) f ON d.path=f.request_url AND d.method=f.request_method
WHERE d.status<>'Trash' 
  AND d.module_path NOT LIKE '%未规划%'
