import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'ابحث في كل شيء...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: const Center(
        child: Text('🔍 اكتب للبحث'),
      ),
    );
  }
}
