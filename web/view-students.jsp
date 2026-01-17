<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.ucms2.model.Student" %>
<%
    List<Student> students = (List<Student>) request.getAttribute("studentList");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin - Student Directory</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 p-8">
    <div class="max-w-5xl mx-auto bg-white rounded-xl shadow-lg overflow-hidden">
        <div class="bg-gray-800 p-6 text-white flex justify-between items-center">
            <h2 class="text-2xl font-bold uppercase">Registered Students</h2>
            <a href="admin-dashboard-data" class="text-sm bg-gray-600 px-4 py-2 rounded">Back to Dashboard</a>
        </div>
        <table class="w-full text-left">
            <thead class="bg-gray-200 border-b">
                <tr>
                    <th class="p-4 font-bold text-gray-700">ID</th>
                    <th class="p-4 font-bold text-gray-700">NAME</th>
                    <th class="p-4 font-bold text-gray-700">EMAIL</th>
                    <th class="p-4 font-bold text-gray-700">JOINED DATE</th>
                </tr>
            </thead>
            <tbody>
                <% if (students != null) {
                    for (Student s : students) { %>
                    <tr class="border-b hover:bg-gray-50">
                        <td class="p-4 font-mono"><%= s.getStudentId() %></td>
                        <td class="p-4"><%= s.getStudentName() %></td>
                        <td class="p-4 text-blue-600"><%= s.getStudentEmail() %></td>
                        <td class="p-4 text-gray-500"><%= s.getCreatedAt() %></td>
                    </tr>
                <%  }
                } %>
            </tbody>
        </table>
    </div>
            <!-- Footer -->
<footer class="bg-white border-t border-gray-200 text-gray-500 text-sm text-center py-6">
    <div class="max-w-7xl mx-auto px-4">
        <p>
            &copy; <%= java.time.Year.now() %> University Club Management System. 
            All rights reserved.
        </p>
        <p class="mt-1">Made with ❤️ for university students</p>
    </div>
</footer>

</body>
</html>