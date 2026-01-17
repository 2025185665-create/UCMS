<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.ucms2.model.Student, com.ucms2.model.CampusBuzz" %>
<%
    if (session.getAttribute("myClubs") == null) {
        response.sendRedirect("MyProfileController?view=profile");
        return;
    }

    Student student = (Student) session.getAttribute("student");
    List myClubs = (List) session.getAttribute("myClubs");
    List myEvents = (List) session.getAttribute("myEvents");
    
    int claimed = (Integer) session.getAttribute("claimedCount");
    int certs = (Integer) session.getAttribute("certCount");
    String lastLogin = (String) session.getAttribute("lastLogin");
    int streak = (Integer) session.getAttribute("streak");

    int CLUB_GOAL = 5;
    int EVENT_GOAL = 10;
    
    int clubProgress = Math.min((myClubs.size() * 100) / CLUB_GOAL, 100);
    int eventProgress = Math.min((myEvents.size() * 100) / EVENT_GOAL, 100);
    int overallMilestone = (clubProgress + eventProgress) / 2;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>My Student Progress | UCMS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
    <style>
        .progress-glow { box-shadow: 0 0 15px rgba(79, 70, 229, 0.2); }
        @keyframes slideIn { from { transform: translateX(-20px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        .animate-slide { animation: slideIn 0.5s ease-out forwards; }
        .gold-border { border-color: #fbbf24 !important; }
        .gold-text { color: #d97706 !important; }

        .nav-link.active {
            background: rgba(59, 130, 246, 0.15);
            border-right: 4px solid #3b82f6;
            box-shadow: inset 0 0 10px rgba(59, 130, 246, 0.2);
            color: #fff !important;
        }
        .interactive-card { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .interactive-card:hover { transform: translateY(-8px); border-color: #3b82f6; }
    </style>
</head>
<body class="bg-[#f8fafc]">
    <div class="dashboard-container">
        <nav class="sidebar">
            <a href="index.jsp" class="sidebar-brand">UCMS</a>
            <a href="student-dashboard.jsp" class="nav-link">🏠 Dashboard</a>
            <a href="events.jsp" class="nav-link">📅 Events</a>
            <a href="campus-buzz.jsp" class="nav-link">📢 Campus Buzz</a>
            <%-- Link points back to Controller to ensure fresh data --%>
            <a href="MyProfileController?view=profile" class="nav-link active">👤 My Progress</a>
            <div style="margin-top: auto;"><a href="logout" class="nav-link" style="color: #ef4444;">🚪 Logout</a></div>
        </nav>

        <main class="main-content">
            <header class="mb-10 flex flex-col md:flex-row md:items-end justify-between gap-4">
                <div class="animate-slide">
                    <h1 class="text-4xl font-black text-[#1e293b] tracking-tight"><%= student.getStudentName() %></h1>
                    <div class="flex items-center gap-3 mt-2">
                        <p class="text-slate-500 font-bold uppercase text-[10px] tracking-widest">Overall Completion: <%= overallMilestone %>%</p>
                        <span class="h-1 w-1 bg-slate-300 rounded-full"></span>
                        <p class="text-slate-400 text-[10px] font-medium italic">Last Login: <%= lastLogin %></p>
                    </div>
                </div>

                <div class="bg-orange-50 border <%= streak >= 5 ? "gold-border" : "border-orange-100" %> p-3 px-5 rounded-2xl flex items-center gap-3 shadow-sm">
                    <div class="text-2xl animate-bounce">🔥</div>
                    <div>
                        <p class="text-[9px] font-black text-orange-400 uppercase leading-none">Activity Streak</p>
                        <p class="text-lg font-black <%= streak >= 5 ? "gold-text" : "text-orange-600" %> leading-tight"><%= streak %> Days</p>
                    </div>
                </div>
            </header>

            <%-- Roadmap Progress Bar --%>
            <div class="bg-white p-2 rounded-full border border-slate-200 mb-10 progress-glow">
                <div class="w-full bg-slate-100 h-3 rounded-full overflow-hidden">
                    <div class="h-full bg-gradient-to-r from-[#2563eb] via-[#4f46e5] to-[#fbbf24] transition-all duration-1000 ease-out" 
                         style="width: <%= overallMilestone %>%"></div>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
                <div class="interactive-card bg-white p-6 rounded-3xl shadow-sm border border-blue-100 group">
                    <h3 class="text-[10px] font-black text-blue-500 uppercase tracking-widest mb-4">Clubs Goal</h3>
                    <div class="text-3xl font-black mb-2 text-[#1e293b]"><%= myClubs.size() %> <span class="text-xs text-slate-300">/ <%= CLUB_GOAL %></span></div>
                    <div class="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                        <div class="bg-[#2563eb] h-full transition-all duration-700" style="width: <%= clubProgress %>%"></div>
                    </div>
                    <p class="text-[9px] text-slate-400 mt-3 uppercase font-bold">Goal: Join 5 Campus Societies</p>
                </div>

                <div class="interactive-card bg-white p-6 rounded-3xl shadow-sm border border-purple-100 group">
                    <h3 class="text-[10px] font-black text-purple-500 uppercase tracking-widest mb-4">Events Goal</h3>
                    <div class="text-3xl font-black mb-2 text-[#1e293b]"><%= myEvents.size() %> <span class="text-xs text-slate-300">/ <%= EVENT_GOAL %></span></div>
                    <div class="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                        <div class="bg-[#4f46e5] h-full transition-all duration-700" style="width: <%= eventProgress %>%"></div>
                    </div>
                    <p class="text-[9px] text-slate-400 mt-3 uppercase font-bold">Goal: Attend 10 Events</p>
                </div>

                <div class="interactive-card bg-white p-6 rounded-3xl shadow-sm border border-emerald-100 group">
                    <h3 class="text-[10px] font-black text-emerald-500 uppercase tracking-widest mb-4">Scholar Status</h3>
                    <div class="flex justify-between items-center h-12">
                        <span class="text-3xl font-black text-[#1e293b]"><%= certs %></span>
                        <span class="text-3xl drop-shadow-sm">🎓</span>
                    </div>
                    <div class="mt-4 pt-4 border-t border-slate-50">
                        <p class="text-[9px] text-slate-400 uppercase font-bold">Official Certifications</p>
                    </div>
                </div>
            </div>

            <div class="bg-white p-8 rounded-3xl shadow-sm border border-slate-200">
                <h2 class="text-sm font-black text-slate-400 uppercase mb-6 tracking-widest flex items-center gap-2">
                    Unlocked Achievements <span class="h-px bg-slate-100 flex-1"></span>
                </h2>
                <div class="flex flex-wrap gap-4">
                    <% if (claimed > 0) { %>
                        <div class="flex items-center p-4 bg-emerald-50 border border-emerald-100 rounded-2xl hover:scale-105 transition-transform">
                            <span class="text-2xl mr-3">🛡️</span>
                            <div>
                                <h4 class="text-[10px] font-black text-emerald-800 uppercase leading-none">Community Hero</h4>
                                <p class="text-[9px] text-emerald-600 mt-1">Returned <%= claimed %> lost item(s)</p>
                            </div>
                        </div>
                    <% } %>
                    <% if (overallMilestone >= 100) { %>
                        <div class="flex items-center p-4 bg-amber-50 border border-amber-100 rounded-2xl hover:scale-105 transition-transform border-yellow-400">
                            <span class="text-2xl mr-3">🏆</span>
                            <div>
                                <h4 class="text-[10px] font-black text-amber-800 uppercase leading-none">Elite Member</h4>
                                <p class="text-[9px] text-amber-600 mt-1">100% Roadmap Completed</p>
                            </div>
                        </div>
                    <% } %>
                    <% if (certs >= 1) { %>
                        <div class="flex items-center p-4 bg-indigo-50 border border-indigo-100 rounded-2xl hover:scale-105 transition-transform">
                            <span class="text-2xl mr-3">📜</span>
                            <div>
                                <h4 class="text-[10px] font-black text-indigo-800 uppercase leading-none">Certified</h4>
                                <p class="text-[9px] text-indigo-600 mt-1">Academic Participant</p>
                            </div>
                        </div>
                    <% } %>
                    <% if (streak >= 5) { %>
                        <div class="flex items-center p-4 bg-orange-50 border border-orange-100 rounded-2xl hover:scale-105 transition-transform border-orange-400">
                            <span class="text-2xl mr-3">⚡</span>
                            <div>
                                <h4 class="text-[10px] font-black text-orange-800 uppercase leading-none">Reliable Student</h4>
                                <p class="text-[9px] text-orange-600 mt-1">High Engagement Active</p>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>
        </main>
    </div>
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