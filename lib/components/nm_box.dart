import 'package:flutter/material.dart';

Color mC = Colors.grey.shade100;
Color mCL = Colors.white;
Color mCD = Colors.black.withOpacity(0.075);
Color mCC = Colors.green.withOpacity(0.65);
Color fCD = Colors.grey.shade700;
Color fCL = Colors.grey;
Color fDQ = Colors.black;

BoxDecoration nMbox = BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    color: mC,
    boxShadow: [
      BoxShadow(
        color: mCD,
        offset: const Offset(10, 10),
        blurRadius: 10,
      ),
      BoxShadow(
        color: mCL,
        offset: const Offset(-10, -10),
        blurRadius: 10,
      ),
    ]);

BoxDecoration nMboxInvert = BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    color: mCD,
    boxShadow: [
      BoxShadow(
          color: mCL,
          offset: const Offset(3, 3),
          blurRadius: 3,
          spreadRadius: -3),
    ]);

BoxDecoration nMboxInvertActive = nMboxInvert.copyWith(color: mCC);

BoxDecoration nMbtn = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: mC,
    boxShadow: [
      BoxShadow(
        color: mCD,
        offset: const Offset(2, 2),
        blurRadius: 2,
      )
    ]);

class NMButton extends StatelessWidget {
  final bool down;
  final IconData icon;
  const NMButton(
      {super.key,
      required this.down,
      required this.icon,
      required Null Function() onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: down ? nMboxInvert : nMbox,
      child: Icon(
        icon,
        color: down ? fCD : fCL,
      ),
    );
  }
}
