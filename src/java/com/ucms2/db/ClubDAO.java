package com.ucms2.db;

import com.ucms2.model.Club;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ClubDAO {

    public Club getClubById(int clubId) {
        Club club = null;
        String sql = "SELECT * FROM CLUB WHERE ClubID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, clubId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                club = new Club();
                club.setClubId(rs.getInt("ClubID"));
                club.setClubName(rs.getString("ClubName"));
                club.setClubDescription(rs.getString("ClubDescription"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return club;
    }

    public boolean createClub(String name, String desc) {
        String sql = "INSERT INTO CLUB (ClubName, ClubDescription) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, desc);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { return false; }
    }

    public boolean joinClub(String studentId, int clubId) {
        String sql = "INSERT INTO CLUB_MEMBERSHIP (StudentID, ClubID, Status) VALUES (?, ?, 'active')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setInt(2, clubId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { return false; }
    }

    // Mark as pending
    public boolean requestToLeave(String studentId, int clubId) {
        String sql = "UPDATE CLUB_MEMBERSHIP SET Status = 'leave_pending' WHERE StudentID = ? AND ClubID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setInt(2, clubId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { return false; }
    }

    // Final deletion by Admin
    public boolean approveLeave(String studentId, int clubId) {
        String sql = "DELETE FROM CLUB_MEMBERSHIP WHERE StudentID = ? AND ClubID = ? AND Status = 'leave_pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setInt(2, clubId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { return false; }
    }

    public boolean isMember(String studentId, int clubId) {
        String sql = "SELECT 1 FROM CLUB_MEMBERSHIP WHERE StudentID = ? AND ClubID = ? AND Status = 'active'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setInt(2, clubId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) { return false; }
    }

    public List getAllClubs() {
        List clubs = new ArrayList();
        String sql = "SELECT * FROM CLUB";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Club club = new Club();
                club.setClubId(rs.getInt("ClubID"));
                club.setClubName(rs.getString("ClubName"));
                club.setClubDescription(rs.getString("ClubDescription"));
                clubs.add(club);
            }
        } catch (SQLException e) { e.printStackTrace(); } 
        return clubs;
    }
}