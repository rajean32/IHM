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
  final String? error;

  EventListState({
    this.events = const [],
    this.isLoading = false,
    this.error,
  });

  EventListState copyWith({
    List<Evenement>? events,
    bool? isLoading,
    String? error,
  }) {
    return EventListState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final eventListProvider = StateNotifierProvider<EventListController, EventListState>((ref) {
  return EventListController(ref.watch(eventRepositoryProvider));
});

class EventListController extends StateNotifier<EventListState> {
  final EventRepository _repository;

  EventListController(this._repository) : super(EventListState()) {
    loadUpcoming();
  }

  Future<void> loadUpcoming() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final events = await _repository.getUpcoming();
      state = state.copyWith(isLoading: false, events: events);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadPopular() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final events = await _repository.getPopular();
      state = state.copyWith(isLoading: false, events: events);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> search({String? q, String? categorie, String? ville, String? statut}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final events = await _repository.search(q: q, categorie: categorie, ville: ville, statut: statut);
      state = state.copyWith(isLoading: false, events: events);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
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
