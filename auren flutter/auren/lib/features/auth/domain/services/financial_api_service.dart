import 'dart:convert';
import 'package:http/http.dart' as http;

class FinancialApiService {
  final String _baseUrl = 'https://api.hgbrasil.com/finance';
  final String _apiKey = 'sua-chave-api';  // Substitua pela sua chave
  
  // Buscar cotações de moedas
  Future<Map<String, dynamic>> getCurrencyRates() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/quotations?key=$_apiKey'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao carregar dados de cotações');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }
  
  // Buscar dados de inflação (API simulada)
  Future<Map<String, dynamic>> getInflationData() async {
    try {
      // Simule uma chamada de API ou use uma API real
      // Aqui estamos simulando para exemplo
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        'success': true,
        'inflation': {
          'atual': 4.25,
          'acumulado_ano': 3.85,
          'previsao_proximos_meses': [4.1, 3.9, 3.7],
          'historico': [
            {'mes': 'Janeiro', 'valor': 0.42},
            {'mes': 'Fevereiro', 'valor': 0.37},
            {'mes': 'Março', 'valor': 0.29},
          ]
        }
      };
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  // Buscar dicas financeiras de uma API (simulada)
  Future<List<Map<String, dynamic>>> getFinancialTips() async {
    try {
      // Simule uma chamada de API ou use uma API real
      await Future.delayed(const Duration(seconds: 1));
      
      return [
        {
          'id': 1,
          'title': 'Crie um orçamento mensal',
          'content': 'Estabeleça metas de gastos para cada categoria e acompanhe-os regularmente.',
          'category': 'Planejamento'
        },
        {
          'id': 2,
          'title': 'Fundo de emergência',
          'content': 'Mantenha uma reserva equivalente a pelo menos 6 meses de despesas.',
          'category': 'Poupança'
        },
        {
          'id': 3,
          'title': 'Diversifique investimentos',
          'content': 'Não coloque todos os ovos na mesma cesta. Diversifique entre diferentes classes de ativos.',
          'category': 'Investimentos'
        },
      ];
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }
}