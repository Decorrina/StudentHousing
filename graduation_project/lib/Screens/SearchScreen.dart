import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? selectedUniversity;
  String? selectedGender;
  double? minPrice = 1000;
  double? maxPrice = 5000;

  final List<String> universityList = [
    '6October University',
    'American University in Cairo',
    'British University in Egypt',
    'German University in Cairo',
    'MSA',
    'MUST',
    'MIST International University',
    'New Cairo Academy',
    'The Canadian International College Fifth Settlement',
  ];

  final Color primaryColor = const Color(0xFF519FEE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Search Apartments'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedUniversity = null;
                selectedGender = null;
                minPrice = 1000;
                maxPrice = 5000;
              });
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Let's Find a room that's perfect for you",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // University Dropdown
            _buildSectionHeader('University'),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              hint: const Text('Select university'),
              value: selectedUniversity,
              isExpanded: true,
              items: universityList.map((String university) {
                return DropdownMenuItem<String>(
                  value: university,
                  child: Text(university),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedUniversity = newValue;
                });
              },
            ),
            const SizedBox(height: 20),

            // Gender Filter
            _buildSectionHeader('Gender'),
            Row(
              children: [
                _buildGenderChip('Any'),
                const SizedBox(width: 10),
                _buildGenderChip('Male'),
                const SizedBox(width: 10),
                _buildGenderChip('Female'),
              ],
            ),
            const SizedBox(height: 20),

            // Price Range
            _buildSectionHeader('Price Range (EGP)'),
            RangeSlider(
              values: RangeValues(minPrice ?? 1000, maxPrice ?? 5000),
              min: 500,
              max: 10000,
              divisions: 100,
              labels: RangeLabels(
                '${minPrice?.toInt() ?? 1000}',
                '${maxPrice?.toInt() ?? 5000}',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  minPrice = values.start;
                  maxPrice = values.end;
                });
              },
              activeColor: primaryColor,
              inactiveColor: primaryColor.withOpacity(0.3),
            ),

            const SizedBox(height: 30),

            // Search Button
            ElevatedButton(
              onPressed: () {
                final filters = <String, dynamic>{};

                if (selectedUniversity != null && selectedUniversity!.trim().isNotEmpty) {
                  filters['university'] = selectedUniversity!.trim();
                }
                if (selectedGender != null && selectedGender != 'Any') {
                  filters['gender'] = selectedGender;
                }
                if (minPrice != null) {
                  filters['minPrice'] = minPrice?.toInt();
                }
                if (maxPrice != null) {
                  filters['maxPrice'] = maxPrice?.toInt();
                }

                print('🎯 Final Filters Sent to API: \$filters');

                Navigator.pop(context, filters);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Search',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGenderChip(String gender) {
    final isSelected = selectedGender == gender || (selectedGender == null && gender == 'Any');
    return ChoiceChip(
      label: Text(gender),
      selected: isSelected,
      selectedColor: primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
      onSelected: (selected) {
        setState(() {
          selectedGender = selected ? gender : null;
        });
      },
    );
  }
}
