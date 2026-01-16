package com.ucms2.servlet;

import com.ucms2.db.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/student-register")
public class StudentRegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String id = request.getParameter("studentId");
        String name = request.getParameter("studentName");
        String email = request.getParameter("studentEmail");
        String pass = request.getParameter("password");

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO STUDENT (StudentID, StudentName, StudentEmail, StudentPassword) VALUES (?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, id);
            ps.setString(2, name);
            ps.setString(3, email);
            ps.setString(4, pass);

            int result = ps.executeUpdate();
            
            if (result > 0) {
                // SUCCESS: Send to login with a message
                response.sendRedirect("login.jsp?success=Registration successful! You can now log in.");
            } else {
                response.sendRedirect("register.jsp?error=Registration failed. Please try again.");
            }

        } catch (SQLException e) {
            // Check for Duplicate Key (SQLState 23505)
            if ("23505".equals(e.getSQLState())) {
                response.sendRedirect("register.jsp?error=This Student ID or Email is already registered.");
            } else {
                response.sendRedirect("register.jsp?error=Database error: " + e.getMessage());
            }
        } catch (Exception e) {
            response.sendRedirect("register.jsp?error=An unexpected error occurred.");
        } finally {
            if (ps != null) try { ps.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
}