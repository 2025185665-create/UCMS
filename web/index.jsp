<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Check if user is already logged in to provide a shortcut
    Object admin = session.getAttribute("admin");
    Object student = session.getAttribute("student");
    String userRole = (String) session.getAttribute("userRole");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>UCMS - Welcome</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@100..900&display=swap" rel="stylesheet">
</head>
<body class="bg-gray-50">
  <div class="flex flex-col md:flex-row h-screen w-full overflow-hidden">
    <%-- Left Panel --%>
    <div class="md:w-1/2 flex items-center justify-center bg-white p-8">
      <div class="max-w-lg w-full text-center">
        <h1 class="text-4xl font-extrabold mb-4 text-blue-600">University Club Management Society</h1>
        <p class="text-gray-600 mb-8 text-lg">Your centralized platform for managing and joining university clubs and events.</p>
        
        <div class="space-y-4 flex flex-col items-center">
          <% if (userRole == null) { %>
              <%-- User is not logged in --%>
              <a href="login.jsp" class="w-full max-w-xs py-3 px-6 bg-blue-600 text-white font-bold rounded-xl shadow-lg hover:bg-blue-700 transition duration-300 text-center">LOG IN</a>
              <a href="register.jsp" class="w-full max-w-xs py-3 px-6 border-2 border-blue-600 text-blue-600 font-bold rounded-xl hover:bg-blue-50 transition duration-300 text-center">REGISTER</a>
          <% } else if ("admin".equals(userRole)) { %>
              <%-- Shortcut for Admin --%>
              <a href="admin-dashboard-data" class="w-full max-w-xs py-3 px-6 bg-green-600 text-white font-bold rounded-xl shadow-lg hover:bg-green-700 transition">GO TO ADMIN DASHBOARD</a>
              <a href="logout" class="text-red-500 font-bold mt-2">Logout</a>
          <% } else { %>
              <%-- Shortcut for Student --%>
              <a href="student-dashboard.jsp" class="w-full max-w-xs py-3 px-6 bg-blue-500 text-white font-bold rounded-xl shadow-lg hover:bg-blue-600 transition">GO TO STUDENT PORTAL</a>
              <a href="logout" class="text-red-500 font-bold mt-2">Logout</a>
          <% } %>
        </div>
      </div>
    </div>

    <%-- Right Panel --%>
    <div class="hidden md:flex md:w-1/2 bg-cover bg-center items-center justify-center relative" 
         style="background-image: url('https://picsum.photos/id/400/800/800');">
      <div class="absolute inset-0 bg-blue-900 opacity-40"></div>
      <div class="relative z-10 p-8 text-white text-center">
        <p class="text-5xl font-extrabold tracking-tight">Engage. Lead. Grow.</p>
        <p class="mt-4 text-xl font-light">Explore a world of opportunities on campus.</p>
      </div>
    </div>
  </div>
</body>
</html>