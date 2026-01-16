package com.ucms2.db;

import com.ucms2.model.Club;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ClubDAO {

    // --- ADD THIS METHOD TO FIX THE "CANNOT FIND SYMBOL" ERROR ---
    public Club getClubById(int clubId) {
        Club club = null;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM CLUB WHERE ClubID = ?";
        
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, clubId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                club = new Club();
                club.setClubId(rs.getInt("ClubID"));
                club.setClubName(rs.getString("ClubName"));
                club.setClubDescription(rs.getString("ClubDescription"));
                club.setCreatedBy(rs.getString("CreatedBy"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return club;
    }

    public List searchClubs(String query) {
        List results = new ArrayList();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        String sql = "SELECT * FROM CLUB WHERE UPPER(ClubName) LIKE UPPER(?) OR UPPER(ClubDescription) LIKE UPPER(?)";
        
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            String searchPattern = "%" + query + "%"; 
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            
            rs = ps.executeQuery();
            while (rs.next()) {
                Club club = new Club();
                club.setClubId(rs.getInt("ClubID"));
                club.setClubName(rs.getString("ClubName"));
                club.setClubDescription(rs.getString("ClubDescription"));
                club.setCreatedBy(rs.getString("CreatedBy"));
                results.add(club);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return results;
    }

    public boolean isMember(String studentId, int clubId) {
        boolean membershipExists = false;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sql = "SELECT 1 FROM CLUB_MEMBERSHIP WHERE StudentID = ? AND ClubID = ?";
        
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, studentId);
            ps.setInt(2, clubId);
            rs = ps.executeQuery();
            if (rs.next()) {
                membershipExists = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return membershipExists;
    }

    public List getAllClubs() {
        List clubs = new ArrayList();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM CLUB";
        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                Club club = new Club();
                club.setClubId(rs.getInt("ClubID"));
                club.setClubName(rs.getString("ClubName"));
                club.setClubDescription(rs.getString("ClubDescription"));
                club.setCreatedBy(rs.getString("CreatedBy"));
                clubs.add(club);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, stmt, rs);
        }
        return clubs;
    }

    private void closeResources(Connection conn, Statement stmt, ResultSet rs) {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
}