package com.ucms2.servlet;

import com.ucms2.db.DBConnection;
import com.ucms2.model.Event;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/admin-events")
public class AdminEventServlet extends HttpServlet {

    // GET: Handles Loading the Event List with Registration Counts
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        List events = new ArrayList(); // Manual typing for Java 1.5 compatibility
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            // SQL includes LEFT JOIN for the registration count 
            String sql = "SELECT e.EventID, e.EventName, e.EventDate, e.EventVenue, COUNT(r.StudentID) as total_reg " +
                         "FROM EVENT e " +
                         "LEFT JOIN EVENT_REGISTRATION r ON e.EventID = r.EventID " +
                         "GROUP BY e.EventID, e.EventName, e.EventDate, e.EventVenue " +
                         "ORDER BY e.EventDate ASC";
            
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Event ev = new Event();
                ev.setEventId(rs.getInt("EventID"));
                ev.setEventName(rs.getString("EventName"));
                ev.setEventDate(rs.getDate("EventDate"));
                ev.setEventVenue(rs.getString("EventVenue"));
                ev.setAttendanceCount(rs.getInt("total_reg")); // Fills the badge 
                events.add(ev);
            }
            
            request.setAttribute("allEvents", events);
            request.getRequestDispatcher("admin-events.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-dashboard.jsp?error=Load failed");
        } finally {
            // Manual closing for Java 1.5/GlassFish 4.1.1 compatibility [cite: 32, 33, 34]
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (ps != null) try { ps.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }

    // POST: Handles Deletion Logic [cite: 18]
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        String eventId = request.getParameter("eventId");
        
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            if ("delete".equals(action)) {
                // Delete registrations first due to foreign keys [cite: 18]
                ps = conn.prepareStatement("DELETE FROM EVENT_REGISTRATION WHERE EventID = ?");
                ps.setInt(1, Integer.parseInt(eventId));
                ps.executeUpdate();
                ps.close();

                // Delete the event
                ps = conn.prepareStatement("DELETE FROM EVENT WHERE EventID = ?");
                ps.setInt(1, Integer.parseInt(eventId));
                ps.executeUpdate();
                
                response.sendRedirect("admin-events?success=Deleted");
            }
        } catch (Exception e) {
            response.sendRedirect("admin-events?error=Delete failed");
        } finally {
            if (ps != null) try { ps.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
}