import 'package:flutter/material.dart';
import 'package:mappls_gl/mappls_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectLocationScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;
  final Color pinColor;
  final String label; // Add this parameter

  const SelectLocationScreen({
    Key? key,
    required this.onLocationSelected,
    required this.pinColor,
    required this.label, // Add this parameter
  }) : super(key: key);

  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  LatLng? _selectedLocation;
  MapplsMapController? _mapController;
  bool _isLocationPermissionGranted = false;
  String _address = "Searching address...";
  final TextEditingController _searchController = TextEditingController();
  const String geoapifyApiKey = String.fromEnvironment('GEOAPIFY_API_KEY');
  bool _isMapMoving = false;
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enable location services")),
      );
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permission is required")),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permission is permanently denied")),
      );
      return;
    }
    setState(() {
      _isLocationPermissionGranted = true;
    });
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!_isLocationPermissionGranted) return;
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
    });
    if (_mapController != null && _selectedLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_selectedLocation!),
      );
      _fetchAddress(_selectedLocation!);
    }
  }

  void _onMapCreated(MapplsMapController controller) {
    _mapController = controller;
    if (_selectedLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_selectedLocation!),
      );
    }
  }

  void _onMapIdle() async {
    setState(() {
      _isMapMoving = false;
    });

    // Fetch the current camera position
    if (_mapController != null) {
      final visibleRegion = await _mapController!.getVisibleRegion();
      final center = LatLng(
        (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) /
            2,
        (visibleRegion.northeast.longitude +
                visibleRegion.southwest.longitude) /
            2,
      );

      setState(() {
        _selectedLocation = center;
      });
      _fetchAddress(center);
    }
  }

  Future<void> _fetchAddress(LatLng location) async {
    final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/reverse?lat=${location.latitude}&lon=${location.longitude}&apiKey=$geoapifyApiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['features'] != null && data['features'].isNotEmpty) {
        setState(() {
          _address = data['features'][0]['properties']['formatted'];
        });
      } else {
        setState(() {
          _address = "Address not found";
        });
      }
    } else {
      setState(() {
        _address = "Failed to fetch address";
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/search?text=$query&apiKey=$geoapifyApiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['features'] != null && data['features'].isNotEmpty) {
        final location = data['features'][0]['geometry']['coordinates'];
        final latLng = LatLng(location[1], location[0]);
        setState(() {
          _selectedLocation = latLng;
        });
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(latLng),
        );
        _fetchAddress(latLng);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location not found")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to search location")),
      );
    }
  }

  Future<void> _fetchPlaceSuggestions(String query) async {
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

    final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/autocomplete?text=$query&apiKey=$geoapifyApiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['features'] != null) {
        setState(() {
          _searchResults = data['features'];
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } else {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _onSuggestionSelected(dynamic suggestion) {
    final location = suggestion['geometry']['coordinates'];
    final latLng = LatLng(location[1], location[0]);
    setState(() {
      _selectedLocation = latLng;
      _searchController.text = suggestion['properties']['formatted'];
      _searchResults = [];
    });
    _mapController!.animateCamera(
      CameraUpdate.newLatLng(latLng),
    );
    _fetchAddress(latLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0096C8),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search location here",
                    hintStyle: TextStyle(color: Colors.black54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  style: TextStyle(color: Colors.black),
                  onChanged: (query) {
                    _fetchPlaceSuggestions(query);
                  },
                  onSubmitted: (query) {
                    _searchLocation(query);
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.search, color: Colors.black),
                onPressed: () {
                  _searchLocation(_searchController.text);
                },
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location, color: Colors.white),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          Listener(
            onPointerDown: (_) {
              setState(() {
                _isMapMoving = true;
              });
            },
            onPointerUp: (_) {
              _onMapIdle();
            },
            child: MapplsMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation ?? LatLng(28.6139, 77.2090),
                zoom: 15.0,
              ),
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              myLocationTrackingMode: MyLocationTrackingMode.tracking,
              onMapIdle: _onMapIdle,
            ),
          ),

          // **Fixed Shadow**
          Align(
            alignment: Alignment.center,
            child: CustomPaint(
              size: Size(40, 60),
              painter: ShadowPainter(),
            ),
          ),

          // **Moving Pointer**
          Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              transform:
                  Matrix4.translationValues(0, _isMapMoving ? -10 : 0, 0),
              child: CustomPaint(
                size: Size(40, 60),
                painter: PointerPainter(pinColor: widget.pinColor),
              ),
            ),
          ),

          // **Search Results List**
          if (_searchResults.isNotEmpty)
            Positioned(
              top: kToolbarHeight - 57, // Below the AppBar
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final suggestion = _searchResults[index];
                    return ListTile(
                      title: Text(suggestion['properties']['formatted']),
                      onTap: () {
                        _onSuggestionSelected(suggestion);
                      },
                    );
                  },
                ),
              ),
            ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _address,
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedLocation != null) {
                        widget.onLocationSelected(_selectedLocation!);
                        Navigator.pop(context); // Close the map screen
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please select a location")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0096C8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Pick Location",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    Rect shadowRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: 20,
      height: 8,
    );
    canvas.drawOval(shadowRect, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class PointerPainter extends CustomPainter {
  final Color pinColor;

  PointerPainter({required this.pinColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint outerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint innerCirclePaint = Paint()
      ..color = pinColor // Use the provided pin color
      ..style = PaintingStyle.fill;

    final Paint whiteCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw outer circle (moves with map)
    canvas.drawCircle(
      Offset(centerX, centerY - 20),
      10,
      outerCirclePaint,
    );

    // Draw inner circle with the provided color
    canvas.drawCircle(
      Offset(centerX, centerY - 20),
      8,
      innerCirclePaint,
    );

    // Draw white circle inside the inner circle
    canvas.drawCircle(
      Offset(centerX, centerY - 20),
      3,
      whiteCirclePaint,
    );

    // Draw black line from the bottom of the outer circle to the center
    canvas.drawLine(
      Offset(centerX, centerY - 10),
      Offset(centerX, centerY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
