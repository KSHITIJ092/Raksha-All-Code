import 'package:flutter/material.dart';
import 'home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController aadharNoController = TextEditingController();
  final TextEditingController securityPinController = TextEditingController();

  String? gender;
  String? selectedState;
  List<Map<String, String>> emergencyContacts = [];

  List<String> states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Lakshadweep'
  ];

  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/img.jpg', height: 50),
        title: const Text(
          'RAKSHA',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Personal Information'),
                  _buildTextField(
                    controller: nameController,
                    label: 'Name',
                    hintText: 'Enter your full name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                        return 'Only letters are allowed';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: mobileNoController,
                    label: 'Mobile Number',
                    hintText: 'Enter your mobile number',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mobile number is required';
                      }
                      if (value.length != 10 ||
                          !RegExp(r'^\d{10}$').hasMatch(value)) {
                        return 'Enter a valid 10-digit mobile number';
                      }
                      return null;
                    },
                  ),
                  _buildGenderSelector(),
                  _buildStateDropdown(),
                  _buildTextField(
                    controller: pinCodeController,
                    label: 'Pin Code',
                    hintText: 'Enter your pin code',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pin code is required';
                      }
                      if (value.length != 6 ||
                          !RegExp(r'^\d{6}$').hasMatch(value)) {
                        return 'Enter a valid 6-digit pin code';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: addressController,
                    label: 'Address',
                    hintText: 'Enter your address',
                    maxLines: 2,
                  ),
                  _buildTextField(
                    controller: aadharNoController,
                    label: 'Aadhar Number',
                    hintText: 'Enter your 12-digit Aadhar number',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Aadhar number is required';
                      }
                      if (value.length != 12 ||
                          !RegExp(r'^\d{12}$').hasMatch(value)) {
                        return 'Enter a valid 12-digit Aadhar number';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: securityPinController,
                    label: 'Security Pin',
                    hintText: 'Enter your 4-digit security pin',
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Security Pin is required';
                      }
                      if (value.length != 4 ||
                          !RegExp(r'^\d{4}$').hasMatch(value)) {
                        return 'Enter a valid 4-digit security pin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Emergency Contacts'),
                  ..._buildEmergencyContactList(),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _addEmergencyContact();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Emergency Contact'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        backgroundColor: Colors.deepPurple,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            emergencyContacts.isNotEmpty &&
                            selectedState != null &&
                            gender != null) {
                          await submitPersonalInfo();
                          _showSuccessAnimation();
                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) {
                                  return const HomeScreen();
                                },
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;

                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                      position: offsetAnimation, child: child);
                                },
                              ),
                            );
                          });
                        } else if (emergencyContacts.isEmpty) {
                          _showErrorMessage(
                              'Add at least one emergency contact!');
                        } else if (gender == null) {
                          _showErrorMessage('Please select gender!');
                        }
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submitPersonalInfo() async {
    // final url = Uri.parse('http://localhost:5000/api/personalinfo');
    // final url = Uri.parse('http://192.168.1.176:5000/api/personalinfo');
    final url = Uri.parse('http://192.168.93.176:5000/api/personalinfo');

    final data = {
      'name': nameController.text,
      'mobileNo': mobileNoController.text,
      'gender': gender,
      'selectedState': selectedState,
      'pinCode': pinCodeController.text,
      'address': addressController.text,
      'aadharNo': aadharNoController.text,
      'securityPin': securityPinController.text,
      'emergencyContacts': emergencyContacts,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      print('Personal information saved successfully');
    } else {
      print('Failed to save personal information: ${response.body}');
    }
  }

  void _showSuccessAnimation() {
    _animationController.forward(from: 0.0);
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: gender,
        onChanged: (value) {
          setState(() {
            gender = value;
          });
        },
        items: const [
          DropdownMenuItem(
            value: 'Male',
            child: Text('Male'),
          ),
          DropdownMenuItem(
            value: 'Female',
            child: Text('Female'),
          ),
        ],
        decoration: const InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null) {
            return 'Gender is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildStateDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedState,
        onChanged: (value) {
          setState(() {
            selectedState = value;
          });
        },
        items: states.map((state) {
          return DropdownMenuItem<String>(
            value: state,
            child: Text(state),
          );
        }).toList(),
        decoration: const InputDecoration(
          labelText: 'State',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null) {
            return 'State is required';
          }
          return null;
        },
      ),
    );
  }

  List<Widget> _buildEmergencyContactList() {
    return emergencyContacts
        .map(
          (contact) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(contact['name'] ?? 'New User'),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      emergencyContacts.remove(contact);
                    });
                  },
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  void _addEmergencyContact() {
    final contactNameController = TextEditingController();
    final contactNumberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Emergency Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contactNameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contactNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (contactNameController.text.isNotEmpty &&
                    contactNumberController.text.isNotEmpty) {
                  setState(() {
                    emergencyContacts.add({
                      'name': contactNameController.text,
                      'phone': contactNumberController.text,
                    });
                  });
                  Navigator.pop(context);
                } else {
                  _showErrorMessage('Please provide valid contact details.');
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
