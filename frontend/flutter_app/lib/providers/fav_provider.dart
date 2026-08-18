// lib/providers/favourites_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dishes_api.dart'; // Adjust import to your DishService file

class FavouritesNotifier extends AsyncNotifier<Set<int>> {
  late final DishService _dishService;

  @override
  Future<Set<int>> build() async {
    _dishService = DishService();
    try {
      // 1. Fetch user's saved dishes from GET /users/me/favourites
      final dishes = await _dishService.fetchFavourites();
      // 2. Extract and return their IDs as a Set<int>
      return dishes.map((dish) => dish.id).toSet();
    } catch (_) {
      // Return empty set if offline or unauthenticated
      return <int>{};
    }
  }

  ///  Toggle
  Future<void> toggle(int dishId) async {
    final currentSet = state.value ?? <int>{};
    final isCurrentlyFav = currentSet.contains(dishId);

    // 1. Instantly update RAM (UI reacts immediately)
    final updatedSet = isCurrentlyFav
        ? (Set<int>.from(currentSet)..remove(dishId))
        : (Set<int>.from(currentSet)..add(dishId));

    state = AsyncValue.data(updatedSet);
    try {
      // 2. Call backend via ApiClient in background
      final isFavOnBackend = await _dishService.toggleFavourite(dishId);

      // 3. Ensure UI aligns with server response
      final confirmedSet = isFavOnBackend
          ? (Set<int>.from(state.value ?? {})..add(dishId))
          : (Set<int>.from(state.value ?? {})..remove(dishId));

      state = AsyncValue.data(confirmedSet);
    } catch (e, stackTrace) {
      // 4. Revert back to original state on network failure
      state = AsyncValue.data(currentSet);
      return Future.error(e, stackTrace);
    }
  }
}

final favouritesProvider = AsyncNotifierProvider<FavouritesNotifier, Set<int>>(() {
  return FavouritesNotifier();
});