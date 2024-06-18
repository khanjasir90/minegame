import 'dart:developer';

import 'package:supabase/supabase.dart';

class SupabaseHandler {

  SupabaseHandler._();

  static final SupabaseHandler _instance = SupabaseHandler._();

  static SupabaseHandler get instance => _instance;

  final String _supabaseUrl = 'https://xtfhagzjynxtoggynfha.supabase.co';
  final String _supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0ZmhhZ3pqeW54dG9nZ3luZmhhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTg2ODY5MjgsImV4cCI6MjAzNDI2MjkyOH0.tr-dv0dc_OYpuujrNE0aqY-w-Up_rwJrjqvoq_aW2Rw';

  SupabaseClient get _client => SupabaseClient(
    _supabaseUrl,
    _supabaseKey,
  );

  SupabaseClient get supbaseClient => _client;

  String get _winnerListDb => 'winner_list';

  String get _gameSessionDb => 'game_sessions';

  Future<void> addNumber({required number}) async {
   try {
     await supbaseClient.from(_winnerListDb).insert({'mobile_number': number});
   }catch(e) {
    log(e.toString());
   }
  }

  Future<void> addGameSessionsData({required String sessionData}) async {
    try {
      await supbaseClient.from(_gameSessionDb).insert({'sessions': sessionData});
    } catch(e)   {
      log(e.toString());
    }
  }

  Future<int> getWinnersCount() async {
    try {
      final response = await supbaseClient.from(_winnerListDb).select() as List<dynamic>;
      return response.length;
    } catch(e) {
      log(e.toString());
    }
    return 100;
  }


}