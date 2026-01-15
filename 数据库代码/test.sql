-- ----------------------------
-- Unit test
-- ----------------------------

-- 表结构验证
-- 1.1 验证dispatcher表主键、字段类型
SELECT 
  COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_KEY 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'zhangsan' AND TABLE_NAME = 'dispatcher';

-- 1.2 验证外键约束（如wuliu表关联oorder表）
SELECT 
  CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME 
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'zhangsan' AND TABLE_NAME = 'wuliu' AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 1.3 验证索引（oorder表的create_time索引）
SHOW INDEX FROM zhangsan.oorder WHERE Key_name = 'create_time';


-- 触发器单元测试
-- 2.1 测试order_insert触发器（插入订单后orderway.count自增）
-- 第一步：记录初始人工订餐数量
SELECT count INTO @init_count FROM orderway WHERE orderway_name = '人工订餐';
-- 第二步：插入测试订单
INSERT INTO oorder (shop_name, order_money, order_way, cons_phone, cons_name, cons_addre, checked, create_time)
VALUES ('大美鸡公煲', 15, '人工订餐', '13800000000', '测试用户', '测试地址', 0, NOW());
-- 第三步：验证count是否+1
SELECT count, IF(count = @init_count + 1, '触发器生效', '触发器失效') AS test_result 
FROM orderway WHERE orderway_name = '人工订餐';
-- 第四步：清理测试数据
DELETE FROM oorder WHERE cons_name = '测试用户';

-- 2.2 测试order_delete_sale触发器（删除订单后店铺销量-1）
-- 第一步：记录小美烤盘饭初始销量
SELECT m_sale_v INTO @init_sale FROM fastfood_shop WHERE shop_name = '小美烤盘饭';
-- 第二步：插入测试订单（关联该店铺）
INSERT INTO oorder (shop_name, order_money, order_way, cons_phone, cons_name, cons_addre, checked, create_time)
VALUES ('小美烤盘饭', 12, '网上订餐', '13800000000', '测试用户', '测试地址', 0, NOW());
-- 第三步：删除该订单
DELETE FROM oorder WHERE cons_name = '测试用户';
-- 第四步：验证销量是否回滚到初始值
SELECT m_sale_v, IF(m_sale_v = @init_sale, '触发器生效', '触发器失效') AS test_result 
FROM fastfood_shop WHERE shop_name = '小美烤盘饭';


-- 存储过程单元测试
-- 3.1 测试batch_insert_random_orders存储过程
-- 第一步：记录插入前订单总数
SELECT COUNT(*) INTO @init_order_count FROM oorder;
-- 第二步：调用存储过程插入5条测试订单
CALL batch_insert_random_orders(5);
-- 第三步：验证订单数是否+5
SELECT COUNT(*), IF(COUNT(*) = @init_order_count + 5, '存储过程生效', '存储过程失效') AS test_result 
FROM oorder;
-- 第四步：清理测试数据（删除最后5条随机插入的订单）
DELETE FROM oorder 
WHERE order_id > (
  -- 把原查询包在一个临时表中（SELECT * FROM (...) AS temp）
  SELECT max_id_minus_5 FROM (
    SELECT MAX(order_id) - 5 AS max_id_minus_5 FROM oorder
  ) AS temp_table
);


-- 视图单元测试
-- 4.1 验证shop_revenue_view（店铺营收计算）
-- 手动计算大美鸡公煲营收：价格15 * 销量101 = 1515
SELECT 
  total_revenue, 
  IF(total_revenue = 15 * 101, '视图计算正确', '视图计算错误') AS test_result 
FROM shop_revenue_view WHERE shop_name = '大美鸡公煲';

-- 4.2 验证platform_revenue_view（平台总计）
SELECT 
  MAX(total_revenue) AS total_revenue,  -- 对非聚合字段做聚合，适配only_full_group_by
  SUM(price * m_sale_v) AS manual_calc_revenue,
  IF(MAX(total_revenue) = SUM(price * m_sale_v), '视图计算正确', '视图计算错误') AS test_result
FROM platform_revenue_view, fastfood_shop;





-- ----------------------------
-- Centralized test
-- ----------------------------

-- 订单-配送-调度员联动测试
-- 1.1 完整流程：插入订单→关联物流→更新订单状态→查询配送视图
-- 第一步：插入新订单
INSERT INTO oorder (shop_name, order_money, order_way, cons_phone, cons_name, cons_addre, checked, create_time)
VALUES ('至美猪脚饭', 20, '人工订餐', '13800000000', '集成测试用户', '8公寓', 0, NOW());
SET @new_order_id = LAST_INSERT_ID();

-- 第二步：关联物流（绑定调度员）
INSERT INTO wuliu (order_id, cons_phone, disp_id, deliver_time, ended)
VALUES (@new_order_id, '13800000000', '010100', '30分钟', 0);

-- 第三步：验证wuliu_insert触发器（订单checked字段是否更新为1）
SELECT checked, IF(checked = 1, '联动生效', '联动失效') AS test_result 
FROM oorder WHERE order_id = @new_order_id;

-- 第四步：验证sending_order视图（是否包含该订单）
SELECT COUNT(*) AS order_in_view 
FROM sending_order WHERE order_id = @new_order_id;

-- 第五步：清理测试数据
DELETE FROM wuliu WHERE order_id = @new_order_id;
DELETE FROM oorder WHERE order_id = @new_order_id;


-- 订单-店铺销量-订餐方式联动测试
-- 2.1 验证：插入订单→店铺销量+1 + 订餐方式计数+1
-- 第一步：记录初始值
SELECT m_sale_v INTO @init_shop_sale FROM fastfood_shop WHERE shop_name = '天美自选饭';
SELECT count INTO @init_way_count FROM orderway WHERE orderway_name = '网上订餐';

-- 第二步：插入订单
INSERT INTO oorder (shop_name, order_money, order_way, cons_phone, cons_name, cons_addre, checked, create_time)
VALUES ('天美自选饭', 10, '网上订餐', '13800000000', '集成测试用户', '10公寓', 0, NOW());

-- 第三步：验证联动结果
SELECT 
  (SELECT m_sale_v FROM fastfood_shop WHERE shop_name = '天美自选饭') = @init_shop_sale + 1 AS shop_sale_ok,
  (SELECT count FROM orderway WHERE orderway_name = '网上订餐') = @init_way_count + 1 AS way_count_ok,
  IF(
    (SELECT m_sale_v FROM fastfood_shop WHERE shop_name = '天美自选饭') = @init_shop_sale + 1 
    AND (SELECT count FROM orderway WHERE orderway_name = '网上订餐') = @init_way_count + 1,
    '模块联动正常', '模块联动异常'
  ) AS test_result;


-- 用户-用户信息联动测试
-- 3.1 验证user_msg外键关联user表（无法删除被关联的用户）
-- 第一步：尝试删除（IGNORE忽略1451报错，不中断执行）
BEGIN;
DELETE IGNORE FROM user WHERE id = 2; -- 关键：加IGNORE
ROLLBACK;

-- 第二步：验证结果（必执行）
SELECT 
  CASE 
    WHEN EXISTS (SELECT 1 FROM user WHERE id = 2) THEN '用户未删除（外键约束生效，符合预期）'
    ELSE '用户被删除（外键约束失效，不符合预期）'
  END AS test_result;

-- 第三步：解除关联后删除（仅测试用）
DELETE FROM user_msg WHERE id = 2;
DELETE FROM user WHERE id = 2;

-- 第四步：恢复数据
INSERT INTO user VALUES (2, 'iu', '123456789', '13525188888', 0);
INSERT INTO user_msg VALUES (2, '李知恩', '男', 18, '320836@qq.com', '13525199999', 'iu');




-- ----------------------------
-- System test
-- ----------------------------


-- 完整下单-配送-营收流程
-- 前置：记录初始状态（拆分多条语句，每条赋值一个变量）
SELECT COUNT(*) INTO @init_order_total FROM oorder;
SELECT m_sale_v INTO @init_tmzf_sale FROM fastfood_shop WHERE shop_name = '天美自选饭';
SELECT count INTO @init_online_count FROM orderway WHERE orderway_name = '网上订餐';
SELECT total_revenue INTO @init_platform_revenue FROM platform_revenue_view;

-- 步骤1：用户下单（模拟网上订餐）
INSERT INTO oorder (shop_name, order_money, order_way, cons_phone, cons_name, cons_addre, checked, create_time)
VALUES ('天美自选饭', 10, '网上订餐', '13525188888', '系统测试用户', '15公寓', 0, NOW());
SET @test_order_id = LAST_INSERT_ID();

-- 步骤2：商家接单（关联物流和调度员）
INSERT INTO wuliu (order_id, cons_phone, disp_id, deliver_time, ended)
VALUES (@test_order_id, '13525188888', '10111', '25分钟', 0);

-- 步骤3：配送完成（更新订单checked为2，物流ended为1）
UPDATE oorder SET checked = 2 WHERE order_id = @test_order_id;
UPDATE wuliu SET ended = 1 WHERE order_id = @test_order_id;

-- 步骤4：验证全链路结果
SELECT
  -- 订单数+1
  (SELECT COUNT(*) FROM oorder) = @init_order_total + 1 AS order_count_ok,
  -- 店铺销量+1
  (SELECT m_sale_v FROM fastfood_shop WHERE shop_name = '天美自选饭') = @init_tmzf_sale + 1 AS shop_sale_ok,
  -- 订餐方式计数+1
  (SELECT count FROM orderway WHERE orderway_name = '网上订餐') = @init_online_count + 1 AS way_count_ok,
  -- 平台营收+10
  (SELECT total_revenue FROM platform_revenue_view) = @init_platform_revenue + 10 AS platform_revenue_ok,
  -- 已完成订单出现在sended_order视图
  (SELECT COUNT(*) FROM sended_order WHERE order_id = @test_order_id) = 1 AS view_data_ok,
  -- 最终结论
  IF(
    (SELECT COUNT(*) FROM oorder) = @init_order_total + 1
    AND (SELECT m_sale_v FROM fastfood_shop WHERE shop_name = '天美自选饭') = @init_tmzf_sale + 1
    AND (SELECT count FROM orderway WHERE orderway_name = '网上订餐') = @init_online_count + 1
    AND (SELECT total_revenue FROM platform_revenue_view) = @init_platform_revenue + 10
    AND (SELECT COUNT(*) FROM sended_order WHERE order_id = @test_order_id) = 1,
    '全流程正常', '全流程异常'
  ) AS system_test_result;

-- 清理测试数据
DELETE FROM wuliu WHERE order_id = @test_order_id;
DELETE FROM oorder WHERE order_id = @test_order_id;


-- 店铺入驻申请-审核流程
-- 步骤1：提交店铺入驻申请
INSERT INTO shop_apply (shop_name, price, contact_name, contact_phone, description, status, apply_time)
VALUES ('系统测试店铺', 18, '测试联系人', '13800000000', '测试店铺描述', 0, NOW());
SET @test_apply_id = LAST_INSERT_ID();

-- 步骤2：管理员审核通过
UPDATE shop_apply 
SET status = 1, process_time = NOW() 
WHERE id = @test_apply_id;

-- 步骤3：验证审核结果
SELECT
  status,
  process_time IS NOT NULL AS process_time_ok,
  IF(status = 1 AND process_time IS NOT NULL, '审核流程正常', '审核流程异常') AS test_result
FROM shop_apply WHERE id = @test_apply_id;

-- 步骤4：将店铺加入fastfood_shop表（模拟审核通过后的业务操作）
INSERT INTO fastfood_shop (shop_name, price, m_sale_v)
VALUES ('系统测试店铺', 18, 0);

-- 步骤5：验证店铺数据同步
SELECT COUNT(*) AS shop_exist FROM fastfood_shop WHERE shop_name = '系统测试店铺';

-- 清理测试数据
DELETE FROM shop_apply WHERE id = @test_apply_id;
DELETE FROM fastfood_shop WHERE shop_name = '系统测试店铺';


-- 系统鲁棒性测试
-- 3.1 测试重复订单ID插入（主键冲突）
-- 加IGNORE：忽略主键冲突报错，继续执行后续语句
INSERT IGNORE INTO oorder (order_id, shop_name, order_money, order_way, cons_phone, cons_name, cons_addre, checked, create_time)
VALUES (1, '大美鸡公煲', 15, '人工订餐', '13800000000', '异常测试', '测试地址', 0, NOW());
-- 验证结果：确认订单未插入（符合预期）
SELECT 
  CASE WHEN EXISTS (SELECT 1 FROM oorder WHERE order_id = 1 AND cons_name = '异常测试') 
    THEN '错误：重复订单ID插入成功（不符合预期）' 
    ELSE '正确：重复订单ID插入失败（符合预期）' 
  END AS test_3_1_result;

-- 3.2 测试外键不存在的物流插入
-- 加IGNORE：忽略外键约束报错，继续执行后续语句
INSERT IGNORE INTO wuliu (order_id, cons_phone, disp_id, deliver_time, ended)
VALUES (99999, '13800000000', '010100', '30分钟', 0);
-- 验证结果：确认物流未插入（符合预期）
SELECT 
  CASE WHEN EXISTS (SELECT 1 FROM wuliu WHERE order_id = 99999) 
    THEN '错误：外键不存在的物流插入成功（不符合预期）' 
    ELSE '正确：外键不存在的物流插入失败（符合预期）' 
  END AS test_3_2_result;

-- 3.3 测试空值插入（非空字段约束）
-- 加IGNORE：忽略非空约束报错，继续执行后续语句
INSERT IGNORE INTO dispatcher (dispatcher_id, dispatcher_name, dispatcher_phone)
VALUES ('99999', NULL, '13800000000');
-- 验证结果：确认调度员未插入（符合预期）
SELECT 
  CASE WHEN EXISTS (SELECT 1 FROM dispatcher WHERE dispatcher_id = '99999') 
    THEN '错误：空值插入调度员成功（不符合预期）' 
    ELSE '正确：空值插入调度员失败（符合预期）' 
  END AS test_3_3_result;