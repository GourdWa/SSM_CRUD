package com.learn.crud.test;

import com.github.pagehelper.PageInfo;
import com.learn.crud.bean.Employee;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import java.util.List;

/**使用Spring测试模块提供的测试功能，测试crud请求的正确性
 * @author ZixiangHu
 * @create 2020-04-03  14:26
 * @description
 */

@ContextConfiguration(locations = {"classpath:applicationContext.xml","file:./src/main/webapp/WEB-INF/dispatcherServlet-servlet.xml"})
//让@Autowired直接获取IOC容器本身
@WebAppConfiguration
@RunWith(SpringJUnit4ClassRunner.class)
public class MvcTest {
    //传入SpringMVC的IOC，直接获取IOC容器本身，需要配合@WebAppConfiguration注解
    @Autowired
    WebApplicationContext context;
    //虚拟MVC请求
    MockMvc mockMvc;
    //每次测试都需要引入
    @Before
    public void initMockMvc(){
        mockMvc = MockMvcBuilders.webAppContextSetup(context).build();
    }

    @Test
    public void testPage() throws Exception {
        //模拟请求并拿到返回值
        MvcResult result = mockMvc.perform(MockMvcRequestBuilders.get("/emps").param("pn", "5")).andReturn();
        //请求成功之后，请求域中会有pageInfo；可以取出进行验证
        MockHttpServletRequest request = result.getRequest();
        PageInfo pageInfo = (PageInfo) request.getAttribute("pageInfo");
        System.out.println("当前页码：" + pageInfo.getPageNum());
        System.out.println("总页码：" + pageInfo.getPages());
        System.out.println("总记录数：" + pageInfo.getTotal());
        int[] nums = pageInfo.getNavigatepageNums();
        for (int num : nums) {
            System.out.print(" " + num);
        }
        List<Employee> list = pageInfo.getList();
        for (Employee employee : list) {
            System.out.println("id:" + employee.getEmpId() + ",name:" + employee.getEmpName());
        }
    }
}
