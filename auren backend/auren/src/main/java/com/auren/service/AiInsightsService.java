package com.auren.service;

import com.auren.ai.GeminiClient;
import com.auren.model.InsightSnapshot;
import com.auren.model.Transaction;
import com.auren.model.TransactionType;
import com.auren.model.User;
import com.auren.repository.InsightSnapshotRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AiInsightsService {

    private final GeminiClient gemini;
    private final TransactionService txService;
    private final InsightSnapshotRepository snapshotRepo;
    private final ObjectMapper mapper = new ObjectMapper();

    public Map<String, Object> generateSnapshot(User user, int months, int topN) {
        LocalDate to = LocalDate.now();
        LocalDate from = to.minusMonths(months).withDayOfMonth(1);
        List<Transaction> txs = txService.list(user, from, to, 180);

        String txHash = computeTxHash(user, txs);
        // Se já existe snapshot com o mesmo hash e caller não pediu refresh, devolva o
        // recente
        var last = snapshotRepo.findTop1ByUserOrderByCreatedAtDesc(user);
        if (last.isPresent() && txHash.equals(last.get().getTxHash())) {
            try {
                return mapper.readValue(last.get().getPayloadJson(), Map.class);
            } catch (Exception ignore) {
                /* cai pra gerar */ }
        }

        var totals = totalsAndCategories(txs);
        BigDecimal totalIncome = (BigDecimal) totals.get("income");
        BigDecimal totalExpense = (BigDecimal) totals.get("expense");
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> categories = (List<Map<String, Object>>) totals.get("categories");

        String aiJson;
        String engine = "gemini";
        try {
            String prompt = buildPrompt(txs, months, topN);
            aiJson = gemini.generateJson(prompt, true);
        } catch (Exception e) {
            engine = "fallback";
            aiJson = "{\"tips\":[],\"content\":[]}";
        }

        Map<String, Object> ai;
        try {
            ai = mapper.readValue(aiJson, Map.class);
        } catch (Exception e) {
            ai = Map.of("tips", List.of(), "content", List.of());
        }
        ai = sanitizeAndBalance(ai, topN);

        List<?> tips = safeList(ai.get("tips"));
        List<?> content = safeList(ai.get("content"));

        Map<String, Object> snapshot = new LinkedHashMap<>();
        snapshot.put("engine", engine); // <<< origem explícita
        snapshot.put("from", from.toString());
        snapshot.put("to", to.toString());
        snapshot.put("totalIncome", totalIncome);
        snapshot.put("totalExpense", totalExpense);
        snapshot.put("categories", categories);
        snapshot.put("tips", tips);
        snapshot.put("content", content);

        persist(user, txHash, snapshot);
        return snapshot;
    }

    private void persist(User user, String txHash, Map<String, Object> snapshot) {
        try {
            var json = mapper.writeValueAsString(snapshot);
            snapshotRepo.save(InsightSnapshot.builder()
                    .user(user)
                    .payloadJson(json)
                    .txHash(txHash)
                    .createdAt(Instant.now())
                    .build());
        } catch (Exception e) {
            throw new RuntimeException("Erro salvando snapshot", e);
        }
    }

    private String computeTxHash(User user, List<Transaction> txs) {
        try {
            var md = java.security.MessageDigest.getInstance("SHA-256");
            var sb = new StringBuilder();
            sb.append(user.getId()).append('|');
            // ordena para estabilidade
            txs.stream()
                    .sorted(Comparator.comparing(Transaction::getDate).thenComparing(Transaction::getId,
                            Comparator.nullsLast(Long::compareTo)))
                    .forEach(t -> sb.append(t.getDate()).append('|')
                            .append(t.getType()).append('|')
                            .append(t.getCategory()).append('|')
                            .append(t.getAmount()).append('|')
                            .append(t.getDescription()).append(';'));
            byte[] hash = md.digest(sb.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (byte b : hash)
                hex.append(String.format("%02x", b));
            return hex.toString();
        } catch (Exception e) {
            return String.valueOf(Objects.hash(user.getId(), txs.size()));
        }
    }

    /**
     * Retorna o snapshot mais recente (se existir).
     */
    public Optional<Map<String, Object>> recent(User user) {
        return snapshotRepo.findTop1ByUserOrderByCreatedAtDesc(user)
                .map(s -> {
                    try {
                        return mapper.readValue(s.getPayloadJson(), Map.class);
                    } catch (Exception e) {
                        throw new RuntimeException("Snapshot JSON inválido", e);
                    }
                });
    }

    private void persist(User user, Map<String, Object> snapshot) {
        try {
            var json = mapper.writeValueAsString(snapshot);
            snapshotRepo.save(InsightSnapshot.builder()
                    .user(user)
                    .payloadJson(json)
                    .createdAt(Instant.now())
                    .build());
        } catch (Exception e) {
            throw new RuntimeException("Erro salvando snapshot", e);
        }
    }

    private Map<String, Object> totalsAndCategories(List<Transaction> txs) {
        BigDecimal income = BigDecimal.ZERO;
        BigDecimal expense = BigDecimal.ZERO;
        Map<String, BigDecimal> byCat = new HashMap<>();

        for (var t : txs) {
            if (t.getType() == TransactionType.INCOME) {
                income = income.add(t.getAmount());
            } else {
                expense = expense.add(t.getAmount());
                byCat.merge(t.getCategory(), t.getAmount(), BigDecimal::add);
            }
        }

        // *** Forma "segura" de montar a lista (evita intersection types) ***
        List<Map<String, Object>> categories = new ArrayList<>();
        List<Map.Entry<String, BigDecimal>> ordered = byCat.entrySet().stream()
                .sorted(Map.Entry.<String, BigDecimal>comparingByValue().reversed())
                .collect(Collectors.toList());

        for (var e : ordered) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("category", e.getKey());
            m.put("amount", e.getValue());
            categories.add(m);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("income", income);
        result.put("expense", expense);
        result.put("categories", categories);
        return result;
    }

    private List<?> safeList(Object o) {
        return (o instanceof List<?>) ? (List<?>) o : Collections.emptyList();
    }

    private String buildPrompt(List<Transaction> txs, int months, int topN) {
        var sb = new StringBuilder();
        sb.append(
                """
                        Você é um assistente financeiro da Auren.
                        Gere recomendações e conteúdo educacional EM PORTUGUÊS, em JSON estrito.
                        Use as transações abaixo (últimos %d meses) para contextualizar e utilizando fontes CONFIÁVEIS da web.

                        REGRAS IMPORTANTES (SIGA À RISCA):
                        - Responda EXCLUSIVAMENTE com JSON VÁLIDO (UTF-8), SEM texto fora do JSON.
                        - Estrutura:
                        {
                          "tips": [
                            {
                              "title": "string",
                              "description": "string",
                              "category": "string",
                              "priority": "low|medium|high",
                              "contentType": "tip|recommendation",
                              "articleId": "string|opcional"
                            }
                          ],
                          "content": [
                            {
                              "id": "string",
                              "title": "string",
                              "description": "string",
                              "type": "article|video|podcast",
                              "category": "string",
                              "url": "https://...",
                              "thumbnailUrl": "string|null",
                              "author": "string",
                              "readTimeMinutes": 8,
                              "tags": ["string", "..."]
                            }
                          ]
                        }
                        - No máximo %d itens em "tips" e %d em "content".
                        - Seja específico e acionável (ex.: “reduza X em Y%%”, “defina teto em Z”).
                        - Produza VARIEDADE: pelo menos 1 "article" e 1 "video". Se pertinente, inclua 1 "podcast".
                        - NÃO invente links. Só use URLs PÚBLICAS e CONFIÁVEIS.
                        - Todo o conteúdo deve ser acessível e verificável.
                        - Todo o conteúdo recomendado deve ser facilmente encontrado no google
                        - NÃO recomende instalar apps de terceiros para controle de gastos uma vez que o nosso app Auren é justamente pra isso
                        - Considere: despesas > renda, categorias concentradas, pico em "Moradia" etc.
                        - Se houver concentração de despesas (ex.: moradia), produza dicas ESPECÍFICAS e acionáveis.
                        - Seja curto, claro e pragmático.
                        """
                        .formatted(months, topN, Math.max(2, topN / 2)));

        sb.append("\nTransações (DATA | TIPO | CATEGORIA | DESCRIÇÃO | VALOR):\n");
        txs.stream()
                .limit(180)
                .forEach(t -> sb.append(
                        "%s | %s | %s | %s | %.2f\n".formatted(
                                t.getDate(), t.getType(), t.getCategory(), t.getDescription(), t.getAmount())));
        return sb.toString();
    }

    private static final Set<String> ALLOW_DOMAINS = Set.of(
            "www.bcb.gov.br", "bcb.gov.br",
            "www.serasa.com.br", "serasa.com.br",
            "www.gov.br", "gov.br",
            "www.anbima.com.br", "anbima.com.br",
            "www.youtube.com", "youtube.com", "youtu.be",
            "open.spotify.com");

    @SuppressWarnings("unchecked")
    private Map<String, Object> sanitizeAndBalance(Map<String, Object> ai, int topN) {
        List<Map<String, Object>> tips = new ArrayList<>();
        List<Map<String, Object>> content = new ArrayList<>();

        Object tipsObj = ai.get("tips");
        if (tipsObj instanceof List<?> l) {
            for (Object o : l)
                if (o instanceof Map<?, ?> m) {
                    tips.add((Map<String, Object>) m);
                }
        }
        Object contObj = ai.get("content");
        if (contObj instanceof List<?> l) {
            for (Object o : l)
                if (o instanceof Map<?, ?> m) {
                    var item = new HashMap<String, Object>((Map<String, Object>) m);

                    // Valida URL/domínio
                    String url = String.valueOf(item.getOrDefault("url", ""));
                    if (!url.startsWith("http"))
                        continue;
                    try {
                        var host = java.net.URI.create(url).getHost();
                        if (host == null)
                            continue;
                        if (!ALLOW_DOMAINS.contains(host.toLowerCase()))
                            continue;
                        if (host.toLowerCase().endsWith("auren.com"))
                            continue;
                    } catch (Exception ignore) {
                        continue;
                    }
                    content.add(item);
                }
        }

        // Garante 1 artigo e 1 vídeo (e tenta 1 podcast)
        var articles = content.stream().filter(c -> "article".equalsIgnoreCase(String.valueOf(c.get("type")))).toList();
        var videos = content.stream().filter(c -> "video".equalsIgnoreCase(String.valueOf(c.get("type")))).toList();
        var podcasts = content.stream().filter(c -> "podcast".equalsIgnoreCase(String.valueOf(c.get("type")))).toList();

        // Se faltar artigo/vídeo, injeta fallback confiável
        if (articles.isEmpty()) {
            content.add(Map.of(
                    "id", "bcb-cidadania",
                    "title", "Cidadania Financeira (BCB)",
                    "description", "Materiais oficiais sobre planejamento, poupança e crédito.",
                    "type", "article",
                    "category", "planejamento",
                    "url", "https://www.bcb.gov.br/cidadaniafinanceira",
                    "thumbnailUrl", null,
                    "author", "Banco Central do Brasil",
                    "readTimeMinutes", 6,
                    "tags", List.of("planejamento", "educacao-financeira")));
        }
        if (videos.isEmpty()) {
            content.add(Map.of(
                    "id", "youtube-bcb",
                    "title", "Canal do Banco Central do Brasil",
                    "description", "Vídeos institucionais e séries sobre educação financeira.",
                    "type", "video",
                    "category", "educacao",
                    "url", "https://www.youtube.com/@BancoCentraldoBrasil",
                    "thumbnailUrl", null,
                    "author", "Banco Central do Brasil",
                    "readTimeMinutes", 10,
                    "tags", List.of("video", "bcb")));
        }

        // Limita tamanho
        if (tips.size() > topN)
            tips = tips.subList(0, topN);
        int contentMax = Math.max(2, topN / 2);
        if (content.size() > contentMax)
            content = content.subList(0, contentMax);

        Map<String, Object> out = new HashMap<>();
        out.put("tips", tips);
        out.put("content", content);
        return out;
    }
}
