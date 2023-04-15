import 'package:chatgpt_app/models/ModelsModel.dart';
import 'package:chatgpt_app/providers/models_provider.dart';
import 'package:chatgpt_app/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';

class ModelsDropDown extends StatefulWidget {
  const ModelsDropDown({super.key});

  @override
  State<ModelsDropDown> createState() => _ModelsDropDownState();
}

class _ModelsDropDownState extends State<ModelsDropDown> {
  String? currnetModel;
  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context, listen: false);
    currnetModel = modelsProvider.getCurrentModel;
    return FutureBuilder<List<ModelsModel>>(
        future: modelsProvider.getAllModels(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: TextWidget(label: snapshot.error.toString()));
          }
          return snapshot.data == null || snapshot.data!.isEmpty
              ? SizedBox.shrink()
              : FittedBox(
                  child: DropdownButton(
                      dropdownColor: scaffoldBackgroundColor,
                      iconEnabledColor: Colors.white,
                      value: currnetModel,
                      items: List<DropdownMenuItem<String>>.generate(
                          snapshot.data!.length,
                          (index) => DropdownMenuItem(
                              value: snapshot.data![index].id,
                              child: TextWidget(
                                label: snapshot.data![index].id,
                                fontSize: 15,
                              ))),
                      onChanged: ((value) {
                        setState(() {
                          currnetModel = value.toString();
                        });
                        modelsProvider.setCurrentModel(value.toString());
                      })),
                );
        });
  }
}
