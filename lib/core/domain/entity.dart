abstract class Entity<T> {
  final T id;

  const Entity(this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Entity<T> && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
