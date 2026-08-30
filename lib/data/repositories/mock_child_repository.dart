import '../../domain/models/child.dart';
import '../../domain/repositories/child_repository.dart';
import '../mock/mock_data.dart';

/// Mock implementation of ChildRepository
class MockChildRepository implements ChildRepository {
  final List<Child> _children = [MockData.getDefaultChild()];

  @override
  Future<List<Child>> getChildren() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_children);
  }

  @override
  Future<Child?> getChildById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _children.firstWhere((child) => child.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addChild(Child child) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _children.add(child);
  }

  @override
  Future<void> updateChild(Child child) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _children.indexWhere((c) => c.id == child.id);
    if (index != -1) {
      _children[index] = child;
    }
  }

  @override
  Future<void> deleteChild(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _children.removeWhere((child) => child.id == id);
  }
}
