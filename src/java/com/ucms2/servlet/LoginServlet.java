package com.ucms2.servlet;

import com.ucms2.db.DBConnection;
import com.ucms2.model.Admin;
import com.ucms2.model.Student;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String adminEmail = request.getParameter("adminEmail");
        String studentId = request.getParameter("studentId");
        String password = request.getParameter("password");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // 1. ADMIN LOGIN (Matches your SQL: AdminEmail and adminPassword)
            if (adminEmail != null && !adminEmail.trim().isEmpty()) {
                // Note: adminPassword is lower/camelCase in your SQL script
                String sql = "SELECT * FROM ADMIN WHERE ADMINEMAIL = ? AND adminPassword = ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, adminEmail);
                ps.setString(2, password);
                
                rs = ps.executeQuery();
                if (rs.next()) {
                    Admin admin = new Admin();
                    admin.setAdminId(rs.getInt("ADMINID"));
                    admin.setAdminName(rs.getString("ADMINNAME"));
                    admin.setAdminEmail(rs.getString("ADMINEMAIL"));

                    HttpSession session = request.getSession();
                    session.setAttribute("admin", admin);
                    session.setAttribute("userRole", "admin");
                    response.sendRedirect("admin-dashboard-data");
                    return;
                }
            } 
            
            // 2. STUDENT LOGIN (Matches your SQL: StudentID and StudentPassword)
            else if (studentId != null && !studentId.trim().isEmpty()) {
                String sql = "SELECT * FROM STUDENT WHERE STUDENTID = ? AND STUDENTPASSWORD = ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, studentId);
                ps.setString(2, password);
                
                rs = ps.executeQuery();
                if (rs.next()) {
                    Student student = new Student();
                    student.setStudentId(rs.getString("STUDENTID"));
                    student.setStudentName(rs.getString("STUDENTNAME"));
                    
                    HttpSession session = request.getSession();
                    session.setAttribute("student", student);
                    session.setAttribute("userRole", "student");
                    response.sendRedirect("student-dashboard.jsp");
                    return;
                }
            }

            response.sendRedirect("login.jsp?error=Invalid Credentials");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=Server Error: " + e.getMessage());
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (ps != null) try { ps.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
}