<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Registration Successful - UCMS2</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body class="bg-gray-50 flex items-center justify-center h-screen">
    <div class="bg-white p-10 rounded-2xl shadow-2xl text-center max-w-md border-t-8 border-green-500">
        <div class="bg-green-100 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6">
            <svg class="w-10 h-10 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
        </div>
        
        <h2 class="text-3xl font-extrabold text-gray-800 mb-2">Welcome!</h2>
        <p class="text-gray-600 mb-6">
            Registration successful for <span class="font-bold text-gray-800"><%= session.getAttribute("regName") %></span>.
        </p>
        
        <div class="bg-gray-50 p-4 rounded-lg mb-8 text-sm text-gray-500">
            Your Student ID is: <span class="font-mono font-bold text-blue-600"><%= session.getAttribute("regId") %></span>
        </div>

        <a href="login.jsp" class="block w-full bg-gray-900 text-white font-bold py-3 rounded-xl hover:bg-gray-800 transition">
            Proceed to Login
        </a>
    </div>
</body>
</html>