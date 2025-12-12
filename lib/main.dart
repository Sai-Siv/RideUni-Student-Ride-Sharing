import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'entry_page.dart';
import 'package:mappls_gl/mappls_gl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  const mapSdkKey = String.fromEnvironment('MAPPLS_MAP_SDK_KEY');
  const restApiKey = String.fromEnvironment('MAPPLS_REST_API_KEY');
  const atlasClientId = String.fromEnvironment('MAPPLS_ATLAS_CLIENT_ID');
  const atlasClientSecret = String.fromEnvironment('MAPPLS_ATLAS_CLIENT_SECRET');
  MapplsAccountManager.setMapSDKKey(mapSdkKey);
  MapplsAccountManager.setRestAPIKey(restApiKey);
  MapplsAccountManager.setAtlasClientId(atlasClientId);
  MapplsAccountManager.setAtlasClientSecret(atlasClientSecret);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EntryPage(),
    );
  }
}
