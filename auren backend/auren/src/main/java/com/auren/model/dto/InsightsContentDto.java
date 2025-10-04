package com.auren.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@Schema(description = "Conteúdo educacional recomendado")
public class InsightsContentDto {
  public String id;
  public String title;
  public String description;

  @Schema(example = "article|video|podcast")
  public String type;

  public String category;
  public String url;
  public String thumbnailUrl;
  public String author;
  public Integer readTimeMinutes;
  public List<String> tags;

  public InsightsContentDto() {}
  public InsightsContentDto(String id, String title, String desc, String type,
                            String category, String url, String thumb, String author,
                            Integer read, List<String> tags) {
    this.id = id; this.title = title; this.description = desc; this.type = type;
    this.category = category; this.url = url; this.thumbnailUrl = thumb;
    this.author = author; this.readTimeMinutes = read; this.tags = tags;
  }
}
