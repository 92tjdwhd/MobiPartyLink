class SupabaseConstants {
  static const String supabaseUrl = 'https://qpauuwmflnvdnnfctjyx.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwYXV1d21mbG52ZG5uZmN0anl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg1OTgwMjksImV4cCI6MjA3NDE3NDAyOX0.hQN2ZhKiWwZ133WyCPhClVJUvN7VozhmNnh3t3PENs4';

  // 테이블 이름
  static const String partiesTable = 'parties';
  static const String partyMembersTable = 'party_members';
  static const String userProfilesTable = 'user_profiles';

  // 컬럼 이름
  static const String idColumn = 'id';
  static const String createdAtColumn = 'created_at';
  static const String updatedAtColumn = 'updated_at';
}
