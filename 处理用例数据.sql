/*
	脚本功能：根据用例request中的method和path，更新用例所属项目和接口定义
*/
CREATE TEMPORARY TABLE test_case AS
(
	SELECT Id,
	REPLACE(JSON_EXTRACT(c.request, '$.method'),'"','') AS method,
	REPLACE(JSON_EXTRACT(c.request, '$.path'),'"','') AS path 
	FROM metersphere.api_test_case c
);
UPDATE test_case AS a 
	INNER JOIN metersphere.api_test_case AS c ON a.Id=c.`id`
	LEFT JOIN metersphere.api_definition AS d ON a.method=d.method AND a.path=d.path AND d.`status`<>'Trash'
SET c.`project_id`=d.`project_id`, c.`api_definition_id`=d.`id`
WHERE a.Path!='/cgp/mail-offline-api/mail/send';

SELECT c.* 
FROM test_case AS a INNER JOIN metersphere.api_test_case AS c ON a.Id=c.`id`
LEFT JOIN metersphere.api_definition AS d ON a.method=d.method AND a.path=d.path AND d.`status`<>'Trash'
WHERE a.Path!='/cgp/mail-offline-api/mail/send';

/*
更新請求JSON中的字段值
*/
SELECT *
FROM metersphere.api_test_case c
WHERE c.status<>'Trash' 
  AND c.api_definition_id<>'' 
  AND c.name LIKE'%獲取優惠券活動列表%';

UPDATE metersphere.api_test_case c 
SET request = json_set(request,'$.path', '/cgp/market-online-api/coupon-activities/query') 
WHERE c.status<>'Trash' 
  AND c.api_definition_id<>'' 
  AND c.name LIKE'%獲取優惠券活動列表%';
  
/*
更新project_id和api_definition_id
*/
SELECT * FROM metersphere.api_definition 
WHERE path='/cgp/market-online-api/coupon-activities/query';

SELECT *
FROM metersphere.api_test_case c
WHERE c.status<>'Trash' AND c.api_definition_id='' AND c.name LIKE'%獲取優惠券活動列表%';

UPDATE metersphere.api_test_case c 
SET project_id='4ea57f8e-6a9f-4a4d-8434-cc4c18b846ba',api_definition_id='2e2e8c09-c720-4ed2-8d69-ac1da9a8255b' 
WHERE c.status<>'Trash' AND c.api_definition_id='' AND c.name LIKE'%獲取優惠券活動列表%';