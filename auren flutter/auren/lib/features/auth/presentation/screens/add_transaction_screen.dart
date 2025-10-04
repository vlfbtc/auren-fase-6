import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auren/features/auth/domain/models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final Function(Transaction) onTransactionAdded;

  const AddTransactionScreen({
    super.key,
    required this.onTransactionAdded,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Tipo e Categoria
  String _type = 'Despesa'; // padrão
  String? _selectedCategory = 'Alimentação';

  final List<String> _categories = const [
    'Alimentação',
    'Transporte',
    'Lazer',
    'Moradia',
    'Outros',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Auren', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  'Auren',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Valor
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  border: UnderlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor informe um valor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descrição
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: UnderlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor informe uma descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tipo (Despesa / Renda)
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: UnderlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Despesa', child: Text('Despesa')),
                  DropdownMenuItem(value: 'Renda', child: Text('Renda')),
                ],
                onChanged: (value) => setState(() => _type = value ?? 'Despesa'),
              ),
              const SizedBox(height: 16),

              // Categoria (apenas quando for Despesa)
              if (_type == 'Despesa')
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: UnderlineInputBorder(),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value),
                  validator: (value) {
                    if (_type == 'Despesa' && (value == null || value.isEmpty)) {
                      return 'Por favor selecione uma categoria';
                    }
                    return null;
                  },
                ),

              const Spacer(),

              // Botão Adicionar (mesmo estilo)
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'ADICIONAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final txType =
    _type == 'Despesa' ? TransactionType.expense : TransactionType.income;

    final tx = Transaction(
      id: null,
      amount: amount, // sempre positivo
      description: _descriptionController.text,
      category: txType == TransactionType.expense
          ? (_selectedCategory ?? 'Outros')
          : 'Renda', // renda não tem categoria no app
      date: DateTime.now(),
      type: txType,
    );

    widget.onTransactionAdded(tx);


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transação adicionada com sucesso')),
    );

    _amountController.clear();
    _amountController.clear();
    _descriptionController.clear();
    setState(() {
      _type = 'Despesa';
      _selectedCategory = 'Alimentação';
    });

    Navigator.pop(context, true);
  }
}
