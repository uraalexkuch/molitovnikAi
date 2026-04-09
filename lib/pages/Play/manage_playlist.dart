import 'package:flutter/material.dart';
import 'package:molitovnik/pages/Data/dummy_data.dart';
import 'package:molitovnik/pages/Data/widgets/audio_item.dart';



class ManagePlaylist extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        left: true,
        top: true,
        right: true,
        bottom: true,
        child:
            GridView(
      padding: const EdgeInsets.all(15),
      gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 1.6,
      ),
      children: DUMMY_AUDIO
          .map((catData) =>
          Container(
              child: AudioItem(catData.id, catData.imgPath, catData.name)))
          .toList(),
    )

      );
        }

  }

