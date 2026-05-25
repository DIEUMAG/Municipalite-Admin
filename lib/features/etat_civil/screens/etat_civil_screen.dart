import 'package:flutter/material.dart';

class EtatCivilScreen extends StatelessWidget {
  const EtatCivilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services =
        [
      {
        "title": "Actes de naissance",
        "icon": Icons.child_care,
        "color": Colors.blue,
      },
      {
        "title": "Actes de mariage",
        "icon": Icons.favorite,
        "color": Colors.pink,
      },
      {
        "title": "Actes de décès",
        "icon": Icons.event_busy,
        "color": Colors.grey,
      },
      {
        "title":
            "Concessions funéraires",
        "icon": Icons.account_balance,
        "color": Colors.brown,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "État Civil",
        ),
        centerTitle: true,
      ),

      body: GridView.builder(
        padding:
            const EdgeInsets.all(16),

        itemCount: services.length,

        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),

        itemBuilder: (context, index) {
          final service =
              services[index];

          return Card(
            elevation: 4,

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),

            child: InkWell(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),

              onTap: () {},

              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),

                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [
                    CircleAvatar(
                      radius: 35,

                      backgroundColor:
                          service["color"]
                              .withOpacity(
                        0.15,
                      ),

                      child: Icon(
                        service["icon"],
                        color:
                            service[
                                "color"],
                        size: 35,
                      ),
                    ),

                    const SizedBox(
                        height: 18),

                    Text(
                      service["title"],

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}