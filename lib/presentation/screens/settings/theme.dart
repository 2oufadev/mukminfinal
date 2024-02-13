import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  _ThemeScreenState createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  bool expanded = false;
  Map<String, dynamic>? userStateMap;

  @override
  Widget build(BuildContext context) {
    String theme = Provider.of<ThemeNotifier>(context).appTheme;
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(82, 82, 82, 1),
        appBar: AppBar(
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/theme/${theme ?? "default"}/appbar.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          title: Text("Tukar Tema"),
        ),
        body: SlidingUpPanel(
          minHeight: 64,
          maxHeight: 265,
          color: Colors.black.withOpacity(0.5),
          panel: BlocBuilder<UserStateCubit, UserState>(
            builder: (context, state) => bottomNavBarWithOpacity(
                context: context,
                loggedIn: state is LoginState
                    ? state.userStateMap!['loggedIn']
                    : false),
          ),
          body: ListView(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () async {
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .setTheme('default');
                      },
                      child: Ink.image(
                        fit: BoxFit.cover,
                        height: 100,
                        width: double.infinity,
                        image: AssetImage("assets/theme/default/appbar.png"),
                      ),
                    ),
                    if (theme == 'default') SelectedIcon(),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () async {
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .setTheme('purple');
                      },
                      child: Ink.image(
                        height: 100,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        image: AssetImage("assets/theme/purple/appbar.png"),
                      ),
                    ),
                    if (theme == 'purple') SelectedIcon(),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () async {
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .setTheme('biru');
                      },
                      child: Ink.image(
                        fit: BoxFit.cover,
                        height: 100,
                        width: double.infinity,
                        image: AssetImage("assets/theme/biru/appbar.png"),
                      ),
                    ),
                    if (theme == 'biru') SelectedIcon(),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () async {
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .setTheme('pink');
                      },
                      child: Ink.image(
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        image: AssetImage("assets/theme/pink/appbar.png"),
                      ),
                    ),
                    if (theme == 'pink') SelectedIcon(),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () async {
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .setTheme('orange');
                      },
                      child: Ink.image(
                        height: 100,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        image: AssetImage("assets/theme/orange/appbar.png"),
                      ),
                    ),
                    if (theme == 'orange') SelectedIcon(),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () async {
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .setTheme('yellow');
                      },
                      child: Ink.image(
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        image: AssetImage(
                          "assets/theme/yellow/appbar.png",
                        ),
                      ),
                    ),
                    if (theme == 'yellow') SelectedIcon(),
                  ],
                ),
              ),
              SizedBox(height: 200)
            ],
          ),
        ),
      ),
    );
  }
}

class SelectedIcon extends StatelessWidget {
  const SelectedIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: SizedBox(width: 1)),
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
