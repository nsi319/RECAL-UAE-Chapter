import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iosrecal/Constant/ColorGlobal.dart';
import 'package:iosrecal/Constant/utils.dart';

class NodataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final double width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Center(
        child: Text("No data available!",
            style: GoogleFonts.josefinSans(
                fontSize:
                    UIUtills().getProportionalHeight(height: 25, choice: 3),
                color: ColorGlobal.textColor)));
  }
}
