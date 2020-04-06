<%--
  Created by IntelliJ IDEA.
  User: 18224
  Date: 2020/4/3
  Time: 14:07
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>员工列表</title>
    <%
        request.setAttribute("APP_PATH", request.getContextPath());
    %>

    <script src="https://cdn.staticfile.org/jquery/2.1.1/jquery.min.js"></script>
    <%--  引入bootstrap样式  --%>
    <link href="${requestScope.APP_PATH}/static/bootstrap-3.3.7-dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="${requestScope.APP_PATH}/static/bootstrap-3.3.7-dist/js/bootstrap.min.js"></script>
</head>
<body>
<%--员工添加的模态框--%>
<!-- Modal -->
<div class="modal fade" id="empAddModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">员工添加</h4>
            </div>
            <div class="modal-body">
                <%--                表单--%>
                <form class="form-horizontal">
                    <div class="form-group">
                        <label for="empName_add_input" class="col-sm-2 control-label">EmpName</label>
                        <div class="col-sm-10">
                            <input type="text" name="empName" class="form-control" id="empName_add_input"
                                   placeholder="EmpName">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="email_add_input" class="col-sm-2 control-label">Email</label>
                        <div class="col-sm-10">
                            <input type="text" name="email" class="form-control" id="email_add_input"
                                   placeholder="email@qq.com">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <%--                        性别选择框--%>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">Gender</label>
                        <div class="col-sm-10">
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender1_add_input" value="m" checked="checked"> 男
                            </label>
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender2_add_input" value="f"> 女
                            </label>
                        </div>
                    </div>
                    <%--          部门选择框          --%>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">deptName</label>
                        <div class="col-sm-4">
                            <%--                            部门id提交即可--%>
                            <select class="form-control" name="dId" id="dept_add_select">

                            </select>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="emp_save_btn">保存</button>
            </div>
        </div>
    </div>
</div>


<%--员工修改的模态框--%>
<div class="modal fade" id="empUpdateModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span>
                </button>
                <h4 class="modal-title">员工修改</h4>
            </div>
            <div class="modal-body">
                <%--                表单--%>
                <form class="form-horizontal">
                    <div class="form-group">
                        <label for="empName_add_input" class="col-sm-2 control-label">EmpName</label>
                        <div class="col-sm-10">
                            <p class="form-control-static" id="empName_update_static"></p>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="email_add_input" class="col-sm-2 control-label">Email</label>
                        <div class="col-sm-10">
                            <input type="text" name="email" class="form-control" id="email_update_input"
                                   placeholder="email@qq.com">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <%--                        性别选择框--%>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">Gender</label>
                        <div class="col-sm-10">
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender1_update_input" value="m" checked="checked">
                                男
                            </label>
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender2_update_input" value="f"> 女
                            </label>
                        </div>
                    </div>
                    <%--          部门选择框          --%>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">deptName</label>
                        <div class="col-sm-4">
                            <%--                            部门id提交即可--%>
                            <select class="form-control" name="dId" id="dept_update_select">

                            </select>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="emp_update_btn">更新</button>
            </div>
        </div>
    </div>
</div>

<%--  搭建显示页面  --%>
<div class="container">
    <%--   标题行 --%>
    <div class="row">
        <div class=".col-md-12">
            <h1>SSM_CRUD</h1>
        </div>
    </div>
    <%--    按钮--%>
    <div class="row">
        <div class="col-md-4 col-md-offset-8">
            <button class="btn btn-primary" id="emp_add_modal_btn">新增</button>
            <button class="btn btn-danger" id="emp_delete_all_btn">删除</button>
        </div>
    </div>
    <%--    表格数据--%>
    <div class="row">
        <div class=".col-md-12">
            <table class="table table-hover" id="emps_table">
                <thead>
                <tr>
                    <th><input type="checkbox" id="check_all"></th>
                    <th>id</th>
                    <th>empName</th>
                    <th>gender</th>
                    <th>email</th>
                    <th>deptName</th>
                    <th>操作</th>
                </tr>
                </thead>
                <tbody>

                </tbody>

            </table>
        </div>
    </div>
    <%--    分页信息--%>
    <div class="row">
        <%--       分页文字信息 --%>
        <div class="col-md-6" id="page_info_area">

        </div>
        <%--        分页条信息--%>
        <div class="col-md-6" id="page_nav_area">

        </div>
    </div>
</div>
<script type="text/javascript">

    var totalRecord;
    var currentPage;
    //页面加载完成后发送AJAX请求要到分页数据,直接去首页
    $(function () {
        to_page(1)
    })

    //页面跳转
    function to_page(pn) {
        $.ajax({
            url: "${requestScope.APP_PATH}/emps",
            data: "pn=" + pn,
            type: "GET",
            success: function (result) {
                // console.log(result.msg.extend.pageInfo)
                //1、解析并显示员工信息
                build_emps_table(result)
                //2、解析并显示分页信息
                build_page_info(result)
                //3、构建导航条
                build_page_nav(result)
            }
        })
    }


    function build_emps_table(result) {
        $("#emps_table tbody").empty();
        var emps = result.msg.extend.pageInfo.list;
        //index索引；item当前的元素
        $.each(emps, function (index, item) {
            var checkBoxTd = $("<td><input type='checkbox' class='check_item'/></td>")
            var empIdTd = $("<td></td>").append(item.empId);
            var empNameId = $("<td></td>").append(item.empName);
            var genderId = $("<td></td>").append(item.gender == 'm' ? "男" : "女");
            var emailId = $("<td></td>").append(item.email);
            var deptNameId = $("<td></td>").append(item.department.deptName);

            var editBtn = $("<button></button>").addClass("btn btn-primary btn-sm edit_btn")
                .append($("<span></span>")).addClass("glyphicon glyphicon-pencil")
                .append("编辑")
            //为编辑按钮添加一个自定义属性，表示当前员工id
            editBtn.attr("edit-id", item.empId);
            var deleteBtn = $("<button></button>").addClass("btn btn-danger btn-sm delete_btn")
                .append($("<span></span>")).addClass("glyphicon glyphicon-trash")
                .append("删除")
            //为删除按钮添加一个自定义属性，表示当前员工的id
            deleteBtn.attr("delete-id", item.empId);
            var btnTd = $("<td></td>").append(editBtn).append(" ").append(deleteBtn);
            $("<tr></tr>").append(checkBoxTd).append(empIdTd)
                .append(empNameId)
                .append(genderId)
                .append(emailId)
                .append(deptNameId)
                .append(btnTd)
                .appendTo("#emps_table tbody");
        })
    }

    //解析显示分页信息
    function build_page_info(result) {
        $("#page_info_area").empty();
        $("#page_info_area").append("当前第" + result.msg.extend.pageInfo.pageNum +
            " 页，一共 " + result.msg.extend.pageInfo.pages + "页，总共" + result.msg.extend.pageInfo.total + " 条记录")
        totalRecord = result.msg.extend.pageInfo.total;
        currentPage = result.msg.extend.pageInfo.pageNum
    }

    //解析显示分页条
    function build_page_nav(result) {
        $("#page_nav_area").empty();
        //***************************构建元素**********************************
        var ul = $("<ul></ul>").addClass("pagination");
        var firstPageLi = $("<li></li>").append($("<a></a>").append("首页").attr("href", "#"));
        var prePageLi = $("<li></li>").append($("<a></a>").append("&laquo;"));
        //如果没有前一页
        if (result.msg.extend.pageInfo.hasPreviousPage == false) {
            firstPageLi.addClass("disabled");
            prePageLi.addClass("disabled");
        } else {
            //否则绑定跳转事件
            firstPageLi.click(function () {
                to_page(1);
            })
            prePageLi.click(function () {
                to_page(result.msg.extend.pageInfo.pageNum - 1)
            })
        }
        var nextPageLi = $("<li></li>").append($("<a></a>").append("&raquo;"));
        var lastPageLi = $("<li></li>").append($("<a></a>").append("末页").attr("href", "#"));
        //如果没有下一页
        if (result.msg.extend.pageInfo.hasNextPage == false) {
            nextPageLi.addClass("disabled");
            lastPageLi.addClass("disabled");
        } else {
            //否则绑定跳转事件
            lastPageLi.click(function () {
                to_page(result.msg.extend.pageInfo.pages)
            })
            nextPageLi.click(function () {
                to_page(result.msg.extend.pageInfo.pageNum + 1)
            })
        }
        ul.append(firstPageLi).append(prePageLi);

        //遍历并获取导航栏并绑定单击事件
        $.each(result.msg.extend.pageInfo.navigatepageNums, function (index, item) {
            var numLi = $("<li></li>").append($("<a></a>").append(item).attr("href", "#"));
            if (result.msg.extend.pageInfo.pageNum == item) {
                numLi.addClass("active")
            }
            //点击页码后跳转
            numLi.click(function () {
                to_page(item)
            })
            ul.append(numLi);
        })
        ul.append(nextPageLi).append(lastPageLi);
        var navEle = ($("<nav></nav>").attr("aria-label", "Page navigation")).append(ul);
        $("#page_nav_area").append(navEle)
    }

    //点击新增按钮弹出模态框
    $("#emp_add_modal_btn").click(function () {
        //模态框弹出前都清除表单数据，DOM对象才有重置，这里只重置了数据，用下面的自定义代替
        // $("#empAddModal form")[0].reset()
        //完整重置
        reset_form("#empAddModal form");
        //发送AJJAX请求，查出部门信息，显示下拉列表中
        getDepts("#dept_add_select");
        $("#empAddModal").modal({
            backdrop: "static"
        })
    })

    function reset_form(ele) {
        $(ele)[0].reset();
        //清空表单样式
        $(ele).find("*").removeClass("has-error has-success");
        $(ele).find(".help-block").text("")
    }

    //查出所有的部门信息并显示在下拉列表中
    function getDepts(ele) {
        $.ajax(
            {
                url: "${requestScope.APP_PATH}/depts",
                type: "GET",
                success: function (result) {
                    $(ele).empty()
                    $.each(result.msg.extend.depts, function (index, item) {
                        var optionEle = $("<option></option>").append(item.deptName).attr("value", item.deptId);
                        $(ele).append(optionEle)
                    })
                }
            }
        )
    }

    //校验表单数据
    function validate_add_form() {
        //1、使用正则表达式校验
        var empName = $("#empName_add_input").val();
        var regName = /(^[a-zA-Z0-9_-]{6,16}$)|(^[\u2E80-\u9FFF]{2,5})/;
        if (!regName.test(empName)) {
            // alert("用户名可以是2-5位种种或6-16位英文");
            show_validate_msg("#empName_add_input", "error", "用户名可以是2-5位种种或6-16位英文");
            return false;
        } else if ($("#emp_save_btn").attr("ajax-va") == "error") {
            show_validate_msg("#empName_add_input", "error", "用户名不可用");
            return false;
        } else {
            show_validate_msg("#empName_add_input", "success", "");
        }
        var email = $("#email_add_input").val();
        var regEmail = /^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/
        if (!regEmail.test(email)) {
            // alert("邮箱格式不符合要求")
            show_validate_msg("#email_add_input", "error", "邮箱格式不符合要求")
            return false;
        } else {
            show_validate_msg("#email_add_input", "success", "")
        }
        return true;
    }

    function show_validate_msg(ele, status, msg) {
        //    清楚当前元素校验
        $(ele).parent().removeClass("has-success has-error");
        $(ele).next("span").text(" ");
        if (status == "success") {
            $(ele).parent().addClass("has-success");
            $(ele).next("span").text(msg)
        } else if (status == "error") {
            $(ele).parent().addClass("has-error");
            $(ele).next("span").text(msg)
        }
    }

    //员工保存单击事件
    $("#emp_save_btn").click(function () {
        //    1、模态框中填写的数据提交服务器保存，借助表单序列化机制
        // $("#empAddModal form").serialize()
        //对提交的数据进行校验,前端校验
        if (!validate_add_form()) {
            return false;
        }
        //判断用户名校验是否成功，如果成功才继续
        if ($("#emp_save_btn").attr("ajax-va") == "error") {
            return false;
        }
        //    2、发送AJAX请求保存员工
        $.ajax({
            url: "${requestScope.APP_PATH}/emp",
            type: "POST",
            data: $("#empAddModal form").serialize(),
            success: function (result) {
                // alert(result.msg.msg)
                //判断后端JSR303校验是否成功
                if (result.msg.code == 100) {
                    //    当员工保存成功，关闭模态框并来到最后一页展示刚才保存的数据
                    $('#empAddModal').modal('hide');
                    //发送AJAX请求，跳转到最后一页，因为PageHelper插件，只要大于最后页码的数字都会跳转到最后一页
                    to_page(totalRecord + 1);
                } else {
                    //提示失败信息
                    if (result.msg.extend.errorField.email != undefined) {
                        show_validate_msg("#email_add_input", "error", result.msg.extend.errorField.email);
                    }
                    if (result.msg.extend.errorField.empName != undefined) {
                        show_validate_msg("#empName_add_input", "error", result.msg.extend.errorField.empName);
                    }
                    return;
                    //显示错误信息
                    // console.log(result.msg)
                }

                //第一版本不利用JSR303校验
                // //    当员工保存成功，关闭模态框并来到最后一页展示刚才保存的数据
                // $('#empAddModal').modal('hide');
                // //发送AJAX请求，跳转到最后一页，因为PageHelper插件，只要大于最后页码的数字都会跳转到最后一页
                // to_page(totalRecord + 1);
            }
        })

    })

    //    服务端的校验，避免用户名重复
    $("#empName_add_input").change(function () {
        //    发送AJAX请求，校验用户名是否可用
        $.ajax({
            url: "${requestScope.APP_PATH}/checkuser",
            type: "GET",
            data: "empName=" + $("#empName_add_input").val(),
            success: function (result) {
                // console.log(result)
                if (result.msg.code == 100) {
                    show_validate_msg("#empName_add_input", "success", "用户名可用");
                    $("#emp_save_btn").attr("ajax-va", "success");
                } else {
                    show_validate_msg("#empName_add_input", "error", result.msg.extend.va_msg);
                    $("#emp_save_btn").attr("ajax-va", "error");
                }
            }
        })
    })


    //    给编辑按钮绑定单击事件
    //因为是在按钮创建之前就绑定了事件（AJAX），利用live方法绑定方法（JQuery新版的live方法替换成了on)
    $(document).on("click", ".edit_btn", function () {
        //0、查出部门信息
        getDepts("#dept_update_select")
        //1.查出员工信息
        //通过JQuery查找
        // getEmp($(this).parent().parent().children(":first").text())
        //给编辑按钮构建一个属性，提前将员工id放入
        getEmp($(this).attr("edit-id"));
        // 2、把员工id传递给模态框的更新按钮
        $("#emp_update_btn").attr("edit-id", $(this).attr("edit-id"));
        $("#empUpdateModal").modal({
            backdrop: "static"
        })
    })

    //根据id获取员工信息
    function getEmp(id) {
        $.ajax({
            url: "${requestScope.APP_PATH}/emp/" + id,
            type: "GET",
            success: function (result) {
                $("#empName_update_static").empty();
                // console.log(result)
                var empEle = result.msg.extend.emp;
                $("#empName_update_static").append(empEle.empName);
                $("#email_update_input").val(empEle.email);
                $("#empUpdateModal input[name=gender]").val([empEle.gender]);
                $("#empUpdateModal select").val([empEle.dId])
            }
        })
    }

    //    点击更新，更新员工信息
    $("#emp_update_btn").click(function () {
        //验证邮箱是否合法
        var email = $("#email_update_input").val();
        var regEmail = /^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/
        if (!regEmail.test(email)) {
            show_validate_msg("#email_add_input", "error", "邮箱格式不符合要求")
            return false;
        } else {
            show_validate_msg("#email_add_input", "success", "")
        }

        //发送AJAX请求保存更新的数据
        $.ajax({
            url: "${requestScope.APP_PATH}/emp/" + $(this).attr("edit-id"),
            type: "PUT",//也可以直接,需要配置HttpPutFormContentFilter过滤器
            data: $("#empUpdateModal form").serialize()/*+"&_method=PUT"*/,
            success: function (result) {
                // alert(result.msg.msg)
                // 1、关闭模态框，回到本页面
                $("#empUpdateModal").modal('hide');
                to_page(currentPage);
            }
        })
    })


    //给删除按钮绑定单击事件
    $(document).on("click", ".delete_btn", function () {
        //        1 弹出确认删除对话框
        var empName = $(this).parents("tr").find("td:eq(2)").text();
        if (confirm("确认删除【" + empName + "】")) {
            //确认删除，发送AJAX请求
            $.ajax({
                url: "${requestScope.APP_PATH}/emp/" + $(this).attr("delete-id"),
                type: "DELETE",//
                success: function (result) {
                    // alert(result.msg)
                    to_page(currentPage)
                }
            })
        }
    })

    //    点击全选的按钮时，全部选中
    $("#check_all").click(function () {
        // alert($(this).prop("checked"))
        $(".check_item").prop("checked", $(this).prop("checked"))
    })

    //如果手动全选满，则全选框自动被选中
    $(document).on("click", ".check_item", function () {
        var flag = $(".check_item:checked").length == $(".check_item").length;
        $("#check_all").prop("checked", flag);
    })

    //    点击全部删除按钮
    $("#emp_delete_all_btn").click(function () {
        // $(".check_item").
        var empNames = "";
        var del_ids = ""
        $.each($(".check_item:checked"), function (index, item) {
            //将要被删除的员工姓名
            // alert($(this).parents("tr").find("td:eq(2)").text())
            empNames += $(this).parents("tr").find("td:eq(2)").text() + ","
            del_ids += $(this).parents("tr").find("td:eq(1)").text() + "-";
        })
        empNames = empNames.substr(0, empNames.length - 1);
        del_ids = del_ids.substr(0, del_ids.length - 1);
        if (confirm("确认删除【" + empNames + "】吗")) {
            $.ajax({
                url: "${requestScope.APP_PATH}/emp/" + del_ids,
                type: "DELETE",
                success: function (result) {
                    alert(result.msg)
                    to_page(currentPage)
                }
            })
        }
    })
</script>
</body>
</html>
