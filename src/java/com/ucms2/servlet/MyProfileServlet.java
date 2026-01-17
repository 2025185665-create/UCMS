package com.ucms2.servlet;

import com.ucms2.db.DBConnection;
import com.ucms2.model.Student;
import com.ucms2.model.CampusBuzz;
import com.ucms2.model.Event;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import java.util.Date;
import java.text.SimpleDateFormat;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/MyProfileController")
public class MyProfileServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Student student = (session != null) ? (Student) session.getAttribute("student") : null;
        
        if (student == null) { 
            response.sendRedirect("login.jsp?error=Session Expired"); 
            return; 
        }

        List myClubs = new ArrayList();
        List myEvents = new ArrayList();
        int clubCount = 0;
        int eventCount = 0;
        int newBuzzCount = 0;
        int claimedCount = 0;
        int certCount = 0;
        boolean hasPendingLeave = false;
        StringBuilder tickerContent = new StringBuilder();
        
        SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, HH:mm");
        String lastLogin = sdf.format(new Date()); 

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // 1. Fetch Clubs
            ps = conn.prepareStatement("SELECT c.ClubName, m.Status FROM CLUB c JOIN CLUB_MEMBERSHIP m ON c.ClubID = m.ClubID WHERE m.StudentID = ?");
            ps.setString(1, student.getStudentId());
            rs = ps.executeQuery();
            while(rs.next()){
                String status = rs.getString("Status");
                if("active".equals(status)) {
                    clubCount++;
                    myClubs.add(rs.getString("ClubName"));
                }
                if("leave_pending".equals(status)) hasPendingLeave = true;
            }
            rs.close(); ps.close();

            // 2. Fetch Events
            ps = conn.prepareStatement("SELECT e.EventName, e.EventDate FROM EVENT e JOIN EVENT_REGISTRATION r ON e.EventID = r.EventID WHERE r.StudentID = ?");
            ps.setString(1, student.getStudentId());
            rs = ps.executeQuery();
            while (rs.next()) { 
                Event e = new Event();
                e.setEventName(rs.getString("EventName"));
                e.setEventDate(rs.getDate("EventDate"));
                myEvents.add(e); 
                eventCount++;
            }
            rs.close(); ps.close();

            // 3. Ticker
            ps = conn.prepareStatement("SELECT EventName, EventDate, EventVenue FROM EVENT WHERE EventDate >= CURRENT_DATE ORDER BY EventDate ASC");
            rs = ps.executeQuery();
            while(rs.next()) { tickerContent.append(rs.getString("EventName")).append(" • "); }
            rs.close(); ps.close();

            // 4. Buzz & Claimed
            ps = conn.prepareStatement("SELECT Status FROM CAMPUS_BUZZ WHERE StudentID = ?");
            ps.setString(1, student.getStudentId());
            rs = ps.executeQuery();
            while (rs.next()) {
                if("claimed".equals(rs.getString("Status"))) claimedCount++;
            }
            rs.close(); ps.close();

            // 5. Certs
            ps = conn.prepareStatement("SELECT COUNT(*) FROM EVENT_REGISTRATION r JOIN EVENT e ON r.EventID = e.EventID WHERE r.StudentID = ? AND e.EventDate < CURRENT_DATE");
            ps.setString(1, student.getStudentId());
            rs = ps.executeQuery();
            if(rs.next()) certCount = rs.getInt(1);
            rs.close(); ps.close();

            // 6. Notifications
            ps = conn.prepareStatement("SELECT COUNT(*) FROM CAMPUS_BUZZ WHERE Status = 'approved'");
            rs = ps.executeQuery();
            if(rs.next()) newBuzzCount = rs.getInt(1);

            session.setAttribute("myClubs", myClubs);
            session.setAttribute("myEvents", myEvents);
            session.setAttribute("clubCount", clubCount);
            session.setAttribute("eventCount", eventCount);
            session.setAttribute("claimedCount", claimedCount);
            session.setAttribute("certCount", certCount);
            session.setAttribute("newBuzzCount", newBuzzCount);
            session.setAttribute("hasPendingLeave", hasPendingLeave);
            session.setAttribute("ticker", tickerContent.toString());
            session.setAttribute("lastLogin", lastLogin);
            session.setAttribute("streak", 5);

            String view = request.getParameter("view");
            if ("profile".equals(view)) {
                response.sendRedirect("my-output.jsp");
            } else {
                response.sendRedirect("student-dashboard.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=Database Error");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (ps != null) try { ps.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
}