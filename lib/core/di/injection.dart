import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../network/supabase_client.dart';
import '../../features/counter/data/datasources/counter_local_datasource.dart';
import '../../features/counter/data/datasources/counter_remote_datasource.dart';
import '../../features/counter/data/repositories/counter_repository_impl.dart';
import '../../features/counter/domain/repositories/counter_repository.dart';
import '../../features/counter/domain/usecases/get_counter.dart';
import '../../features/counter/domain/usecases/increment_counter.dart';
import '../../features/counter/domain/usecases/decrement_counter.dart';
import '../../features/counter/domain/usecases/reset_counter.dart';
import '../../features/counter/presentation/providers/counter_provider.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/party/data/datasources/party_remote_datasource.dart';
import '../../features/party/data/repositories/party_repository_impl.dart';
import '../../features/party/domain/repositories/party_repository.dart';
import '../../features/party/domain/usecases/get_parties.dart';
import '../../features/party/domain/usecases/get_party_by_id.dart';
import '../../features/party/domain/usecases/create_party.dart';
import '../../features/party/domain/usecases/join_party.dart';
import '../../features/party/domain/usecases/leave_party.dart';
import '../../features/party/domain/usecases/delete_party.dart';
import '../../features/party/domain/usecases/update_party.dart';
import '../../features/party/domain/usecases/search_parties.dart';
import '../../features/party/domain/usecases/get_my_parties.dart';
import '../../features/party/domain/usecases/get_joined_parties.dart';
import '../../features/party/data/datasources/job_remote_datasource.dart';
import '../../features/party/data/repositories/job_repository_impl.dart';
import '../../features/party/domain/repositories/job_repository.dart';
import '../../features/party/domain/usecases/get_job_categories.dart';
import '../../features/party/domain/usecases/get_jobs.dart';
import '../../features/party/domain/usecases/get_jobs_by_category.dart';
import '../../features/party/domain/usecases/get_job_by_id.dart';
import '../../features/party/domain/usecases/get_jobs_grouped_by_category.dart';
import '../../features/party/data/datasources/party_template_server_datasource.dart';
import '../../features/party/data/datasources/party_template_local_datasource.dart';
import '../../features/party/data/repositories/party_template_repository_impl.dart';
import '../../features/party/domain/repositories/party_template_repository.dart';
import '../services/auth_service.dart';

part 'injection.g.dart';

// Core
@riverpod
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
}

// Network
@riverpod
DioClient dioClient(DioClientRef ref) => DioClient();

@riverpod
NetworkInfo networkInfo(NetworkInfoRef ref) => NetworkInfoImpl();

@riverpod
SupabaseClient supabaseClient(SupabaseClientRef ref) =>
    AppSupabaseClient.instance.client;

// Auth Service
@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService(
    supabaseClient: ref.watch(supabaseClientProvider),
    prefs: ref.watch(sharedPreferencesProvider),
  );
}

// Data Sources
@riverpod
CounterLocalDataSource counterLocalDataSource(CounterLocalDataSourceRef ref) =>
    CounterLocalDataSourceImpl(
        sharedPreferences: ref.watch(sharedPreferencesProvider));

@riverpod
CounterRemoteDataSource counterRemoteDataSource(
        CounterRemoteDataSourceRef ref) =>
    CounterRemoteDataSourceImpl(dio: ref.watch(dioClientProvider).dio);

@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) =>
    AuthRemoteDataSourceImpl(supabaseClient: ref.watch(supabaseClientProvider));

// Repository
@riverpod
CounterRepository counterRepository(CounterRepositoryRef ref) =>
    CounterRepositoryImpl(
      localDataSource: ref.watch(counterLocalDataSourceProvider),
      remoteDataSource: ref.watch(counterRemoteDataSourceProvider),
      networkInfo: ref.watch(networkInfoProvider),
    );

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) => AuthRepositoryImpl(
      remoteDataSource: ref.watch(authRemoteDataSourceProvider),
      networkInfo: ref.watch(networkInfoProvider),
    );

@riverpod
PartyRemoteDataSource partyRemoteDataSource(PartyRemoteDataSourceRef ref) =>
    PartyRemoteDataSourceImpl(
        supabaseClient: ref.watch(supabaseClientProvider));

@riverpod
PartyRepository partyRepository(PartyRepositoryRef ref) => PartyRepositoryImpl(
      remoteDataSource: ref.watch(partyRemoteDataSourceProvider),
      networkInfo: ref.watch(networkInfoProvider),
      authService: ref.watch(authServiceProvider),
    );

// Use Cases
@riverpod
GetCounter getCounter(GetCounterRef ref) =>
    GetCounter(ref.watch(counterRepositoryProvider));

@riverpod
IncrementCounter incrementCounter(IncrementCounterRef ref) =>
    IncrementCounter(ref.watch(counterRepositoryProvider));

@riverpod
DecrementCounter decrementCounter(DecrementCounterRef ref) =>
    DecrementCounter(ref.watch(counterRepositoryProvider));

@riverpod
ResetCounter resetCounter(ResetCounterRef ref) =>
    ResetCounter(ref.watch(counterRepositoryProvider));

// Party Use Cases
@riverpod
GetParties getParties(GetPartiesRef ref) =>
    GetParties(ref.watch(partyRepositoryProvider));

@riverpod
GetPartyById getPartyById(GetPartyByIdRef ref) =>
    GetPartyById(ref.watch(partyRepositoryProvider));

@riverpod
CreateParty createParty(CreatePartyRef ref) =>
    CreateParty(ref.watch(partyRepositoryProvider));

@riverpod
JoinParty joinParty(JoinPartyRef ref) =>
    JoinParty(ref.watch(partyRepositoryProvider));

@riverpod
LeaveParty leaveParty(LeavePartyRef ref) =>
    LeaveParty(ref.watch(partyRepositoryProvider));

@riverpod
DeleteParty deleteParty(DeletePartyRef ref) =>
    DeleteParty(ref.watch(partyRepositoryProvider));

@riverpod
UpdateParty updateParty(UpdatePartyRef ref) =>
    UpdateParty(ref.watch(partyRepositoryProvider));

@riverpod
SearchParties searchParties(SearchPartiesRef ref) =>
    SearchParties(ref.watch(partyRepositoryProvider));

// Presentation Layer
@riverpod
class CounterNotifier extends _$CounterNotifier {
  @override
  CounterState build() {
    return CounterState();
  }

  Future<void> _loadCounter() async {
    state = state.copyWith(isLoading: true, isError: false);

    final getCounter = ref.read(getCounterProvider);
    final result = await getCounter();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: failure.message,
      ),
      (counter) => state = state.copyWith(
        isLoading: false,
        isError: false,
        counter: counter,
      ),
    );
  }

  Future<void> increment() async {
    state = state.copyWith(isLoading: true, isError: false);

    final incrementCounter = ref.read(incrementCounterProvider);
    final result = await incrementCounter();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: failure.message,
      ),
      (counter) => state = state.copyWith(
        isLoading: false,
        isError: false,
        counter: counter,
      ),
    );
  }

  Future<void> decrement() async {
    state = state.copyWith(isLoading: true, isError: false);

    final decrementCounter = ref.read(decrementCounterProvider);
    final result = await decrementCounter();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: failure.message,
      ),
      (counter) => state = state.copyWith(
        isLoading: false,
        isError: false,
        counter: counter,
      ),
    );
  }

  Future<void> reset() async {
    state = state.copyWith(isLoading: true, isError: false);

    final resetCounter = ref.read(resetCounterProvider);
    final result = await resetCounter();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: failure.message,
      ),
      (counter) => state = state.copyWith(
        isLoading: false,
        isError: false,
        counter: counter,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(isError: false, errorMessage: null);
  }
}

// Job Data Sources
@riverpod
JobRemoteDataSource jobRemoteDataSource(JobRemoteDataSourceRef ref) {
  return JobRemoteDataSourceImpl(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
}

// Job Repositories
@riverpod
JobRepository jobRepository(JobRepositoryRef ref) {
  return JobRepositoryImpl(
    remoteDataSource: ref.watch(jobRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
}

// Party Template Data Sources
@riverpod
PartyTemplateServerDataSource partyTemplateServerDataSource(
    PartyTemplateServerDataSourceRef ref) {
  return PartyTemplateServerDataSourceImpl(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
}

@riverpod
PartyTemplateLocalDataSource partyTemplateLocalDataSource(
    PartyTemplateLocalDataSourceRef ref) {
  return PartyTemplateLocalDataSourceImpl(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
}

// Party Template Repository
@riverpod
PartyTemplateRepository partyTemplateRepository(
    PartyTemplateRepositoryRef ref) {
  return PartyTemplateRepositoryImpl(
    serverDataSource: ref.watch(partyTemplateServerDataSourceProvider),
    localDataSource: ref.watch(partyTemplateLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
}

// Job Use Cases
@riverpod
GetJobCategories getJobCategoriesProvider(GetJobCategoriesProviderRef ref) {
  return GetJobCategories(jobRepository: ref.watch(jobRepositoryProvider));
}

@riverpod
GetJobs getJobsProvider(GetJobsProviderRef ref) {
  return GetJobs(jobRepository: ref.watch(jobRepositoryProvider));
}

@riverpod
GetJobsByCategory getJobsByCategoryProvider(GetJobsByCategoryProviderRef ref) {
  return GetJobsByCategory(jobRepository: ref.watch(jobRepositoryProvider));
}

@riverpod
GetJobById getJobByIdProvider(GetJobByIdProviderRef ref) {
  return GetJobById(jobRepository: ref.watch(jobRepositoryProvider));
}

@riverpod
GetJobsGroupedByCategory getJobsGroupedByCategoryProvider(
    GetJobsGroupedByCategoryProviderRef ref) {
  return GetJobsGroupedByCategory(
      jobRepository: ref.watch(jobRepositoryProvider));
}

// Party List Use Cases
@riverpod
GetMyParties getMyPartiesProvider(GetMyPartiesProviderRef ref) {
  return GetMyParties(ref.watch(partyRepositoryProvider));
}

@riverpod
GetJoinedParties getJoinedPartiesProvider(GetJoinedPartiesProviderRef ref) {
  return GetJoinedParties(ref.watch(partyRepositoryProvider));
}
