package com.auren.ai;

public interface GeminiClient {
    String generateJson(String prompt, boolean grounded) throws Exception;

    default boolean isAvailable() { return true; }
}
