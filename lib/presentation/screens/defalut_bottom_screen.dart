import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/bottom_bar/cubit.dart';
import 'package:mukim_app/business_logic/cubit/bottom_bar/states.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Default extends StatefulWidget {
  String screenTitle = '';
  Default(this.screenTitle);

  @override
  _DefaultState createState() => _DefaultState();
}

class _DefaultState extends State<Default> {
  Map<String, dynamic>? userStateMap;
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    return SafeArea(
      top: false,
      child: BlocConsumer<MukminCubit, MukminStates>(
        listener: (context, state) {},
        builder: (BuildContext context, state) {
          MukminCubit cubit = MukminCubit.getCubitObj(context);
          double width = MediaQuery.of(context).size.width;

          return OrientationBuilder(
            builder: (context, orientation) => Scaffold(
              extendBodyBehindAppBar: true,
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
                body: CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      floating: false,
                      expandedHeight: width * 0.267,
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(30.0),
                        child: Text(''),
                      ),
                      flexibleSpace: Stack(
                        alignment: Alignment.centerRight,
                        children: <Widget>[
                          Container(
                            width: width,
                            height: width * 0.267,
                            child: FlexibleSpaceBar(
                              background: FutureBuilder<SharedPreferences>(
                                future: SharedPreferences.getInstance(),
                                builder: (context, snapshot) {
                                  String? theme;
                                  if (snapshot.hasData) {
                                    theme =
                                        snapshot.data!.getString('appTheme');
                                  }
                                  return Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          "assets/theme/${theme ?? "default"}/appbar.png",
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 35.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 5.0,
                                  ),
                                  child: Text(
                                    '${widget.screenTitle}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      backgroundColor: Colors.transparent,
                      leading: Icon(null),
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
