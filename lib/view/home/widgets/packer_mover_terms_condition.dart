import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/view_model/packer_mover_terms_view_model.dart';
import 'package:provider/provider.dart';

class PackerMoverTermsCondition extends StatefulWidget {
  const PackerMoverTermsCondition({super.key});

  @override
  State<PackerMoverTermsCondition> createState() =>
      _PackerMoverTermsConditionState();
}

class _PackerMoverTermsConditionState
    extends State<PackerMoverTermsCondition> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final packerTermsVm =
      Provider.of<PackerMoverTermsViewModel>(context, listen: false);
      packerTermsVm.packerTermsConditionApi("");
      print("I am the....");
    });
  }

  @override
  Widget build(BuildContext context) {
    final packerTermsVm = Provider.of<PackerMoverTermsViewModel>(context);


    return Scaffold(
      backgroundColor: PortColor.bg,
      appBar: AppBar(
        backgroundColor: PortColor.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Terms & Conditions",
          style: TextStyle(
            fontFamily: AppFonts.kanitReg,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: PortColor.black,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: PortColor.black),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: packerTermsVm.loading
                  ? const Center(
                child: CircularProgressIndicator(color: PortColor.gold),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: HtmlWidget(
                  packerTermsVm.packerMoverTermsModel?.data?.description ?? "",
                  textStyle: TextStyle(
                    fontFamily: AppFonts.kanitReg,
                    fontSize: 14,
                    color: PortColor.blackLight,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

    );
  }
}
