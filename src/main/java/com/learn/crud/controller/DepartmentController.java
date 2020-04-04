package com.learn.crud.controller;

import com.learn.crud.bean.Department;
import com.learn.crud.bean.Msg;
import com.learn.crud.service.DepartmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.json.MappingJackson2JsonView;

import java.util.List;

/**
 * 处理和部门有关的请求
 *
 * @author ZixiangHu
 * @create 2020-04-04  21:48
 * @description
 */
@Controller
public class DepartmentController {
    @Autowired
    private DepartmentService departmentService;

    @RequestMapping("/depts")
    public ModelAndView getDetps() {
        ModelAndView mv = new ModelAndView();
        mv.setView(new MappingJackson2JsonView());
        List<Department> departments = departmentService.getDepts();
        Msg msg = Msg.success().add("depts", departments);
        mv.addObject(msg);
        return mv;
    }
}
