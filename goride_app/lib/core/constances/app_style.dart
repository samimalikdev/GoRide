import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle style({Color? color, FontWeight? fw, double? size}) =>
    GoogleFonts.poppins(color: color, fontSize: size, fontWeight: fw);

TextStyle outfitStyle({Color? color, FontWeight? fw, double? size}) =>
    GoogleFonts.outfit(color: color, fontSize: size, fontWeight: fw);
