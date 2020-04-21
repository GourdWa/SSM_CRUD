# Spring注解开发笔记 
**** 
## Spring IOC
****
利用配置类代替配置文件
### Configuration注解
使用在配置类上，告诉Spring这是一个配置类，取代XML配置  
##### Bean注解
使用在配置类中的方法上，作用是将实例放入IOC容器，类似于XML配置中的**bean元素**，默认的id是方法名，可以通过其name属性重新起名  
```
@Configuration
public class MainConfig {
    @Bean
    public Person person(){
        return new Person("lisi",20);
    }
}
```
##### 创建IOC容器的方法
`ApplicationContext context = new AnnotationConfigApplicationContext(MainConfig.class);`
### 包扫描注解ComponentScan
ComponentScan通过其**basePackages**属性指定包扫描路径，自动将使用Controller注解、Service注解、Repository和Component注解的类装进IOC容器。其**excludeFilters**属性可以指定排除响应的类。如下，扫描com.learn包下的类，但是排除使用Controller注解和Service注解的组件。其中Filter注解的type属性的值**FilterType.ANNOTATION**指定了使用注解来扫描特定的包
```
@ComponentScan(value = {"com.learn"},
        excludeFilters = {@ComponentScan.Filter(type = FilterType.ANNOTATION,classes = {Controller.class, Service.class})})
```
**includeFilters**属性则用来指定扫描的时候只需要包含那些组件，但是当使用这个属性时需要禁用掉默认的扫描规则，即**useDefaultFilters**属性设置为false。例如下面的配置代表只扫描使用Controller注解的组件
```
@ComponentScan(value = {"com.learn"},
        includeFilters = {@ComponentScan.Filter(type = FilterType.ANNOTATION,classes = {Controller.class})},
        useDefaultFilters = false)
```
当过滤器的type为**FilterType.ASSIGNABLE_TYPE**时，是指按给定的类型加载或排除组件，例如下面的实例，指定只扫描使用Controller注解的组件和BookService的组件（包含其子类（或实现类））
```
@ComponentScan(value = {"com.learn"},
        includeFilters = {@ComponentScan.Filter(type = FilterType.ANNOTATION, classes = {Controller.class}),
        @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE,classes = {BookService.class})},
        useDefaultFilters = false)
```
### @Scope注解
在IOC容器中的组件默认都是单实例的。通过Scope注解的**scopeName属性**可以实现多实例和单实例的改变  
1. 当scopeName的值为prototype，创建多实例对象
2. 当scopeName的值为SCOPE_SINGLETON，创建单实例对象，也就是默认的情况
在单实例（也就是默认）情况下，IOC容器启动就会调用方法创建对象并放进IOC容器，以后每次获取就直接从容器中拿；在多实例的情况下，IOC容器在启动时不会创建该对象，只有在真正获取对象时才会创建对象
### 懒加载@Lazy注解
因为单实例的Bean是在容器启动时创建对象，创建完之后就会放进IOC容器。使用Lazy注解启动懒加载，懒加载就是在容器启动时不会创建对象，在第一次获取对象时才会创建
### @Conditional注解
按照一定的条件进行判断，满足条件则给容器中注册Bean。这个注解既可以标记在方法上也可以标记在类上，在使用该注解的时候需要传入Condition数组（这是一个接口，需要自己实现，返回true时条件满足，返回false时条件不满足）。这个接口只有一个方法，**ConditionContext类型**参数是指判断条件能使用的上下文环境；**AnnotatedTypeMetadata类型**参数当前注释信息
`boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata);`
例如实现一个Condition的类，判断运行环境是否是Windows环境或者Linux环境，如果是Windows环境则将bill这个Bean加入IOC容器；如果是Linux环境则将Linus加入IOC容器(只给出Windows的判断，Linux类似)
```
public class WindowsCondition implements Condition {
    @Override
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        Environment environment = context.getEnvironment();
        return environment.getProperty("os.name").contains("Windows");
    }
}
```
根据运行环境添加Bean
```
    @Bean("bill")
    @Conditional(WindowsCondition.class)
    public Person person01() {
        return new Person("Bill", 62);
    }

    @Bean("linus")
    @Conditional(LinuxCondition.class)
    public Person person02() {
        return new Person("linus", 48);
    }
```
### @Import注解
1. 快速的给容器中导入一个组件，例如有一个Color类，没有加任何注解，在不使用Bean注解的情况下，可以在配置类上使用Import注解导入该类的Bean到IOC容器中，id默认是全类名  
例如通过Import注解向容器中添加Color实例和Red实例，注意id是全类名  
`@Import({Color.class, Red.class})`
2. **ImportSelector接口**，这是一个接口，只有一个selectImports方法，该方法以字符串数组的形式返回需要导入的组件的全类名，其**AnnotationMetadata类型**参数能够获取标注了Import注解的类上的所有注解信息。只需要将该接口传递到Import注解中即可
例如通过实现ImportSelector向容器中加入Blue和Yellow实例
```
public class MyImportSelector implements ImportSelector {
    /**
     * 返回值就是导入到容器中的组件的全类名
     * @param importingClassMetadata 当前标注@Import注解的类的所有注解信息
     * @return
     */
    @Override
    public String[] selectImports(AnnotationMetadata importingClassMetadata) {
        return new String[]{"com.learn.bean.Blue","com.learn.bean.Yellow"};
    }
}
```
在配置类上添加Import注解  
`@Import({Color.class, Red.class, MyImportSelector.class})`
3. **ImportBeanDefinitionRegistrar接口**，需要自己实现，其可以通过registerBeanDefinitions方法的BeanDefinitionRegistry类型的参数将需要的Bean自己手动注册进容器。BeanDefinitionRegistry类型的参数表示了容器中定义的注册类，通过它可以向容器中手动添加所需的Bean
例如如果容器中有Red实例和Blue实例就通过ImportBeanDefinitionRegistrar接口的实现类向容器中添加一个RainBow的实例
```
public class MyImportBeanDefinitionRegistrar implements ImportBeanDefinitionRegistrar {
    /**
     * @param importingClassMetadata
     * @param registry               Bean的注册类
     *                               把所有需要添加到容器中的Bean，可以通过registry注册进容器
     */
    @Override
    public void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry) {
        //判断IOC中是否有Red和Blue
        boolean red = registry.containsBeanDefinition("com.learn.bean.Red");
        boolean blue = registry.containsBeanDefinition("com.learn.bean.Blue");
        if (red && blue)
            //向容器中添加RainBow类
            registry.registerBeanDefinition("rainBow", new RootBeanDefinition(RainBow.class));
    }
}
```
通过Import注解引入  
`@Import({Color.class, Red.class, MyImportSelector.class, MyImportBeanDefinitionRegistrar.class})`
### Spring提供的FactoryBean接口
这是一个泛型接口，需要传入创建什么类型的Bean  
这个接口有三个方法需要实现  
1. T getObject()：返回创建的Bean实例，这个实例会添加到容器中
2. Class<?> getObjectType()：返回创建的类型
3. boolean isSingleton()：是否是单实例，返回true则是单实例；返回false，每次创建时都会调用getObject()方法重新创建  

例如，利用自己实现的FactoryBean接口的类来完成Color实例的创建  
a. 实现该接口，并且注明泛型为Color
```
public class ColorFactoryBean implements FactoryBean<Color> {
    @Override
    public Color getObject() throws Exception {
        System.out.println("ColorFactoryBean...getObject...");
        return new Color();
    }

    @Override
    public Class<?> getObjectType() {
        return Color.class;
    }

    @Override
    public boolean isSingleton() {
        return true;
    }
}
```
b. 在配置类中通过Bean注解加入ColorFactoryBean
```
    @Bean
    public ColorFactoryBean colorFactoryBean(){
        return new ColorFactoryBean();
    }
```
c. 在实际获取这个实例时，实际拿到的是Color类型，注意一定要用id获取，如果按类型获取，那么还是取得的是工厂Bean本身（或者在id前面加一个&，这样获取的也是工厂Bean）
```
Object bean =  context.getBean("colorFactoryBean");
System.out.println(bean.getClass());
```
输出为
> class com.learn.bean.Color
### Bean的生命周期
bean创建-->初始化-->销毁  
容器管理者Bean的生命周期，可以自定义初始化和销毁方法；容器在Bean进行到当前生命周期的时候来调用我们自定义的初始化和销毁方法  
对于单实例Bean，在容器启动的时候创建对象；而多实例是在获取的时候创建
1. 指定初始化和销毁方法，通过Bean注解的initMethod和destroyMethod属性指定
例如创建一个Car实例（Car类中有自定义的init和destroy方法）  
```
@Bean(initMethod = "init",destroyMethod = "destory")
public Car car(){
    return new Car();
}
```
*运行过程*：构造方法-->初始化方法-->执行逻辑-->容器关闭执行销毁方法（多实例情况下，IOC不会管理这个Bean，只会创建调用初始化方法，不会调用销毁方法）
2. 通过让Bean实现**InitializingBean接口**定义初始化逻辑；**DisposableBean接口**定义销毁逻辑  
例如定义一个Cat类实现这两个方法  
```
public class Cat implements InitializingBean, DisposableBean {
    public Cat() {
        System.out.println("cat constructor...");
    }

    @Override
    public void destroy() throws Exception {
        System.out.println("cat..destroy..");
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        System.out.println("cat..afterPropertiesSet..");
    }
}
```
3. 可以使用JSR250里面规定的注解；**PostConstruct注解**在Bean创建完成，并且属性赋值完成来执行初始化；**PreDestroy注解**在容器销毁bean之前通知进行清理工作。这两个注解只能使用在方法上
4. **BeanPostProcessor接口**，bean的后置处理器，在bean初始化前后进行处理工作。其postProcessBeforeInitialization方法能在初始化之前工作；postProcessAfterInitialization方法在初始化之后进行工作  
*需要注意*，BeanPostProcessor接口一经配置对所有的Bean都有效。如果实现了**BeanPostProcessor接口和配置了init-method和destroy-method**，一个Bean的生命周期为：  
* 初始化（构造器）
* 依赖注入  
* BeanPostProcessor的postProcessBeforeInitialization方法  
* init方法，自定义初始化方法  
* BeanPostProcessor的postProcessAfterInitialization方法  
* 生存期，执行指定逻辑  
* destroy方法，自定义销毁方法  
### ApplicationContextAware接口
该接口有一个setApplicationContext方法，通过该方法可以获得容器，例如，如果Dog的Bean实现了该接口，那么可以将容器作为一个属性保存
### Value注解
使用Value注解对Bean进行赋值
1. 可以赋值基本属性  
```
@Value("张三")
private String name;
```
2. 可以使用SpEL表达式，#{}
```
@Value("#{20-2}")
private Integer age;
```
3. 可以使用${}，取出配置文件的值（运行环境变量中的值）
### PropertySource注解
导入properties文件
### Spring的自动装配
Spring利用依赖注入（DI），完成对IOC容器中各个组件的依赖关系赋值  
* **Autowired注解**，自动注入，如果一个bean的属性上加了Autowired注解。那么它会优先按照类型去容器中找对应的组件，如果找到就赋值；如果这个类型的组件有多个相同类型的组件，再将属性名作为组件的id去容器中查找
* **Qualifier注解**，因为当容器中有多个类型时，例如BookDao接口有多个实现类，DaoImpl1和DaoImpl2。但是在Service中Autowired的属性名是bookDao。此时，仅使用Autowired注解就会报错（因为不管是使用类型装配还是id装配都不能成功）。在这种情况下可以使用Qualifier注解，指定从容器中找到装配的id名
```
@Autowired
@Qualifier("bookDao2")
private BookDao bookDao;
```
如果指定了Qualifier注解，但是容器中并没有相应id的组件，此时程序就会报错。此时可以通过Autowired注解将其**required属性**设置为false，如果没有装配成功就会自动装配为null（或者不装配）
* **Primary注解**，只能用在类或者方法上。当使用Autowired装配时，容器中有多个相同的组件时，使用Primary注解可以指定优先装配那个组件  
例如，下面的代码，当容器中有多个BookDao类型的组件时，将优先装配使用Primary注解标记的组件
```
@Bean("bookDao2")
@Primary
public BookDao bookDao(){
    BookDao bookDao = new BookDao();
    bookDao.setLabel("2");
    return bookDao;
}
```
### Resource注解和Inject注解
这两个是java规范的注解；Autowired是Spring的规范  
**Resource注解**和Autowired一样都可以实现自动装配，默认情况下，Resource注解按照属性的名称进行装配，可以通过指定其name属性来装配指定id的bean。相比于Autowired注解，其没有Primary功能和required=false的功能  
**Inject注解**和Autowired的功能一样，其可以支持Primary功能，但是没有required=false的功能
### Autowired注解的标注位置说明
1. 当Autowired注解标注在方法上，Spring容器创建当前对象，就会调用方法，完成赋值。方法使用的参数，自定义类型的值从IOC容器中获取
```
@Autowired
public void setCar(Car car) {
    this.car = car;
}
```
2. Autowired标注在有参构造器上，Spring在启动时会代用有参构造器。如果仅有有参构造而没有无参构造，在这种情况下，有参的Autowired注解可以省略，此时Spring也会从IOC容器中去获取该类型的参数来进行装配。*默认不写Autowired*    
默认加载IOC容器中的组件，容器启动会调用无参构造器创建对象，在进行初始化赋值等操作
3. Autowired放在参数位置。在这种情况下，参数位置的Autowired注解可以省略，此时Spring也会从IOC容器中去获取该类型的参数来进行装配。*默认不写Autowired*
```
@Bean
public Color color(@Autowired Car car){
    return new Color(car);
}
```
### 自定义组件使用底层组件
如果自定义组件要使用例如ApplicationContext、BeanFactory等底层组件。在这种情况下，只要让这个组件实现[XXXX]Aware接口就行，例如之前所说的**ApplicationContextAware接口**可以注入ApplicationContext。这些接口都继承自了**Aware接口**，在创建对象的时候会调用接口规定的方法注入相关组件。每一个[XXXX]Aware都有一个[XXXX]Processor来进行处理
### Profile注解 
Spring提供的根据当前环境动态激活和切换一系列组件的功能  
**Profile注解**，指定组件在哪个环境的情况下才能被注册到容器中，以前不指定，任何环境下都能注册到这个组件中  
没有被Profile注解标识的组件，任何环境下都会被注册  
加了环境标识后的bean，只有在这个环境被激活时才能被注册到IOC容器中  
例如有三个数据源 分别对应测试、开发和生成，只有在测试环境中才将测试数据源加入IOC容器，依次类推
```
@Configuration
@PropertySource(value = "classpath:dbconfig.properties")
public class MainConfigOfProfile {
    @Value("${db.user}")
    private String user;

    @Bean
    @Profile("test")
    public Yellow yello(){
        return new Yellow();
    }

    @Bean("testDataSource")
    @Profile("test")
    public DataSource dataSourceTest(@Value("${db.password}") String pwd) throws PropertyVetoException {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/test");
        dataSource.setDriverClass("com.mysql.jdbc.Driver");
        return dataSource;
    }
    @Bean("devDataSource")
    @Profile("dev")
    public DataSource dataSourceDev(@Value("${db.password}") String pwd) throws PropertyVetoException {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/ssm_crud");
        dataSource.setDriverClass("com.mysql.jdbc.Driver");
        return dataSource;
    }

    @Bean("prodDataSource")
    @Profile("prod")
    public DataSource dataSourceProd(@Value("${db.password}") String pwd) throws PropertyVetoException {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/ssm");
        dataSource.setDriverClass("com.mysql.jdbc.Driver");
        return dataSource;
    }
}
```
使用代码的方式切换运行环境
1. 创建一个ApplicationContext对象（使用无参的构造）
`AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();`
2. 设置激活的环境
`context.getEnvironment().setActiveProfiles("test","dev");`
3. 注册主配置类
`context.register(MainConfigOfProfile.class);`
4. 启动刷新容器
`context.refresh();`  
当**Profile注解写在配置类上**只有在指定的环境下，配置类下的所有配置才会生效  
## Spring AOP
****
AOP指在程序运行期间动态的将某段代码切入到指定方法指定位置进行运行的编程方式  
1. 前置通知（**Before注解**）：在目标方法之前运行
2. 后置通知（**After注解**）：在目标方法运行结束之后运行
3. 返回通知（**AfterReturning**）：在目标方法正常返回后运行
4. 异常通知（**AfterThrowing注解**）：在目标方法出现异常以后运行
5. 环绕通知（**Around注解**）：动态代理，手动推进目标方法运行
### 基于注解版的AOP开发步骤
1. 定义一个切面类，用**Aspect注解**标注在类上
2. 给切面类上的目标方法标注何时何地运行（也就上面的四个注解），以及配置切入点表达式，告诉这些方法需要切入的方法
3. 将切面类和业务逻辑类（被切入的类）都需要加入到容器中，且在配置类上使用**EnableAspectJAutoProxy**注解开启切面功能
### Pointcut注解
抽取可重用的切入点表达式。用法是标注在一个空方法上，PointCut注解里写切入点表达式，在使用是只需要传入方法名即可（不同包引用需要加上包名）
```
@Pointcut("execution(public * com.learn.aop.MathCalculator.*(..))")
public void pointCut(){

}
@Before("pointCut()")
public void logStart(){
    System.out.println("除法运行...参数列表是：{}");
}
```
### JoinPoint类
在通知方法的形参上标注可以获取切入的方法名称和参数等信息，需要注意的是JoinPoint一定要放在参数表的第一位
```
@Before("pointCut()")
public void logStart(JoinPoint joinPoint){
    System.out.println(joinPoint.getSignature().getName()+"运行...参数列表是："+ Arrays.toString(joinPoint.getArgs()));
}
```
### 获取返回值和异常信息
**AfterReturning注解**有一个**returning属性**，可以通过它指定封装返回值（如果有返回值）  
**AfterThrowing注解**有一个**throwing属性**，可以通过它指定封装异常信息，注意接收异常的参数类型需要是*Throwable类型*
```
@AfterReturning(value = "pointCut()", returning = "res")
public void logReturn(JoinPoint joinPoint, Object res) {
    System.out.println(joinPoint.getSignature().getName() + "正常返回...计算结果是：【" + res + "】");
}

@AfterThrowing(value = "pointCut()",throwing = "throwing")
public void logException(JoinPoint joinPoint,Throwable throwing) {
    System.out.println(joinPoint.getSignature().getName()  +"异常...异常信息是：【"+throwing.getMessage()+"】");
}
```  
### EnableAspectJAutoProxy注解
这个注解上有一个Import注解，导入了**AspectJAutoProxyRegistrar类**给容器中注册一个**AnnotationAwareAspectJAutoProxyCreator组件**
1. 传入配置类，创建IOC容器
2. 注册配置类，调用refresh()方法刷新容器
3. 来到AbstractApplicationContext类中调用`registerBeanPostProcessors(beanFactory)`注册后置处理器，方便bean的拦截
	1. PostProcessorRegistrationDelegate类中调用invokeBeanFactoryPostProcessors方法先获取IOC容器中已经定义的需要创建对象的所有BeanPostProcessor
	2. 给容器中加别的BeanPostProcessor
	3. 优先注册实现了PriorityOrdered接口的BeanPostProcessor
	4. 再给容器中注册实现了Ordered接口的BeanPostProcessor
	5. 最后是普通的BeanPostProcessor
	6. 注册BeanPostProcessor，实际上就是创建BeanPostProcessor对象，保存在容器中
		1. 创建internalAutoProxyCreator的BeanPostProcessor
		2. initializeBean初始化Bean
			1. invokeAwareMethods：处理Aware接口的方法回调
			2. applyBeanPostProcessorsBeforeInitialization：应用后置处理器的postProcessBeforeInitialization
			3. invokeInitMethods：执行自定义的初始化方法
			4. applyBeanPostProcessorsAfterInitialization：执行后置处理器的postProcessAfterInitialization
		3. 调用setBeanFactory方法   
##### 以上是创建和注册AnnotationAwareAspectJAutoProxyCreator组件的过程
..........以下省略.............

### AOP原理总结
1. EnableAspectJAutoProxy注解开启AOP功能
2. EnableAspectJAutoProxy注解会给容器中注册一个AnnotationAwareAspectJAutoProxyCreator组件
3. AnnotationAwareAspectJAutoProxyCreator组件是一个后置处理器  
4. 容器的创建流程
	1. registerBeanPostProcessors()注册后置处理器；创建AnnotationAwareAspectJAutoProxyCreator对象  
	2. finishBeanFactoryInitialization()初始化剩下的单实例Bean  
		1. 创建业务逻辑组件和切面组件  
		2.  AnnotationAwareAspectJAutoProxyCreator拦截组件的创建过程
		3. 组件创建 完成后，判断组件是否需要增强
			1. 是：切面的通知方法，包装成增强器（Advisor） ；给业务逻辑组件创建一个代理对象，默认是CGLIB创建，如果有接口也可以使用JDK动态代理
5. 执行目标方法
	1. 代理对象执行目标方法
	2. 使用CglibAopProxy.intercept()进行拦截
		1. 得到目标方法的拦截器链（增强器包装成拦截器）
		2. 利用拦截器的链式机制，依次进入每一个拦截器进行执行
		3. 效果
			1. 前置通知==》目标方法==》后置通知==》返回通知
			2. 前置通知==》目标方法==》后置通知==》异常通知
## Spring 事务管理
### Transactional注解
当方法上标注了Transactional注解，则说明该方法是事务方法  
### EnableTransactionManagement注解
开启基于注解的事务管理功能  
Spring事务管理的基本步骤
1. 在配置类上开启Spring的事务管理功能
```
@EnableTransactionManagement
public class TxConfig {
...
}
```
2. 向容器中配置事务管理器管理数据源
```
@Bean
public PlatformTransactionManager transactionManager(DataSource dataSource) {
    //管理数据源
    return new DataSourceTransactionManager(dataSource);
}
```
3. 在需要事务管理的方法上使用Transactional注解
### 原理
1. EnableTransactionManagement注解
	* 利用TransactionManagementConfigurationSelector给容器中会导入组件
	* 导入两个组件：**AutoProxyRegistrar、ProxyTransactionManagementConfiguration**
2. AutoProxyRegistrar
	*  给容器中注册一个 InfrastructureAdvisorAutoProxyCreator 组件。这个组件的作用是利用后置处理器机制在对象创建以后，包装对象，返回一个代理对象（增强器），代理对象执行方法利用拦截器链进行调用
3. ProxyTransactionManagementConfiguration的作用
	* 给容器中注册事务增强器 
		* 事务增强器要用事务注解的信息，AnnotationTransactionAttributeSource解析事务注解
		* 事务拦截器
			* TransactionInterceptor；保存了事务属性信息，事务管理器，它是一个 MethodInterceptor
			* 事务拦截器
				1. 先获取事务相关的属性
				2. 再获取PlatformTransactionManager，如果事先没有添加指定任何transactionmanger，最终会从容器中按照类型获取一个PlatformTransactionManager；
				3. 执行目标方法

## 扩展
### BeanFactoryPostProcessor
与*BeanPostProcessor*不同，BeanPostProcessor是bean的后置处理器，bean创建对象初始化前后进行拦截工作  
**BeanFactoryPostProcessor**是一个接口，beanFactory的后置处理器，在BeanFactory标准初始化之后调用，也就是所有的bean定义已经保存加载到BeanFactory中，但是bean的实例还没有创建  
执行流程：
1. IOC容器创建对象
2. invokeBeanFactoryPostProcessors(beanFactory)方法执行
	1.直接在BeanFactory中找到所有类型是 BeanFactoryPostProcessor的组件
3. 执行单实例Bean的初始化finishBeanFactoryInitialization(beanFactory)
### BeanDefinitionRegistryPostProcessor接口
BeanDefinitionRegistryPostProcessor接口属于BeanFactoryPostProcessor的子接口，其额外定义了一个方法  
`void postProcessBeanDefinitionRegistry(BeanDefinitionRegistry registry)`
BeanDefinitionRegistry保存每一个创建的bean实例的信息  
在所有bean定义信息将要被加载， bean实例还未创建。这个接口优先于BeanFactoryPostProcessor执行，可以利用其**postProcessBeanDefinitionRegistry方法**可以向容器中额外添加一些组件
### ApplicationListener
**ApplicationListener**是一个接口，可以监听容器中发布的事件
`public interface ApplicationListener<E extends ApplicationEvent> extends EventListener`
监听**ApplicationEvent**及其下面的子事件  
当容器中发布要监听的事件时，接口中的方法触发
```
//当容器中发布此事件，方法触发
@Override
public void onApplicationEvent(ApplicationEvent event) {
    System.out.println("收到事件");
}
```
如果实现了这个接口，默认容器刷新完成和关闭容器都会触发上面的方法  
自己实现事件监听
1. 写一个监听器来监听，事件需要是*ApplicationEvent*的子类
2. 把监听器放入容器
3. 只要容器中有相关事件的发布，就能监听到这个事件
4. 发布一个事件
```
context.publishEvent(new ApplicationEvent("我发布的事件") {
        }); 
```
**原理**  
1. ContextRefreshedEvent事件
	1. 容器创建调用refresh()刷新容器
	2. refresh方法里的finishRefresh()方法完成容器刷新
	3. finishRefresh()方法发布事件 publishEvent(new ContextRefreshedEvent(this));
		1. publishEvent方法中通过getApplicationEventMulticaster()获取事件的派发器
		2. 派发器调用multicastEvent方法派发事件
		3. 在multicastEvent方法中获取所有的ApplicationListeners
			1. 判断是同步派发还是异步派发
			2. 拿到listener调用onApplicationEvent方法
### EventListener注解
当一个普通方法上使用EventListener注解后，该方法就可以变成监听方法，在方法的形式参数上使用ApplicationEvent接收监听到的事件
```
@EventListener(classes = {ApplicationEvent.class})
public void listen(ApplicationEvent applicationEvent) {
    System.out.println("UserService监听到的事件" + applicationEvent);
}
```
### Spring容器的创建过程
**Spring容器的refresh()**  
```
Spring容器的refresh()【创建刷新】;
1、prepareRefresh()刷新前的预处理;
	1）、initPropertySources()初始化一些属性设置;子类自定义个性化的属性设置方法；
	2）、getEnvironment().validateRequiredProperties();检验属性的合法等
	3）、earlyApplicationEvents= new LinkedHashSet<ApplicationEvent>();保存容器中的一些早期的事件；
2、obtainFreshBeanFactory();获取BeanFactory；
	1）、refreshBeanFactory();刷新【创建】BeanFactory；
			创建了一个this.beanFactory = new DefaultListableBeanFactory();
			设置id；
	2）、getBeanFactory();返回刚才GenericApplicationContext创建的BeanFactory对象；
	3）、将创建的BeanFactory【DefaultListableBeanFactory】返回；
3、prepareBeanFactory(beanFactory);BeanFactory的预准备工作（BeanFactory进行一些设置）；
	1）、设置BeanFactory的类加载器、支持表达式解析器...
	2）、添加部分BeanPostProcessor【ApplicationContextAwareProcessor】
	3）、设置忽略的自动装配的接口EnvironmentAware、EmbeddedValueResolverAware、xxx；
	4）、注册可以解析的自动装配；我们能直接在任何组件中自动注入：
			BeanFactory、ResourceLoader、ApplicationEventPublisher、ApplicationContext
	5）、添加BeanPostProcessor【ApplicationListenerDetector】
	6）、添加编译时的AspectJ；
	7）、给BeanFactory中注册一些能用的组件；
		environment【ConfigurableEnvironment】、
		systemProperties【Map<String, Object>】、
		systemEnvironment【Map<String, Object>】
4、postProcessBeanFactory(beanFactory);BeanFactory准备工作完成后进行的后置处理工作；
	1）、子类通过重写这个方法来在BeanFactory创建并预准备完成以后做进一步的设置
======================以上是BeanFactory的创建及预准备工作==================================
5、invokeBeanFactoryPostProcessors(beanFactory);执行BeanFactoryPostProcessor的方法；
	BeanFactoryPostProcessor：BeanFactory的后置处理器。在BeanFactory标准初始化之后执行的；
	两个接口：BeanFactoryPostProcessor、BeanDefinitionRegistryPostProcessor
	1）、执行BeanFactoryPostProcessor的方法；
		先执行BeanDefinitionRegistryPostProcessor
		1）、获取所有的BeanDefinitionRegistryPostProcessor；
		2）、看先执行实现了PriorityOrdered优先级接口的BeanDefinitionRegistryPostProcessor、
			postProcessor.postProcessBeanDefinitionRegistry(registry)
		3）、在执行实现了Ordered顺序接口的BeanDefinitionRegistryPostProcessor；
			postProcessor.postProcessBeanDefinitionRegistry(registry)
		4）、最后执行没有实现任何优先级或者是顺序接口的BeanDefinitionRegistryPostProcessors；
			postProcessor.postProcessBeanDefinitionRegistry(registry)
			
		
		再执行BeanFactoryPostProcessor的方法
		1）、获取所有的BeanFactoryPostProcessor
		2）、看先执行实现了PriorityOrdered优先级接口的BeanFactoryPostProcessor、
			postProcessor.postProcessBeanFactory()
		3）、在执行实现了Ordered顺序接口的BeanFactoryPostProcessor；
			postProcessor.postProcessBeanFactory()
		4）、最后执行没有实现任何优先级或者是顺序接口的BeanFactoryPostProcessor；
			postProcessor.postProcessBeanFactory()
6、registerBeanPostProcessors(beanFactory);注册BeanPostProcessor（Bean的后置处理器）【 intercept bean creation】
		不同接口类型的BeanPostProcessor；在Bean创建前后的执行时机是不一样的
		BeanPostProcessor、
		DestructionAwareBeanPostProcessor、
		InstantiationAwareBeanPostProcessor、
		SmartInstantiationAwareBeanPostProcessor、
		MergedBeanDefinitionPostProcessor【internalPostProcessors】、
		
		1）、获取所有的 BeanPostProcessor;后置处理器都默认可以通过PriorityOrdered、Ordered接口来执行优先级
		2）、先注册PriorityOrdered优先级接口的BeanPostProcessor；
			把每一个BeanPostProcessor；添加到BeanFactory中
			beanFactory.addBeanPostProcessor(postProcessor);
		3）、再注册Ordered接口的
		4）、最后注册没有实现任何优先级接口的
		5）、最终注册MergedBeanDefinitionPostProcessor；
		6）、注册一个ApplicationListenerDetector；来在Bean创建完成后检查是否是ApplicationListener，如果是
			applicationContext.addApplicationListener((ApplicationListener<?>) bean);
7、initMessageSource();初始化MessageSource组件（做国际化功能；消息绑定，消息解析）；
		1）、获取BeanFactory
		2）、看容器中是否有id为messageSource的，类型是MessageSource的组件
			如果有赋值给messageSource，如果没有自己创建一个DelegatingMessageSource；
				MessageSource：取出国际化配置文件中的某个key的值；能按照区域信息获取；
		3）、把创建好的MessageSource注册在容器中，以后获取国际化配置文件的值的时候，可以自动注入MessageSource；
			beanFactory.registerSingleton(MESSAGE_SOURCE_BEAN_NAME, this.messageSource);	
			MessageSource.getMessage(String code, Object[] args, String defaultMessage, Locale locale);
8、initApplicationEventMulticaster();初始化事件派发器；
		1）、获取BeanFactory
		2）、从BeanFactory中获取applicationEventMulticaster的ApplicationEventMulticaster；
		3）、如果上一步没有配置；创建一个SimpleApplicationEventMulticaster
		4）、将创建的ApplicationEventMulticaster添加到BeanFactory中，以后其他组件直接自动注入
9、onRefresh();留给子容器（子类）
		1、子类重写这个方法，在容器刷新的时候可以自定义逻辑；
10、registerListeners();给容器中将所有项目里面的ApplicationListener注册进来；
		1、从容器中拿到所有的ApplicationListener
		2、将每个监听器添加到事件派发器中；
			getApplicationEventMulticaster().addApplicationListenerBean(listenerBeanName);
		3、派发之前步骤产生的事件；
11、finishBeanFactoryInitialization(beanFactory);初始化所有剩下的单实例bean；
	1、beanFactory.preInstantiateSingletons();初始化后剩下的单实例bean
		1）、获取容器中的所有Bean，依次进行初始化和创建对象
		2）、获取Bean的定义信息；RootBeanDefinition
		3）、Bean不是抽象的，是单实例的，不是懒加载；
			1）、判断是否是FactoryBean；是否是实现FactoryBean接口的Bean；
			2）、不是工厂Bean。利用getBean(beanName);创建对象
				0、getBean(beanName)； ioc.getBean();
				1、doGetBean(name, null, null, false);
				2、先获取缓存中保存的单实例Bean。如果能获取到说明这个Bean之前被创建过（所有创建过的单实例Bean都会被缓存起来）
					从private final Map<String, Object> singletonObjects = new ConcurrentHashMap<String, Object>(256);获取的
				3、缓存中获取不到，开始Bean的创建对象流程；
				4、标记当前bean已经被创建
				5、获取Bean的定义信息；
				6、【获取当前Bean依赖的其他Bean;如果有按照getBean()把依赖的Bean先创建出来；】
				7、启动单实例Bean的创建流程；
					1）、createBean(beanName, mbd, args);
					2）、Object bean = resolveBeforeInstantiation(beanName, mbdToUse);让BeanPostProcessor先拦截返回代理对象；
						【InstantiationAwareBeanPostProcessor】：提前执行；
						先触发：postProcessBeforeInstantiation()；
						如果有返回值：触发postProcessAfterInitialization()；
					3）、如果前面的InstantiationAwareBeanPostProcessor没有返回代理对象；调用4）
					4）、Object beanInstance = doCreateBean(beanName, mbdToUse, args);创建Bean
						 1）、【创建Bean实例】；createBeanInstance(beanName, mbd, args);
						 	利用工厂方法或者对象的构造器创建出Bean实例；
						 2）、applyMergedBeanDefinitionPostProcessors(mbd, beanType, beanName);
						 	调用MergedBeanDefinitionPostProcessor的postProcessMergedBeanDefinition(mbd, beanType, beanName);
						 3）、【Bean属性赋值】populateBean(beanName, mbd, instanceWrapper);
						 	赋值之前：
						 	1）、拿到InstantiationAwareBeanPostProcessor后置处理器；
						 		postProcessAfterInstantiation()；
						 	2）、拿到InstantiationAwareBeanPostProcessor后置处理器；
						 		postProcessPropertyValues()；
						 	=====赋值之前：===
						 	3）、应用Bean属性的值；为属性利用setter方法等进行赋值；
						 		applyPropertyValues(beanName, mbd, bw, pvs);
						 4）、【Bean初始化】initializeBean(beanName, exposedObject, mbd);
						 	1）、【执行Aware接口方法】invokeAwareMethods(beanName, bean);执行xxxAware接口的方法
						 		BeanNameAware\BeanClassLoaderAware\BeanFactoryAware
						 	2）、【执行后置处理器初始化之前】applyBeanPostProcessorsBeforeInitialization(wrappedBean, beanName);
						 		BeanPostProcessor.postProcessBeforeInitialization（）;
						 	3）、【执行初始化方法】invokeInitMethods(beanName, wrappedBean, mbd);
						 		1）、是否是InitializingBean接口的实现；执行接口规定的初始化；
						 		2）、是否自定义初始化方法；
						 	4）、【执行后置处理器初始化之后】applyBeanPostProcessorsAfterInitialization
						 		BeanPostProcessor.postProcessAfterInitialization()；
						 5）、注册Bean的销毁方法；
					5）、将创建的Bean添加到缓存中singletonObjects；
				ioc容器就是这些Map；很多的Map里面保存了单实例Bean，环境信息。。。。；
		所有Bean都利用getBean创建完成以后；
			检查所有的Bean是否是SmartInitializingSingleton接口的；如果是；就执行afterSingletonsInstantiated()；
12、finishRefresh();完成BeanFactory的初始化创建工作；IOC容器就创建完成；
		1）、initLifecycleProcessor();初始化和生命周期有关的后置处理器；LifecycleProcessor
			默认从容器中找是否有lifecycleProcessor的组件【LifecycleProcessor】；如果没有new DefaultLifecycleProcessor();
			加入到容器；
			
			写一个LifecycleProcessor的实现类，可以在BeanFactory
				void onRefresh();
				void onClose();	
		2）、	getLifecycleProcessor().onRefresh();
			拿到前面定义的生命周期处理器（BeanFactory）；回调onRefresh()；
		3）、publishEvent(new ContextRefreshedEvent(this));发布容器刷新完成事件；
		4）、liveBeansView.registerApplicationContext(this);
	
	======总结===========
	1）、Spring容器在启动的时候，先会保存所有注册进来的Bean的定义信息；
		1）、xml注册bean；<bean>
		2）、注解注册Bean；@Service、@Component、@Bean、xxx
	2）、Spring容器会合适的时机创建这些Bean
		1）、用到这个bean的时候；利用getBean创建bean；创建好以后保存在容器中；
		2）、统一创建剩下所有的bean的时候；finishBeanFactoryInitialization()；
	3）、后置处理器；BeanPostProcessor
		1）、每一个bean创建完成，都会使用各种后置处理器进行处理；来增强bean的功能；
			AutowiredAnnotationBeanPostProcessor:处理自动注入
			AnnotationAwareAspectJAutoProxyCreator:来做AOP功能；
			xxx....
			增强的功能注解：
			AsyncAnnotationBeanPostProcessor
			....
	4）、事件驱动模型；
		ApplicationListener；事件监听；
		ApplicationEventMulticaster；事件派发：
```
## Servlet3.0
---
### WebServlet注解
**WebServlet注解**用来替代web.xml中Servlet的配置信息
```
@WebServlet("/hello")
public class HelloServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req,resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.getWriter().write("Hello");
    }
}

```
同样，注册Filter时，可以使用**WebFilter注解**；注册Listener时可以使用**WebListener注解**
### Shared libraries / runtimes pluggability
1. servlet容器启动会扫描当前应用里面每一个jar包的**ServletContainerInitializer**的实现
```
@HandlesTypes(value = {HelloService.class})
public class MyServletContainerInitializer implements ServletContainerInitializer {
    /**
     * 应用启动时运行onStartup方法
     *
     * @param c   HandlesTypes传递过来的类型及其子类型
     * @param ctx 代表当前web应用的ServletContext；一个web应用代表一个ServletContext
     * @throws ServletException
     */
    @Override
    public void onStartup(Set<Class<?>> c, ServletContext ctx) throws ServletException {
        for (Class<?> aClass : c) {
            System.out.println(aClass);
        }
    }
}
```
2. 提供**ServletContainerInitializer实现类**（ServletContainerInitializer是一个接口），且必须绑定在META-INF/services/javax.servlet.ServletContainerInitializer文件（自己手动创建即可，只是文件名必须是这个），文件的内容就是ServletContainerInitializer实现类的全类名  
> com.learn.servlet.MyServletContainerInitializer   

**总结**  
容器在启动应用的时候，会扫描当前应用每一个jar包里面META-INF/services/javax.servlet.ServletContainerInitializer指定的实现类，启动并运行这个类的实现方法

### HandlesTypes注解
HandlesTypes注解，容器启动时会将其指定的类的子类（包括子类和实现类，但是不包括传递的类本身，例如下面的代码不会把HelloService类传递过来）传递过来  
`@HandlesTypes(value = {HelloService.class})`  
### 使用ServletContext注册Web组件
```
@HandlesTypes(value = {HelloService.class})
public class MyServletContainerInitializer implements ServletContainerInitializer {
    /**
     * 应用启动时运行onStartup方法
     *
     * @param c   HandlesTypes传递过来的类型的子类型
     * @param ctx 代表当前web应用的ServletContext；一个web应用代表一个ServletContext
     * @throws ServletException
     */
    @Override
    public void onStartup(Set<Class<?>> c, ServletContext ctx) throws ServletException {
        for (Class<?> aClass : c) {
            System.out.println(aClass);
        }
        //注册组件
        ServletRegistration.Dynamic userServlet = ctx.addServlet("userServlet", new UserServlet());
        userServlet.addMapping("/user");

        //添加一个Listener
        ctx.addListener("com.learn.servlet.UserListener");

        //注册Filter
        FilterRegistration.Dynamic userFilter = ctx.addFilter("userFilter", UserFilter.class);
        userFilter.addMappingForUrlPatterns(EnumSet.of(DispatcherType.REQUEST),true,"/*");
    }
}

```
## 注解版的SpringMVC的开发
---
1. 容器在启动的时候会自动扫描每个jar包的*META-INF/services/javax.servlet.ServletContainerInitializer文件*，同时会加载这个文件指定的启动类。这个配置在springweb包下有现成的
2. spring的应用一启动会加载**WebApplicationInitializer接口**下的所有组件，并且为这些组件（不是接口和抽象类）创建对象
	1. 子类**AbstractContextLoaderInitializer**：创建根容器
	2. **AbstractDispatcherServletInitializer**
		1. 创建web的IOC容器
		2. 创建了一个DispatcherServlet
		3. 将创建的DispatcherServlet添加到ServletContext中
	3. **AbstractAnnotationConfigDispatcherServletInitializer**：注解方式配置Servlet
		1. 创建根容器：createRootApplicationContext() （重写了父类的方法）
		2. **createServletApplicationContext()**，创建web容器  

**总结**  
以注解方法启动SpringMVC，继承**AbstractAnnotationConfigDispatcherServletInitializer**，实现抽象方法指定DispatcherServlet的配置信息
### EnableWebMVC注解
开启SpringMVC定制配置功能，相当于原来使用xml配置如下  
` <mvc:annotation-driven/>`  
### WebMvcConfigurer接口
SpringMVC配置类实现该接口定制MVC的配置功能  
如下，**定制视图解析器**
```
@ComponentScan(basePackages = {"com.learn"},
        includeFilters = {@ComponentScan.Filter(type = FilterType.ANNOTATION, classes = Controller.class)},
        useDefaultFilters = false)
@EnableWebMvc
@Configuration
public class AppConfig implements WebMvcConfigurer {
    @Override
    public void configureViewResolvers(ViewResolverRegistry registry) {
        //默认所有页面都从WEB_INF下开始找所有的jsp页面
        //也可以自己制定规则
        registry.jsp("/WEB-INF/views/", ".jsp");
    }
}
```
**配置静态资源访问**
```
@Override
public void configureDefaultServletHandling(DefaultServletHandlerConfigurer configurer) {
    configurer.enable();
}
```
上面的代码在xml中是  
`<mvc:default-servlet-handler/>`  
**配置拦截器**，拦截hello请求
```
@Override
public void addInterceptors(InterceptorRegistry registry) {
    registry.addInterceptor(new MyFirstInterceptor()).addPathPatterns("/hello");
}
```  
在xml中同样的实现是
```
<mvc:interceptors>
    <mvc:interceptor>
        <mvc:mapping path="/hello"/>
        <bean class="com.learn.interceptors.MyFirstInterceptor"/>
    </mvc:interceptor>
</mvc:interceptors>
```
### Servlet的异步请求处理
使用注解开启异步处理  
`@WebServlet(value = "/async", asyncSupported = true)`  
测试案例  
```
@Override
protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    System.out.println("主线程开始..." + Thread.currentThread().getName());
    //1. 开启异步处理
    AsyncContext asyncContext = req.startAsync();
    asyncContext.start(() -> {
                System.out.println("副线程开始..." + Thread.currentThread().getName());
                sayHello();
                asyncContext.complete();
                //获取异步的上下文
                AsyncContext reqAsyncContext = req.getAsyncContext();
                //获取响应
                ServletResponse response = reqAsyncContext.getResponse();
                try {
                    response.getWriter().write("hello...async");
                    System.out.println("副线程结束..." + Thread.currentThread().getName());
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
    );
    System.out.println("主线程结束..." + Thread.currentThread().getName());
}

public void sayHello() {
    try {
        System.out.println(Thread.currentThread() + " processing...");
        Thread.sleep(3000);
    } catch (InterruptedException e) {
        e.printStackTrace();
    }
}
```
### SpringMVC中的异步处理
返回值为**Callable<String>**（参见官方文档）
```
@Controller
public class AsyncController {
    @RequestMapping("/async01")
    @ResponseBody
    public Callable<String> async01() {
        System.out.println("主线程开始...... " + Thread.currentThread().getName() + "==>" + System.currentTimeMillis());
        Callable<String> callable = new Callable<String>() {
            @Override
            public String call() throws Exception {
                System.out.println("副线程开始...... " + Thread.currentThread().getName() + "==>" + System.currentTimeMillis());
                Thread.sleep(2000);
                System.out.println("副线程结束...... " + Thread.currentThread().getName() + "==>" + System.currentTimeMillis());
                return "Callable<String> async01()";
            }
        };
        System.out.println("主线程结束...... " + Thread.currentThread().getName() + "==>" + System.currentTimeMillis());
        return callable;
    }
}

```
**思想**
1. 控制器返回Callable
2. Spring异步处理，将Callable提交到TaskExecutor使用一个隔离的线程进行执行
3. DispatcherServlet和所有的Filter退出web容器的线程，但是response保持打开状态
4. Callable返回结果，SpringMVC**将请求重新派发给容器**，恢复之前的处理
5. 根据Callable返回的结果，SpringMVC继续进行视图渲染流程等
> MyFirstInterceptor...preHandle...  
> 主线程开始...... http-nio-8080-exec-13==>1587440173826  
> 主线程结束...... http-nio-8080-exec-13==>1587440173827  
> 
**DispatcherServlet和所有的Filter退出线程**

> 副线程开始...... MvcAsync1==>1587440173833  
> 副线程结束...... MvcAsync1==>1587440175845  

**Callable执行完成**
> MyFirstInterceptor...preHandle...  
> MyFirstInterceptor...postHandle...（Callable的返回值就是目标方法的返回值）  
> MyFirstInterceptor...afterCompletion...  

### 异步拦截器
1. 原生的AsyncListener
2. 实现**AsyncHandlerInterceptor接口**


### SpringMVC异步请求返回DeferredResult
```
@ResponseBody
@RequestMapping("/createOrder")
public DeferredResult<Object> createOrder() {
    //如果3s超时，则返回超时结果
    DeferredResult<Object> deferredResult = new DeferredResult<>(3000L, "create fail");
    DeferredResultQueue.save(deferredResult);
    return deferredResult;
}

@ResponseBody
@RequestMapping("/create")
public String create() {
    String order = UUID.randomUUID().toString();
    DeferredResult<Object> deferredResult = DeferredResultQueue.get();
    deferredResult.setResult(order);
    return "success==>" + order;
}
```
```
public class DeferredResultQueue {
    private static Queue<DeferredResult<Object>> queue = new ConcurrentLinkedDeque<>();

    public static void save(DeferredResult<Object> deferredResult) {
        queue.add(deferredResult);
    }

    public static DeferredResult<Object> get() {
        return queue.poll();
    }
}
```