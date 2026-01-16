package com.ucms2.servlet;

import com.ucms2.db.ClubDAO;
import com.ucms2.db.EventDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/admin-dashboard-data")
public class AdminDashboardServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            com.ucms2.db.ClubDAO clubDAO = new com.ucms2.db.ClubDAO();
            com.ucms2.db.EventDAO eventDAO = new com.ucms2.db.EventDAO();
            
            // Get data for stats
            int totalClubs = clubDAO.getAllClubs().size();
            int totalEvents = eventDAO.getAllEvents().size();
            
            // Fetch Top Contributors (ensure this method exists in a DAO)
            // request.setAttribute("topContributors", someDAO.getTopInformants());

            request.setAttribute("totalClubs", totalClubs);
            request.setAttribute("totalEvents", totalEvents);
            
            request.getRequestDispatcher("admin-dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.getRequestDispatcher("admin-dashboard.jsp").forward(request, response);
        }
    }
}