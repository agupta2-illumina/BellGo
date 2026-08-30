import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models/child.dart';
import '../../domain/models/school.dart';

class ChildrenData {
  const ChildrenData({
    required this.children,
    required this.schools,
  });

  final List<Child> children;
  final Map<String, School> schools;
}

class ChildrenNotifier extends AsyncNotifier<ChildrenData> {
  @override
  Future<ChildrenData> build() async {
    final childRepository = ref.read(childRepositoryProvider);
    final schoolRepository = ref.read(schoolRepositoryProvider);

    final children = await childRepository.getChildren();
    final schoolMap = <String, School>{};

    for (final child in children) {
      final school = await schoolRepository.getSchoolById(child.schoolId);
      if (school != null) {
        schoolMap[school.id] = school;
      }
    }

    return ChildrenData(
      children: children,
      schools: schoolMap,
    );
  }

  Future<void> deleteChild(String childId) async {
    final childRepository = ref.read(childRepositoryProvider);
    await childRepository.deleteChild(childId);
    ref.invalidateSelf();
  }
}

final childrenProvider =
    AsyncNotifierProvider<ChildrenNotifier, ChildrenData>(() {
  return ChildrenNotifier();
});
