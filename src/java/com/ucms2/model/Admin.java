package com.ucms2.model;

import java.io.Serializable;
import java.util.Date;

public class Admin implements Serializable {
    private int adminId;
    private String adminName;
    private String adminEmail;
    private String adminPassword;
    private Date createdAt;
    
    public Admin() {}
    
    public Admin(String adminName, String adminEmail, String adminPassword) {
        this.adminName = adminName;
        this.adminEmail = adminEmail;
        this.adminPassword = adminPassword;
    }
    
    // Getters and Setters
    public int getAdminId() { return adminId; }
    public void setAdminId(int adminId) { this.adminId = adminId; }
    
    public String getAdminName() { return adminName; }
    public void setAdminName(String adminName) { this.adminName = adminName; }
    
    public String getAdminEmail() { return adminEmail; }
    public void setAdminEmail(String adminEmail) { this.adminEmail = adminEmail; }
    
    public String getAdminPassword() { return adminPassword; }
    public void setAdminPassword(String adminPassword) { this.adminPassword = adminPassword; }
    
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}