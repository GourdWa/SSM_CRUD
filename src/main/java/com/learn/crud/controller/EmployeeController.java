package com.learn.crud.controller;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.learn.crud.bean.Employee;
import com.learn.crud.service.EmployeeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import java.util.List;

/**
 * 处理员工CRUD请求
 *
 * @author ZixiangHu
 * @create 2020-04-03  14:06
 * @description
 */
@Controller
public class EmployeeController {
    @Autowired
    EmployeeService employeeService;

    @RequestMapping("/emps")
    public ModelAndView getEmps(@RequestParam(value = "pn", required = false, defaultValue = "1") Integer pn, ModelAndView mv) {
        //查询之前调用，传入页码以及每页的大小
        PageHelper.startPage(pn, 5);
        //startPage后面紧跟的查询就是分页查询
        List<Employee> emps = employeeService.getAll();
        //使用PageInfo包装查询之后的结果，只需要将PageInfo交给页面即可
        //封装了详细的分页信息，包括查询出来的数据，可以传入连续显示的页数
        PageInfo page = new PageInfo(emps,5);
        mv.addObject("pageInfo", page);
        mv.setViewName("list");
//        测试git pull
        return mv;
    }
}
