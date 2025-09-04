// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:medical_healthcare_app/data/dummy_data.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:medical_healthcare_app/utils/app_styles.dart';
import 'package:medical_healthcare_app/widgets/category_card.dart';
import 'package:medical_healthcare_app/widgets/doctor_card.dart';
import 'package:medical_healthcare_app/models/doctor.dart';
import 'package:medical_healthcare_app/screens/my_appointments_screen.dart';
import 'package:medical_healthcare_app/screens/favorite_doctors_screen.dart';
import 'package:medical_healthcare_app/screens/profile_wrapper_screen.dart';
import 'package:medical_healthcare_app/screens/messages_list_screen.dart'; // New: Import MessagesListScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      _HomeContent(onFavoriteChanged: _refreshUi),
      const MyAppointmentsScreen(),
      const FavoriteDoctorsScreen(),
      const MessagesListScreen(), // New: MessagesListScreen for the messages tab
      const ProfileWrapperScreen(),
    ];
  }

  void _refreshUi() {
    setState(() {
      // Rebuilds the current view to reflect any changes in favorite status or other data
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'MediCare',
          style: AppStyles.headline2.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              // Handle notification tap
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {
              // Handle profile tap
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Messages', // Label remains 'Messages'
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.lightTextColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// Callback definition for favorite changes
typedef OnFavoriteChanged = void Function();

// Create a separate widget for the Home screen's main content
class _HomeContent extends StatefulWidget {
  final OnFavoriteChanged onFavoriteChanged;

  const _HomeContent({required this.onFavoriteChanged});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  List<Doctor> _getFilteredDoctors() {
    List<Doctor> doctors = DummyData.doctors;

    if (_selectedCategory != null) {
      doctors = doctors
          .where((doctor) => doctor.specialty == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      doctors = doctors
          .where(
            (doctor) =>
                doctor.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                doctor.specialty.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return doctors;
  }

  @override
  Widget build(BuildContext context) {
    final List<Doctor> filteredDoctors = _getFilteredDoctors();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: AppColors.primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Your Doctor',
                  style: AppStyles.headline1.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for doctors or specialists...',
                    hintStyle: AppStyles.bodyText1.copyWith(
                      color: Colors.white70,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.accentColor.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  style: AppStyles.bodyText1.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Categories Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Categories', style: AppStyles.titleStyle),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: DummyData.categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemBuilder: (context, index) {
                final category = DummyData.categories[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectedCategory == category['name']) {
                        _selectedCategory = null;
                      } else {
                        _selectedCategory = category['name'];
                      }
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                  child: CategoryCard(
                    name: category['name'],
                    icon: category['icon'],
                    color: category['color'],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Top Doctors Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Top Doctors', style: AppStyles.titleStyle),
                if (_selectedCategory != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                    child: Text(
                      'Clear Filter',
                      style: AppStyles.bodyText2.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          filteredDoctors.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      _searchQuery.isNotEmpty && _selectedCategory != null
                          ? 'No doctors found matching "$_searchQuery" in "$_selectedCategory".'
                          : _searchQuery.isNotEmpty
                          ? 'No doctors found matching "$_searchQuery".'
                          : _selectedCategory != null
                          ? 'No doctors found for "$_selectedCategory".'
                          : 'No doctors available.',
                      style: AppStyles.bodyText1.copyWith(
                        color: AppColors.lightTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(
                  children: filteredDoctors.map((doctor) {
                    return DoctorCard(
                      doctor: doctor,
                      onToggleFavorite: widget.onFavoriteChanged,
                    );
                  }).toList(),
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
