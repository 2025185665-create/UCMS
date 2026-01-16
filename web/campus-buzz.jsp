<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ucms2.model.Student, com.ucms2.model.Admin, com.ucms2.model.CampusBuzz, java.util.List, java.util.ArrayList" %>
<%
    // --- LECTURER REQUIREMENT: INTERNAL FORWARDING ---
    if (request.getAttribute("approvedBuzz") == null) {
        request.getRequestDispatcher("/CampusBuzzController").forward(request, response);
        return; 
    }

    String userRole = (String) session.getAttribute("userRole");
    List pending = (List) request.getAttribute("pendingBuzz");
    List approved = (List) request.getAttribute("approvedBuzz");
    if (approved == null) approved = new ArrayList();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Campus Buzz | UCMS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
    <style>
        .animate-fadeIn { animation: fadeIn 0.3s ease-in; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
        .filter-active { background-color: #1e293b !important; color: white !important; border-color: #1e293b !important; }
    </style>
</head>
<body class="bg-slate-50">
    <div class="dashboard-container">
        <nav class="sidebar">
            <a href="index.jsp" class="sidebar-brand">UCMS</a>
            <% if ("admin".equals(userRole)) { %>
                <a href="admin-dashboard-data" class="nav-link">📊 Overview</a>
                <a href="clubs.jsp" class="nav-link">🏛️ Manage Clubs</a>
                <a href="events.jsp" class="nav-link">📅 Event Control</a>
                <a href="campus-buzz.jsp" class="nav-link active">📢 Moderation</a>
            <% } else { %>
                <a href="student-dashboard.jsp" class="nav-link">🏠 Dashboard</a>
                <a href="clubs.jsp" class="nav-link">🔍 Explore Clubs</a>
                <a href="events.jsp" class="nav-link">📅 Events</a>
                <a href="campus-buzz.jsp" class="nav-link active">📢 Campus Buzz</a>
            <% } %>
            <div style="margin-top: auto;"><a href="logout" class="nav-link" style="color: #ef4444;">🚪 Logout</a></div>
        </nav>

        <main class="main-content">
            <header class="mb-10">
                <h1 class="text-3xl font-black text-slate-800 tracking-tight">Campus Buzz 📢</h1>
                <p class="text-slate-500 mt-1"><%= "admin".equals(userRole) ? "Review student reports and programs." : "Share news, items, or host a program." %></p>
            </header>

            <%-- ALERTS --%>
            <% if (request.getParameter("success") != null) { %>
                <div class="bg-emerald-100 text-emerald-700 p-4 rounded-2xl mb-6 font-bold text-sm border border-emerald-200 animate-fadeIn">
                    ✅ <%= request.getParameter("success") %>
                </div>
            <% } %>

            <%-- STUDENT SECTION: POST SUBMISSION --%>
            <% if ("student".equals(userRole)) { %>
                <div class="bg-white p-8 rounded-3xl shadow-sm border border-slate-200 mb-10">
                    <h3 class="text-sm font-black text-slate-400 uppercase tracking-widest mb-4">Create New Post</h3>
                    <form method="POST" action="CampusBuzzController">
                        <input type="hidden" name="action" value="create">
                        <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
                            <select name="category" id="catSelect" onchange="checkCategory()" class="p-3 bg-slate-50 border rounded-xl outline-none font-bold text-sm focus:ring-2 focus:ring-blue-500">
                                <option value="General Info">📢 Info</option>
                                <option value="Lost & Found">🔍 Lost & Found</option>
                                <option value="Program">🎓 Program</option>
                            </select>
                            <textarea name="content" class="md:col-span-3 p-4 bg-slate-50 border rounded-2xl outline-none h-24 focus:ring-2 focus:ring-blue-500" placeholder="Details about your post..." required></textarea>
                        </div>

                        <%-- Dynamic Program Fields --%>
                        <div id="programDetails" class="hidden grid grid-cols-1 md:grid-cols-2 gap-4 mb-4 animate-fadeIn">
                            <div class="p-4 bg-blue-50/50 rounded-2xl border border-blue-100">
                                <label class="block text-[10px] font-black text-blue-500 uppercase mb-2">Select Venue</label>
                                <select name="venue" class="w-full p-2 bg-white border border-blue-200 rounded-lg outline-none text-sm">
                                    <option value="Room A">Room A</option><option value="Room B">Room B</option>
                                    <option value="Room C">Room C</option><option value="Hall Ali">Hall Ali</option>
                                    <option value="Hall Abu">Hall Abu</option><option value="Hall Fatimah">Hall Fatimah</option>
                                    <option value="Football Field">Football Field</option><option value="Basketball Court">Basketball Court</option>
                                </select>
                            </div>
                            <div class="p-4 bg-blue-50/50 rounded-2xl border border-blue-100">
                                <label class="block text-[10px] font-black text-blue-500 uppercase mb-2">Program Date</label>
                                <input type="date" name="eventDate" class="w-full p-2 bg-white border border-blue-200 rounded-lg outline-none text-sm">
                            </div>
                        </div>

                        <div class="flex justify-end">
                            <button type="submit" class="bg-blue-600 text-white px-10 py-3 rounded-2xl font-bold hover:bg-blue-700 transition transform active:scale-95 shadow-lg shadow-blue-100">
                                Submit for Approval
                            </button>
                        </div>
                    </form>
                </div>
            <% } %>

            <%-- ADMIN SECTION: PENDING QUEUE --%>
            <% if ("admin".equals(userRole)) { %>
                <h2 class="text-xl font-black text-slate-800 mb-6 flex items-center">
                    <span class="w-3 h-3 bg-amber-500 rounded-full mr-3"></span> Pending Review
                </h2>
                <div class="grid gap-4 mb-12">
                    <% if (pending != null && !pending.isEmpty()) {
                        for (Object obj : pending) { CampusBuzz pb = (CampusBuzz) obj; %>
                            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200 flex justify-between items-start">
                                <div class="max-w-2xl">
                                    <span class="px-2 py-1 bg-amber-50 text-amber-600 text-[10px] font-black uppercase rounded mb-2 inline-block"><%= pb.getCategory() %></span>
                                    <p class="text-slate-700 font-medium whitespace-pre-wrap"><%= pb.getContent() %></p>
                                    <p class="text-[10px] font-bold text-slate-400 mt-3 uppercase">Proposed by: <%= pb.getStudentName() %></p>
                                </div>
                                <div class="flex gap-2">
                                    <form action="CampusBuzzController" method="POST">
                                        <input type="hidden" name="postId" value="<%= pb.getPostId() %>">
                                        <input type="hidden" name="action" value="approve">
                                        <button type="submit" class="bg-emerald-600 text-white px-4 py-2 rounded-xl font-bold text-xs hover:bg-emerald-700 transition">Approve</button>
                                    </form>
                                    <form action="CampusBuzzController" method="POST">
                                        <input type="hidden" name="postId" value="<%= pb.getPostId() %>">
                                        <input type="hidden" name="action" value="reject">
                                        <button type="submit" class="bg-slate-100 text-slate-600 px-4 py-2 rounded-xl font-bold text-xs hover:bg-slate-200 transition">Reject</button>
                                    </form>
                                </div>
                            </div>
                    <% } } else { %>
                        <div class="text-center py-10 bg-white rounded-3xl border border-dashed text-slate-400 font-medium">No pending posts at the moment.</div>
                    <% } %>
                </div>
            <% } %>

            <%-- FEED SECTION WITH CATEGORY FILTER --%>
            <div class="flex justify-between items-center mb-6">
                <h2 class="text-xl font-black text-slate-800">Live Feed</h2>
                <div class="flex gap-2">
                    <button onclick="filterBuzz('all', this)" class="filter-btn filter-active px-3 py-1.5 bg-white border border-slate-200 text-slate-500 rounded-lg text-xs font-bold transition hover:bg-slate-50">All</button>
                    <button onclick="filterBuzz('Program', this)" class="filter-btn px-3 py-1.5 bg-white border border-slate-200 text-slate-500 rounded-lg text-xs font-bold transition hover:bg-slate-50">🎓 Programs</button>
                    <button onclick="filterBuzz('Lost & Found', this)" class="filter-btn px-3 py-1.5 bg-white border border-slate-200 text-slate-500 rounded-lg text-xs font-bold transition hover:bg-slate-50">🔍 Lost & Found</button>
                    <button onclick="filterBuzz('General Info', this)" class="filter-btn px-3 py-1.5 bg-white border border-slate-200 text-slate-500 rounded-lg text-xs font-bold transition hover:bg-slate-50">📢 Info</button>
                </div>
            </div>

            <div class="space-y-6" id="buzzFeed">
                <% if (approved != null && !approved.isEmpty()) {
                    for (int i = 0; i < approved.size(); i++) { 
                        CampusBuzz buzz = (CampusBuzz) approved.get(i); %>
                        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 hover:shadow-md transition buzz-card" data-category="<%= buzz.getCategory() %>">
                            <div class="flex justify-between items-start mb-2">
                                <span class="text-[10px] font-black <%= buzz.getCategory().equals("Program") ? "text-purple-600" : "text-blue-600" %> uppercase tracking-widest"><%= buzz.getCategory() %></span>
                                
                                <%-- CLAIM BUTTON FOR LOST & FOUND --%>
                                <% if ("Lost & Found".equals(buzz.getCategory()) && !"claimed".equals(buzz.getStatus())) { %>
                                    <form action="CampusBuzzController" method="POST">
                                        <input type="hidden" name="action" value="claim">
                                        <input type="hidden" name="postId" value="<%= buzz.getPostId() %>">
                                        <button type="submit" class="text-[10px] font-bold bg-amber-50 text-amber-600 px-3 py-1 rounded-full border border-amber-200 hover:bg-amber-600 hover:text-white transition">
                                            Claim Item
                                        </button>
                                    </form>
                                <% } else if ("claimed".equals(buzz.getStatus())) { %>
                                    <span class="text-[10px] font-bold bg-emerald-50 text-emerald-600 px-3 py-1 rounded-full border border-emerald-200">
                                        ✅ Returned
                                    </span>
                                <% } %>
                            </div>

                            <p class="text-slate-700 mt-2 whitespace-pre-wrap <%= "claimed".equals(buzz.getStatus()) ? "opacity-50 line-through" : "" %>"><%= buzz.getContent() %></p>
                            
                            <div class="flex items-center mt-4 pt-4 border-t border-slate-50">
                                <div class="w-7 h-7 bg-slate-100 rounded-full flex items-center justify-center text-[10px] font-bold text-slate-400 mr-3">
                                    <%= buzz.getStudentName().substring(0,1).toUpperCase() %>
                                </div>
                                <div class="text-[10px] font-bold text-slate-400 uppercase">
                                    <%= buzz.getStudentName() %> • <%= buzz.getUploadDate() %>
                                </div>
                            </div>
                        </div>
                <% } } else { %>
                    <p class="text-slate-400 italic">No news yet.</p>
                <% } %>
            </div>
        </main>
    </div>

    <script>
    function checkCategory() {
        const val = document.getElementById('catSelect').value;
        const details = document.getElementById('programDetails');
        if(val === 'Program') {
            details.classList.remove('hidden');
        } else {
            details.classList.add('hidden');
        }
    }

    function filterBuzz(category, btn) {
        const cards = document.querySelectorAll('.buzz-card');
        const buttons = document.querySelectorAll('.filter-btn');
        buttons.forEach(b => b.classList.remove('filter-active'));
        btn.classList.add('filter-active');

        cards.forEach(card => {
            if (category === 'all' || card.getAttribute('data-category') === category) {
                card.style.display = 'block';
                card.classList.add('animate-fadeIn');
            } else {
                card.style.display = 'none';
            }
        });
    }
    </script>
</body>
</html>