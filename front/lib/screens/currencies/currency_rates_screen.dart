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
               backgroundColor: Color(0xFF1E1E1E),
               title: Text(
                  'Изменить курс для ${currency.toUpperCase()}',
                  style: TextStyle(color: Colors.white),
               ),
               content: TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                     labelText: 'Новый курс',
                     labelStyle: TextStyle(color: Colors.grey[400]),
                     border: OutlineInputBorder(),
                     enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[700]!),
                     ),
                     focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightBlueAccent),
                     ),
                  ),
                  style: TextStyle(color: Colors.white),
                  controller: TextEditingController(text: newRate),
                  onChanged: (value) => newRate = value,
               ),
               actions: [
                  TextButton(
                     onPressed: () => Navigator.pop(context),
                     child: Text('Отмена', style: TextStyle(color: Colors.grey[400])),
                  ),
                  CustomButton(
                     onPressed: () {
                        setState(() {
                           editableRates[currency] = double.tryParse(newRate) ?? editableRates[currency]!;
                        });
                        Navigator.pop(context);
                     },
                     text: 'Сохранить',
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
               backgroundColor: Color(0xFF1E1E1E),
               title: Text('Добавить валюту', style: TextStyle(color: Colors.white)),
               content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                           labelText: 'Название (например: usd)',
                           labelStyle: TextStyle(color: Colors.grey[400]),
                           enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[700]!),
                           ),
                           focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.lightBlueAccent),
                           ),
                        ),
                        onChanged: (value) => newCurrency = value.toLowerCase(),
                     ),
                     SizedBox(height: 16),
                     TextField(
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                           labelText: 'Курс',
                           labelStyle: TextStyle(color: Colors.grey[400]),
                           enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[700]!),
                           ),
                           focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.lightBlueAccent),
                           ),
                        ),
                        onChanged: (value) => newRate = value,
                     ),
                  ],
               ),
               actions: [
                  TextButton(
                     onPressed: () => Navigator.pop(context),
                     child: Text('Отмена', style: TextStyle(color: Colors.grey[400])),
                  ),
                  CustomButton(
                     onPressed: () {
                        setState(() {
                           editableRates[newCurrency] = double.tryParse(newRate) ?? 0;
                        });
                        Navigator.pop(context);
                     },
                     text: 'Добавить',
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
            backgroundColor: Color(0xFF1E1E1E),
            title: Text('Сбросить все курсы?', style: TextStyle(color: Colors.white)),
            content: Text('Вы уверены, что хотите удалить все валюты и их курсы?',
               style: TextStyle(color: Colors.grey[300])),
            actions: [
               TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена', style: TextStyle(color: Colors.grey[400])),
               ),
               CustomButton(
                  onPressed: () {
                     setState(() {
                        editableRates.clear();
                     });
                     Navigator.pop(context);
                  },
                  text: 'Сбросить',
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
         backgroundColor: Color(0xFF121212),
         appBar: AppBar(
            backgroundColor: Color(0xFF1E1E1E),
            centerTitle: true,
            title: Text('Редактор курсов валют', style: TextStyle(color: Colors.white)),
            iconTheme: IconThemeData(color: Colors.white),
            actions: [
               IconButton(
                  icon: Icon(Icons.delete_forever, color: Colors.red[300]),
                  onPressed: _clearRates,
               ),
               IconButton(
                  icon: Icon(Icons.add, color: Colors.lightBlueAccent),
                  onPressed: _addCurrencyDialog,
               ),
               IconButton(
                  icon: Icon(Icons.check, color: Colors.greenAccent),
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
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                           hintText: 'Поиск валюты',
                           hintStyle: TextStyle(color: Colors.grey[500]),
                           prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                           border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                           ),
                           enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[700]!),
                           ),
                           focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.lightBlueAccent),
                           ),
                           fillColor: Color(0xFF2A2A2A),
                           filled: true,
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
                           Text('Валюта',
                              style: TextStyle(
                                 fontWeight: FontWeight.bold,
                                 color: Colors.white,
                              )
                           ),
                           TextButton.icon(
                              onPressed: () {
                                 setState(() {
                                    _sortAscending = !_sortAscending;
                                 });
                              },
                              icon: Icon(
                                 _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                 color: Colors.lightBlueAccent,
                              ),
                              label: Text(
                                 'Курс',
                                 style: TextStyle(color: Colors.lightBlueAccent)
                              ),
                           ),
                        ],
                     ),
                     SizedBox(height: 8),
                     Expanded(
                        child: filteredRates.isEmpty
                           ? Center(
                               child: Text(
                                  'Нет валют.',
                                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                               )
                           )
                           : ListView.builder(
                              itemCount: filteredRates.length,
                              itemBuilder: (context, index) {
                                 final entry = filteredRates[index];
                                 return Card(
                                    color: Color(0xFF1E1E1E),
                                    shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(vertical: 6),
                                    child: InkWell(
                                       borderRadius: BorderRadius.circular(12),
                                       onTap: () => _editRate(entry.key),
                                       splashColor: Colors.lightBlueAccent.withOpacity(0.2),
                                       highlightColor: Colors.lightBlueAccent.withOpacity(0.1),
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
                                                            color: Colors.white,
                                                         ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                         'Обновлено вручную',
                                                         style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey[400],
                                                         ),
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
                                                            color: Colors.lightBlueAccent,
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