import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:neumorphic_example/utils/size_config.dart';
import 'package:neumorphic_example/utils/ui_data.dart';
import 'package:neumorphic/neumorphic.dart';

/// this screen is a copy from
/// https://github.com/Tomison-E/neuomorphic_container/blob/master/example/lib/neuomorphism.dart
/// OLUWATOMISIN ESAN (https://github.com/Tomison-E) is its copyright holder
class Neumorphism extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final container = PageView.builder(
      controller: PageController(viewportFraction: 0.85, initialPage: 2),
      itemBuilder: (_, i) => Neumorphic(
        bevel: 12,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  '   ${UIData.bankName}',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Image.asset('assets/images/chip.png'),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            ),
            Row(
              children: <Widget>[
                Text(
                  '      5303   6084\n      2402   3649',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.start,
            ),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            Expanded(
              child: Image.asset(
                'assets/images/ce.png',
                fit: BoxFit.cover,
                width: SizeConfig.blockSizeHorizontal * 40,
                height: SizeConfig.blockSizeVertical * 40,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      '   ESAN \n   TOMISIN      \n',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '09/24    \n',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        width: MediaQuery.of(context).size.width * 0.53,
        height: SizeConfig.blockSizeVertical * 37,
        margin: EdgeInsets.all(20),
        decoration: NeumorphicDecoration(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
    );
    return Scaffold(
      // backgroundColor: Colors.grey[400],
      body: Column(
        children: <Widget>[
          Flexible(
            child: SizedBox(height: SizeConfig.blockSizeVertical * 2.5),
            flex: 1,
          ),
          Flexible(
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 30.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.blueGrey[100],
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(209, 205, 199, 1.0),
                                    blurRadius: 16.0,
                                  ),
                                ],
                                border: Border.all(
                                    color: Color.fromRGBO(239, 238, 238, 1.0))),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Icon(
                                    Icons.keyboard_backspace,
                                    color: Colors.blueGrey[500],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(239, 238, 238, 1.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Icon(
                                      Icons.apps,
                                      size: 30.0,
                                      color: Colors.blueGrey[200],
                                    ),
                                  ),
                                  margin: EdgeInsets.only(left: 10.0),
                                )
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Text(
                            UIData.statistic,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Neumorphic(
                      child: Row(
                        children: <Widget>[
                          Text(
                            '${UIData.period}:',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            UIData.last30Days,
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10.0),
                          NeumorphicButton(
                            padding: EdgeInsets.all(3.0),
                            child: Icon(
                              Icons.navigate_next,
                              color: Colors.blueGrey,
                              size: 30.0,
                            ),
                            shape: BoxShape.circle,
                            onPressed: () {},
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                      ),
                      margin: EdgeInsets.all(20.0),
                      height: SizeConfig.blockSizeVertical * 6.12,
                      decoration: NeumorphicDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            flex: 2,
          ),
          Flexible(child: container, flex: 5),
          Flexible(
              child: Neumorphic(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: Color.fromRGBO(209, 205, 199, 1.0),
                      width: 2.0,
                    ),
                  ),
                  width: SizeConfig.blockSizeHorizontal * 80,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.account_balance, color: Colors.blueGrey),
                          Text(
                            '25%',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: <Widget>[
                          Text(
                            UIData.bankName,
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₦ 950,000',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                ),
                height: 100.0,
                decoration: NeumorphicDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                      color: Color.fromRGBO(239, 238, 238, 1.0), width: 3.0),
                ),
              ),
              flex: 2),
          Flexible(
            child: Padding(
              child: Row(
                children: [
                  NeumorphicButton(
                    // padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.account_balance,
                      color: Colors.blueGrey[300],
                      size: 30.0,
                    ),
                    onPressed: () {},
                  ),
                  NeumorphicButton(
                    // padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.home,
                      color: Colors.blueGrey[300],
                      size: 30.0,
                    ),
                    onPressed: () {},
                  ),
                  NeumorphicButton(
                    // padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.credit_card,
                      color: Colors.blueGrey[300],
                      size: 30.0,
                    ),
                    onPressed: () {},
                  ),
                  NeumorphicButton(
                    child: Icon(
                      Icons.settings,
                      color: Colors.blueGrey[300],
                      size: 30.0,
                    ),
                    onPressed: () {},
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
              padding: EdgeInsets.only(bottom: 5.0),
            ),
            flex: 1,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      ),
    );
  }
}
