package com.auren.service;

import com.auren.model.Transaction;
import com.auren.model.TransactionType;
import com.auren.model.dto.InsightsRequest;
import com.auren.model.dto.InsightsResponse;
import com.auren.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InsightsService {

    private final TransactionRepository transactionRepository;

    public InsightsResponse generate(Long userId, InsightsRequest req) {
        LocalDate to = Optional.ofNullable(req.getTo()).orElse(LocalDate.now());
        LocalDate from = Optional.ofNullable(req.getFrom()).orElse(to.minusMonths(6));

        // 1) Dados base
        List<Transaction> txs = transactionRepository
                .findByUserIdAndDateBetweenOrderByDateDesc(userId, from, to);

        BigDecimal totalIncome = BigDecimal.ZERO;
        BigDecimal totalExpense = BigDecimal.ZERO;
        Map<String, BigDecimal> expenseByCategory = new HashMap<>();

        for (Transaction t : txs) {
            if (t.getType() == TransactionType.INCOME) {
                totalIncome = totalIncome.add(ns(t.getAmount()));
            } else if (t.getType() == TransactionType.EXPENSE) {
                BigDecimal amt = ns(t.getAmount());
                totalExpense = totalExpense.add(amt);
                expenseByCategory.merge(sc(t.getCategory()), amt, BigDecimal::add);
            }
        }

        // 2) Top categorias de despesa
        List<InsightsResponse.CategoryBreakdown> topCategories = expenseByCategory.entrySet()
                .stream()
                .sorted((a, b) -> b.getValue().compareTo(a.getValue()))
                .limit(5)
                .map(e -> InsightsResponse.CategoryBreakdown.builder()
                        .category(e.getKey())
                        .amount(e.getValue())
                        .build())
                .collect(Collectors.toList());

        // 3) Dicas contextuais
        List<InsightsResponse.Tip> tips = new ArrayList<>();

        if (gt(totalExpense, totalIncome)) {
            tips.add(InsightsResponse.Tip.builder()
                    .title("Gastos acima da renda")
                    .description("Suas despesas no período superaram sua renda. Reavalie as categorias mais altas e defina um teto semanal.")
                    .category("Orçamento")
                    .priority("high")
                    .contentType("recommendation")
                    .build());
        }

        if (!topCategories.isEmpty() && totalExpense.compareTo(BigDecimal.ZERO) > 0) {
            InsightsResponse.CategoryBreakdown top = topCategories.get(0);
            BigDecimal pct = top.getAmount()
                    .multiply(BigDecimal.valueOf(100))
                    .divide(totalExpense, 2, RoundingMode.HALF_UP);
            if (pct.compareTo(BigDecimal.valueOf(30)) >= 0) {
                tips.add(InsightsResponse.Tip.builder()
                        .title("Reveja '" + top.getCategory() + "'")
                        .description("A categoria '" + top.getCategory() + "' representa " + pct + "% dos seus gastos. Busque alternativas e metas de redução.")
                        .category("Categorias")
                        .priority("medium")
                        .contentType("recommendation")
                        .build());
            }
        }

        tips.add(InsightsResponse.Tip.builder()
                .title("Regra 50/30/20")
                .description("Tente alocar 50% necessidades, 30% desejos e 20% poupança/investimentos.")
                .category("Planejamento")
                .priority("low")
                .contentType("tip")
                .build());

        // 4) Conteúdo educacional (lista compatível com Java 8)
        List<InsightsResponse.Content> content = Arrays.asList(
                InsightsResponse.Content.builder()
                        .id("edu001")
                        .title("Como montar um orçamento familiar")
                        .description("Aprenda a criar um orçamento eficiente.")
                        .type("article")
                        .category("Orçamento")
                        .url("https://exemplo/artigos/edu001")
                        .author("Equipe Auren")
                        .readTimeMinutes(8)
                        .tags(Arrays.asList("orçamento", "finanças pessoais"))
                        .build(),
                InsightsResponse.Content.builder()
                        .id("edu002")
                        .title("Investimentos para iniciantes")
                        .description("Primeiros passos no mundo dos investimentos.")
                        .type("video")
                        .category("Investimentos")
                        .url("https://exemplo/videos/edu002")
                        .author("Equipe Auren")
                        .readTimeMinutes(15)
                        .tags(Arrays.asList("investimentos", "iniciantes"))
                        .build()
        );

        // 5) Monta resposta
        return InsightsResponse.builder()
                .from(from)
                .to(to)
                .totalIncome(totalIncome)
                .totalExpense(totalExpense)
                .categories(topCategories)
                .tips(tips)
                .content(content)
                .build();
    }

    // --- helpers ---
    private static BigDecimal ns(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }
    private static String sc(String c) {
        return (c == null || c.trim().isEmpty()) ? "Outros" : c;
    }
    private static boolean gt(BigDecimal a, BigDecimal b) {
        return a.compareTo(b) > 0;
    }
}
