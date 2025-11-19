import 'package:flutter/material.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';

class AllIndiaEnterPickupDetail extends StatefulWidget {
  final String location;
  final double lat;
  final double lng;

  const AllIndiaEnterPickupDetail({
    super.key,
    required this.location,
    required this.lat,
    required this.lng,
  });

  @override
  State<AllIndiaEnterPickupDetail> createState() => _AllIndiaEnterPickupDetailState();
}

class _AllIndiaEnterPickupDetailState extends State<AllIndiaEnterPickupDetail> {
  final TextEditingController nameController =
  TextEditingController(text: "Tanisha Sharma");
  final TextEditingController mobileController =
  TextEditingController(text: "7235947667");
  final TextEditingController emailController =
  TextEditingController(text: "tanishansh02@gmail.com");
  final TextEditingController houseController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  String selectedType = "Home";

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: PortColor.bg,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back)),
                TextConst(title: "Enter Pickup Detail", color: PortColor.black),
              ],
            ),
            SizedBox(height: screenHeight*0.02,),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                   Icon(Icons.location_on, color: PortColor.button),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextConst(title:
                      widget.location,
                       fontFamily: AppFonts.kanitReg,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Go back to change location
                    },
                    child: const TextConst(title:
                      "Change",
                      color: PortColor.button,
                      fontFamily: AppFonts.kanitReg,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ Mobile
            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Mobile number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ Email
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ House / Flat
            TextField(
              controller: houseController,
              decoration: const InputDecoration(
                labelText: "House No/ Flat No/ Building Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ Pincode
            TextField(
              controller: pincodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Pincode",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Save as
            const Text("Save address as:"),
            const SizedBox(height: 8),
            Row(
              children: [
                choiceChip("Home"),
                const SizedBox(width: 8),
                choiceChip("Shop"),
                const SizedBox(width: 8),
                choiceChip("Others"),
              ],
            ),
            const SizedBox(height: 24),

            // ✅ Confirm button
            SizedBox(
              width: screenWidth,
              height: screenHeight * 0.06,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  // ✅ Collect entered details
                  final details = {
                    "name": nameController.text,
                    "mobile": mobileController.text,
                    "email": emailController.text,
                    "house": houseController.text,
                    "pincode": pincodeController.text,
                    "addressType": selectedType,
                    "location": widget.location,
                    "lat": widget.lat,
                    "lng": widget.lng,
                  };

                  debugPrint("Pickup details: $details");
                  Navigator.pop(context, details);
                },
                child: const Text("Confirm",
                    style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget choiceChip(String type) {
    return ChoiceChip(
      label: Text(type),
      selected: selectedType == type,
      onSelected: (val) {
        if (val) {
          setState(() => selectedType = type);
        }
      },
    );
  }
}
