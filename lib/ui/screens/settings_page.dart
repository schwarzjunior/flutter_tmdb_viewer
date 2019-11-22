import 'package:flutter/material.dart';
import 'package:flutter_dynamic_theme_mode/flutter_dynamic_theme_mode.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeController = DynamicThemeController();

    Future<bool> _onWillPop() async {
      return themeController.reloadThemeMode().then((hasReloaded) async {
        if (hasReloaded) await Future.delayed(const Duration(milliseconds: 500));
        return true;
      });
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SwitchListTile(
                title: const Text('Use dark mode'),
                value: themeController.data.mode == ThemeMode.dark,
                onChanged: (_) {
                  themeController.toggleMode();
                },
              ),
              Align(
                alignment: const Alignment(1, 0),
                child: RaisedButton(
                  child: const Text('Save settings'),
                  onPressed: () {
                    themeController.saveThemeMode();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
