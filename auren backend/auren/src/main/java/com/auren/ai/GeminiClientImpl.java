package com.auren.ai;

import com.google.genai.Client;
import com.google.genai.types.GenerateContentConfig;
import com.google.genai.types.GenerateContentResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GeminiClientImpl implements GeminiClient {

    private static final Logger log = LoggerFactory.getLogger(GeminiClientImpl.class);

    private final Client client;
    private final String model;

    public GeminiClientImpl(String apiKey, String model) {
        this.model = (model == null || model.isBlank()) ? "gemini-2.5-flash" : model;
        this.client = (apiKey == null || apiKey.isBlank())
                ? new Client()
                : Client.builder().apiKey(apiKey).build();

        log.info("[Gemini] Inicializado com modelo={} (apiKey via {} )",
                this.model, (apiKey == null || apiKey.isBlank() ? "ENV" : "config"));
    }

    @Override
    public String generateJson(String prompt, boolean grounded) throws Exception {
        GenerateContentConfig cfg = GenerateContentConfig.builder()
                .responseMimeType("application/json")
                .build();

        log.info("[Gemini] Chamando modelo={}  promptChars={}", model, prompt.length());
        long t0 = System.currentTimeMillis();

        GenerateContentResponse resp = client.models.generateContent(model, prompt, cfg);
        String txt = resp.text();
        long ms = System.currentTimeMillis() - t0;

        log.info("[Gemini] OK em {} ms  bytes={}", ms, (txt == null ? 0 : txt.length()));
        if (txt == null || txt.isBlank()) return "{}";
        log.debug("[Gemini] preview: {}", txt.substring(0, Math.min(200, txt.length())));
        return txt;
    }
}
