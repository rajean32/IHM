import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/event_repository.dart';
import '../models/evenement.dart';
import '../models/venue.dart';
import 'auth_controller.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.watch(apiClientProvider));
});

class EventListState {
  final List<Evenement> events;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  EventListState({
    this.events = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  EventListState copyWith({
    List<Evenement>? events,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return EventListState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

final eventListProvider = StateNotifierProvider<EventListController, EventListState>((ref) {
  return EventListController(ref.watch(eventRepositoryProvider));
});

class EventListController extends StateNotifier<EventListState> {
  final EventRepository _repository;
  List<Evenement> _allEvents = [];
  static const int _pageSize = 20;
  int _currentPage = 0;

  EventListController(this._repository) : super(EventListState()) {
    loadUpcoming();
  }

  Future<void> loadUpcoming() async {
    state = state.copyWith(isLoading: true, error: null, isLoadingMore: false);
    try {
      _allEvents = await _repository.getUpcoming();
      _currentPage = 0;
      state = state.copyWith(
        isLoading: false,
        events: _paginate(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadPopular() async {
    state = state.copyWith(isLoading: true, error: null, isLoadingMore: false);
    try {
      _allEvents = await _repository.getPopular();
      _currentPage = 0;
      state = state.copyWith(
        isLoading: false,
        events: _paginate(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> search({
    String? q,
    String? categorie,
    String? ville,
    int? idLieu,
    String? dateFrom,
    String? dateTo,
    String? statut,
    double? prixMin,
    double? prixMax,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isLoadingMore: false);
    try {
      _allEvents = await _repository.search(
        q: q,
        categorie: categorie,
        ville: ville,
        idLieu: idLieu,
        dateFrom: dateFrom,
        dateTo: dateTo,
        statut: statut,
        prixMin: prixMin,
        prixMax: prixMax,
      );
      _currentPage = 0;
      state = state.copyWith(isLoading: false, events: _paginate());
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void loadMore() {
    if (state.isLoadingMore) return;
    final totalPages = (_allEvents.length / _pageSize).ceil();
    if (_currentPage >= totalPages) return;
    state = state.copyWith(isLoadingMore: true);
    _currentPage++;
    state = state.copyWith(
      isLoadingMore: false,
      events: _paginate(),
    );
  }

  List<Evenement> _paginate() {
    final end = (_currentPage + 1) * _pageSize;
    return _allEvents.sublist(0, end > _allEvents.length ? _allEvents.length : end);
  }

  bool get hasMore => (_currentPage + 1) * _pageSize < _allEvents.length;
}

final eventDetailProvider = StateNotifierProvider.family<EventDetailController, EventDetailState, int>((ref, id) {
  return EventDetailController(ref.watch(eventRepositoryProvider), id);
});

class EventDetailState {
  final EventDetail? event;
  final List<SeatingPlace> availableSeats;
  final bool isLoading;
  final String? error;

  EventDetailState({
    this.event,
    this.availableSeats = const [],
    this.isLoading = false,
    this.error,
  });

  EventDetailState copyWith({
    EventDetail? event,
    List<SeatingPlace>? availableSeats,
    bool? isLoading,
    String? error,
  }) {
    return EventDetailState(
      event: event ?? this.event,
      availableSeats: availableSeats ?? this.availableSeats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EventDetailController extends StateNotifier<EventDetailState> {
  final EventRepository _repository;
  final int eventId;

  EventDetailController(this._repository, this.eventId) : super(EventDetailState()) {
    loadDetail();
  }

  Future<void> loadDetail() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final event = await _repository.getDetail(eventId);
      final seats = await _repository.getAvailableSeats(eventId);
      state = state.copyWith(isLoading: false, event: event, availableSeats: seats);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
