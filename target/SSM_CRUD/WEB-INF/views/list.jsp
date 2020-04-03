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
            <table class="table table-hover">
                <tr>
                    <th>#</th>
                    <th>empName</th>
                    <th>gender</th>
                    <th>email</th>
                    <th>deptName</th>
                    <th>操作</th>
                </tr>

                <c:forEach items="${requestScope.pageInfo.list}" var="emp">
                    <tr>
                        <td>${emp.empId}</td>
                        <td>${emp.empName}</td>
                        <td>${emp.gender=="m"?"男":"女"}</td>
                        <td>${emp.email}</td>
                        <td>${emp.department.deptName}</td>
                        <td>
                            <button class="btn btn-primary btn-sm">
                                <span class="glyphicon glyphicon-pencil" aria-hidden="true"></span> 编辑
                            </button>
                            <button class="btn btn-danger btn-sm">
                                <span class="glyphicon glyphicon-trash" aria-hidden="true"></span>删除
                            </button>
                        </td>
                    </tr>
                </c:forEach>
            </table>
        </div>
    </div>
    <%--    分页信息--%>
    <div class="row">
        <%--       分页文字信息 --%>
        <div class="col-md-6">
            当前第${requestScope.pageInfo.pageNum}页，一共${requestScope.pageInfo.pages}页，总共${requestScope.pageInfo.total}条记录
        </div>
        <%--        分页条信息--%>
        <div class="col-md-6">
            <nav aria-label="Page navigation">
                <ul class="pagination">
                    <li>
                        <a href="${requestScope.APP_PATH}/emps">首页</a>
                    </li>
                    <%--                    如果有上一页才显示上一页的图标--%>
                    <c:if test="${requestScope.pageInfo.hasPreviousPage}">
                        <li>
                            <a href="${requestScope.APP_PATH}/emps?pn=${requestScope.pageInfo.pageNum - 1}"
                               aria-label="Previous">
                                <span aria-hidden="true">&laquo;</span>
                            </a>
                        </li>
                    </c:if>

                    <%--                    遍历获取pageInfo中的页码数组--%>
                    <c:forEach items="${requestScope.pageInfo.navigatepageNums}" var="pageNum">
                        <c:if test="${pageNum==requestScope.pageInfo.pageNum}">
                            <li class="active"><a href="#">${pageNum}</a></li>
                        </c:if>
                        <c:if test="${pageNum!=requestScope.pageInfo.pageNum}">
                            <li><a href="${requestScope.APP_PATH}/emps?pn=${pageNum}">${pageNum}</a></li>
                        </c:if>
                    </c:forEach>
                    <%--       判断是否有下一页，如果有才显示 --%>
                    <c:if test="${requestScope.pageInfo.hasNextPage}">
                        <li>
                            <a href="${requestScope.APP_PATH}/emps?pn=${requestScope.pageInfo.pageNum + 1}" aria-label="Next">
                                <span aria-hidden="true">&raquo;</span>
                            </a>
                        </li>
                    </c:if>

                    <li>
                        <a href="${requestScope.APP_PATH}/emps?pn=${requestScope.pageInfo.pages}">末页</a>
                    </li>
                </ul>
            </nav>
        </div>

    </div>
</div>
</body>
</html>
