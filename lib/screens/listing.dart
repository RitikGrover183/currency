import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Listing extends StatefulWidget {
  const Listing({super.key});

  @override
  State<Listing> createState() => _ListingState();
}

class _ListingState extends State<Listing> {
  List<dynamic> currencyData = [];
  Timer? timer;
  bool isPlaying = false;
  int countdown = 5;

  @override
  void initState() {
    super.initState();
    fetchCurrencyData();
  }

  void resetTimer() {
    setState(() {
      countdown = 5;
    });
  }

  void startUpdatingPrice() {
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        currencyData = currencyData.map((currency) {
          final random = Random();
          final priceChange =
              random.nextDouble() * (random.nextBool() ? 1 : -1);

          return {
            'currency': currency['currency'] ?? 'Unknown',
            'price': (currency['price'] != null)
                ? (currency['price'] + priceChange).toStringAsFixed(2)
                : '0.00'
          };
        }).toList();
      });
    });
    setState(() {
      isPlaying = true;
    });
  }

  void stopUpdatingPrice() {
    timer?.cancel();
    setState(() {
      isPlaying = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchCurrencyData() async {
    final url = 'https://mocki.io/v1/f27e42bf-c598-4950-b557-8befc8c478f3';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          currencyData = data['data'] ?? [];
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Currency List")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text("Next update in: $countdown seconds"),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: startUpdatingPrice,
                  child: const Text("Play"),
                ),
                SizedBox(width: 10,),
                ElevatedButton(
                  onPressed: stopUpdatingPrice,
                  child: const Text("Pause"),
                ),
              ],
            ),
          ),
          Expanded(
            child: currencyData.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.green,
                    ),
                  )
                : ListView.builder(
                    itemCount: currencyData.length,
                    itemBuilder: (context, index) {
                      final currency = currencyData[index];
                      final currencyName =
                          currency['currency']?.toString() ?? 'Unknown';
                      final currencyPrice =
                          currency['price']?.toString() ?? '0.00';

                      return ListTile(
                        title: Text(currencyName),
                        subtitle: Text(currencyPrice),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
