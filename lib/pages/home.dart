import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SizedBox(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.05,
              ),
              _ProfileHeader(),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.02,
              ),
              _Steps()
            ]));
  }

  Widget _ProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(
        5.0,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.account_circle_sharp,
                  size: 38, // Adjust the size of the icon
                  color: Colors.grey[900], // Set the color of the icon
                  semanticLabel:
                      'Account', // Add a semantic label for accessibility
                ), // Add the icon here
                onPressed: () {
                  // Handle icon tap
                },
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.grey[900],
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Text(
                    "Time   02:47:12",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _Steps() {
    return
    Container(
     padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
     child:Column(
      
      children: [
        Row(
         children: [
           Text(
              "Steps",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.0,
              ),
            ),
         ],
        ),
        SizedBox(height: 10),
        Row(
         
         children: [
          Text(
            "9,257",
             style: const TextStyle(
                  fontSize: 55,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.0,
                ),
          )
         ],

        ),
      ],
     ),
    );
    
  }
}
