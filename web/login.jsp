<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>UCMS - Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body class="bg-gray-50">
    <% 
        String error = request.getParameter("error"); 
        String success = request.getParameter("success"); 
    %>

    <div class="ucms-layout">
        <div class="ucms-left-panel">
            <div class="p-8 max-w-lg w-full">
                
                <%-- ALERT AREA --%>
                <div class="mb-6">
                    <% if (success != null) { %>
                        <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 rounded shadow-sm flex items-center">
                            <span class="mr-2">✅</span>
                            <p class="text-sm font-bold"><%= success %></p>
                        </div>
                    <% } %>

                    <% if (error != null) { %>
                        <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 rounded shadow-sm flex items-center">
                            <span class="mr-2">⚠️</span>
                            <p class="text-sm font-bold"><%= error %></p>
                        </div>
                    <% } %>
                </div>

                <div class="flex justify-center mb-6">
                    <div class="bg-gray-200 p-1 rounded-lg flex">
                        <button type="button" id="student-tab" onclick="switchRole('student')" class="px-4 py-2 rounded-md bg-white shadow-sm font-bold transition-all">Student</button>
                        <button type="button" id="admin-tab" onclick="switchRole('admin')" class="px-4 py-2 rounded-md text-gray-600 transition-all">Admin</button>
                    </div>
                </div>

                <h2 id="login-title" class="text-3xl font-extrabold mb-8 text-center uppercase">Student Login</h2>

                <form id="login-form" action="login" method="POST" class="space-y-6">
                    <div class="ucms-input-box">
                        <div>
                            <label id="id-label" for="login-id" class="ucms-label text-sm font-bold">STUDENT ID</label>
                            <input type="text" id="login-id" name="studentId" class="ucms-input-field w-full p-2 border rounded" required>
                        </div>
                        <div class="mt-4">
                            <label for="login-password" class="ucms-label text-sm font-bold">PASSWORD</label>
                            <input type="password" id="login-password" name="password" class="ucms-input-field w-full p-2 border rounded" required>
                        </div>
                        <div class="flex justify-center pt-8">
                            <button type="submit" class="bg-gray-900 text-white p-3 rounded-lg w-full font-bold hover:bg-gray-800 transition">LOGIN</button>
                        </div>
                        <p id="reg-link" class="mt-4 text-center text-sm text-gray-600">
                            Don't have an account? <a href="register.jsp" class="font-bold text-blue-600">Register Here</a>
                        </p>
                    </div>
                </form>
            </div>
        </div>

        <div class="ucms-right-panel hidden lg:block bg-cover bg-center" style="background-image: url('https://picsum.photos/id/200/800/800');">
            <div class="h-full flex flex-col justify-center items-center bg-black bg-opacity-40 text-white p-8">
                <p class="text-4xl font-extrabold text-center uppercase">Welcome Back</p>
                <p class="mt-4 text-lg font-light text-center">Enter your credentials to access the portal.</p>
            </div>
        </div>
    </div>

    <script>
        function switchRole(role) {
            const title = document.getElementById('login-title');
            const label = document.getElementById('id-label');
            const input = document.getElementById('login-id');
            const regLink = document.getElementById('reg-link');
            const sTab = document.getElementById('student-tab');
            const aTab = document.getElementById('admin-tab');

            if (role === 'admin') {
                title.innerText = 'Admin Login';
                label.innerText = 'ADMIN EMAIL';
                input.name = 'adminEmail';
                input.type = 'email';
                regLink.style.display = 'none';
                aTab.className = "px-4 py-2 rounded-md bg-white shadow-sm font-bold transition-all";
                sTab.className = "px-4 py-2 rounded-md text-gray-600 transition-all";
            } else {
                title.innerText = 'Student Login';
                label.innerText = 'STUDENT ID';
                input.name = 'studentId';
                input.type = 'text';
                regLink.style.display = 'block';
                sTab.className = "px-4 py-2 rounded-md bg-white shadow-sm font-bold transition-all";
                aTab.className = "px-4 py-2 rounded-md text-gray-600 transition-all";
            }
        }
    </script>
</body>
</html>