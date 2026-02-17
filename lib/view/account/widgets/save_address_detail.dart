import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yoyomiles/generated/assets.dart';
import 'package:yoyomiles/l10n/app_localizations.dart';
import 'package:yoyomiles/main.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view/account/widgets/address/save_pickup_address.dart';
import 'package:yoyomiles/view_model/address_delete_view_model.dart';
import 'package:yoyomiles/view_model/address_show_view_model.dart';
import 'package:provider/provider.dart';

class SaveAddressDetail extends StatefulWidget {
  const SaveAddressDetail({super.key});
  @override
  State<SaveAddressDetail> createState() => _SaveAddressDetailState();
}

class _SaveAddressDetailState extends State<SaveAddressDetail> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressShowViewModel =
          Provider.of<AddressShowViewModel>(context, listen: false);
      addressShowViewModel.addressShowApi();
      print("hoooo");
    });
  }

  @override
  Widget build(BuildContext context) {
    final addressShowViewModel = Provider.of<AddressShowViewModel>(context);
    final loc = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.bg,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20, left: 5),
              height: screenHeight * 0.095,
              width: screenWidth,
              decoration: BoxDecoration(
                color: PortColor.white,
                boxShadow: [
                  BoxShadow(
                    color: PortColor.gray.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: screenWidth * 0.03,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: PortColor.black,
                      size: screenHeight * 0.025,
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.25,
                  ),
                  TextConst(
                    title: loc.saved_address,
                    color: PortColor.black,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavePickUpAddress(),
                    ),
                  );
                },
                child: Material(
                  elevation: 3.0,
                  borderRadius: BorderRadius.circular(10.0),
                  shadowColor: PortColor.grey.withOpacity(0.5),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: PortColor.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: PortColor.gold,
                        size: screenHeight * 0.025,
                      ),
                    ),
                    title: TextConst(
                        title: loc.add_new_add, color: PortColor.gold,fontFamily: AppFonts.kanitReg,),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: PortColor.black,
                      size: screenHeight * 0.02,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: TextConst(
                  title: loc.your_saved_add,
                  color: PortColor.black.withOpacity(0.6)),
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: addressShowViewModel.loading
                  ? const Center(
                child: CupertinoActivityIndicator(
                  radius: 14, // you can adjust the size (default = 10)
                  color: PortColor.black, // optional (works on newer Flutter versions)
                ),
              )
                  : addressShowViewModel.addressShowModel?.data?.isNotEmpty == true
                      ? ListView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05),
                          itemCount: addressShowViewModel
                              .addressShowModel!.data!.length,
                          itemBuilder: (context, index) {
                            final saveAddress = addressShowViewModel
                                .addressShowModel?.data![index];
                            return Padding(
                              padding:
                                  EdgeInsets.only(bottom: screenHeight * 0.02),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                    vertical: screenHeight * 0.02),
                                decoration: BoxDecoration(
                                  color: PortColor.white,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                      offset: const Offset(1, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Image(
                                          image: const AssetImage(
                                              Assets.assetsShop),
                                          height: screenHeight * 0.038,
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextConst(
                                                title:
                                                    saveAddress?.addressType ??
                                                        "",
                                                color: PortColor.black,
                                            fontFamily: AppFonts.kanitReg,
                                              size: 14,
                                            ),
                                            Row(
                                              children: [
                                                TextConst(
                                                    title:
                                                        saveAddress?.name ?? "",
                                                    color: PortColor.gray,
                                                fontFamily: AppFonts.poppinsReg,
                                                  size: 12,
                                                ),
                                                SizedBox(
                                                  width: screenWidth * 0.01,
                                                ),
                                                TextConst(
                                                    title: saveAddress?.contactNo
                                                            .toString() ??
                                                        "",
                                                    color: PortColor.gray,
                                                  fontFamily: AppFonts.poppinsReg,
                                                  size: 12,

                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      thickness: screenWidth * 0.001,
                                    ),
                                    TextConst(
                                        title: saveAddress?.houseArea ?? "mfnwe",
                                        color: PortColor.gray,
                                    fontFamily: AppFonts.poppinsReg,
                                      size: 12,
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.01,
                                    ),
                                    TextConst(
                                        title: saveAddress?.address ?? "",
                                        color: PortColor.gray,
                                      fontFamily: AppFonts.poppinsReg,
                                      size: 12,
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.01,
                                    ),
                                    TextConst(
                                      title: " ${loc.pin_code} ${saveAddress?.pincode.toString() ?? ""} ",
                                      color: PortColor.gray,
                                      fontFamily: AppFonts.poppinsReg,
                                      size: 12,
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        /// edit button
                                        // Container(
                                        //   height: screenHeight * 0.046,
                                        //   width: screenWidth * 0.35,
                                        //   decoration: BoxDecoration(
                                        //     border: Border.all(color : PortColor.gold,width: 0.5),
                                        //     color:
                                        //         PortColor.blue.withOpacity(0.1),
                                        //     borderRadius:
                                        //         BorderRadius.circular(8),
                                        //   ),
                                        //   child: Center(
                                        //       child: TextConst(
                                        //           title: 'Edit',
                                        //           color: PortColor.gold,
                                        //           fontFamily: AppFonts.kanitReg,
                                        //         fontWeight: FontWeight.w600,
                                        //       )),
                                        // ),
                                        SizedBox(width: screenWidth * 0.1),
                                        GestureDetector(
                                          onTap: () {
                                           // AddressDeleteViewModel.addressDeleteApi();
                                            showModalBottomSheet(
                                              backgroundColor: PortColor.white,
                                              context: context,
                                              shape: const RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.vertical(top: Radius.circular(10)),
                                              ),
                                              builder: (BuildContext context) {
                                                return deleteBottomSheet(context, saveAddress!.id.toString());
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: screenHeight * 0.03,
                                            width: screenWidth * 0.35,
                                            decoration: BoxDecoration(
                                              border: Border.all(color : PortColor.gold,width: 0.5),
                                              color:
                                                  PortColor.blue.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                                child: TextConst(
                                                    title: loc.delete,
                                                    fontFamily: AppFonts.kanitReg,
                                                    fontWeight: FontWeight.w600,
                                                    color: PortColor.gold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      :  Center(child: Text(loc.no_add_available)),
            ),
          ],
        ),
      ),
    );
  }
  Widget deleteBottomSheet(context, String addressId){
    final addressDeleteViewModel = Provider.of<AddressDeleteViewModel>(context);
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.all(screenHeight * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextConst(
              title: loc.delete_shop_add,
              color: PortColor.black),
          SizedBox(height: screenHeight * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  height: screenHeight * 0.058,
                  width: screenWidth * 0.4,
                  decoration: BoxDecoration(
                    color: PortColor.white,
                    border: Border.all(
                        color: PortColor.gold,
                        width: 1.5),
                    borderRadius: const BorderRadius.all(
                        Radius.circular(20)),
                  ),
                  child: Center(
                    child: TextConst(
                        title: loc.no,
                        fontFamily: AppFonts.kanitReg,
                        fontWeight: FontWeight.w600,
                        color: PortColor.gold),
                  ),
                ),
              ),
              SizedBox(
                width: screenWidth * 0.02,
              ),
              GestureDetector(
                onTap: (){
                  addressDeleteViewModel.deleteAddressApi( addressId: addressId, context: context);
                  Navigator.pop(context);
                },
                child: Container(
                  height: screenHeight * 0.058,
                  width: screenWidth * 0.4,
                  decoration: BoxDecoration(
                    color: PortColor.gold,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(20)),
                  ),
                  child: Center(
                    child: TextConst(
                        fontFamily: AppFonts.kanitReg,
                        fontWeight: FontWeight.w600,
                        title: loc.yes, color: PortColor.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
