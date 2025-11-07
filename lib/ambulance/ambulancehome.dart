import 'package:flutter/material.dart';
import 'package:healthcare/services/firestore_service.dart'; // REQUIRED
import 'package:healthcare/models/ambulance_type_model.dart'; // REQUIRED Model
import 'ambulancedetial.dart'; // Next page

class Ambulancehome extends StatefulWidget {
  const Ambulancehome({super.key});

  @override
  State<Ambulancehome> createState() => _AmbulancehomeState();
}

class _AmbulancehomeState extends State<Ambulancehome> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  
  // Local state to hold the search query
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Set up listener for search bar changes
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  // Local filtering function (now uses the fetched model list)
  List<AmbulanceTypeModel> _filterAmbulances(List<AmbulanceTypeModel> allTypes) {
    if (_searchQuery.isEmpty) {
      return allTypes;
    }
    return allTypes.where(
      (type) => type.name.toLowerCase().contains(_searchQuery.toLowerCase()),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambulance Service'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.red.shade700, // Appropriate color for urgency
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search Box (Now correctly hooked to state)
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Cardiac, ICU, Basic...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              // We rely on the listener set up in initState, so onChanged is unnecessary
              // but can be kept if preferred. We use the listener for efficiency.
            ),
            const SizedBox(height: 16),

            // Results List via StreamBuilder
            Expanded(
              child: StreamBuilder<List<AmbulanceTypeModel>>(
                stream: _firestoreService.getAmbulanceTypes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading services: ${snapshot.error}'));
                  }
                  
                  final allAmbulances = snapshot.data ?? [];
                  final filteredAmbulances = _filterAmbulances(allAmbulances);

                  if (filteredAmbulances.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty 
                            ? "No ambulance types available."
                            : "No results for '$_searchQuery'",
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredAmbulances.length,
                    itemBuilder: (context, index) {
                      final ambulance = filteredAmbulances[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 2,
                        child: ListTile(
                          leading: Icon(
                            ambulance.name.toLowerCase().contains('icu') || ambulance.name.toLowerCase().contains('cardiac') 
                                ? Icons.favorite
                                : Icons.local_hospital,
                            color: Colors.red,
                          ),
                          title: Text(
                            ambulance.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Fare from Rs. ${ambulance.baseFare.toStringAsFixed(0)}',
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Pass the entire AmbulanceTypeModel object to the detail page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Ambulancedetail(
                                  // NOTE: Ambulancedetail must be updated to accept AmbulanceTypeModel
                                  ambulanceType: ambulance, 
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}