import 'package:attendance_app/data/model/site.dart';
import 'package:attendance_app/data/repo/site_repo.dart';
import 'package:attendance_app/ui/drawer/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditSiteScreen extends StatefulWidget {
  const EditSiteScreen({super.key, required this.id});
  final String id;

  @override
  State<EditSiteScreen> createState() => _EditSiteScreenState();
}

class _EditSiteScreenState extends State<EditSiteScreen> {
  final repo = SiteRepo();
  final _siteNameController = TextEditingController();
  final _LatController = TextEditingController();
  final _LongController = TextEditingController();
  final _distFromSiteController = TextEditingController();

  late Site? site;

  String? _siteNameError;
  String? _LatError;
  String? _LongError;
  String? _distFromSiteError;

  double? latitude;
  double? longitude;
  int? distance;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() async{
    site = await repo.getSiteById(
      widget.id,
    ); //widget is the object of EditTodoScreen
    _siteNameController.text = site?.sitename ?? "";
    _LatController.text = site?.latitude.toString() ?? "";
    _LongController.text = site?.longitude.toString() ?? "";
    _distFromSiteController.text = site?.distanceFromSite.toString() ?? "";
  }

  void _updateSite() async {
    setState(() {
      _siteNameError = null;
      _LatError = null;
      _LongError = null;
      _distFromSiteError = null;
    });

    if (_siteNameController.text.isEmpty) {
      setState(() {
        _siteNameError = "Site Name cannot be empty";
      });
      return;
    }

    if (_LatController.text.isEmpty) {
      setState(() {
        _LatError = "Latitude cannot be empty";
      });
      return;
    }

    if (_LongController.text.isEmpty) {
      setState(() {
        _LongError = "Longitude cannot be empty";
      });
      return;
    }

    if (_distFromSiteController.text.isEmpty) {
      setState(() {
        _distFromSiteError = "Distance from Site cannot be empty";
      });
      return;
    }

    try {
      latitude = double.parse(_LatController.text);
    } catch (e) {
      setState(() => _LatError = "Invalid latitude format");
      return;
    }

    try {
      longitude = double.parse(_LongController.text);
    } catch (e) {
      setState(() => _LongError = "Invalid longitude format");
      return;
    }

    try {
      distance = int.parse(_distFromSiteController.text);
    } catch (e) {
      setState(() => _distFromSiteError = "Invalid distance format");
      return;
    }

    await repo.updateSite(
      site!.copy(
        sitename: _siteNameController.text,
        latitude: latitude!,
        longitude: longitude!,
        distanceFromSite: distance!,
      ),
    );
    if (!mounted) return;
    context.pop(true);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Sites',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // automaticallyImplyLeading: false,
        backgroundColor: Colors.greenAccent,
        elevation: 0,
        actions: [
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _siteNameController,
                onChanged:
                    (_) => setState(() {
                      _siteNameError = null;
                    }),
                decoration: InputDecoration(
                  labelText: "Enter Site Name",
                  border: OutlineInputBorder(),
                  errorText: _siteNameError,
                ),
              ),
              SizedBox(height: 16.0),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _LatController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Latitude ex. 1.12345",
                        border: OutlineInputBorder(),
                        errorText: _LatError,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0), // spacing between fields
                  Expanded(
                    child: TextField(
                      controller: _LongController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Longitude ex. 1.12345",
                        border: OutlineInputBorder(),
                        errorText: _LongError,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.0),

              TextField(
                controller: _distFromSiteController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Enter distance from site in meters",
                  border: OutlineInputBorder(),
                  errorText: _distFromSiteError,
                ),
              ),
              SizedBox(height: 16.0),

              FilledButton(
                onPressed:_updateSite,
                style: ButtonStyle(backgroundColor: WidgetStateColor.resolveWith((states)=>Colors.greenAccent)),
                child: Text("Update Site"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}