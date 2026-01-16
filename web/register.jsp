<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>UCMS - Register</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@100..900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body class="bg-gray-50">
    <%-- 1. GET ERROR MESSAGE FROM SERVLET --%>
    <% 
        String error = request.getParameter("error"); 
    %>

    <div class="ucms-layout">
        <div class="ucms-left-panel">
            <div class="p-8 max-w-lg w-full">
                
                <h2 class="text-3xl font-extrabold mb-4 text-center uppercase">Student Registration</h2>
                
                <%-- 2. DISPLAY FRIENDLY ERROR MESSAGE --%>
                <% if (error != null) { %>
                    <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6 rounded shadow-sm" role="alert">
                        <div class="flex items-center">
                            <span class="font-bold mr-2">⚠️</span>
                            <p class="text-sm"><%= error %></p>
                        </div>
                    </div>
                <% } %>

                <%-- Action matches StudentRegisterServlet --%>
                <form id="register-form" method="POST" action="student-register" onsubmit="return validateForm()" class="space-y-4">
                    <div class="ucms-input-box">
                        <div>
                            <label for="studentId" class="ucms-label text-sm font-bold">STUDENT ID (7 Characters)</label>
                            <input type="text" id="studentId" name="studentId" 
                                   class="ucms-input-field w-full p-2 border rounded focus:ring-2 focus:ring-blue-500 outline-none" 
                                   placeholder="E.g., S123456" required>
                            <p id="id-error" class="text-red-500 text-[10px] font-bold mt-1 hidden italic uppercase">ID must be exactly 7 characters.</p>
                        </div>
                        
                        <div class="mt-4">
                            <label for="studentName" class="ucms-label text-sm font-bold">FULL NAME</label>
                            <input type="text" id="studentName" name="studentName" 
                                   class="ucms-input-field w-full p-2 border rounded focus:ring-2 focus:ring-blue-500 outline-none" 
                                   placeholder="Enter your full name" required>
                        </div>

                        <div class="mt-4">
                            <label for="studentEmail" class="ucms-label text-sm font-bold">EMAIL</label>
                            <input type="email" id="studentEmail" name="studentEmail" 
                                   class="ucms-input-field w-full p-2 border rounded focus:ring-2 focus:ring-blue-500 outline-none" 
                                   placeholder="student@university.edu" required>
                        </div>

                        <div class="mt-4">
                            <label for="password" class="ucms-label text-sm font-bold">PASSWORD</label>
                            <input type="password" id="password" name="password" 
                                   class="ucms-input-field w-full p-2 border rounded focus:ring-2 focus:ring-blue-500 outline-none" 
                                   required>
                        </div>

                        <div class="flex justify-center pt-8">
                            <button type="submit" class="bg-gray-900 text-white p-3 rounded-lg w-full font-bold hover:bg-gray-800 transition shadow-lg">
                                REGISTER
                            </button>
                        </div>

                        <p class="mt-4 text-center text-sm text-gray-600">
                            Already have an account? 
                            <a href="login.jsp" class="font-bold text-blue-600 hover:text-blue-800">Login Here</a>
                        </p>
                    </div>
                </form>
            </div>
        </div>

        <%-- Right Panel --%>
        <div class="ucms-right-panel hidden lg:block bg-cover bg-center" style="background-image: url('https://picsum.photos/id/300/800/800');">
            <div class="h-full flex flex-col justify-center items-center bg-black bg-opacity-40 text-white p-8">
                <p class="text-4xl font-extrabold">Join Us!</p>
                <p class="mt-4 text-lg font-light">Start your campus journey with great clubs.</p>
            </div>
        </div>
    </div>

    

    <script>
        function validateForm() {
            const studentId = document.getElementById('studentId').value;
            const errorMsg = document.getElementById('id-error');
            
            // Logical check for exact length of 7 (Matches SQL CHAR(7) constraint)
            if (studentId.length !== 7) {
                errorMsg.classList.remove('hidden');
                return false; // Stop form submission
            }
            
            errorMsg.classList.add('hidden');
            return true; // Proceed to Servlet
        }
    </script>
</body>
</html>