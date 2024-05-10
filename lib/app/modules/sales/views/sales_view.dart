import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/sales_controller.dart';

class SalesView extends GetView<SalesController> {
  const SalesView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SalesView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'SalesView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
