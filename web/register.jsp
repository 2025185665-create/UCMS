<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>UCMS - Register</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
    <style>
        body { font-family: 'Inter', sans-serif !important; }
        .ucms-layout { display: flex; min-height: 100vh; }
        .ucms-left-panel { flex: 1; display: flex; align-items: center; justify-content: center; background: white; }
        .ucms-right-panel { flex: 1.2; position: relative; background-image: url('https://images.unsplash.com/photo-1541339907198-e08756ebafe3?auto=format&fit=crop&w=1200&q=80'); background-size: cover; background-position: center; }
        
        .overlay { 
            position: absolute; 
            inset: 0; 
            background: rgba(58, 93, 106, 0.7); 
            backdrop-blur: 2px;
        }
    </style>
</head>
<body class="bg-gray-50">
    <% String error = request.getParameter("error"); %>

    <div class="ucms-layout">
        <div class="ucms-left-panel">
            <div class="p-8 max-w-lg w-full mx-auto">
                <h2 class="text-3xl font-black mb-4 text-center uppercase tracking-tighter text-slate-800">Student Registration</h2>
                <p class="text-center text-slate-500 mb-8 text-sm font-medium">Join the university society network.</p>

                <% if (error != null) { %>
                    <div class="bg-red-50 border-l-4 border-red-500 text-red-700 p-4 mb-6 rounded-xl shadow-sm" role="alert">
                        <div class="flex items-center">
                            <span class="mr-2">⚠️</span>
                            <p class="text-xs font-black uppercase tracking-tight"><%= error %></p>
                        </div>
                    </div>
                <% } %>

                <form id="register-form" method="POST" action="RegistrationServlet" onsubmit="return validateForm()" class="space-y-4">
                    <div class="ucms-input-box">
                        <div>
                            <label for="studentId" class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 block ml-1">Student ID (7 Characters)</label>
                            <input type="text" id="studentId" name="studentId" 
                                   class="w-full p-4 bg-slate-100 border-transparent border-2 focus:border-[#568ca1] focus:bg-white rounded-2xl outline-none transition-all font-semibold" 
                                   placeholder="E.g., B032110" required>
                            <p id="id-error" class="text-red-500 text-[10px] font-black mt-2 hidden uppercase">ID must be exactly 7 characters.</p>
                        </div>
                        
                        <div class="mt-4">
                            <label for="studentName" class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 block ml-1">Full Name</label>
                            <input type="text" id="studentName" name="studentName" 
                                   class="w-full p-4 bg-slate-100 border-transparent border-2 focus:border-[#568ca1] focus:bg-white rounded-2xl outline-none transition-all font-semibold" 
                                   placeholder="Enter your full name" required>
                        </div>

                        <div class="mt-4">
                            <label for="studentEmail" class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 block ml-1">Email Address</label>
                            <input type="email" id="studentEmail" name="studentEmail" 
                                   class="w-full p-4 bg-slate-100 border-transparent border-2 focus:border-[#568ca1] focus:bg-white rounded-2xl outline-none transition-all font-semibold" 
                                   placeholder="student@university.edu" required>
                        </div>

                        <div class="mt-4">
                            <label for="password" class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 block ml-1">Secure Password</label>
                            <input type="password" id="password" name="password" 
                                   class="w-full p-4 bg-slate-100 border-transparent border-2 focus:border-[#568ca1] focus:bg-white rounded-2xl outline-none transition-all font-semibold" 
                                   placeholder="••••••••" required>
                        </div>

                        <div class="flex justify-center pt-8">
                            <button type="submit" class="bg-[#568ca1] text-white p-4 rounded-xl w-full font-black hover:bg-[#457283] transition-all shadow-xl active:scale-95 uppercase tracking-widest">
                                CREATE ACCOUNT
                            </button>
                        </div>

                        <p class="mt-8 text-center text-[10px] font-black uppercase tracking-widest text-slate-400">
                            Already part of UCMS? 
                            <a href="login.jsp" class="text-[#568ca1] hover:underline">Login Here</a>
                        </p>
                    </div>
                </form>
            </div>
        </div>

        <div class="ucms-right-panel hidden lg:block">
            <div class="overlay"></div>
            <div class="flex flex-col justify-center items-center text-white p-12 text-center z-10 relative h-full">
                <p class="text-6xl font-black tracking-tighter uppercase leading-none">Engage.<br>Lead. Grow.</p>
                <div class="w-16 h-1 bg-white/40 my-6"></div>
                <p class="text-xl font-light opacity-80 max-w-md">Connect with clubs, attend events, and build your campus legacy with UCMS.</p>
            </div>
        </div>
    </div>

    <script>
        function validateForm() {
            const studentId = document.getElementById('studentId').value;
            const errorMsg = document.getElementById('id-error');
            if (studentId.length !== 7) {
                errorMsg.classList.remove('hidden');
                return false;
            }
            errorMsg.classList.add('hidden');
            return true;
        }
    </script>
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