package com.auren.ai;

public class GeminiClientNoop implements GeminiClient {
    @Override
    public String generateJson(String prompt, boolean grounded) {
        // Fallback estático mas decente (artigos/vídeos reais e em PT-BR)
        return """
        {
          "tips":[
            {
              "title":"Revise a categoria 'Moradia'",
              "description":"Moradia concentra grande parte dos seus gastos. Considere renegociar aluguel, revisar tarifas e estabelecer um teto mensal.",
              "category":"Moradia",
              "priority":"high",
              "contentType":"recommendation"
            },
            {
              "title":"Regra 50/30/20",
              "description":"Tente alocar 50%% necessidades, 30%% desejos e 20%% poupança/investimentos.",
              "category":"Planejamento",
              "priority":"medium",
              "contentType":"tip"
            }
          ],
          "content":[
            {
              "id":"bc-orcamento",
              "title":"Como montar um orçamento pessoal",
              "description":"Guia do Banco Central sobre como planejar seu orçamento e controlar despesas.",
              "type":"article",
              "category":"Orçamento",
              "url":"https://www.bcb.gov.br/estabilidadefinanceira/educacaofinanceira",
              "author":"Banco Central do Brasil",
              "readTimeMinutes":8,
              "tags":["orçamento","finanças pessoais"]
            },
            {
              "id":"yt-invest-basico",
              "title":"Investimentos para iniciantes",
              "description":"Conceitos básicos de renda fixa, fundos e diversificação.",
              "type":"video",
              "category":"Investimentos",
              "url":"https://www.youtube.com/watch?v=f9K8BvQp5wQ",
              "author":"Canal de Educação Financeira",
              "readTimeMinutes":12,
              "tags":["investimentos","iniciantes"]
            },
            {
              "id":"pod-financas",
              "title":"Podcast: planejamento financeiro sem complicação",
              "description":"Episódio sobre metas, poupança e controle de gastos.",
              "type":"podcast",
              "category":"Planejamento",
              "url":"https://open.spotify.com/search/educa%C3%A7%C3%A3o%20financeira",
              "author":"Podcast Educação Financeira",
              "readTimeMinutes":20,
              "tags":["podcast","planejamento"]
            }
          ]
        }
        """;
    }
}