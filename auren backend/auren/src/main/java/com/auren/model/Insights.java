package com.auren.model;

import lombok.*;

import java.time.OffsetDateTime;

/**
 * DTO de domínio para conteúdos de Insight (não é entidade JPA).
 * Use esta classe para trafegar "dicas, recomendações, artigos" na aplicação.
 * Os snapshots persistidos no banco continuam sendo representados por InsightSnapshot.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Insights {

    private Long id;

    // Metadados textuais do conteúdo (não persistidos por JPA aqui)
    private String title;        // ex.: "Reduza gastos em alimentação"
    private String description;  // ex.: "Tente substituir X por Y..."
    private String category;     // ex.: "Alimentação", "Moradia", etc.
    private Priority priority;   // HIGH | MEDIUM | LOW
    private ContentType contentType; // TIP | RECOMMENDATION | ARTICLE
    private String articleId;    // opcional: id externo de artigo

    // Momento de criação (na camada de conteúdo)
    private OffsetDateTime createdAt;

    // Enums usados pelo DTO
    public enum Priority {
        HIGH, MEDIUM, LOW
    }

    public enum ContentType {
        TIP, RECOMMENDATION, ARTICLE
    }
}
