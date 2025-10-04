package com.auren.model.dto;

import com.auren.model.Insights;
import java.time.OffsetDateTime;

public class InsightsDto {
    private Long id;
    private String title;
    private String description;
    private String category;
    private String priority;     // HIGH | MEDIUM | LOW
    private String contentType;  // TIP | RECOMMENDATION | ARTICLE
    private String articleId;    // opcional
    private OffsetDateTime createdAt;

    public InsightsDto() {}

    public static InsightsDto fromEntity(Insights i) {
        InsightsDto dto = new InsightsDto();
        dto.id = i.getId();
        dto.title = i.getTitle();
        dto.description = i.getDescription();
        dto.category = i.getCategory();
        dto.priority = i.getPriority().name();
        dto.contentType = i.getContentType().name();
        dto.articleId = i.getArticleId();
        dto.createdAt = i.getCreatedAt();
        return dto;
    }

    // getters/setters
    public Long getId() { return id; }
    public String getTitle() { return title; }
    public String getDescription() { return description; }
    public String getCategory() { return category; }
    public String getPriority() { return priority; }
    public String getContentType() { return contentType; }
    public String getArticleId() { return articleId; }
    public OffsetDateTime getCreatedAt() { return createdAt; }

    public void setId(Long id) { this.id = id; }
    public void setTitle(String title) { this.title = title; }
    public void setDescription(String description) { this.description = description; }
    public void setCategory(String category) { this.category = category; }
    public void setPriority(String priority) { this.priority = priority; }
    public void setContentType(String contentType) { this.contentType = contentType; }
    public void setArticleId(String articleId) { this.articleId = articleId; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}
