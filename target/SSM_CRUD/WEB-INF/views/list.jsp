<%--
  Created by IntelliJ IDEA.
  User: 18224
  Date: 2020/4/3
  Time: 14:07
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
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
            <table class="table table-hover">
                <tr>
                    <th>#</th>
                    <th>empName</th>
                    <th>gender</th>
                    <th>email</th>
                    <th>deptName</th>
                    <th>操作</th>
                </tr>
                <tr>
                    <td>1</td>
                    <td>aaa</td>
                    <td>男</td>
                    <td>aaa@qq.com</td>
                    <td>开发部</td>
                    <td>
                        <button class="btn btn-primary btn-sm">
                            <span class="glyphicon glyphicon-pencil" aria-hidden="true"></span> 编辑
                        </button>
                        <button class="btn btn-danger btn-sm">
                            <span class="glyphicon glyphicon-trash" aria-hidden="true"></span>删除
                        </button>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <%--    分页信息--%>
    <div class="row">
        <%--       分页文字信息 --%>
        <div class="col-md-6">
            当前记录数
        </div>
        <%--        分页条信息--%>
        <div class="col-md-6">
            <nav aria-label="Page navigation">
                <ul class="pagination">
                    <li>
                        <a href="#">首页</a>
                    </li>
                    <li>
                        <a href="#" aria-label="Previous">
                            <span aria-hidden="true">&laquo;</span>
                        </a>
                    </li>
                    <li><a href="#">1</a></li>
                    <li><a href="#">2</a></li>
                    <li><a href="#">3</a></li>
                    <li><a href="#">4</a></li>
                    <li><a href="#">5</a></li>
                    <li>
                        <a href="#" aria-label="Next">
                            <span aria-hidden="true">&raquo;</span>
                        </a>
                    </li>
                    <li>
                        <a href="#">末页</a>
                    </li>
                </ul>
            </nav>
        </div>

    </div>
</div>
</body>
</html>
