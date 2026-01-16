package com.ucms2.model;

import java.io.Serializable;
import java.util.Date;

public class CampusBuzz implements Serializable {
    private int postId;
    private String studentId;
    private String studentName;
    private String content;
    private String status; // pending, approved, rejected
    private int adminId;
    private Date uploadDate;
    private Date approvedDate;
    private String category; // info, lost_found, program

    public CampusBuzz() {}
    
    public CampusBuzz(String studentId, String studentName, String content) {
        this.studentId = studentId;
        this.studentName = studentName;
        this.content = content;
        this.status = "pending";
    }
    
    // Getters and Setters
    
    public int getPostId() { return postId; }
    public void setPostId(int postId) { this.postId = postId; }
    

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }
    
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public Date getUploadDate() { return uploadDate; }
    public void setUploadDate(Date uploadDate) { this.uploadDate = uploadDate; }
    
    public int getAdminId() { return adminId; }
    public void setAdminId(int adminId) { this.adminId = adminId; }
    
    public Date getApprovedDate() { return approvedDate; }
    public void setApprovedDate(Date approvedDate) { this.approvedDate = approvedDate; }
}