import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet/constants/colors.dart';
import 'package:pet/constants/constants.dart';
import 'package:pet/features/home/home.dart';
import 'package:get/get.dart';
import '../../payment/service.dart';
import '../../pets/controller/pet_controller.dart';
import '../../pets/model/pet_model.dart';

class AppointmentSelectionScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String name;
  final String description;
  final double price;

  AppointmentSelectionScreen({
    required this.userName,
    required this.userEmail,
    required this.name,
    required this.description,
    required this.price,
  });

  @override
  _AppointmentSelectionScreenState createState() =>
      _AppointmentSelectionScreenState();
}

class _AppointmentSelectionScreenState
    extends State<AppointmentSelectionScreen> {
  DateTime selectedDate = DateTime.now();
  String selectedSlot = '';
  String address = ''; // Variable to store the entered address
  String selectedPaymentMethod = ''; // To store the selected payment method
  String? selectedPetId; // Store the selected pet's ID
  Pet? selectedPet; // Store the selected pet object

  List<String> timeSlots = [
    '9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM',
    '1:00 PM', '1:30 PM', '2:00 PM', '2:30 PM',
    '3:00 PM', '3:30 PM', '4:00 PM', '4:30 PM',
    '5:00 PM'
  ];

  final userId = FirebaseAuth.instance.currentUser?.uid;
  final PetController petController = Get.put(PetController());

  // Fetch the pets for the current user
  @override
  void initState() {
    super.initState();
    petController.fetchPets(userId ?? "");
  }

  // Function to select the date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  // Function to select the time slot
  void _selectTimeSlot(String slot) {
    setState(() {
      selectedSlot = slot;
    });
  }

  // Validate if all inputs are valid
  bool _isValidSelection() {
    return selectedSlot.isNotEmpty &&
        selectedDate != null &&
        address.isNotEmpty &&
        selectedPaymentMethod.isNotEmpty &&
        selectedPetId != null;
  }

  // Function to handle the booking flow with payment
  Future<void> _bookAppointment() async {
    if (_isValidSelection()) {
      if (selectedPaymentMethod == "Credit/Debit Card") {
        try {
          // Await the payment process and check if it's successful
          bool paymentSuccess = await StripeService.instance.makePayment(widget.userEmail, widget.price);

          if (paymentSuccess) {
            // Proceed with booking the appointment only if the payment was successful
            String currentUserEmail =
                FirebaseAuth.instance.currentUser?.email ?? 'No User';

            // Confirm booking after payment success
            await FirebaseFirestore.instance.collection('appointments').add({
              'providerName': widget.userName,
              'providerEmail': widget.userEmail,
              'serviceName': widget.name,
              'appointmentDate': selectedDate,
              'appointmentTime': selectedSlot,
              'userEmail': currentUserEmail,
              'address': address,
              'paymentMethod': selectedPaymentMethod,
              'petId': selectedPetId, // Include the selected pet
              'petName': selectedPet?.name, // Include the selected pet's name
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Appointment booked successfully!')),
            );
            Get.back();  // Navigate to home after booking
          } else {
            // Payment failed, show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment failed, please try again.')),
            );
          }
        } catch (e) {
          // Handle errors during the payment or booking process
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error during payment or booking: $e')),
          );
        }
      } else {
        // If payment method is COD, proceed with booking directly
        String currentUserEmail =
            FirebaseAuth.instance.currentUser?.email ?? 'No User';

        try {
          await FirebaseFirestore.instance.collection('appointments').add({
            'providerName': widget.userName,
            'providerEmail': widget.userEmail,
            'serviceName': widget.name,
            'appointmentDate': selectedDate,
            'appointmentTime': selectedSlot,
            'userEmail': currentUserEmail,
            'address': address,
            'paymentMethod': selectedPaymentMethod,
            'petId': selectedPetId, // Include the selected pet
            'petName': selectedPet?.name, // Include the selected pet's name
          });

          print("Appointment successfully booked!");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Appointment booked successfully!')),
          );
          Get.back();  // Navigate to home after booking
        } catch (e) {
          print("Error booking appointment: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to book appointment: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a valid date, time, address, pet, and payment method'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Appointment',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        foregroundColor: textColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Date:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${selectedDate.toLocal()}".split(' ')[0],
                    style: TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: textColor,
                    ),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Time Slot Selection using GridView
              Text(
                "Select Time Slot:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  childAspectRatio: 2.5,
                ),
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  return ChoiceChip(
                    label: Text(timeSlots[index]),
                    selected: selectedSlot == timeSlots[index],
                    onSelected: (selected) {
                      _selectTimeSlot(timeSlots[index]);
                    },
                    backgroundColor: backgrndclrpurple,
                    selectedColor: Colors.purple[200],
                    labelStyle: TextStyle(color: Colors.black),
                  );
                },
              ),
              SizedBox(height: 20),

              // Select Pet Dropdown
              Text(
                "Select Pet:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Obx(() {
                // Fetch pets from the PetController
                var pets = petController.pets;

                if (pets.isEmpty) {
                  return Center(child: Text("No pets found"));
                }

                return DropdownButton<String>(
                  hint: Text("Select your pet"),
                  value: selectedPetId,
                  onChanged: (String? newPetId) {
                    setState(() {
                      selectedPetId = newPetId;
                      selectedPet = pets.firstWhere((pet) => pet.id == newPetId);
                    });
                  },
                  items: pets.map<DropdownMenuItem<String>>((Pet pet) {
                    return DropdownMenuItem<String>(
                      value: pet.id,
                      child: Text(pet.name),
                    );
                  }).toList(),
                );
              }),
              SizedBox(height: 20),

              // Address Input Field
              Text(
                "Enter Address:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  setState(() {
                    address = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter your address',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Payment Method Selection
              Text(
                "Select Payment Method:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  ListTile(
                    title: Text("Credit/Debit Card"),
                    leading: Radio<String>(
                      value: "Credit/Debit Card",
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text("Cash on Delivery (COD)"),
                    leading: Radio<String>(
                      value: "Cash on Delivery",
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Confirm Button
              Center(
                child: ElevatedButton(
                  onPressed: _bookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgrndclrpurple,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text("Confirm Booking"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
