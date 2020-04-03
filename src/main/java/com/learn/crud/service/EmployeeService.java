package com.learn.crud.service;

import com.learn.crud.bean.Employee;
import com.learn.crud.dao.EmployeeMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author ZixiangHu
 * @create 2020-04-03  14:09
 * @description
 */
@Service
public class EmployeeService {
    @Autowired
    private EmployeeMapper employeeMapper;

    /**
     * 查询所有员工
     * @return
     */
    public List<Employee> getAll() {
        //这不是一个分页查询
        //引入pageHelper分页插件
        return employeeMapper.selectByExampleWithDept(null);
    }
}
