<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>UCMS - Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .ucms-layout { display: flex; min-height: 100vh; }
        .ucms-left-panel { flex: 1; display: flex; align-items: center; justify-content: center; background: white; }
        
        /* High-Res Sharpness Fix */
        .ucms-right-panel { 
            flex: 1.2; 
            position: relative; 
            background-image: url('img/background.jpg'); 
            background-size: cover; 
            background-position: center;
            image-rendering: -webkit-optimize-contrast;
            image-rendering: high-quality;
        }
        
        .overlay {
            position: absolute;
            inset: 0;
            background: rgba(30, 41, 59, 0.45); 
            z-index: 1;
        }
        
        .panel-content {
            position: relative;
            z-index: 10;
            text-shadow: 0 4px 10px rgba(0,0,0,0.5);
        }
    </style>
</head>
<body class="bg-gray-50 flex flex-col min-h-screen">
    <% String error = request.getParameter("error"); String success = request.getParameter("success"); %>
    
    <div class="ucms-layout flex-grow">
        <div class="ucms-left-panel">
            <div class="p-8 max-w-md w-full mx-auto">
                <div class="mb-6">
                    <% if (success != null) { %><div class="bg-emerald-50 text-emerald-700 p-4 rounded-xl text-sm font-bold border border-emerald-100 mb-4 animate-pulse">✅ <%= success %></div><% } %>
                    <% if (error != null) { %><div class="bg-red-50 text-red-700 p-4 rounded-xl text-sm font-bold border border-red-100 mb-4">⚠️ <%= error %></div><% } %>
                </div>

                <div class="flex justify-center mb-8">
                    <div class="bg-slate-100 p-1 rounded-xl flex w-full">
                        <button type="button" id="student-tab" onclick="switchRole('student')" class="flex-1 px-4 py-2 rounded-lg bg-white shadow-sm font-black text-[10px] uppercase tracking-widest transition-all">Student</button>
                        <button type="button" id="admin-tab" onclick="switchRole('admin')" class="flex-1 px-4 py-2 rounded-lg text-slate-400 font-black text-[10px] uppercase tracking-widest transition-all">Admin</button>
                    </div>
                </div>

                <h2 id="login-title" class="text-3xl font-black mb-2 text-slate-800 tracking-tighter uppercase">Student Login</h2>
                <p id="login-subtitle" class="text-slate-500 mb-8 text-sm">Please enter your credentials to continue.</p>

                <form id="login-form" action="LoginServlet" method="POST" class="space-y-5">
                    <input type="hidden" id="userRole" name="userRole" value="student">
                    <div>
                        <label id="id-label" class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 block ml-1">Student ID</label>
                        <input type="text" id="login-id" name="studentId" class="w-full p-4 bg-slate-50 border border-slate-200 rounded-2xl outline-none focus:ring-2 focus:ring-[#568ca1] font-semibold" placeholder="B032110xxx" required>
                    </div>
                    <div>
                        <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 block ml-1">Password</label>
                        <input type="password" name="password" class="w-full p-4 bg-slate-50 border border-slate-200 rounded-2xl outline-none focus:ring-2 focus:ring-[#568ca1] font-semibold" placeholder="••••••••" required>
                    </div>
                    <button type="submit" class="bg-[#568ca1] text-white p-4 rounded-xl w-full font-black hover:bg-[#457283] transition-all shadow-xl active:scale-95 uppercase tracking-widest">SIGN IN</button>
                </form>
                <p id="reg-link" class="mt-8 text-center text-xs font-bold text-slate-400 uppercase tracking-widest">
                    Don't have an account? <a href="register.jsp" class="text-[#568ca1] hover:underline">Register Now</a>
                </p>
            </div>
        </div>

        <div class="ucms-right-panel hidden lg:flex items-center justify-center">
            <div class="overlay"></div>
            <div class="panel-content text-white text-center p-12">
                <p class="text-6xl font-black uppercase tracking-tighter leading-none">Welcome Back</p>
                <div class="w-16 h-1 bg-white/40 mx-auto my-6"></div>
                <p class="text-xl font-light opacity-95">Access your profile and manage club activities.</p>
            </div>
        </div>
    </div>

    <footer class="bg-white border-t border-gray-200 text-gray-500 text-sm text-center py-6">
        <div class="max-w-7xl mx-auto px-4">
            <p>&copy; <%= java.time.Year.now() %> UCMS. All rights reserved.</p>
        </div>
    </footer>

    <script>
        function switchRole(role) {
            const title = document.getElementById('login-title'); const label = document.getElementById('id-label');
            const input = document.getElementById('login-id'); const regLink = document.getElementById('reg-link');
            const subtitle = document.getElementById('login-subtitle');
            const sTab = document.getElementById('student-tab'); const aTab = document.getElementById('admin-tab');
            document.getElementById('userRole').value = role;

            if (role === 'admin') {
                title.innerText = 'Admin Portal'; label.innerText = 'ADMIN EMAIL';
                subtitle.innerText = 'System administration & control panel';
                input.name = 'adminEmail'; input.placeholder = 'admin@university.edu';
                regLink.style.display = 'none';
                aTab.className = "flex-1 px-4 py-2 rounded-lg bg-white shadow-sm font-black text-[10px] uppercase tracking-widest transition-all";
                sTab.className = "flex-1 px-4 py-2 rounded-lg text-slate-400 font-black text-[10px] uppercase tracking-widest transition-all";
            } else {
                title.innerText = 'Student Login'; label.innerText = 'STUDENT ID';
                subtitle.innerText = 'Please enter your credentials to continue.';
                input.name = 'studentId'; input.placeholder = 'B032110xxx';
                regLink.style.display = 'block';
                sTab.className = "flex-1 px-4 py-2 rounded-lg bg-white shadow-sm font-black text-[10px] uppercase tracking-widest transition-all";
                aTab.className = "flex-1 px-4 py-2 rounded-lg text-slate-400 font-black text-[10px] uppercase tracking-widest transition-all";
            }
        }
    </script>
</body>
</html>