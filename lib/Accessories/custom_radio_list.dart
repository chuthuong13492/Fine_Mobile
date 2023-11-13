import 'package:fine/ViewModel/partyOrder_viewModel.dart';
import 'package:fine/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';

class RadioList extends StatefulWidget {
  final bool? isRemove;
  const RadioList({super.key, required this.isRemove});

  @override
  State<RadioList> createState() => _RadioListState();
}

class _RadioListState extends State<RadioList> {
  String? id;
  int _selectedUserIndex = -1;
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: Get.find<PartyOrderViewModel>(),
        child: ScopedModelDescendant<PartyOrderViewModel>(
          builder: (context, child, model) {
            List<Widget> listWidget = [];
            for (var i = 0; i < model.listCustomer!.length; i++) {
              listWidget.add(Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Radio(
                    value: i,
                    groupValue: _selectedUserIndex,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        _selectedUserIndex = value as int;
                        id = model.listCustomer![i]!.id;
                      });
                      // print(value);
                      print(id);
                    },
                  ),
                  Center(
                    child: Text(
                      model.listCustomer![i]!.name!,
                      style: FineTheme.typograhpy.subtitle1,
                    ),
                  ),
                ],
              ));
            }
            return Column(
              children: [
                ...listWidget.toList(),
                // Container(
                //   width: Get.width,
                //   height: 200,
                //   child: ListView.builder(
                //     itemCount: model.listCustomer!.length,
                //     itemBuilder: (BuildContext context, int index) {
                //       return ListTile(
                //         // onTap: () {
                //         //   setState(() {
                //         //     _selectedUserIndex = -1;
                //         //     _selectedUserIndex = _selectedUserIndex++;
                //         //     id = model.listCustomer![index]!.id;
                //         //   });
                //         //   print(id);
                //         //   print(_selectedUserIndex);
                //         // },
                //         leading: Radio(
                //           value: index,
                //           groupValue: _selectedUserIndex,
                //           activeColor: Colors.green,
                //           onChanged: (value) {
                //             setState(() {
                //               _selectedUserIndex = value as int;
                //               id = model.listCustomer![index]!.id;
                //             });
                //             // print(value);
                //             print(id);
                //           },
                //         ),
                //         title: Text(model.listCustomer![index]!.name!),
                //         // trailing: widget.userList[index].isSelected
                //         //     ? Icon(Icons.check_circle, color: Colors.green)
                //         //     : null,
                //       );
                //     },
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: InkWell(
                    onTap: () async {
                      if (id != null) {
                        if (widget.isRemove == false) {
                          await Get.find<PartyOrderViewModel>()
                              .cancelCoOrder(false, id: id);
                          id = null;
                        } else {
                          await Get.find<PartyOrderViewModel>()
                              .removeMember(id: id);
                          id = null;
                        }
                      }
                    },
                    child: Container(
                      height: 55,
                      width: Get.width,
                      decoration: BoxDecoration(
                        color: FineTheme.palettes.primary100,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Chọn",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            color: FineTheme.palettes.shades100,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ));
  }
}
