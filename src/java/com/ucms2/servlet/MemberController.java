package com.ucms2.servlet;

import com.ucms2.db.DBConnection;
import com.ucms2.db.StudentDAO;
import com.ucms2.model.Admin;
import com.ucms2.model.Student;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/MemberController")
public class MemberController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String userRole = (String) session.getAttribute("userRole");
        String action = request.getParameter("action");
        String studentId = request.getParameter("studentId"); // For Transcript

        // Security check using your userRole session logic
        if (!"admin".equals(userRole)) {
            response.sendRedirect("login.jsp");
            return;
        }

        // NEW: If a studentId is provided, forward to transcript view in JSP
        if (studentId != null && !studentId.isEmpty()) {
            request.getRequestDispatcher("members.jsp").forward(request, response);
            return;
        }

        if ("viewAll".equals(action)) {
            StudentDAO dao = new StudentDAO();
            List<Student> students = dao.getAllStudents();
            request.setAttribute("studentList", students);
            request.getRequestDispatcher("view-students.jsp").forward(request, response);
        } else {
            fetchClubMemberships(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");

        if ("register".equals(action)) {
            handleStudentRegistration(request, response);
        } else if ("revoke".equals(action)) {
            handleRevokeMembership(request, response);
        } else if ("approveLeave".equals(action)) {
            processLeaveRequest(request, response, true);
        } else if ("rejectLeave".equals(action)) {
            processLeaveRequest(request, response, false);
        }
    }

    private void processLeaveRequest(HttpServletRequest request, HttpServletResponse response, boolean approve) 
            throws IOException {
        String studentId = request.getParameter("studentId");
        String clubIdRaw = request.getParameter("clubId");
        
        if (studentId == null || clubIdRaw == null) {
            response.sendRedirect("AdminDashboardController?error=Missing Data");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            int clubId = Integer.parseInt(clubIdRaw);
            
            String sql = approve ? "DELETE FROM CLUB_MEMBERSHIP WHERE StudentID = ? AND ClubID = ?" 
                                 : "UPDATE CLUB_MEMBERSHIP SET Status = 'active' WHERE StudentID = ? AND ClubID = ?";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, studentId);
            ps.setInt(2, clubId);
            ps.executeUpdate();
            response.sendRedirect("AdminDashboardController?success=Request Processed");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("AdminDashboardController?error=Action Failed");
        }
    }

    private void fetchClubMemberships(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        List<Map<String, String>> members = new ArrayList<Map<String, String>>();
        
        String sql = "SELECT m.StudentID, s.StudentName, s.StudentEmail, c.ClubName, m.JoinDate " +
                     "FROM CLUB_MEMBERSHIP m " +
                     "JOIN STUDENT s ON m.StudentID = s.StudentID " +
                     "JOIN CLUB c ON m.ClubID = c.ClubID " +
                     "WHERE m.Status = 'active' " +
                     "ORDER BY m.JoinDate DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Map<String, String> member = new HashMap<String, String>();
                member.put("id", rs.getString("StudentID"));
                member.put("name", rs.getString("StudentName"));
                member.put("email", rs.getString("StudentEmail"));
                member.put("club", rs.getString("ClubName"));
                member.put("date", rs.getString("JoinDate"));
                members.add(member);
            }
            
            session.setAttribute("members", members);
            response.sendRedirect("members.jsp");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("AdminDashboardController?error=Data load failed");
        }
    }

    private void handleStudentRegistration(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String id = request.getParameter("studentId");
        String name = request.getParameter("studentName");
        String email = request.getParameter("studentEmail");
        String pass = request.getParameter("password");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO STUDENT (StudentID, StudentName, StudentEmail, Password) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, id);
            ps.setString(2, name);
            ps.setString(3, email);
            ps.setString(4, pass);

            if (ps.executeUpdate() > 0) {
                response.sendRedirect("login.jsp?success=Registration successful!");
            } else {
                response.sendRedirect("register.jsp?error=Registration failed.");
            }
        } catch (SQLException e) {
            if ("23505".equals(e.getSQLState())) {
                response.sendRedirect("register.jsp?error=ID or Email already registered.");
            } else {
                e.printStackTrace();
                response.sendRedirect("register.jsp?error=Database error.");
            }
        }
    }

    private void handleRevokeMembership(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String studentId = request.getParameter("studentId");
        String clubName = request.getParameter("clubName");
        String sql = "DELETE FROM CLUB_MEMBERSHIP WHERE StudentID = ? " +
                     "AND ClubID = (SELECT ClubID FROM CLUB WHERE ClubName = ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setString(2, clubName);
            ps.executeUpdate();
            response.sendRedirect("MemberController?success=Membership revoked successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("MemberController?error=Remove failed");
        }
    }
}