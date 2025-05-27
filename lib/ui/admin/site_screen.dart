import 'package:attendance_app/data/model/site.dart';
import 'package:attendance_app/data/repo/attendance_repo.dart';
import 'package:attendance_app/data/repo/auth_repo.dart';
import 'package:attendance_app/data/repo/site_repo.dart';
import 'package:attendance_app/nav/navigation.dart';
import 'package:attendance_app/ui/drawer/app_drawer.dart';
import 'package:attendance_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SiteScreen extends StatefulWidget {
  const SiteScreen({super.key});

  @override
  State<SiteScreen> createState() => _SiteScreenState();
}

class _SiteScreenState extends State<SiteScreen> {
  List<Site> _sites = [];

  final repo = SiteRepo();

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  Future<void> _loadSites() async {
    final sites = await repo.getAllSites();
    setState(() {
      _sites = sites;
    });
  }

  void _navigateToAddSite() async {
    final result = await context.pushNamed(Screen.addSite.name);

    if (result == true) {
      _loadSites(); // Reload the site list only if a new site was added
    }
  }

  void _navigateToEdit(Site site) async {
    final result = await context.pushNamed(
      Screen.updateSite.name,
      pathParameters: {"id": site.docId!},
    );

    if (result == true) {
      _loadSites(); // Reload after editing a site
    }
  }

  void _deleteSite(Site site) async {
    await repo.deleteSite(site.docId!);
    _loadSites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sites',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.greenAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SiteSearchDelegate(
                  _sites,
                  onClickItem: _navigateToEdit,
                  onClickDelete: _deleteSite,
                ),
              );
            },
          ),

          Builder(
            builder:
                (context) => IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.blueAccent),
                  ),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
          ),
        ],
      ),

      endDrawer: AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.lightGreenAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child:
                    _sites.isEmpty
                        ? Center(
                          child: Text(
                            "No sites found",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        )
                        : ListView.builder(
                          itemCount: _sites.length,
                          itemBuilder:
                              (context, index) => SiteItem(
                                site: _sites[index],
                                onClickItem: (site) => _navigateToEdit(site),
                                onClickDelete: (site) => _deleteSite(site),
                              ),
                        ),
              ),

              FloatingActionButton(
                onPressed: _navigateToAddSite,
                child: Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SiteSearchDelegate extends SearchDelegate {
  final List<Site> sites;
  final void Function(Site) onClickItem;
  final void Function(Site) onClickDelete;

  SiteSearchDelegate(
    this.sites, {
    required this.onClickItem,
    required this.onClickDelete,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredSites =
        sites
            .where(
              (site) =>
                  site.sitename.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    return SizedBox.expand(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.lightGreenAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filteredSites.length,
            itemBuilder:
                (context, index) => SiteItem(
                  site: filteredSites[index],
                  onClickItem: (site) {
                    close(context, null);
                    onClickItem(site);
                  },
                  onClickDelete: (site) {
                    close(context, null);
                    onClickDelete(site);
                  },
                ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList =
        sites
            .where(
              (site) =>
                  site.sitename.toLowerCase().startsWith(query.toLowerCase()),
            )
            .toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.greenAccent, Colors.lightGreenAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: suggestionList.length,
          itemBuilder:
              (context, index) => SiteItem(
                site: suggestionList[index],
                onClickItem: (site) {
                  close(context, null);
                  onClickItem(site);
                },
                onClickDelete: (site) {
                  close(context, null);
                  onClickDelete(site);
                },
              ),
        ),
      ),
    );
  }
}

class SiteItem extends StatelessWidget {
  SiteItem({
    super.key,
    required this.site,
    required this.onClickItem,
    required this.onClickDelete,
  });

  final Site site;
  final utils = Utils();
  final Function(Site) onClickItem;
  final Function(Site) onClickDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClickItem(site),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Site name with delete icon
              Row(
                children: [
                  Icon(Icons.place, color: Colors.indigo),
                  SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      site.sitename,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Tooltip(
                    message: 'Delete site',
                    child: GestureDetector(
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text("Confirm Deletion"),
                                content: Text(
                                  "Are you sure you want to delete this site?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: Text("Delete"),
                                  ),
                                ],
                              ),
                        );

                        if (confirmed == true) {
                          onClickDelete(site);
                        }
                      },
                      child: const Icon(Icons.delete, color: Colors.redAccent),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Icon(Icons.my_location, color: Colors.teal),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lat: ${site.latitude.toStringAsFixed(5)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Icon(Icons.explore, color: Colors.deepOrange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Long: ${site.longitude.toStringAsFixed(5)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.straighten, color: Colors.brown),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Allowed distance: ${site.distanceFromSite} meters',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
