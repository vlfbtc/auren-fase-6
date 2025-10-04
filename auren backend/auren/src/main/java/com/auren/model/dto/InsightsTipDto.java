package com.auren.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Dica ou recomendação personalizada")
public class InsightsTipDto {
  @Schema(example = "Reveja 'Moradia'")
  public String title;

  @Schema(example = "A categoria representa 35% das suas despesas.")
  public String description;

  @Schema(example = "Moradia")
  public String category;

  @Schema(example = "low|medium|high")
  public String priority;

  @Schema(example = "tip|recommendation")
  public String contentType;

  @Schema(example = "artigo-123", nullable = true)
  public String articleId;

  public InsightsTipDto() {}
  public InsightsTipDto(String t, String d, String c, String p, String ct, String aid) {
    title = t; description = d; category = c; priority = p; contentType = ct; articleId = aid;
  }
}
