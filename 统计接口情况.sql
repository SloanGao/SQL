/*
脚本功能：统计接口自动化实现情况，如下内容：
	1）接口总数
	2）需实现数
	3）接口用例接口覆盖数
字段说明：
		sys_pro：系统项目   pro_module：项目模块   api_tags：接口模块     
	   api_name：接口名称   api_method：接口方法   api_path：接口地址  
	 api_status：接口状态      autoQty：需实现数    hasCase：以实现数
         apiQty：接口总数
*/

/*查询接口用例中接口覆盖数，已经统计接口总数和需实现数*/

SELECT
	CONCAT(p.name,'-',substring_index(substring_index(d.module_path,'/',2),'/',-1)) AS '系统项目',
	substring_index(substring_index(d.module_path,'/',-2),'/',1) AS '项目模块',
    m.name AS '接口模块',
    d.name AS '接口名称',
	d.method AS '接口方法',
	d.path AS '接口地址',
    CASE WHEN d.tags='["AT"]' THEN 
		CASE WHEN d.status='Prepare' THEN '未开始' 
			 WHEN d.status='Underway' THEN '进行中' 
             WHEN d.status='Completed' THEN '已完成' 
		END ELSE '-' 
	END AS '接口状态',
	CASE WHEN d.tags='["AT"]' THEN 1 ELSE 0 END AS '需实现数',
	CASE WHEN d.status='Completed' THEN 1 ELSE 0 END AS '已实现数', 
	1 AS '接口总数',
    FROM_UNIXTIME(d.create_time/1000, '%Y-%m-%d') AS '创建日期',
    FROM_UNIXTIME(d.update_time/1000, '%Y-%m-%d') AS '更新日期'
FROM metersphere.project p
JOIN metersphere.api_module m ON p.id=m.project_id
JOIN metersphere.api_definition d ON m.id=d.module_id
WHERE d.status<>'Trash' AND d.module_path NOT LIKE '%未规划%'
