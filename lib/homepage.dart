import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seasoncalendar/helpers/styles.dart';
import 'food.dart';
import 'favoritefoods.dart';
import 'foodsview.dart';
import 'foodsearch.dart';
import 'settings.dart';
import 'routes.dart';

class HomeState extends State<HomePage> {

  List<Food> _foods = List<Food>();
  bool _favoritesSelected = false;
  int _monthIndex = DateTime.now().toLocal().month - 1;

  @override
  void initState() {
    super.initState();
    //favorites.init();
    setState(() {
      _monthIndex = _monthIndex;
      _favoritesSelected = _favoritesSelected;
      _foods = _getFilteredAndSortedFoods(widget._favoriteFoodNames, widget._settings);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(icon: Icon(_favoritesSelected ? Icons.star : Icons.star_border), onPressed: () {_toggleFavoritesSelected();}),
          IconButton(icon: Icon(Icons.settings), onPressed: _showSettings),
          IconButton(icon: Icon(Icons.search), onPressed: () {showSearch(context: context, delegate: FoodSearch(widget._allFoods, _monthIndex));}),
          FlatButton(
              child: Text(widget._hpText['imprintPageButtonText'], style: const TextStyle(color: Colors.white),),
              onPressed: () {Navigator.of(context).pushNamed("/imprint");}
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: _chooseEtcPage,
            itemBuilder: (context) {
              return etcPages.keys.map((String page) {
                return PopupMenuItem<String>(
                  value: page,
                  child: Text(page)
                );
              }).toList();
            },
          ),
        ],
      ),
      body: foodsView(_foods, _monthIndex),
      bottomNavigationBar: Container(
        color: Colors.black12,
        child: ListTile(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {_shiftMonth(-1);},
          ),
          title: Text(widget._hpText['monthToString'][_monthIndex], textAlign: TextAlign.center, style: font20b,),
          trailing: IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {_shiftMonth(1);},
          ),
        ),
      )
    );
  }

  _shiftMonth(int value) {
    setState(() {
      _monthIndex = (_monthIndex + value) % 12;
    });
    _filterAndSortFoodsAsync();
  }

  void _toggleFavoritesSelected() async{
    setState(() {_favoritesSelected = !_favoritesSelected;});
    _filterAndSortFoodsAsync();
  }

  _filterAndSortFoodsAsync() async {
    final favoriteFoodNames = await getFavoriteFoods();
    Map<String, dynamic> settings = await SettingsPageState.getSettings();
    setState(() {
      _foods = _getFilteredAndSortedFoods(favoriteFoodNames, settings);
    });
  }

  List<Food> _getFilteredAndSortedFoods(List<String> favoriteFoodNames, Map<String, dynamic> settings) {

    List<Food> filteredFoods = widget._allFoods;
    if (_favoritesSelected) {
      filteredFoods = getFoodsFromFoodNames(favoriteFoodNames, widget._allFoods);
    }

    filteredFoods = filteredFoods.where((food) => [for (String av in food.getAvailabilityModes(_monthIndex)) availabilityModeValues[av]]
        .reduce(max) >= settings['foodMinAvailability']).toList();
    if (settings['foodSorting'] == true) {
      filteredFoods.sort((a, b) => [for (String av in b.getAvailabilityModes(_monthIndex)) availabilityModeValues[av]]
          .reduce(max).compareTo([for (String av in a.getAvailabilityModes(_monthIndex)) availabilityModeValues[av]]
          .reduce(max)));
    }
    return filteredFoods;
  }

  void _showSettings() {
    Navigator.of(context).pushNamed("/settings")
        .then((_) => _filterAndSortFoodsAsync());
  }

  void _chooseEtcPage(String pageRoute) {
    Navigator.of(context).pushNamed(etcPages[pageRoute]);
  }
}

class HomePage extends StatefulWidget {

  final List<String> _favoriteFoodNames;
  final Map<String, dynamic> _settings;
  final Map<String, dynamic> _hpText;
  final List<Food> _allFoods;

  HomePage(List<String> favoriteFoodNames, Map<String, dynamic> settings,
      Map<String, dynamic> homepageText, List<Food> allFoods,) :
    _favoriteFoodNames = favoriteFoodNames,
    _settings = settings,
    _hpText = homepageText,
    _allFoods = allFoods;

  @override
  HomeState createState() => HomeState();
}