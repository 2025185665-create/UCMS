<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.ucms2.model.Student" %>
<%
    if (request.getAttribute("reportData") == null) {
        request.getRequestDispatcher("/ReportController").forward(request, response);
        return;
    }
    Student student = (Student) session.getAttribute("student");
    String userRole = (String) session.getAttribute("userRole");
    List reportData = (List) request.getAttribute("reportData");
    List studentClubs = (List) request.getAttribute("studentClubs");
    String generatedDate = (String) request.getAttribute("generatedDate");
    Boolean isGlobal = (Boolean) request.getAttribute("isGlobalReport");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Activity Report | UCMS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif !important; }
        @media print { .no-print { display: none !important; } .main-content { padding: 0 !important; } }
        .nav-link.active { background: rgba(59, 130, 246, 0.15); border-right: 4px solid #3b82f6; color: #fff !important; }
    </style>
</head>
<body class="bg-[#f8fafc]">
    <div class="dashboard-container">
        <nav class="sidebar no-print">
            <a href="index.jsp" class="sidebar-brand text-2xl font-black tracking-tighter">UCMS</a>
            <a href="<%= "admin".equals(userRole) ? "admin-dashboard.jsp" : "student-dashboard.jsp" %>" class="nav-link">🏠 Dashboard</a>
            <a href="events.jsp" class="nav-link">📅 Events</a>
            <a href="report-view.jsp" class="nav-link active">📄 Activity Report</a>
            <div style="margin-top: auto;"><a href="logout" class="nav-link" style="color: #ef4444;">🚪 Logout</a></div>
        </nav>

        <main class="main-content">
            <div class="no-print flex justify-between items-center mb-8">
                <button onclick="window.location.href='student-dashboard.jsp'" class="px-5 py-2 bg-white border border-slate-200 rounded-xl font-bold text-slate-600 text-sm shadow-sm hover:bg-slate-50 transition">← Back</button>
                <button onclick="window.print()" class="bg-blue-600 text-white px-6 py-2 rounded-xl font-bold text-sm shadow-lg hover:bg-blue-700 transition">Print or Save PDF</button>
            </div>

            <div class="bg-white rounded-[2rem] shadow-2xl border border-slate-100 overflow-hidden max-w-5xl mx-auto">
                <div class="h-3 bg-gradient-to-r from-blue-600 to-indigo-600"></div>
                <div class="p-12">
                    <header class="flex justify-between items-start mb-12">
                        <div>
                            <h1 class="text-4xl font-black text-slate-800 tracking-tighter">UCMS</h1>
                            <p class="text-[10px] font-black text-blue-500 uppercase tracking-[0.3em] mt-2">Official Activity Report</p>
                        </div>
                        <div class="text-right">
                            <p class="text-[9px] font-black text-slate-400 uppercase">Generated On</p>
                            <p class="text-xs font-bold text-slate-700 mt-1"><%= generatedDate %></p>
                        </div>
                    </header>

                    <% if (Boolean.TRUE.equals(isGlobal)) { %>
                        <h3 class="text-blue-600 font-black text-xs uppercase tracking-widest mb-6">Global Membership Summary</h3>
                        <table class="w-full text-left border-collapse">
                            <thead class="bg-slate-50 border-b border-slate-100">
                                <tr>
                                    <th class="p-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Student ID</th>
                                    <th class="p-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Name</th>
                                    <th class="p-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Club</th>
                                    <th class="p-4 text-[10px] font-black text-slate-400 uppercase tracking-widest text-center">Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Object obj : reportData) { Map row = (Map) obj; String status = (String) row.get("status"); %>
                                    <tr class="border-b border-slate-50">
                                        <td class="p-4 text-sm font-mono text-slate-500"><%= row.get("id") %></td>
                                        <td class="p-4 text-sm font-bold text-slate-700"><%= row.get("name") %></td>
                                        <td class="p-4 text-sm text-slate-600 font-medium"><%= row.get("club") %></td>
                                        <td class="p-4 text-center">
                                            <% if ("active".equals(status)) { %>
                                                <span class="bg-blue-50 text-blue-600 px-3 py-1 rounded-full text-[9px] font-black uppercase">Active</span>
                                            <% } else { %>
                                                <span class="bg-amber-50 text-amber-600 px-3 py-1 rounded-full text-[9px] font-black uppercase border border-amber-100">Leave Pending</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    <% } else { %>
                        <div class="bg-blue-600 p-8 rounded-3xl text-white shadow-xl mb-12 flex justify-between items-center">
                            <div>
                                <p class="text-[10px] font-black text-blue-200 uppercase tracking-widest opacity-80">Registration ID</p>
                                <p class="text-xl font-bold font-mono"><%= request.getAttribute("reportStudentId") %></p>
                                <p class="text-3xl font-black mt-4"><%= student.getStudentName() %></p>
                            </div>
                            <div class="text-right opacity-20 text-6xl font-black uppercase tracking-tighter">UCMS RECORD</div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-10">
                            <div>
                                <h3 class="text-blue-600 font-black text-xs uppercase tracking-widest mb-4">Societies & Membership Status</h3>
                                <ul class="space-y-3">
                                    <% if (studentClubs != null) { for (Object obj : studentClubs) { Map c = (Map) obj; %>
                                        <li class="p-4 bg-slate-50 rounded-2xl font-bold text-sm text-slate-700 border border-slate-100 flex justify-between items-center">
                                            <span><%= c.get("name") %></span>
                                            <% if ("active".equals(c.get("status"))) { %>
                                                <span class="text-[9px] text-emerald-500 font-black uppercase">Active Member</span>
                                            <% } else { %>
                                                <span class="text-[9px] text-amber-500 font-black uppercase">Exit Requested</span>
                                            <% } %>
                                        </li>
                                    <% }} %>
                                </ul>
                            </div>
                            <div>
                                <h3 class="text-indigo-600 font-black text-xs uppercase tracking-widest mb-4">Event Participation Log</h3>
                                <div class="space-y-4">
                                    <% for (Object obj : reportData) { Map row = (Map) obj; %>
                                        <div class="p-4 border border-slate-50 rounded-2xl hover:bg-slate-50 transition-colors">
                                            <p class="font-bold text-slate-800 text-sm"><%= row.get("eventName") %></p>
                                            <p class="text-[10px] text-slate-400 font-medium mt-1 uppercase tracking-wider"><%= row.get("eventDate") %> • <%= row.get("eventVenue") %></p>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    <% } %>

                    <footer class="mt-20 pt-10 border-t border-dashed border-slate-200 text-center">
                        <p class="text-[10px] text-slate-300 font-black uppercase tracking-[0.4em]">Digital Verification Active • UCMS Official Record</p>
                    </footer>
                </div>
            </div>
        </main>
    </div>
</body>
</html>