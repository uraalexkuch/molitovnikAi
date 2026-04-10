import 'package:flutter/material.dart';
import 'package:molitovnik/pages/Play/player.dart';




class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  const SafeArea(
              left: true,
              top: true,
              right: true,
              bottom: true,
              child: Center(
                child: Player(),
              )
          );
        }
 }
