import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:seat_sense_flutter/services/web_socket_service.dart';
import 'package:seat_sense_flutter/utils/constants.dart';
import 'package:seat_sense_flutter/utils/secure_storage.dart';

class OccupancyScreen extends StatefulWidget {
  const OccupancyScreen({super.key});

  @override
  State<OccupancyScreen> createState() => _OccupancyScreenState();
}

class _OccupancyScreenState extends State<OccupancyScreen> {
  final WebSocketService _webSocketService = WebSocketService();
  Map<String, dynamic> seatData = {};
  String selectedFilter = 'All';
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _initializeWebSocket(); // Initialize WebSocket connection here
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    // Reset orientation back to normal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _initializeWebSocket() async {
    String? token = await SecureStorage.getAccessToken();
    _webSocketService.connect('${Constants.apiBaseWebSocketUrl}?token=$token');

    _webSocketService.stream?.listen(
      (message) {
        final correctedMessage = message.replaceAll("'", '"');
        try {
          // Decode the message into a map
          final decoded = jsonDecode(correctedMessage);
          setState(() {
            seatData = Map<String, dynamic>.from(decoded);
          });
        } catch (e) {
          logger.e('Error decoding JSON: $e');
          setState(() {
            seatData = {}; // Reset seatData in case of decoding error
          });
        }
      },
      onError: (error) {
        logger.e('WebSocket Error: $error');
        setState(() {
          seatData = {}; // Reset seatData in case of WebSocket error
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (seatData.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auditorium Seating'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedFilter = value;
              });
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'All', child: Text('All Seats')),
                  const PopupMenuItem(
                    value: 'Occupied',
                    child: Text('Occupied Only'),
                  ),
                  const PopupMenuItem(value: 'Free', child: Text('Free Only')),
                ],
          ),
        ],
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: buildSeatingLayout(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildSeatingLayout() {
    List<Widget> seating = [];

    seatData.forEach((rowKey, rowValue) {
      seating.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  rowKey,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ...buildSeatsForRow(rowKey, rowValue),
            ],
          ),
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: seating,
    );
  }

  List<Widget> buildSeatsForRow(String rowKey, Map<String, dynamic> seats) {
    List<Widget> seatWidgets = [];
    seats.forEach((seatNumberString, status) {
      final seatNumber = int.tryParse(
        seatNumberString,
      ); // Convert string to int

      if (seatNumber != null) {
        if (selectedFilter == 'All' ||
            (selectedFilter == 'Occupied' && status == 1) ||
            (selectedFilter == 'Free' && status == 0)) {
          seatWidgets.add(buildSeat(rowKey, seatNumber, status));
        }
      }
    });
    return seatWidgets;
  }

  Widget buildSeat(String row, int seatNumber, int status) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: status == 1 ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: status == 1 ? Colors.redAccent : Colors.greenAccent,
            blurRadius: 2,
            spreadRadius: 2,
          ),
        ],
      ),
      child: GestureDetector(
        child: Center(
          child: Text(
            seatNumber.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
