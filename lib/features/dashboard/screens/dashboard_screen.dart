// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF3B82F6);
  static const Color backgroundColor = Color(0xFFF3F4F6);

  final List<Map<String, dynamic>> modules = const [
  {
    "title": "Utilisateurs",
    "icon": Icons.person_outline,
    "route": "/profile",
    "color": Color(0xFF2563EB),
    "count": "01",
  },
  {
    "title": "Annuaires",
    "icon": Icons.contacts_outlined,
    "route": "/annuaires",
    "color": Color(0xFF059669),
    "count": "120",
  },
  {
    "title": "Actualités",
    "icon": Icons.newspaper_outlined,
    "route": "/actualites",
    "color": Color(0xFFD97706),
    "count": "32",
  },
  {
    "title": "Incidents",
    "icon": Icons.warning_amber_rounded,
    "route": "/incidents",
    "color": Color(0xFFDC2626),
    "count": "08",
  },
  {
    "title": "Notifications",
    "icon":
        Icons.notifications_none_rounded,
    "route": "/notifications",
    "color": Color(0xFF7C3AED),
    "count": "15",
  },
  {
    "title": "Actes",
    "icon": Icons.description_outlined,
    "route": "/actes",
    "color": Color(0xFF0891B2),
    "count": "245",
  },

  {
    "title": "État Civil",
    "icon": Icons.badge_outlined,
    "route": "/etat-civil",
    "color": Color(0xFF0F766E),
    "count": "128",
  },

  {
    "title": "Élections",
    "icon": Icons.how_to_vote_outlined,
    "route": "/elections",
    "color": Color(0xFFBE123C),
    "count": "560",
  },

  {
    "title": "Concessions",
    "icon":
        Icons.account_balance_outlined,
    "route": "/concessions",
    "color": Color(0xFF4F46E5),
    "count": "73",
  },

  {
    "title": "Archivage",
    "icon": Icons.archive_outlined,
    "route": "/archivage",
    "color": Color(0xFF7C2D12),
    "count": "940",
  },
];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          "Administration Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Badge(
              label: Text("3"),
              child: Icon(Icons.notifications_none),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(
              backgroundImage: AssetImage(
                "assets/images/admin.jpg",
              ),
            ),
          ),
        ],
      ),

      // ================= DRAWER =================
      drawer: Drawer(
        backgroundColor: primaryColor,
        child: Column(
          children: [
            const DrawerHeader(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: primaryColor,
                      size: 35,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Administration",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "admin@mairie.cm",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];

                  return ListTile(
                    leading: Icon(
                      module['icon'],
                      color: Colors.white,
                    ),
                    title: Text(
                      module['title'],
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.white70,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        module['route'],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

                                               //BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
                                              // HEADER
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    primaryColor,
                    secondaryColor,
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Bienvenue Admin 👋",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Gérez efficacement votre plateforme municipale.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.dashboard_customize,
                    size: 90,
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

                                                    //STATS
            Row(
              children: [
                _buildStatCard(
                  "Incidents",
                  "08",
                  Icons.warning,
                  Colors.red,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  "Actualités",
                  "32",
                  Icons.newspaper,
                  Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  "Notifications",
                  "15",
                  Icons.notifications,
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 35),

            const Text(
              "Modules Administration",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            //GRID
            GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: modules.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final module = modules[index];

                return InkWell(
                  borderRadius:
                      BorderRadius.circular(24),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      module['route'],
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 300,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.grey.shade200,
                          blurRadius: 10,
                          offset:
                              const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.all(
                            14,
                          ),
                          decoration: BoxDecoration(
                            color: (module['color']
                                    as Color)
                                .withOpacity(0.1),
                            borderRadius:
                                BorderRadius
                                    .circular(18),
                          ),
                          child: Icon(
                            module['icon'],
                            size: 28,
                            color: module['color'],
                          ),
                        ),

                        Text(
                          module['count'],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                module['color'],
                          ),
                        ),

                        Text(
                          module['title'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // STAT CARD 
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}