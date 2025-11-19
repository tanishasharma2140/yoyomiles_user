import 'package:flutter/material.dart';
import 'package:yoyomiles/res/app_fonts.dart';
import 'package:yoyomiles/res/constant_color.dart';
import 'package:yoyomiles/res/constant_text.dart';
import 'package:yoyomiles/view_model/goods_type_view_model.dart';
import 'package:provider/provider.dart';

class GoodsTypeScreen extends StatefulWidget {
  const GoodsTypeScreen({super.key});

  @override
  State<GoodsTypeScreen> createState() => _GoodsTypeScreenState();
}

class _GoodsTypeScreenState extends State<GoodsTypeScreen> {
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goodsTypeVm = Provider.of<GoodsTypeViewModel>(context, listen: false);
      goodsTypeVm.goodsTypeApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final goodType = Provider.of<GoodsTypeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        title: TextConst(
          title: "Select your goods type",
          size: 16,
          color: PortColor.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (_) {
                if (goodType.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: PortColor.gold),
                  );
                } else if (goodType.goodsTypeModel == null ||
                    goodType.goodsTypeModel!.data == null ||
                    goodType.goodsTypeModel!.data!.isEmpty) {
                  // ✅ No data found
                  return const Center(
                    child: Text(
                      "No Data Found",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  );
                } else {
                  return ListView.separated(
                    itemCount: goodType.goodsTypeModel!.data!.length,
                    separatorBuilder: (_, __) => Divider(
                      color: Colors.grey.shade300,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final goods = goodType.goodsTypeModel!.data![index];
                      return ListTile(
                        title: TextConst(
                          title: goods.name ?? "",
                          size: 13,
                          fontFamily: AppFonts.kanitReg,
                          color: PortColor.blackLight,
                        ),
                        trailing: selectedIndex == index
                            ? const Icon(Icons.check, color: PortColor.blue)
                            : null,
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedIndex == null
                    ? Colors.grey.shade300
                    : PortColor.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: selectedIndex == null
                  ? null
                  : () {
                final selected =
                goodType.goodsTypeModel!.data![selectedIndex!];
                Navigator.pop(context, {
                  "id": selected.id,
                  "goods_name": selected.name,
                });
              },
              child: Text(
                "Update",
                style: TextStyle(
                  color: selectedIndex == null ? Colors.black : Colors.black,
                  fontFamily: AppFonts.kanitReg,
                ),
              ),
            ),
          ),

        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
