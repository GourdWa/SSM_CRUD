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
            <button class="btn btn-primary">新增</button>
            <button class="btn btn-danger">删除</button>
        </div>
    </div>
    <%--    表格数据--%>
    <div class="row">
        <div class=".col-md-12">
            <table class="table table-hover" id="emps_table">
                <thead>
                <tr>
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
        <div class="col-md-6">
            当前第 页，一共 页，总共 条记录
        </div>
        <%--        分页条信息--%>
        <div class="col-md-6">

        </div>
    </div>
</div>
<script type="text/javascript">
    //页面加载完成后发送AJAX请求要到分页数据
    $(function () {
        $.ajax({
            url: "${requestScope.APP_PATH}/emps",
            data: "pn=1",
            type: "GET",
            success: function (result) {
                // console.log(result.msg.extend.pageInfo)
                //1、解析并显示员工信息
                build_emps_table(result)
                //2、解析并显示分页信息

            }
        })
    })

    function build_emps_table(result) {
        var emps = result.msg.extend.pageInfo.list;
        //index索引；item当前的元素
        $.each(emps, function (index, item) {
            var empIdTd = $("<td></td>").append(item.empId);
            var empNameId = $("<td></td>").append(item.empName);
            var genderId = $("<td></td>").append(item.gender == 'm' ? "男" : "女");
            var emailId = $("<td></td>").append(item.email);
            var deptNameId = $("<td></td>").append(item.department.deptName);

            var editBtn =　$("<button></button>").addClass("btn btn-primary btn-sm")
                .append($("<span></span>")).addClass("glyphicon glyphicon-pencil")
                .append("编辑")
            var deleteBtn =　$("<button></button>").addClass("btn btn-danger btn-sm")
                .append($("<span></span>")).addClass("glyphicon glyphicon-trash")
                .append("删除")
            var btnTd = $("<td></td>").append(editBtn).append(" ").append(deleteBtn);
            $("<tr></tr>").append(empIdTd)
                .append(empNameId)
                .append(genderId)
                .append(emailId)
                .append(deptNameId)
                .append(btnTd)
                .appendTo("#emps_table tbody");
        })
    }

    function build_page_nav(result) {

    }
</script>
</body>
</html>
