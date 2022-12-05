/*查询不在页面展示的测试计划*/
SELECT test_plan_id 
FROM metersphere.test_plan_principal 
WHERE principal_id='xlgao' AND test_plan_id NOT IN(
	SELECT id 
    FROM metersphere.test_plan 
	WHERE project_id IN('ef66fd2d-0649-4c08-a191-65d45c7438bf','4ea57f8e-6a9f-4a4d-8434-cc4c18b846ba','736d22f3-bdd2-4de5-9c6d-879d9928477c','ab767e1c-5e98-4ab7-9d76-51f88d05e8a6')
);

SELECT * 
FROM metersphere.test_plan_api_scenario 
WHERE test_plan_id='fbcc5991-2303-48e0-a868-0dfc0741aa61';

SELECT * FROM metersphere.test_plan_api_case
WHERE test_plan_id='88667644-209a-4ade-8f9a-5ca72c65739c';

SELECT * FROM metersphere.test_plan_report
WHERE test_plan_id='0225d7ce-1763-41c9-8a33-c3a7cfcfb712';


DELETE FROM metersphere.test_plan_api_scenario 
WHERE test_plan_id IN(
	SELECT test_plan_id 
	FROM metersphere.test_plan_principal 
	WHERE principal_id='xlgao' AND test_plan_id NOT IN(
		SELECT id 
		FROM metersphere.test_plan 
		WHERE project_id IN('ef66fd2d-0649-4c08-a191-65d45c7438bf','4ea57f8e-6a9f-4a4d-8434-cc4c18b846ba','736d22f3-bdd2-4de5-9c6d-879d9928477c','ab767e1c-5e98-4ab7-9d76-51f88d05e8a6')
));
DELETE FROM metersphere.test_plan_api_case WHERE test_plan_id='88667644-209a-4ade-8f9a-5ca72c65739c';
DELETE FROM metersphere.test_plan_principal WHERE test_plan_id='fbcc5991-2303-48e0-a868-0dfc0741aa61';

/*删除操作日志*/
CREATE TABLE `operating_log_tmp`
AS SELECT * FROM metersphere.operating_log 
WHERE FROM_UNIXTIME(oper_time/1000, '%Y-%m-%d') > DATE_ADD(CURRENT_DATE(), INTERVAL -7 DAY);

ALTER  TABLE `operating_log` RENAME TO `operating_log_old`;
ALTER  TABLE `operating_log_tmp` RENAME TO `operating_log`;


ALTER  TABLE `operating_log` ADD PRIMARY KEY (`id`);
ALTER  TABLE `operating_log` ADD INDEX oper_module_index (`oper_module`);
ALTER  TABLE `operating_log` ADD INDEX oper_time_index (`oper_time`);


DROP TABLE `operating_log_old`