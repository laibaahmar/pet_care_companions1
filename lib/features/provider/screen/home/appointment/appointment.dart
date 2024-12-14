import 'package:flutter/material.dart';
import 'package:pet/constants/colors.dart';
import 'package:pet/constants/sizes.dart';

class AppointmentSection extends StatelessWidget {
  const AppointmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Sizes.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Upcoming Appointments",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: Sizes.s*2),
          const AppointmentCard(
            clientName: "Jane Smith",
            dateTime: "25th Sept, 10:00 AM",
            service: "Dog Walking",
            serviceName: null,
          ),
          const AppointmentCard(
            clientName: "Michael Brown",
            dateTime: "25th Sept, 12:00 PM",
            service: "Grooming",
            serviceName: null,
          ),
        ],
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String clientName;
  final String dateTime;
  final String service;

  const AppointmentCard({super.key, required this.clientName, required this.dateTime, required this.service, required serviceName});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
      color: logoPurple.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clientName, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 5),
                Text(service, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 5),
                Text(dateTime, style: const TextStyle(color: textColor, fontSize: 14),),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, color: textColor,),
          ],
        ),
      ),
    );
  }
}

