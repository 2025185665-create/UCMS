package com.ucms2.servlet;

import com.ucms2.db.DBConnection;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RegistrationServlet")
public class RegistrationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Capture Form Data
        String studentId = request.getParameter("studentId");
        String studentName = request.getParameter("studentName");
        String studentEmail = request.getParameter("studentEmail");
        String password = request.getParameter("password");

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            
            // 2. Prepare SQL (Ensure table name matches your DB: STUDENT)
            String sql = "INSERT INTO STUDENT (StudentID, StudentName, StudentEmail, Password) VALUES (?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, studentId);
            ps.setString(2, studentName);
            ps.setString(3, studentEmail);
            ps.setString(4, password);

            int result = ps.executeUpdate();

            if (result > 0) {
                // 3. SUCCESS: Redirect to login.jsp with a message
                String msg = "Account created successfully for " + studentName + "! Please login.";
                response.sendRedirect("login.jsp?success=" + URLEncoder.encode(msg, "UTF-8"));
            } else {
                response.sendRedirect("register.jsp?error=Registration failed. Please try again.");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            String errorMsg = "Error: Student ID already registered or database issue.";
            response.sendRedirect("register.jsp?error=" + URLEncoder.encode(errorMsg, "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("register.jsp?error=An unexpected error occurred.");
        } finally {
            if (ps != null) try { ps.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
}