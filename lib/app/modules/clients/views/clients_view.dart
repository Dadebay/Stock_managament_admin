import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/clients_controller.dart';

class ClientsView extends GetView<ClientsController> {
  const ClientsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClientsView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ClientsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
