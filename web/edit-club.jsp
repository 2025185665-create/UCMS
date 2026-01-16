<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ucms2.model.Club" %>
<%
    Club club = (Club) request.getAttribute("club");
    if (club == null) { response.sendRedirect("manage-clubs"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Edit Club | UCMS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
</head>
<body class="bg-slate-50 flex items-center justify-center min-h-screen p-6">

    <div class="max-w-xl w-full">
        <a href="manage-clubs" class="text-slate-400 hover:text-slate-600 mb-6 inline-flex items-center text-sm font-semibold transition">
            <span class="mr-2">←</span> Back to Clubs List
        </a>

        <div class="bg-white rounded-3xl shadow-xl border border-slate-200 overflow-hidden">
            <div class="bg-slate-800 p-8 text-white">
                <h2 class="text-2xl font-black uppercase tracking-tight">Edit Club Details</h2>
                <p class="text-slate-400 text-sm mt-1 italic">Editing: <%= club.getClubName() %></p>
            </div>

            <form action="edit-club" method="POST" class="p-8 space-y-6">
                <input type="hidden" name="clubId" value="<%= club.getClubId() %>">
                
                <div>
                    <label class="block text-xs font-black text-slate-500 uppercase tracking-widest mb-2">Club Name</label>
                    <input type="text" name="clubName" value="<%= club.getClubName() %>" 
                           class="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:bg-white outline-none transition font-semibold text-slate-800">
                </div>
                
                <div>
                    <label class="block text-xs font-black text-slate-500 uppercase tracking-widest mb-2">Description</label>
                    <textarea name="clubDescription" rows="5" 
                              class="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:bg-white outline-none transition font-medium text-slate-600"><%= club.getClubDescription() %></textarea>
                </div>
                
                <div class="pt-4 flex gap-4">
                    <button type="submit" class="flex-1 bg-blue-600 text-white py-4 rounded-2xl font-bold hover:bg-blue-700 transition shadow-lg shadow-blue-100">
                        Save Changes
                    </button>
                    <button type="button" onclick="history.back()" 
                            class="px-8 bg-slate-100 text-slate-600 py-4 rounded-2xl font-bold hover:bg-slate-200 transition">
                        Cancel
                    </button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>