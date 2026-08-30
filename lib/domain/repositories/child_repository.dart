import '../models/child.dart';

/// Repository for managing children
abstract class ChildRepository {
  /// Get all children
  Future<List<Child>> getChildren();

  /// Get a child by ID
  Future<Child?> getChildById(String id);

  /// Add a new child
  Future<void> addChild(Child child);

  /// Update an existing child
  Future<void> updateChild(Child child);

  /// Delete a child
  Future<void> deleteChild(String id);
}
