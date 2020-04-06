# SSM_CRUD重要知识汇总
#### 一、Mybatis逆向工程的使用  
1. 导入Mybatis逆向工程的jar包  
2. 创建Mybatis逆向工程的xml配置文件（建议直接放在工程根目录下），具体配置项参考官方文档  
```
<!DOCTYPE generatorConfiguration PUBLIC
        "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
        "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">
<generatorConfiguration>
    <context id="simple" targetRuntime="MyBatis3">
        <!--     不要生成的文件有注释   -->
        <commentGenerator>
            <property name="suppressAllComments" value="true"/>
        </commentGenerator>

        <!--      配置数据库连接信息  -->
        <jdbcConnection driverClass="com.mysql.jdbc.Driver"
                        connectionURL="jdbc:mysql://localhost:3306/ssm_crud"
                        password="root"
                        userId="root"/>
        <!--        指定javaBean生成的位置-->
        <javaModelGenerator targetPackage="com.learn.crud.bean" targetProject="./src/main/java"/>
        <!--指定映射文件生成的位置-->
        <sqlMapGenerator targetPackage="mapper" targetProject="./src/main/resources"/>
        <!--      指定DAO接口生成的位置  -->
        <javaClientGenerator type="XMLMAPPER" targetPackage="com.learn.crud.dao" targetProject="./src/main/java"/>
        <!--    table指定每个表的生成策略    -->
        <table tableName="tbl_emp" domainObjectName="Employee"/>
        <table tableName="tbl_dept" domainObjectName="Department"/>
    </context>
</generatorConfiguration>
```
3. 参考官方文档生成对应的映射器文件、Bean文件和DAO文件
#### 二、Mybatis整合Spring配置说明
1. 配置数据库连接池，管理数据源  
2. 利用Mybatis整合Spring的框架，构建***SqlSessionFactoryBean***实例  
  a. 指定数据库连接池，这里配置后无需在Mybatis的xml配置中配置数据库连接  
  b. 配置Mybatis的xml配置路径  
  c. 配置映射器的xml文件，在这里配置后就无需在Mybatis的xml配置文件中配置映射器  
3. 配置***MapperScannerConfigurer***实例，将映射器的接口实例加到IOC容器中
```
    <!--  配置和Mybatis的整合  -->
    <bean class="org.mybatis.spring.SqlSessionFactoryBean" id="sqlSessionFactoryBean">
        <property name="dataSource" ref="pooledDataSource"/>
        <property name="configLocation" value="classpath:mybatis-config.xml"/>
        <!--   指定Mybatis Mapper文件的位置     -->
        <property name="mapperLocations" value="classpath:mapper/*.xml"/>
    </bean>
    <!--   配置扫描器,将Mybatis接口的实现加到IOC容器 -->
    <bean class="org.mybatis.spring.mapper.MapperScannerConfigurer" id="mapperScannerConfigurer">
        <!--     扫描多具有Repository注解的DAO接口的实现加到IOC容器中   -->
        <property name="basePackage" value="com.learn.crud.dao"/>
        <property name="annotationClass" value="org.springframework.stereotype.Repository"/>
    </bean>
```
#### 三、合理利用Spring的单元测试模块
1. 导入Spring单元测试的jar包  
2. 使用***ContextConfiguration注解***标注在测试类上，其location属性指定Spring配置文件路径  
`@ContextConfiguration(locations = {"classpath:applicationContext.xml"})`
3. 使用***RunWith注解***指定测试使用的模块，比如Junit  
`@RunWith(SpringJUnit4ClassRunner.class)`
4. 直接在测试类中使用Autowired自动装配获取IOC容器中的值
#### 四、引入Mybatis的插件PageHelper管理分页
1. 引入PageHelper的jar包  
2. 在查询之前调用PageHelper的静态方法***startPage***传入查询的页数和每页的数量  
3. 将查询结果封装成一个PageInfo实例，并传入页码数量  
4. 可以利用封装好的PageInfo实例实现分页所需的逻辑功能
```
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
```
#### 五、再说Spring单元测试，利用Spring单元测试模拟MVC发送请求
1. 除了Spring单元测试的基本配置，还需要在***ContextConfiguration注解***中指定SpringMVC的配置文件路径  
2. 在测试类上使用***WebAppConfiguration注解***，以便在测试类中使用Autowired能直接拿到SpringMVC的IOC容器（不是容器中的内容，是容器本身）  
```
@ContextConfiguration(locations = {"classpath:applicationContext.xml","file:./src/main/webapp/WEB-INF/dispatcherServlet-servlet.xml"})
//让@Autowired直接获取IOC容器本身
@WebAppConfiguration
@RunWith(SpringJUnit4ClassRunner.class)
```
3. 创建一个***MockMvc***实例虚拟MVC请求，这个实例在每次虚拟时都要初始化  
```
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
```
4. 调用MockMvc实例的perform方法模拟请求并获得返回值  
`MvcResult result = mockMvc.perform(MockMvcRequestBuilders.get("/emps").param("pn", "5")).andReturn();`
5. 完整的Demo  
```
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

```
#### 六、直接利用AJAX发送PUT请求用于数据更新  
1. 方式一  
发送POST请求，但是通过_method参数将其封装为PUT请求，也就是之前学习的利用POST请求发送PUT请求  
```
...
type: "POST",
data:$("#empUpdateModal form").serialize()+"&_method=PUT",
...
```
2. 方式二  
直接发送PUT请求，但是需要通过***HttpPutFormContentFilter过滤器***过滤，因此需要在web.xml中配置该过滤器，然后就可以通过AJAX请求直接发送PUT请求
```
...
type: "PUT",
data:$("#empUpdateModal form").serialize(),
...`

```