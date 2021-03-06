import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:seasoncalendar/l10n/app_localizations.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:seasoncalendar/theme/themes.dart';
import 'package:seasoncalendar/models/food.dart';
import 'package:seasoncalendar/helpers/text_selector.dart';

class FoodDetailsDialog extends StatelessWidget {
  final String _foodDisplayName;
  final Image _foodImage;
  final String _foodInfoURL;
  final List<List<String>> _allAvailabilities;

  FoodDetailsDialog(String foodDisplayName, String foodInfoURL, Image foodImage,
      List<List<String>> allAvailabilities)
      : _foodDisplayName = foodDisplayName,
        _foodImage = foodImage,
        _foodInfoURL = foodInfoURL,
        _allAvailabilities = allAvailabilities;

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    var availabilities = Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [for (var i = 0; i < 4; i += 1) getAvailabilityInfoCard(context, i)],
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [for (var i = 4; i < 8; i += 1) getAvailabilityInfoCard(context, i)],
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 8; i < 12; i += 1) getAvailabilityInfoCard(context, i)
          ],
        ),
      ],
    );

    var imgAndAvailabilities;

    if (isPortrait) {
      imgAndAvailabilities = Column(
        children: <Widget>[_foodImage, SizedBox(height: 10), availabilities],
      );
    } else {
      imgAndAvailabilities = Row(
        children: <Widget>[
          Expanded(
            flex: 41,
            child: _foodImage,
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 100,
            child: availabilities,
          )
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Text(
            _foodDisplayName,
            textAlign: TextAlign.center,
            style: defaultTheme.textTheme.headline5,
          ),
          SizedBox(height: 10),
          imgAndAvailabilities,
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                child: Text(AppLocalizations.of(context).back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              RaisedButton(
                child: Text(AppLocalizations.of(context).wikipedia),
                onPressed: () async {
                  final url = _foodInfoURL;
                  if (await canLaunch(url)) {
                    await launch(
                      url,
                      forceSafariVC: false,
                    );
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget getAvailabilityInfoCard(BuildContext context, int monthIndex) {
    Widget containerChild;

    if (_allAvailabilities[monthIndex].length == 1) {
      containerChild = Icon(
          availabilityModeIcons[_allAvailabilities[monthIndex][0]],
          color: Colors.black.withAlpha(180));
    } else {
      containerChild = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(availabilityModeIcons[_allAvailabilities[monthIndex][0]],
              color: Colors.black.withAlpha(180)),
          Text(" / "),
          Icon(availabilityModeIcons[_allAvailabilities[monthIndex][1]],
              color: Colors.black.withAlpha(110)),
        ],
      );
    }

    return Expanded(
      flex: 1,
      child: Container(
        child: Card(
            elevation: 1,
            color: availabilityModeColor[_allAvailabilities[monthIndex][0]],
            child: Container(
              padding: const EdgeInsets.all(2),
              child: Column(
                children: <Widget>[
                  Text(getMonthNameFromIndex(context, monthIndex).substring(0, 3),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  FittedBox(
                    fit: BoxFit.contain,
                    child: containerChild,
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
