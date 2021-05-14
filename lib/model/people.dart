import 'package:flutter/material.dart';

class People {
  final String id;
  final String picture;
  final Map<String, dynamic> name;
  final String email;
  final Map<String, dynamic> location;

  People({
    @required this.id,
    this.picture,
    this.name,
    this.email,
    this.location,
  });
}
