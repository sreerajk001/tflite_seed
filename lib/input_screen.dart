import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tflite_model.dart';

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nController = TextEditingController();
  final TextEditingController pController = TextEditingController();
  final TextEditingController kController = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController phController = TextEditingController();
  final TextEditingController humidityController = TextEditingController();
  final TextEditingController rainfallController = TextEditingController();

  String _predictionResult = "";

  @override
  void initState() {
    super.initState();
    // Load the model when the screen is initialized
    final model = Provider.of<TFLiteModel>(context, listen: false);
    model.loadModel();
  }

  void _predictCrop() async {
    final model = Provider.of<TFLiteModel>(context, listen: false);

    // Check if the model is loaded
    if (!model.isModelLoaded) {
      setState(() {
        _predictionResult = "Model is loading. Please wait...";
      });
      return;
    }

    if (_formKey.currentState!.validate()) {
      List<double> inputValues = [
        double.parse(nController.text),
        double.parse(pController.text),
        double.parse(kController.text),
        double.parse(tempController.text),
        double.parse(phController.text),
        double.parse(humidityController.text),
        double.parse(rainfallController.text),
      ];

      try {
        List<Map<String, dynamic>> predictions = await model.predict(inputValues);

        setState(() {
          _predictionResult = "Top 3 Crops:\n";
          predictions.asMap().forEach((index, prediction) {
            double confidence = double.tryParse(prediction['confidence'].toString()) ?? 0.0; // ✅ Convert to double safely
            int confidencePercentage = (confidence * 100).toInt(); // ✅ Convert to whole number percentage
            _predictionResult += "${index + 1}. ${prediction['crop']}: $confidencePercentage%\n";
          });
        });
      } catch (e) {
        print("Error during prediction: $e");
      }


    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crop Prediction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(nController, 'Nitrogen (N)'),
              _buildTextField(pController, 'Phosphorus (P)'),
              _buildTextField(kController, 'Potassium (K)'),
              _buildTextField(tempController, 'Temperature'),
              _buildTextField(phController, 'pH Level'),
              _buildTextField(humidityController, 'Humidity'),
              _buildTextField(rainfallController, 'Rainfall'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _predictCrop,
                child: Text('Predict'),
              ),
              SizedBox(height: 20),
              Text(_predictionResult, style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
    );
  }
}
