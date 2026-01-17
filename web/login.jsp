<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>UCMS - Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .ucms-layout { display: flex; min-height: 100vh; }
        .ucms-left-panel { flex: 1; display: flex; align-items: center; justify-content: center; background: white; }
        .ucms-right-panel { flex: 1.2; position: relative; background-image: url('https://images.unsplash.com/photo-1541339907198-e08756ebafe3?auto=format&fit=crop&w=1200&q=80'); background-size: cover; background-position: center; }
    </style>
</head>
<body class="bg-gray-50">
    <% String error = request.getParameter("error"); String success = request.getParameter("success"); %>
    <div class="ucms-layout">
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

        <div class="ucms-right-panel hidden lg:block">
            <div class="absolute inset-0 bg-[#3a5d6a]/70 backdrop-blur-[2px]"></div>
            <div class="relative h-full flex flex-col justify-center items-center text-white p-12 text-center">
                <p class="text-6xl font-black uppercase tracking-tighter leading-none">Welcome Back</p>
                <div class="w-16 h-1 bg-white/40 my-6"></div>
                <p class="text-xl font-light opacity-90">Access your profile and manage club activities.</p>
            </div>
        </div>
    </div>

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