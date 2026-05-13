import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api_service.dart';
import '../../../core/theme.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  late Future<List<dynamic>> _schedules;

  @override
  void initState() {
    super.initState();
    _schedules = _fetchMySchedules();
  }

  Future<List<dynamic>> _fetchMySchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return [];

    final parts = token.split('.');
    if (parts.length != 3) return [];
    final payload = String.fromCharCodes(base64Url.decode(base64Url.normalize(parts[1])));
    final payloadMap = jsonDecode(payload);

    final userId = payloadMap['id'];
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/schedules/user/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load schedule');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: AppTheme.pageBackground,
        child: SafeArea(
          child: FutureBuilder<List<dynamic>>(
            future: _schedules,
            builder: (context, snapshot) {
              final content = <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: AppTheme.panelDecoration(radius: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'My Work Schedule',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Jadwal kerja tetap mingguan dengan jam masuk dan jam selesai.',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ];

              if (snapshot.connectionState == ConnectionState.waiting) {
                content.add(const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ));
              } else if (snapshot.hasError) {
                content.add(
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.panelDecoration(radius: 22),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: AppTheme.danger),
                      ),
                    ),
                  ),
                );
              } else {
                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  content.add(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: AppTheme.panelDecoration(radius: 22),
                        child: const Text(
                          'Belum ada jadwal tetap.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  );
                } else {
                  content.addAll(
                    data.map((item) => Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: AppTheme.panelDecoration(radius: 20),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppTheme.warning.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.work_history_outlined,
                                    color: AppTheme.warning,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['dayOfWeek']?.toString() ?? '-',
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${item['startTime']} - ${item['endTime']}',
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryPurple.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Aktif',
                                    style: TextStyle(
                                      color: AppTheme.primaryPurple,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  );
                }
              }

              content.add(const SizedBox(height: 24));
              return ListView(children: content);
            },
          ),
        ),
      ),
    );
  }
}
