import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mukim_app/resources/global.dart';

class DialogChangeMaximumNumber extends StatefulWidget {
  Function(int)? maximumCount;
  String? selectedValue;
  int? count;

  DialogChangeMaximumNumber(
      {this.count, this.maximumCount, this.selectedValue});

  @override
  _DialogChangeMaximumNumberState createState() =>
      _DialogChangeMaximumNumberState();
}

class _DialogChangeMaximumNumberState extends State<DialogChangeMaximumNumber> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = "${widget.count}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        gradient: _getSelectedGradient(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Change maximum count",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 20),
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: "",
                hintText: "Enter Maximum number",
              ),
            ),
          ),
          InkWell(
            onTap: () {
              if (_controller.text.isEmpty) {
                return;
              }
              int number = 0;
              try {
                number = int.parse(_controller.text);
              } catch (e) {
                number = 100;
              }
              if (number < 10) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Enter minimum 10")));
                return;
              }

              if (number > 1000) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Enter Maximum 1000")));
                return;
              }
              if (widget.maximumCount != null) widget.maximumCount!(number);
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                "Change",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Gradient _getSelectedGradient() {
    if (widget.selectedValue == "Design 4") {
      return Globals.selectedGradient1!;
    } else if (widget.selectedValue == "Design 2") {
      return Globals.selectedGradient2!;
    } else if (widget.selectedValue == "Design 3") {
      return Globals.selectedGradient3!;
    } else if (widget.selectedValue == "Design 1") {
      return Globals.selectedGradient4!;
    } else {
      return Globals.selectedGradient1!;
    }
  }
}
