import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:ride_uni/search_screen_selector.dart';
import 'ride_details_page.dart'; // Import the RideDetailsPage
import 'find_ride_details_page.dart'; // Import the FindRideDetailsPage
import 'package:mappls_gl/mappls_gl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Import the new pages
import 'my_rides_page.dart';
import 'wallet_page.dart';
import 'profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPageIndex = 0;
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Reset the selected index to 0 when the HomeScreen is initialized
    _selectedIndex = 0;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the respective page based on the selected index
    switch (index) {
      case 0:
        // Home page is already the current page
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyRidesPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WalletPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reset the selected index to 0 when the HomeScreen is built
    _selectedIndex = 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0096C8),
        centerTitle: true,
        toolbarHeight: 52.0, // Reduced AppBar height
        title: SizedBox(
          width: 120,
          height: 30,
          child: Text(
            'RIDE UNI',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontFamily: 'Inria Serif',
              fontWeight: FontWeight.w400,
              letterSpacing: 1.5,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // App bar background extended to the Find Ride/Offer Ride section
          Container(
            color: const Color(0xFF0096C8),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavButton('Find Ride', 0),
                _buildNavButton('Offer Ride', 1),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              children: const [
                RideForm(isOfferRide: false),
                RideForm(isOfferRide: true),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Shadow color
              blurRadius: 10, // Blur radius
              offset: const Offset(0, -5), // Top shadow
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor:
              Colors.white, // White background for the bottom nav bar
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'My Rides',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF0096C8),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildNavButton(String text, int pageIndex) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4, // Responsive width
        padding: const EdgeInsets.symmetric(vertical: 8), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _currentPageIndex == pageIndex
                ? const Color(0xFF0096C8) // Active text color
                : Colors.grey, // Inactive text color
            fontSize: 16, // Reduced font size
            fontFamily: 'Inria Serif',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class RideForm extends StatefulWidget {
  final bool isOfferRide;
  const RideForm({super.key, required this.isOfferRide});

  @override
  _RideFormState createState() => _RideFormState();
}

class _RideFormState extends State<RideForm> {
  LatLng? _fromLocation;
  LatLng? _toLocation;
  DateTime? _selectedDateTime;
  final TextEditingController _pricePerSeatController = TextEditingController();
  final TextEditingController _numberOfSeatsController =
      TextEditingController();
  String? _priceError; // To store the error message for price
  String? _seatsError; // To store the error message for number of seats
  String? _dateTimeError; // To store the error message for date and time
  String? _fromAddress;
  String? _toAddress;

  const String geoapifyApiKey = String.fromEnvironment('GEOAPIFY_API_KEY');

  Future<void> _selectDateTime() async {
    try {
      DateTime? dateTime = await showOmniDateTimePicker(
        context: context,
        initialDate: _selectedDateTime ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 3652)),
        is24HourMode: false,
        isShowSeconds: false,
        minutesInterval: 1,
        secondsInterval: 1,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        constraints: const BoxConstraints(maxWidth: 350, maxHeight: 650),
        transitionBuilder: (context, anim1, anim2, child) {
          return FadeTransition(
            opacity: anim1.drive(Tween(begin: 0, end: 1)),
            child: ScaleTransition(
              scale: anim1.drive(Tween(begin: 0.8, end: 1)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        barrierDismissible: true,
        theme: ThemeData(
          primaryColor: const Color(0xFF0096C8),
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF0096C8),
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          dialogTheme: DialogTheme(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );

      if (dateTime != null) {
        if (dateTime.isBefore(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You cannot select a past date and time.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          setState(() {
            _selectedDateTime = dateTime;
            _dateTimeError =
                null; // Clear the error message when a date is selected
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select date and time: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _isLocationUniversityCollegeOrSchool(LatLng location) async {
    final url =
        'https://api.geoapify.com/v2/place-details?lat=${location.latitude}&lon=${location.longitude}&apiKey=$geoapifyApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['features'] != null && data['features'].isNotEmpty) {
        final categories = data['features'][0]['properties']['categories'];
        if (categories != null && categories.isNotEmpty) {
          for (final category in categories) {
            if (category.contains('education') ||
                category.contains('university') ||
                category.contains('college') ||
                category.contains('school')) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  void _validateAndSubmit() async {
    setState(() {
      _priceError = null; // Reset the error message for price
      _seatsError = null; // Reset the error message for number of seats
      _dateTimeError = null; // Reset the error message for date and time
    });

    bool isValid = true; // Flag to track overall form validity

    // Validate date and time
    if (_selectedDateTime == null) {
      setState(() {
        _dateTimeError = 'Date and time are required';
      });
      isValid = false; // Form is invalid
    }

    if (widget.isOfferRide) {
      // Validate price per seat for "Offer Ride"
      if (_pricePerSeatController.text.isEmpty) {
        setState(() {
          _priceError = 'Price per seat is required';
        });
        isValid = false; // Form is invalid
      } else if (double.tryParse(_pricePerSeatController.text) == null) {
        setState(() {
          _priceError = 'Please enter a valid number';
        });
        isValid = false; // Form is invalid
      }
    } else {
      // Validate number of seats for "Find Ride"
      if (_numberOfSeatsController.text.isEmpty) {
        setState(() {
          _seatsError = 'Number of seats is required';
        });
        isValid = false; // Form is invalid
      } else if (int.tryParse(_numberOfSeatsController.text) == null) {
        setState(() {
          _seatsError = 'Please enter a valid number';
        });
        isValid = false; // Form is invalid
      }
    }

    // Show a loading indicator while performing network calls
    if (isValid && _fromLocation != null && _toLocation != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF0096C8)),
          ),
        ),
      );

      // Run network calls in parallel using Future.wait
      try {
        final results = await Future.wait([
          _isLocationUniversityCollegeOrSchool(_fromLocation!),
          _isLocationUniversityCollegeOrSchool(_toLocation!),
        ]);

        final fromIsValid = results[0] as bool;
        final toIsValid = results[1] as bool;

        if (!fromIsValid && !toIsValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Either "From" or "To" location must be a university, college, or school.'),
              backgroundColor: Colors.red,
            ),
          );
          isValid = false; // Form is invalid
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to validate locations: $e'),
            backgroundColor: Colors.red,
          ),
        );
        isValid = false; // Form is invalid
      } finally {
        Navigator.pop(context); // Hide the loading indicator
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Both "From" and "To" locations are required.'),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false; // Form is invalid
    }

    // Proceed only if the form is valid
    if (isValid) {
      if (widget.isOfferRide) {
        // Navigate to RideDetailsPage for "Offer Ride"
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideDetailsPage(
              from: _fromAddress ?? 'Unknown Location',
              to: _toAddress ?? 'Unknown Location',
              dateTime: _selectedDateTime!.toLocal().toString(),
              pricePerSeat: double.parse(_pricePerSeatController.text),
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AvailableRidesPage(
              from: _fromAddress ?? 'Unknown Location',
              to: _toAddress ?? 'Unknown Location',
              dateTime: _selectedDateTime?.toLocal().toString() ??
                  DateTime.now().toLocal().toString(),
              requiredSeats: int.parse(_numberOfSeatsController.text),
            ),
          ),
        );
        // Navigate to FindRideDetailsPage for "Find Ride"
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Image at the top
          Image.asset('assets/sharing.png', height: 180),
          const SizedBox(height: 24),
          // White background container with rounded top corners
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), // Rounded top-left corner
              topRight: Radius.circular(20), // Rounded top-right corner
            ),
            child: Container(
              color: Colors.white, // White background
              padding: const EdgeInsets.all(16.0), // Inner padding
              child: Column(
                children: [
                  // Adjusted to bring the text down
                  Center(
                    child: Text(
                      widget.isOfferRide ? 'Offer Ride' : 'Find Ride',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.white, // Set Card background to white
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildLocationSelector(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    'Date & time',
                    Icons.calendar_today,
                    onTap: _selectDateTime, // Pass the onTap callback
                  ),
                  if (_dateTimeError !=
                      null) // Display error message if present
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _dateTimeError!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Conditional field based on isOfferRide
                  if (widget.isOfferRide) _buildPricePerSeatField(),
                  if (!widget.isOfferRide) _buildNumberOfSeatsField(),
                  if (_priceError != null) // Display error message if present
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _priceError!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (_seatsError != null) // Display error message if present
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _seatsError!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Conditional button based on isOfferRide
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _validateAndSubmit, // Use the validation method
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0096C8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.isOfferRide ? 'Offer Ride' : 'Find Ride',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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

  Widget _buildLocationSelector() {
    return Stack(
      children: [
        Positioned(
          left: 14,
          top: 30,
          bottom: 30,
          child: CustomPaint(
            size: Size(2, 120), // Increased height for more dashes
            painter: DashedLinePainter(),
          ),
        ),
        Column(
          children: [
            _buildLocationField(
              'From',
              Colors.green,
              Icons.circle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SelectLocationScreen(
                            onLocationSelected: _updateFromLocation,
                            pinColor: Colors.green,
                            label: "Pick Location",
                          )),
                );
              },
            ),
            const SizedBox(
                height: 40), // Increased distance between "From" and "To"
            _buildLocationField(
              'To',
              Colors.red,
              Icons.location_on,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SelectLocationScreen(
                            onLocationSelected: _updateToLocation,
                            pinColor: Colors.red,
                            label: "Drop Location",
                          )),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  void _updateFromLocation(LatLng location) async {
    setState(() {
      _fromLocation = location;
    });
    String address = await _getAddressFromLatLng(location);
    setState(() {
      // Add this setState to update the address
      _fromAddress = address;
    });
  }

  void _updateToLocation(LatLng location) async {
    setState(() {
      _toLocation = location;
    });
    String address = await _getAddressFromLatLng(location);
    setState(() {
      // Add this setState to update the address
      _toAddress = address;
    });
  }

  Future<String> _getAddressFromLatLng(LatLng location) async {
    final url =
        'https://api.geoapify.com/v1/geocode/reverse?lat=${location.latitude}&lon=${location.longitude}&apiKey=$geoapifyApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['features'] != null && data['features'].isNotEmpty) {
        final address = data['features'][0]['properties']['formatted'];
        return address;
      }
    }
    return 'Address not found';
  }

  Widget _buildLocationField(String label, Color color, IconData icon,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap, // Handle the tap event
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  label == 'From'
                      ? _fromAddress ?? 'Select location'
                      : _toAddress ?? 'Select location',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, IconData icon,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap, // Handle the tap event
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDateTime != null && label == 'Date & time'
                    ? '${_selectedDateTime!.toLocal()}'
                        .split('.')[0] // Display date and time
                    : label,
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPricePerSeatField() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8), // Reduced vertical padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: 48, // Reduced height of the container
      ),
      child: Row(
        children: [
          Icon(Icons.attach_money, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _pricePerSeatController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Price per seat',
                border: InputBorder.none,
                isDense:
                    true, // Reduces the internal padding of the TextFormField
                contentPadding: EdgeInsets
                    .zero, // Removes extra padding inside the TextFormField
              ),
              style: TextStyle(
                fontSize: 14, // Adjust font size if needed
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberOfSeatsField() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8), // Reduced vertical padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: 48, // Reduced height of the container
      ),
      child: Row(
        children: [
          Icon(Icons.event_seat, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _numberOfSeatsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Number of seats',
                border: InputBorder.none,
                isDense:
                    true, // Reduces the internal padding of the TextFormField
                contentPadding: EdgeInsets
                    .zero, // Removes extra padding inside the TextFormField
              ),
              style: TextStyle(
                fontSize: 14, // Adjust font size if needed
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.5
      ..style;
    PaintingStyle.stroke;

    final dashWidth = 3; // Reduced dash width for more dashes
    final dashSpace = 2; // Reduced dash space for more dashes
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
