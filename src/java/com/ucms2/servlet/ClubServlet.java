package com.ucms2.servlet;

import com.ucms2.db.ClubDAO;
import com.ucms2.db.DBConnection;
import com.ucms2.model.Student;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ClubController")
public class ClubServlet extends HttpServlet {
    private ClubDAO clubDAO = new ClubDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String userRole = (String) session.getAttribute("userRole");
        String action = request.getParameter("action");
        String searchQuery = request.getParameter("search");

        if ("admin".equals(userRole)) {
            int pendingLeaves = 0;
            Connection connL = null;
            try {
                connL = DBConnection.getConnection();
                ResultSet rsL = connL.createStatement().executeQuery(
                    "SELECT COUNT(*) FROM CLUB_MEMBERSHIP WHERE Status = 'leave_pending'");
                if(rsL.next()) pendingLeaves = rsL.getInt(1);
                request.setAttribute("pendingLeaves", pendingLeaves);
            } catch (Exception e) { e.printStackTrace(); }
            finally { if(connL != null) try{connL.close();}catch(Exception e){} }
        }
        
        if ("edit".equals(action)) {
            int id = Integer.parseInt(request.getParameter("clubId"));
            request.setAttribute("club", clubDAO.getClubById(id));
            // Important: Forward to clubs.jsp and keep the action=edit parameter for the JSP logic
            request.getRequestDispatcher("clubs.jsp?action=edit").forward(request, response);
            return;
        }

        List clubsWithCounts = new ArrayList();
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT c.*, (SELECT COUNT(*) FROM CLUB_MEMBERSHIP m WHERE m.ClubID = c.ClubID AND m.Status = 'active') as memberCount FROM CLUB c";
            if (searchQuery != null && !searchQuery.isEmpty()) {
                sql += " WHERE UPPER(ClubName) LIKE '%" + searchQuery.toUpperCase() + "%'";
            }
            ResultSet rs = conn.createStatement().executeQuery(sql);
            while(rs.next()) {
                Map map = new HashMap();
                map.put("id", new Integer(rs.getInt("ClubID")));
                map.put("name", rs.getString("ClubName"));
                map.put("desc", rs.getString("ClubDescription"));
                map.put("count", new Integer(rs.getInt("memberCount")));
                clubsWithCounts.add(map);
            }
            request.setAttribute("clubList", clubsWithCounts);
            request.getRequestDispatcher("clubs.jsp").forward(request, response);
        } catch (Exception e) { e.printStackTrace(); }
        finally { if(conn != null) try{conn.close();}catch(Exception e){} }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String userRole = (String) session.getAttribute("userRole");
        String action = request.getParameter("action");
        String msg = "Action Successful";

        try {
            if ("create".equals(action) && "admin".equals(userRole)) {
                clubDAO.createClub(request.getParameter("clubName"), request.getParameter("clubDescription"));
            } 
            else if ("delete".equals(action) && "admin".equals(userRole)) {
                int id = Integer.parseInt(request.getParameter("clubId"));
                
                // --- LOGIC: Check for active members ---
                int activeMembers = 0;
                Connection connCheck = null;
                try {
                    connCheck = DBConnection.getConnection();
                    PreparedStatement psCheck = connCheck.prepareStatement("SELECT COUNT(*) FROM CLUB_MEMBERSHIP WHERE ClubID = ? AND Status = 'active'");
                    psCheck.setInt(1, id);
                    ResultSet rsCheck = psCheck.executeQuery();
                    if(rsCheck.next()) activeMembers = rsCheck.getInt(1);
                } finally { if(connCheck != null) connCheck.close(); }

                if (activeMembers > 0) {
                    msg = "Error: Cannot delete. Society still has " + activeMembers + " active members.";
                } else {
                    handleDelete(id);
                    msg = "Club deleted";
                }
            }
            else if ("join".equals(action)) {
                Student s = (Student) session.getAttribute("student");
                clubDAO.joinClub(s.getStudentId(), Integer.parseInt(request.getParameter("clubId")));
                msg = "Welcome to the club!";
            }
            else if ("update".equals(action) && "admin".equals(userRole)) {
            int id = Integer.parseInt(request.getParameter("clubId"));
            String name = request.getParameter("clubName");
            String desc = request.getParameter("clubDescription");

            if(clubDAO.updateClub(id, name, desc)) {
                msg = "Society profile updated successfully";
            } else {
                msg = "Error: Failed to update society";
            }
        }
            else if ("leave".equals(action)) {
                Student s = (Student) session.getAttribute("student");
                clubDAO.requestToLeave(s.getStudentId(), Integer.parseInt(request.getParameter("clubId")));
                msg = "Leave request sent to Admin for approval.";
            }
            else if ("create".equals(action) && "admin".equals(userRole)) {
            String name = request.getParameter("clubName");
            String desc = request.getParameter("clubDescription");

            // Safety check: ensure values aren't null
            if (name != null && desc != null) {
                boolean success = clubDAO.createClub(name, desc);
                if (success) {
                    msg = "Society established successfully!";
                } else {
                    msg = "Error: Could not create society. Name might be too long.";
                }
            }
        }
            else if ("approveLeave".equals(action) && "admin".equals(userRole)) {
                String sid = request.getParameter("studentId");
                int cid = Integer.parseInt(request.getParameter("clubId"));
                clubDAO.approveLeave(sid, cid);
                msg = "Leave Request Approved";
            }
        } catch (Exception e) { e.printStackTrace(); msg = "Error occurred"; }

        response.sendRedirect("ClubController?success=" + java.net.URLEncoder.encode(msg, "UTF-8"));
    }

    private void handleDelete(int id) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps1 = conn.prepareStatement("DELETE FROM CLUB_MEMBERSHIP WHERE ClubID = ?");
            ps1.setInt(1, id);
            ps1.executeUpdate();
            PreparedStatement ps2 = conn.prepareStatement("DELETE FROM CLUB WHERE ClubID = ?");
            ps2.setInt(1, id);
            ps2.executeUpdate();
        } finally { if(conn != null) conn.close(); }
    }
}