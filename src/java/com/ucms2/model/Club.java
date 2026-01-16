package com.ucms2.model;

import java.io.Serializable;
import java.util.Date;

public class Club implements Serializable {
    private int clubId;
    private String clubName;
    private String clubDescription;
    private String createdBy;
    private Date createdAt;
    
    public Club() {}
    
    public Club(String clubName, String clubDescription, String createdBy) {
        this.clubName = clubName;
        this.clubDescription = clubDescription;
        this.createdBy = createdBy;
    }
    
    // Getters and Setters
    public int getClubId() { return clubId; }
    public void setClubId(int clubId) { this.clubId = clubId; }
    
    public String getClubName() { return clubName; }
    public void setClubName(String clubName) { this.clubName = clubName; }
    
    public String getClubDescription() { return clubDescription; }
    public void setClubDescription(String clubDescription) { this.clubDescription = clubDescription; }
    
    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }
    
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}