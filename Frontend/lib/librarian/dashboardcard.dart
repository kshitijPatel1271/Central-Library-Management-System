import 'package:flutter/material.dart';

class DashboardCard extends StatefulWidget {
  final String title;
  final String iconPath; 
  final String count;
  final Widget page;

  const DashboardCard({
    super.key,
    required this.title,
    required this.iconPath, 
    required this.count,
    required this.page,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => widget.page));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        surfaceTintColor: Color.fromARGB(255, 141, 133, 133),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              widget.iconPath,
              height: 50,
              width: 50,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, size: 40, color: Colors.grey);
              },
            ),
            const SizedBox(height: 5),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              widget.count,
              style: const TextStyle(color: Color.fromARGB(255, 18, 17, 17), fontSize: 14,fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
