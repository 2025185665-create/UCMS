<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.Year" %>
<%
    String uri = request.getRequestURI();
    if (uri.endsWith("/") || uri.endsWith("UCMS2")) {
        response.sendRedirect("index.jsp");
        return;
    }

    String userRole = (String) session.getAttribute("userRole");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>UCMS - Welcome</title>
    
    <link rel="stylesheet" href="css/styles.css">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@100..900&display=swap" rel="stylesheet">

    <style>
        body { font-family: 'Inter', sans-serif !important; }
        
        .ucms-right-panel { 
            background-image: url('img/background.jpg'); 
            background-size: cover;
            background-position: center center;
            image-rendering: -webkit-optimize-contrast; /* Sharpens for Webkit browsers */
            image-rendering: high-quality;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        .overlay {
            position: absolute;
            inset: 0;
            background: rgba(30, 41, 59, 0.35); 
            z-index: 1;
        }

        .panel-content {
            position: relative;
            z-index: 10;
            /* Subtle text shadow to maintain readability over the clear image */
            text-shadow: 0 4px 10px rgba(0,0,0,0.5);
        }
    </style>
</head>
<body class="bg-gray-50 min-h-screen flex flex-col">

    <div class="ucms-layout flex-grow">
        <div class="ucms-left-panel">
            <div class="p-8 max-w-lg w-full text-center">
                <h1 class="text-4xl font-extrabold mb-4 text-slate-800 tracking-tighter uppercase">
                    University Club Management System
                </h1>
                <p class="text-gray-600 mb-10 text-lg">
                    Your centralized platform for managing and joining university clubs and events.
                </p>
                
                <div class="flex flex-col items-center space-y-5">
                  <% if (userRole == null) { %>
                      <a href="login.jsp" class="bg-[#568ca1] text-white p-4 rounded-xl w-full max-w-xs font-black hover:bg-[#457283] transition-all shadow-xl active:scale-95 text-center uppercase tracking-widest no-underline">
                          LOG IN
                      </a>
                      <a href="register.jsp" class="bg-white border-2 border-slate-200 text-slate-800 p-4 rounded-xl w-full max-w-xs font-black hover:bg-slate-50 transition-all active:scale-95 text-center uppercase tracking-wider no-underline">
                          REGISTER
                      </a>
                  <% } else { %>
                      <a href="<%= "admin".equals(userRole) ? "AdminDashboardController" : "MyProfileController" %>" 
                         class="bg-[#568ca1] text-white p-4 rounded-xl w-full max-w-xs font-black hover:bg-[#457283] transition-all shadow-xl text-center uppercase tracking-widest no-underline">
                          ENTER PORTAL
                      </a>
                      <a href="logout" class="text-red-500 font-bold mt-4 hover:underline uppercase text-xs tracking-widest no-underline">Logout Account</a>
                  <% } %>
                </div>
            </div>
        </div>

        <div class="ucms-right-panel hidden lg:flex">
            <div class="overlay"></div>
            
            <div class="panel-content text-white text-center p-8">
                <p class="text-6xl font-black tracking-tighter leading-none uppercase">Engage.<br>Lead. Grow.</p>
                <div class="w-20 h-1.5 bg-white/80 mx-auto my-8 rounded-full"></div>
                <p class="text-xl font-semibold opacity-100">Explore a world of opportunities on campus.</p>
            </div>
        </div>
    </div>   

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