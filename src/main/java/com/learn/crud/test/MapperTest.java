package com.learn.crud.test;

import com.learn.crud.bean.Department;
import com.learn.crud.bean.Employee;
import com.learn.crud.dao.DepartmentMapper;
import com.learn.crud.dao.EmployeeMapper;
import org.apache.ibatis.session.SqlSession;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.UUID;

/**
 * 测试DAO层工作
 *
 * @author ZixiangHu
 * @create 2020-04-03  13:05
 * @description 1、导入Spring单元测试模块
 * 2、@ContextConfiguration指定Spring配置文件位置
 * 3、直接Autowired
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {"classpath:applicationContext.xml"})
public class MapperTest {
    @Autowired
    DepartmentMapper departmentMapper;
    @Autowired
    EmployeeMapper employeeMapper;
    @Autowired
    SqlSession sqlSession;

    /**
     * 测试department的Mapper
     */
    @Test
    public void testCRUD() {
        //1、测试部门插入
//        departmentMapper.insertSelective(new Department(null, "开发部"));
//        departmentMapper.insertSelective(new Department(null, "测试部"));
        //2、生成员工数据
//        employeeMapper.insertSelective(new Employee(null,"Jerry","m","Jerry@163.com",1));
        //3、批量插入
        EmployeeMapper employeeMapper = sqlSession.getMapper(EmployeeMapper.class);
        for (int i = 0; i < 1000; i++) {
            String uid = UUID.randomUUID().toString().substring(0, 5) + i;
            employeeMapper.insertSelective(new Employee(null, uid, "m", uid + "@163.com", 1));
        }
        System.out.println("批量插入成功");
    }
}
