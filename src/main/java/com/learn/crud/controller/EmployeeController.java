package com.learn.crud.controller;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.learn.crud.bean.Employee;
import com.learn.crud.bean.Msg;
import com.learn.crud.service.EmployeeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.validation.Errors;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.json.MappingJackson2JsonView;

import javax.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
    public ModelAndView getEmpsWithJson(@RequestParam(value = "pn", required = false, defaultValue = "1") Integer pn) {
        ModelAndView mv = new ModelAndView();
        //查询之前调用，传入页码以及每页的大小
        PageHelper.startPage(pn, 5);
        //startPage后面紧跟的查询就是分页查询
        List<Employee> emps = employeeService.getAll();
        //使用PageInfo包装查询之后的结果，只需要将PageInfo交给页面即可
        //封装了详细的分页信息，包括查询出来的数据，可以传入连续显示的页数
        PageInfo page = new PageInfo(emps, 5);
        mv.addObject(Msg.success().add("pageInfo", page));
        mv.setView(new MappingJackson2JsonView());
        return mv;
    }

//    第一版，不利用AJAX请求
    /*
    //@RequestMapping("/emps")
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
    }*/


    /**
     * 员工保存
     *
     * @return
     */
    @RequestMapping(value = "/emp", method = RequestMethod.POST)
    public ModelAndView saveEmp(@Valid Employee employee, BindingResult result) {
        ModelAndView mv = new ModelAndView();
        mv.setView(new MappingJackson2JsonView());
        Map<String, Object> map = new HashMap<>();
        if (result.hasErrors()) {
            List<FieldError> errors = result.getFieldErrors();
            for (FieldError error : errors) {
                System.out.println("错误的字段名：" + error.getField());
                System.out.println("错误的信息：" + error.getDefaultMessage());
                map.put(error.getField(), error.getDefaultMessage());
            }
            mv.addObject(Msg.fail().add("errorField", map));
            return mv;
        } else {
            employeeService.saveEmp(employee);
            mv.addObject(Msg.success());
            return mv;
        }
    }

    /**
     * 检测用户名是否可用
     *
     * @param empName
     * @return
     */
    @RequestMapping("/checkuser")
    public ModelAndView checkuser(@RequestParam("empName") String empName) {
        ModelAndView mv = new ModelAndView();
        mv.setView(new MappingJackson2JsonView());
        //先判断用户名是否是合法的表达式
        String regx = "(^[a-zA-Z0-9_-]{6,16}$)|(^[\u2E80-\u9FFF]{2,5})";
        //如果匹配失败
        if (!empName.matches(regx)) {
            mv.addObject(Msg.fail().add("va_msg", "用户名必须是6-16位数字和字母的组合或者2-5位中文"));
            return mv;
        }
        //数据库用户名重复校验
        boolean b = employeeService.checkUser(empName);
        if (b) {
            //可用
            mv.addObject(Msg.success());
        } else {
            mv.addObject(Msg.fail().add("va_msg", "用户名不可用"));
        }
        return mv;
    }

    /**
     * 查询员工
     *
     * @param id
     * @return
     */
    @RequestMapping(value = "/emp/{id}", method = RequestMethod.GET)
    public ModelAndView getEmp(@PathVariable("id") Integer id) {
        ModelAndView mv = new ModelAndView();
        mv.setView(new MappingJackson2JsonView());
        Employee employee = employeeService.getEmp(id);
        mv.addObject(Msg.success().add("emp", employee));
        return mv;
    }

    @RequestMapping(value = "/emp/{empId}",method = RequestMethod.PUT)
    public ModelAndView updateEmp(Employee employee) {
        ModelAndView mv = new ModelAndView();
        mv.setView(new MappingJackson2JsonView());
        employeeService.updateEmp(employee);
        mv.addObject(Msg.success());
        return mv;
    }
}
