import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/view_model/contact_list_view_model.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/res/launcher.dart';

class HelpSupport extends StatefulWidget {
  const HelpSupport({super.key});

  @override
  State<HelpSupport> createState() => _HelpSupportState();
}

class _HelpSupportState extends State<HelpSupport> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContactListViewModel>(context, listen: false)
          .contactListApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactListVm = Provider.of<ContactListViewModel>(context);

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.bg,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ HEADER
            Container(
              padding: const EdgeInsets.only(top: 14),
              height: screenHeight * 0.096,
              width: screenWidth,
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
                color: PortColor.white,
              ),
              child: Row(
                children: [
                  SizedBox(width: screenWidth * 0.04),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: PortColor.black,
                      size: screenHeight * 0.025,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.25),
                  TextConst(
                    title: "Contact Support",
                    color: PortColor.black,
                    size: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),

            // ✅ SUBTITLE
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.023,
              ),
              child: TextConst(
                title: "Need help with your orders?",
                color: PortColor.black.withOpacity(0.5),
              ),
            ),

            // ✅ CONTACT LIST
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Container(
                width: screenWidth * 0.88,
                decoration: BoxDecoration(
                  color: PortColor.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),

                  // ✅ 1. If Loading → show loader
                  child: contactListVm.loading
                      ? SizedBox(
                    height: screenHeight * 0.15,
                    child:  Center(
                      child: CupertinoActivityIndicator(
                        radius: 12,
                      ),
                    ),
                  )
                      : (contactListVm.contactListModel == null ||
                      contactListVm.contactListModel!.data == null ||
                      contactListVm.contactListModel!.data!.isEmpty)
                      ? SizedBox(
                    height: screenHeight * 0.15,
                    child: const Center(
                      child: Text(
                        "No data found",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )

                  // ✅ 3. ELSE → Show ListView
                      : ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: contactListVm
                        .contactListModel!.data!.length,
                    itemBuilder: (context, index) {
                      final item = contactListVm
                          .contactListModel!.data![index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: SizedBox(
                          height: 40,
                          width: 40,
                          child: Image.network(
                            item.icon ?? "",
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.error),
                          ),
                        ),
                        title: TextConst(
                          title: item.name ?? "Unknown",
                          color: PortColor.black,
                        ),
                        trailing: GestureDetector(
                          onTap: () => Launcher.launchDialPad(
                            context,
                            item.phone ?? "0000000000",
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(6.0),
                            decoration: const BoxDecoration(
                              color: PortColor.gold,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.call_outlined,
                              color: PortColor.black,
                              size: screenHeight * 0.025,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ✅ OTHER SUPPORT
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                height: screenHeight * 0.08,
                width: screenWidth * 0.88,
                decoration: BoxDecoration(
                  color: PortColor.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Any Other question?\n",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: PortColor.black,
                                  fontFamily: AppFonts.kanitReg,
                                  fontSize: 15,
                                ),
                              ),
                              TextSpan(
                                text: "Call or Mail us!",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontFamily: AppFonts.kanitReg,
                                  color: PortColor.black,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Launcher.launchEmail(
                        context,
                        contactListVm.contactListModel?.email??"yoyomiles234@gmail.com",
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: const BoxDecoration(
                          color: PortColor.gold,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mail_outline,
                          color: PortColor.black,
                          size: screenHeight * 0.025,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    GestureDetector(
                      onTap: () => Launcher.launchDialPad(
                        context,
                        contactListVm.contactListModel?.data?.first.phone ?? "0000000000",
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: const BoxDecoration(
                          color: PortColor.gold,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.call_outlined,
                          color: PortColor.black,
                          size: screenHeight * 0.025,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
            // SizedBox(height: 20,),
            _buildEmergencySection(),
          ],
        ),
      ),
    );
  }
  Widget _buildEmergencySection() {
    final contactListVm =
    Provider.of<ContactListViewModel>(context, listen: false);

    final String supportNumber =
        contactListVm.contactListModel?.sosNumber ?? "6306513131";
    final String sosMessage =
        contactListVm.contactListModel?.sosMessage ?? "Hello";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// LEFT INFO
          Expanded(
            child: Row(
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 22,
                ),
                SizedBox(width: 6),
                TextConst(
                  title: "Emergency",
                  size: 15,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),

          /// 🔴 SOS BUTTON
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              _openWhatsApp(
                phone: supportNumber,
                message: sosMessage,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextConst(
                title: "SOS",
                color: Colors.white,
                size: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 8),

          /// 🟡 CHAT SUPPORT
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              _openWhatsApp(
                phone: supportNumber,
                message: "Hello Support, I need help with my ongoing ride.",
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: PortColor.gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chat_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

void _openWhatsApp({
  required String phone,
  String message = "",
}) async {
  final cleanNumber = phone
      .replaceAll("+", "")
      .replaceAll(" ", "")
      .replaceAll("-", "");

  final encodedMessage = Uri.encodeComponent(message);

  final Uri whatsappUrl = Uri.parse(
    "whatsapp://send?phone=$cleanNumber&text=$encodedMessage",
  );

  if (await canLaunchUrl(whatsappUrl)) {
    await launchUrl(
      whatsappUrl,
      mode: LaunchMode.externalApplication,
    );
  } else {
    debugPrint("❌ WhatsApp not installed");
  }
}
