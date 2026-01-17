<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String userRole = (String) session.getAttribute("userRole");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>UCMS - Welcome</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&display=swap" rel="stylesheet">
     <link rel="stylesheet" href="css/style.css">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .ucms-layout { display: flex; min-height: 100vh; }
        .ucms-left-panel { flex: 1; display: flex; align-items: center; justify-content: center; background: white; }
        .ucms-right-panel { flex: 1.2; position: relative; background-image: url('https://images.unsplash.com/photo-1523050853063-9136a6ba7ce9?auto=format&fit=crop&w=1200&q=80'); background-size: cover; background-position: center; }
    </style>
</head>
<body class="bg-gray-50">
    <div class="ucms-layout">
        <div class="ucms-left-panel">
            <div class="p-8 max-w-lg w-full text-center">
                <h1 class="text-4xl font-black mb-4 text-slate-800 tracking-tighter uppercase">
                    University Club Management
                </h1>
                <p class="text-slate-500 mb-10 text-sm">
                    Your centralized platform for managing and joining university clubs and events.
                </p>
                
                <div class="flex flex-col items-center space-y-5">
                  <% if (userRole == null) { %>
                      <a href="login.jsp" class="bg-[#568ca1] text-white p-4 rounded-xl w-full max-w-xs font-black hover:bg-[#457283] transition-all shadow-xl active:scale-95 text-center uppercase tracking-widest">
                          LOG IN
                      </a>
                      <a href="register.jsp" class="bg-white border-2 border-slate-200 text-slate-800 p-4 rounded-xl w-full max-w-xs font-black hover:bg-slate-50 transition-all active:scale-95 text-center uppercase tracking-widest">
                          REGISTER
                      </a>
                  <% } else { %>
                      <a href="<%= "admin".equals(userRole) ? "AdminDashboardController" : "MyProfileController" %>" 
                         class="bg-[#568ca1] text-white p-4 rounded-xl w-full max-w-xs font-black hover:bg-[#457283] transition-all shadow-xl text-center uppercase tracking-widest">
                          ENTER PORTAL
                      </a>
                      <a href="logout" class="text-red-500 font-bold mt-4 hover:underline uppercase text-xs tracking-widest">Logout</a>
                  <% } %>
                </div>
            </div>
        </div>

        <div class="ucms-right-panel hidden lg:block">
            <div class="absolute inset-0 bg-[#3a5d6a]/70 backdrop-blur-[2px]"></div>
            <div class="relative h-full flex flex-col justify-center items-center text-white p-12 text-center">
                <p class="text-6xl font-black uppercase tracking-tighter leading-none">Engage. Lead. Grow.</p>
                <div class="w-16 h-1 bg-white/40 my-6"></div>
                <p class="text-xl font-light opacity-90">Explore a world of opportunities on campus.</p>
            </div>
        </div>
    </div>   
    <!-- Footer -->
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