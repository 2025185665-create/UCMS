package com.ucms2.model;

import java.io.Serializable;
import java.util.Date;

public class ClubMembership implements Serializable {
    private int membershipId;
    private String studentId;
    private int clubId;
    private Date joinDate;
    
    public ClubMembership() {}
    
    public ClubMembership(String studentId, int clubId) {
        this.studentId = studentId;
        this.clubId = clubId;
    }
    
    // Getters and Setters
    public int getMembershipId() { return membershipId; }
    public void setMembershipId(int membershipId) { this.membershipId = membershipId; }
    
    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }
    
    public int getClubId() { return clubId; }
    public void setClubId(int clubId) { this.clubId = clubId; }
    
    public Date getJoinDate() { return joinDate; }
    public void setJoinDate(Date joinDate) { this.joinDate = joinDate; }
}