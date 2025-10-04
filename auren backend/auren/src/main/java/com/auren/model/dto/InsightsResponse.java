package com.auren.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InsightsResponse {

    private LocalDate from;
    private LocalDate to;

    private BigDecimal totalIncome;
    private BigDecimal totalExpense;

    private List<CategoryBreakdown> categories; // despesas por categoria
    private List<Tip> tips;
    private List<Content> content;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CategoryBreakdown {
        private String category;
        private BigDecimal amount;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Tip {
        private String title;
        private String description;
        private String category;
        private String priority;     // high|medium|low
        private String contentType;  // tip|recommendation|articleRecommendation
        private String articleId;    // opcional
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Content {
        private String id;
        private String title;
        private String description;
        private String type;            // article|video|podcast
        private String category;
        private String url;
        private String thumbnailUrl;
        private String author;
        private Integer readTimeMinutes;
        private List<String> tags;
    }
}