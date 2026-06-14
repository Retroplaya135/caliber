// Fixed FIFO-style sequence for onboarding screens, following the DSAinDart
// queue shape while keeping the production surface immutable.
final class OnboardingStepQueue<T> {
  OnboardingStepQueue(Iterable<T> items) : _items = List<T>.unmodifiable(items);

  final List<T> _items;

  int get length => _items.length;

  T at(int index) => _items[index];

  Iterable<T> get items => _items;
}
