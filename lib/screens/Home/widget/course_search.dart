import 'package:flutter/material.dart';
import 'package:ramysmart/util/constants.dart';
import 'search_result.dart'; // We'll create this file next

class CourseSearch extends StatefulWidget {
  final Function(String) onSearch;

  const CourseSearch({
    Key? key,
    required this.onSearch,
  }) : super(key: key);

  @override
  State<CourseSearch> createState() => _CourseSearchState();
}

class _CourseSearchState extends State<CourseSearch> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _showClearButton = _searchController.text.isNotEmpty;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearch('');
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      widget.onSearch(query);
      // Navigate to search results page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(
            searchQuery: query,
            onNavigateBack: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Search courses...',
          prefixIcon: const Icon(Icons.search, color: kPrimaryColor),
          suffixIcon: _showClearButton
              ? IconButton(
            icon: const Icon(Icons.clear, color: kPrimaryColor),
            onPressed: _clearSearch,
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _submitSearch(),
      ),
    );
  }
}