package com.auren.config;

import com.auren.ai.GeminiClient;
import com.auren.ai.GeminiClientImpl;
import com.auren.ai.GeminiClientNoop;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AiConfig {
    private static final Logger log = LoggerFactory.getLogger(AiConfig.class);

    @Bean
    public GeminiClient geminiClient(
            @Value("${gemini.api-key:}") String apiKeyProp,
            @Value("${gemini.model:gemini-2.5-flash}") String model
    ) {
        String apiKeyEnv = System.getenv("GEMINI_API_KEY");
        String apiKeySys = System.getProperty("GEMINI_API_KEY");

        String apiKey = !isBlank(apiKeyProp) ? apiKeyProp
                      : !isBlank(apiKeyEnv)  ? apiKeyEnv
                      : !isBlank(apiKeySys)  ? apiKeySys
                      : "AIzaSyDkatof6YvZyDNilOuD98ShUPZ0lTj4mRE"; // usando api hardcoded para o professor conseguir rodar localmente sem precisar de configurar o env

        if (apiKey.isBlank()) {
            log.warn("Gemini desativado (sem API key). Usando fallback.");
            return new GeminiClientNoop();
        }

        String masked = apiKey.length() <= 6 ? "******" : apiKey.substring(0, 3) + "***";
        log.info("Gemini habilitado (model={}), origem da chave: {}.",
                model,
                !isBlank(apiKeyProp) ? "application.properties" :
                !isBlank(apiKeyEnv)  ? "ENV (GEMINI_API_KEY)" :
                                       "System property (GEMINI_API_KEY)");
        return new GeminiClientImpl(apiKey, model);
    }

    private static boolean isBlank(String s) {
        return s == null || s.isBlank();
    }
}
