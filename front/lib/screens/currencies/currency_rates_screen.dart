import 'package:flutter/material.dart';
import 'package:exchanger/components/background/animated_background.dart';
import 'package:exchanger/components/buttons/custom_button.dart';
import 'package:exchanger/components/dropdowns/custom_dropdown.dart';
import 'package:exchanger/styles/app_theme.dart';

class CurrencyRatesScreen extends StatefulWidget {
   final Map<String, dynamic> rates;

   const CurrencyRatesScreen({super.key, required this.rates});

   @override
   State<CurrencyRatesScreen> createState() => _CurrencyRatesScreenState();
}

class _CurrencyRatesScreenState extends State<CurrencyRatesScreen> {
   late Map<String, double> editableRates;
   String _searchQuery = '';
   bool _sortAscending = true;

   @override
   void initState() {
      super.initState();
      editableRates = widget.rates.map((k, v) {
         return MapEntry(k, v is String ? double.tryParse(v) ?? 0 : v.toDouble());
      });
   }

   void _editRate(String currency) async {
      String newRate = editableRates[currency]!.toString();

      await showDialog(
         context: context,
         builder: (context) {
            return AlertDialog(
               title: Text('Изменить курс для ${currency.toUpperCase()}'),
               content: TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                     labelText: 'Новый курс',
                     border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: newRate),
                  onChanged: (value) => newRate = value,
               ),
               actions: [
                  TextButton(
                     onPressed: () => Navigator.pop(context),
                     child: Text('Отмена'),
                  ),
                  ElevatedButton(
                     onPressed: () {
                        setState(() {
                           editableRates[currency] = double.tryParse(newRate) ?? editableRates[currency]!;
                        });
                        Navigator.pop(context);
                     },
                     child: Text('Сохранить'),
                  ),
               ],
            );
         },
      );
   }

   void _addCurrencyDialog() async {
      String newCurrency = '';
      String newRate = '';

      await showDialog(
         context: context,
         builder: (context) {
            return AlertDialog(
               title: Text('Добавить валюту'),
               content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     TextField(
                        decoration: InputDecoration(labelText: 'Название (например: usd)'),
                        onChanged: (value) => newCurrency = value.toLowerCase(),
                     ),
                     SizedBox(height: 16),
                     TextField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: 'Курс'),
                        onChanged: (value) => newRate = value,
                     ),
                  ],
               ),
               actions: [
                  TextButton(
                     onPressed: () => Navigator.pop(context),
                     child: Text('Отмена'),
                  ),
                  ElevatedButton(
                     onPressed: () {
                        setState(() {
                           editableRates[newCurrency] = double.tryParse(newRate) ?? 0;
                        });
                        Navigator.pop(context);
                     },
                     child: Text('Добавить'),
                  ),
               ],
            );
         },
      );
   }

   void _clearRates() {
      showDialog(
         context: context,
         builder: (context) => AlertDialog(
            title: Text('Сбросить все курсы?'),
            content: Text('Вы уверены, что хотите удалить все валюты и их курсы?'),
            actions: [
               TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена'),
               ),
               ElevatedButton(
                  onPressed: () {
                     setState(() {
                        editableRates.clear();
                     });
                     Navigator.pop(context);
                  },
                  child: Text('Сбросить'),
               ),
            ],
         ),
      );
   }

   void _saveAndExit() {
      Navigator.pop(context, editableRates);
   }

   @override
   Widget build(BuildContext context) {
      final isTablet = MediaQuery.of(context).size.width > 600;
      final double padding = isTablet ? 24 : 12;

      final filteredRates = editableRates.entries
         .where((entry) => entry.key.toLowerCase().contains(_searchQuery.toLowerCase()))
         .toList()
         ..sort((a, b) => _sortAscending ? a.value.compareTo(b.value) : b.value.compareTo(a.value));

      return Scaffold(
         appBar: AppBar(
            centerTitle: true,
            title: Text('Редактор курсов валют'),
            actions: [
               IconButton(
                  icon: Icon(Icons.delete_forever),
                  onPressed: _clearRates,
               ),
               IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addCurrencyDialog,
               ),
               IconButton(
                  icon: Icon(Icons.check),
                  onPressed: _saveAndExit,
               ),
            ],
         ),
         body: AnimatedBackground(
            child: Padding(
               padding: EdgeInsets.all(padding),
               child: Column(
                  children: [
                     TextField(
                        decoration: InputDecoration(
                           hintText: 'Поиск валюты',
                           prefixIcon: Icon(Icons.search),
                           border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                           ),
                        ),
                        onChanged: (value) {
                           setState(() {
                              _searchQuery = value;
                           });
                        },
                     ),
                     SizedBox(height: 16),
                     Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Text('Валюта', style: TextStyle(fontWeight: FontWeight.bold)),
                           TextButton.icon(
                              onPressed: () {
                                 setState(() {
                                    _sortAscending = !_sortAscending;
                                 });
                              },
                              icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                              label: Text('Курс'),
                           ),
                        ],
                     ),
                     SizedBox(height: 8),
                     Expanded(
                        child: filteredRates.isEmpty
                           ? Center(child: Text('Нет валют.'))
                           : ListView.builder(
                              itemCount: filteredRates.length,
                              itemBuilder: (context, index) {
                                 final entry = filteredRates[index];
                                 return Card(
                                    color: Theme.of(context).cardColor,
                                    shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(vertical: 6),
                                    child: InkWell(
                                       borderRadius: BorderRadius.circular(12),
                                       onTap: () => _editRate(entry.key),
                                       child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                          child: Row(
                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                             children: [
                                                Column(
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: [
                                                      Text(
                                                         entry.key.toUpperCase(),
                                                         style: TextStyle(
                                                            fontSize: isTablet ? 20 : 16,
                                                            fontWeight: FontWeight.w600,
                                                         ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                         'Обновлено вручную',
                                                         style: TextStyle(fontSize: 12, color: Colors.grey),
                                                      ),
                                                   ],
                                                ),
                                                Column(
                                                   crossAxisAlignment: CrossAxisAlignment.end,
                                                   children: [
                                                      Text(
                                                         '${entry.value.toStringAsFixed(2)}',
                                                         style: TextStyle(
                                                            fontSize: isTablet ? 20 : 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                         ),
                                                      ),
                                                   ],
                                                ),
                                             ],
                                          ),
                                       ),
                                    ),
                                 );
                              },
                           ),
                     ),
                  ],
               ),
            ),
         ),
      );
   }
}