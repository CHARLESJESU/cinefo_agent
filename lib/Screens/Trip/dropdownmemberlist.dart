import 'package:flutter/material.dart';

class DriverSearchService {
  final List<String> driverList;
  List<String> filteredDriverList;

  DriverSearchService({required this.driverList})
      : filteredDriverList = List.from(driverList);

  /// Filters the internal list of drivers based on the provided query.
  /// The results are prioritized by matches starting with the query.
  void filterDrivers(String query) {
    if (query.isEmpty) {
      filteredDriverList = List.from(driverList);
    } else {
      String lowerQuery = query.toLowerCase();
      filteredDriverList = driverList.where((driver) {
        String lowerDriver = driver.toLowerCase();

        // Split driver info to search in different parts (e.g., Name-Code-Mobile)
        List<String> driverParts = driver.split('-');
        String driverName =
        driverParts.isNotEmpty ? driverParts[0].toLowerCase() : '';
        String driverCode =
        driverParts.length > 1 ? driverParts[1].toLowerCase() : '';
        String driverMobile =
        driverParts.length > 2 ? driverParts[2].toLowerCase() : '';

        // Check if query matches start of name, code, mobile, or anywhere in the string
        return driverName.startsWith(lowerQuery) ||
            driverCode.startsWith(lowerQuery) ||
            driverMobile.startsWith(lowerQuery) ||
            lowerDriver.contains(lowerQuery);
      }).toList();

      // Sort results: prioritize those that start with the query
      filteredDriverList.sort((a, b) {
        // Assuming the name is the first part before '-'
        String aName = a.split('-')[0].toLowerCase();
        String bName = b.split('-')[0].toLowerCase();

        bool aStartsWithQuery = aName.startsWith(lowerQuery);
        bool bStartsWithQuery = bName.startsWith(lowerQuery);

        if (aStartsWithQuery && !bStartsWithQuery) return -1;
        if (!aStartsWithQuery && bStartsWithQuery) return 1;

        // Fallback to alphabetical sorting
        return aName.compareTo(bName);
      });
    }
  }

  /// Builds a RichText widget for a single driver string, highlighting parts
  /// that match the search query.
  Widget buildDriverItem(String driver, String searchQuery) {
    if (searchQuery.isEmpty) {
      return Text(
        driver,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12),
      );
    }

    // Split driver info to highlight different parts
    List<String> driverParts = driver.split('-');
    String driverName = driverParts.isNotEmpty ? driverParts[0] : '';
    String driverCode = driverParts.length > 1 ? driverParts[1] : '';
    String driverMobile = driverParts.length > 2 ? driverParts[2] : '';

    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: Colors.black),
        children: [
          _buildHighlightedTextSpan(driverName, searchQuery),
          if (driverCode.isNotEmpty) ...[
            TextSpan(text: '-', style: TextStyle(color: Colors.grey[600])),
            _buildHighlightedTextSpan(driverCode, searchQuery),
          ],
          if (driverMobile.isNotEmpty) ...[
            TextSpan(text: '-', style: TextStyle(color: Colors.grey[600])),
            _buildHighlightedTextSpan(driverMobile, searchQuery),
          ],
        ],
      ),
    );
  }

  /// Helper method to create highlighted TextSpans for parts of the driver string.
  TextSpan _buildHighlightedTextSpan(String text, String searchQuery) {
    if (searchQuery.isEmpty || text.isEmpty) {
      return TextSpan(text: text);
    }

    String lowerText = text.toLowerCase();
    String lowerQuery = searchQuery.toLowerCase();

    List<TextSpan> spans = [];
    int startIndex = 0;

    while (startIndex < text.length) {
      int index = lowerText.indexOf(lowerQuery, startIndex);

      if (index == -1) {
        // No more matches, add remaining text
        spans.add(TextSpan(text: text.substring(startIndex)));
        break;
      }

      // Add text before match
      if (index > startIndex) {
        spans.add(TextSpan(text: text.substring(startIndex, index)));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + searchQuery.length),
        style: TextStyle(
          backgroundColor: Colors.yellow[200],
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ));

      startIndex = index + searchQuery.length;
    }

    return TextSpan(children: spans);
  }

  /// Displays the driver selection dialog with search functionality.
  /// It requires a BuildContext, the search controller, and a setState function
  /// to update the dialog's state in real-time.
  Future<void> showDriverSelectionDialog({
    required BuildContext context,
    required TextEditingController searchController,
    required Function(void Function()) setDialogState,
    required Function(String driver) onDriverSelected,
    String? selectedDriver,
  }) async {
    // Reset search when opening dialog
    searchController.clear();
    filterDrivers(''); // Reset filtered list

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Override local setState for the dialog's StatefulBuilder
            setDialogState = setState;

            return AlertDialog(
              title: const Text('Select Driver', style: TextStyle(fontSize: 18)),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    // Search field
                    TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        hintText: 'Search drivers...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            searchController.clear();
                            filterDrivers('');
                            setDialogState(() {});
                          },
                        )
                            : null,
                      ),
                      onChanged: (value) {
                        filterDrivers(value);
                        setDialogState(() {}); // Trigger rebuild of dialog content
                      },
                    ),
                    const SizedBox(height: 12),

                    // Results count
                    if (searchController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${filteredDriverList.length} drivers found',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                    // Driver list
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredDriverList.length,
                        itemBuilder: (context, index) {
                          String driver = filteredDriverList[index];
                          bool isSelected = selectedDriver == driver;

                          return ListTile(
                            dense: true,
                            title: buildDriverItem(
                                driver, searchController.text),
                            selected: isSelected,
                            selectedTileColor: Colors.blue[50],
                            onTap: () {
                              onDriverSelected(driver);
                              Navigator.of(context).pop();
                            },
                            trailing: isSelected
                                ? const Icon(Icons.check, color: Colors.blue)
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}