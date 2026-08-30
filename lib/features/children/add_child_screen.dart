import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../domain/models/child.dart';
import '../../domain/models/school.dart';

class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key});

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _searchController = TextEditingController();

  int _selectedGrade = 1;
  School? _selectedSchool;
  List<School> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Child'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                hintText: 'Enter first name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a first name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter last name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedGrade,
              decoration: const InputDecoration(
                labelText: 'Grade',
              ),
              items: List.generate(13, (index) => index).map((grade) {
                return DropdownMenuItem(
                  value: grade,
                  child: Text(grade == 0 ? 'Kindergarten' : 'Grade $grade'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedGrade = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'School',
                hintText: 'Search for a school',
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search),
              ),
              onChanged: (value) => _searchSchools(value),
              validator: (value) {
                if (_selectedSchool == null) {
                  return 'Please select a school';
                }
                return null;
              },
            ),
            if (_selectedSchool != null) ...[
              const SizedBox(height: 8),
              Card(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: ListTile(
                  leading: const Icon(Icons.school),
                  title: Text(_selectedSchool!.name),
                  subtitle: Text(_selectedSchool!.fullAddress),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedSchool = null;
                        _searchController.clear();
                        _searchResults = [];
                      });
                    },
                  ),
                ),
              ),
            ],
            if (_searchResults.isNotEmpty && _selectedSchool == null) ...[
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: _searchResults.map((school) {
                    return ListTile(
                      title: Text(school.name),
                      subtitle: Text(school.fullAddress),
                      onTap: () {
                        setState(() {
                          _selectedSchool = school;
                          _searchController.text = school.name;
                          _searchResults = [];
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveChild,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Add Child'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchSchools(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final schoolRepository = ref.read(schoolRepositoryProvider);
    final results = await schoolRepository.searchSchools(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _saveChild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final childRepository = ref.read(childRepositoryProvider);

    final child = Child(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      grade: _selectedGrade,
      schoolId: _selectedSchool!.id,
    );

    await childRepository.addChild(child);

    if (mounted) {
      context.pop();
    }
  }
}
