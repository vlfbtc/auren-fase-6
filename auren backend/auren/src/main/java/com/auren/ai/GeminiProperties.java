package com.auren.ai;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "gemini")
public class GeminiProperties {
  private String endpoint = "https://generativelanguage.googleapis.com";
  private String model = "gemini-2.5-flash";

  public String getEndpoint() { return endpoint; }
  public void setEndpoint(String endpoint) { this.endpoint = endpoint; }
  public String getModel() { return model; }
  public void setModel(String model) { this.model = model; }
}
