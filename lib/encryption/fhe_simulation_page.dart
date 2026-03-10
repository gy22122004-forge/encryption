import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/glass_container.dart';

class FheSimulationPage extends StatefulWidget {
  const FheSimulationPage({super.key});

  @override
  State<FheSimulationPage> createState() => _FheSimulationPageState();
}

class _FheSimulationPageState extends State<FheSimulationPage> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  
  // Data State
  bool _keysGenerated = false;
  int _plainA = 5;
  int _plainB = 10;
  
  String _encodedA = "";
  String _encodedB = "";
  
  String _cipherA = "";
  String _cipherB = "";
  
  String _cipherResult = "";
  int _decryptedResult = 0;
  
  double _noiseLevel = 0.0;
  bool _isOptimized = false;
  String _operation = "Addition (+)";

  // Animation controller
  late AnimationController _animController;
  
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // --- Core Functions (Simulating FHE Principles) ---

  void _generateKeys() async {
    _startLoading('Generating FHE Keys (Public, Secret, Eval)...');
    await Future.delayed(Duration(milliseconds: _isOptimized ? 500 : 1500));
    
    setState(() {
      _keysGenerated = true;
      _currentStep = 1;
      _stopLoading();
    });
  }

  void _encodeAndEncrypt() async {
    _startLoading('Encoding data to polynomials & encrypting with noise...');
    await Future.delayed(Duration(milliseconds: _isOptimized ? 500 : 1500));
    
    setState(() {
      // 2. Efficient Data Encoding (simulating integer to polynomial ring format)
      _encodedA = "P(x)=${_plainA}x^0";
      _encodedB = "P(x)=${_plainB}x^0";
      
      // 3. Encryption Algorithm (simulating ciphertext space)
      final rand = Random();
      _cipherA = "ct_A[${rand.nextInt(9000) + 1000}, ${rand.nextInt(9000) + 1000}]";
      _cipherB = "ct_B[${rand.nextInt(9000) + 1000}, ${rand.nextInt(9000) + 1000}]";
      
      // 6. Initial noise from encryption
      _noiseLevel = 0.15; 
      
      _currentStep = 2;
      _stopLoading();
    });
  }

  void _evaluateHomomorphically() async {
    _startLoading('Evaluating computation directly on ciphertexts...');
    await Future.delayed(Duration(milliseconds: _isOptimized ? 800 : 2500));
    
    setState(() {
      final rand = Random();
      // 4 & 5. Homomorphic Evaluation & Arbitrary Computations
      _cipherResult = "ct_RES[${rand.nextInt(90000) + 10000}, ${rand.nextInt(90000) + 10000}]";
      
      // Noise growth during operations
      if (_operation.contains("+")) {
        _noiseLevel = (_noiseLevel + 0.2).clamp(0.0, 1.0);
      } else { // Multiplication causes huge noise growth
        _noiseLevel = (_noiseLevel + 0.6).clamp(0.0, 1.0);
      }
      
      _currentStep = 3;
      _stopLoading();
    });
  }

  void _bootstrap() async {
    _startLoading('Bootstrapping to reduce noise (refreshing ciphertext)...');
    await Future.delayed(Duration(milliseconds: _isOptimized ? 1000 : 3000));
    
    setState(() {
      // 6. Noise Management
      _noiseLevel = 0.1; // Reduced to baseline
      final rand = Random();
      _cipherResult = "ct_RES_boot[${rand.nextInt(9000) + 1000}, ${rand.nextInt(9000) + 1000}]";
      _stopLoading();
    });
  }

  void _decrypt() async {
    if (_noiseLevel > 0.85) {
      _showError("Decryption failed! Noise level is too high. Please Bootstrap the ciphertext first.");
      return;
    }

    _startLoading('Decrypting & proving correctness...');
    await Future.delayed(Duration(milliseconds: _isOptimized ? 500 : 1500));
    
    setState(() {
      // 8 & 9. Decryption Algorithm & Correctness Guarantee
      if (_operation.contains("+")) {
        _decryptedResult = _plainA + _plainB;
      } else {
        _decryptedResult = _plainA * _plainB;
      }
      _currentStep = 4;
      _stopLoading();
    });
  }

  // --- UI Helpers ---

  bool _isProcessing = false;
  String _processMessage = "";

  void _startLoading(String msg) {
    setState(() {
      _isProcessing = true;
      _processMessage = msg;
    });
    _animController.repeat();
  }

  void _stopLoading() {
    setState(() {
      _isProcessing = false;
    });
    _animController.stop();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red.shade800,
      content: Text(msg, style: const TextStyle(color: Colors.white)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/data_cloud_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          const TopNavBar(isLogin: false),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Advanced Mathematical Security (FHE Simulator)',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Interact with the 10 core principles of Fully Homomorphic Encryption.',
                    style: TextStyle(fontSize: 16, color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 20),
                  
                  // Optimizations Toggle (Point 10)
                  GlassContainer(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('10. Performance Optimizations', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                              Text('Enable SIMD Vectorization / RNS Speedup', style: TextStyle(fontSize: 12, color: AppColors.primaryDark)),
                            ],
                          ),
                          Switch(
                            activeColor: AppColors.primaryDark,
                            value: _isOptimized,
                            onChanged: (val) {
                              setState(() => _isOptimized = val);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(val ? "Optimizations Enabled! Algorithms will run 3x faster." : "Optimizations Disabled."),
                                duration: const Duration(seconds: 1),
                              ));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Main Content Area
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Interactive Steps
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            child: Stepper(
                              currentStep: _currentStep,
                              controlsBuilder: (context, details) => const SizedBox.shrink(),
                              steps: [
                                _buildStep1_KeyGen(),
                                _buildStep2_Encode_Encrypt(),
                                _buildStep3_Evaluate(),
                                _buildStep4_Decrypt(),
                                _buildStep5_Correctness(),
                              ],
                            ),
                          ),
                        ),
                        
                        // Right Column: Noise Meter & Processing Overlay (Point 6 & 7)
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              // Noise Management Widget
                              GlassContainer(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.waves, color: AppColors.primaryDark, size: 40),
                                      const SizedBox(height: 10),
                                      const Text('6. Noise Management', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 18)),
                                      const SizedBox(height: 5),
                                      const Text('Ciphertext noise grows with operations.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.primaryDark, fontSize: 12)),
                                      const SizedBox(height: 20),
                                      
                                      // Custom Noise Gauge
                                      Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Container(
                                            height: 150,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withValues(alpha: 0.3),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            height: 150 * _noiseLevel,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [
                                                  Colors.green,
                                                  _noiseLevel > 0.5 ? Colors.orange : Colors.green,
                                                  _noiseLevel > 0.8 ? Colors.red : (_noiseLevel > 0.5 ? Colors.orange : Colors.green),
                                                ]
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text('${(_noiseLevel * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: _noiseLevel > 0.8 ? Colors.red : AppColors.primaryDark, fontSize: 24)),
                                      const SizedBox(height: 15),
                                      
                                      // Bootstrapping Button
                                      ElevatedButton.icon(
                                        onPressed: (_currentStep == 3 && _noiseLevel > 0.1 && !_isProcessing) ? _bootstrap : null,
                                        icon: const Icon(Icons.refresh, color: AppColors.white, size: 16),
                                        label: const Text('Bootstrap', style: TextStyle(color: AppColors.white)),
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Processing Overlay
                              if (_isProcessing)
                                GlassContainer(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        RotationTransition(
                                          turns: _animController,
                                          child: const Icon(Icons.settings, size: 50, color: AppColors.primaryDark),
                                        ),
                                        const SizedBox(height: 15),
                                        Text(_processMessage, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                                        const SizedBox(height: 10),
                                        const LinearProgressIndicator(color: AppColors.primaryDark, backgroundColor: Colors.transparent),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Back Button
          Positioned(
            bottom: 20,
            left: 20,
            child: GlassContainer(
               child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Stepper UI Components ---

  Step _buildStep1_KeyGen() {
    return Step(
      title: const Text('1 & 7. Key Generation & Math Security', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      isActive: _currentStep >= 0,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Generates Ring-LWE keys. Mathematical security relies on the hardness of the Learning With Errors problem.', style: TextStyle(color: AppColors.primaryDark)),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: !_keysGenerated && !_isProcessing ? _generateKeys : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
            child: const Text('Generate Keys (pk, sk, evk)', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Step _buildStep2_Encode_Encrypt() {
    return Step(
      title: const Text('2 & 3. Encoding & Encryption', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      isActive: _currentStep >= 1,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Data A: '),
              SizedBox(width: 50, child: TextField(keyboardType: TextInputType.number, onChanged: (v) => _plainA = int.tryParse(v) ?? 0, decoration: InputDecoration(hintText: '$_plainA'))),
              const SizedBox(width: 20),
              const Text('Data B: '),
              SizedBox(width: 50, child: TextField(keyboardType: TextInputType.number, onChanged: (v) => _plainB = int.tryParse(v) ?? 0, decoration: InputDecoration(hintText: '$_plainB'))),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: (_currentStep == 1 && !_isProcessing) ? _encodeAndEncrypt : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
            child: const Text('Encode & Encrypt Data', style: TextStyle(color: AppColors.white)),
          ),
          if (_cipherA.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Encoded A: $_encodedA  ➔  $_cipherA', style: const TextStyle(fontFamily: 'monospace', color: Colors.blueGrey, fontSize: 12)),
            Text('Encoded B: $_encodedB  ➔  $_cipherB', style: const TextStyle(fontFamily: 'monospace', color: Colors.blueGrey, fontSize: 12)),
          ]
        ],
      ),
    );
  }

  Step _buildStep3_Evaluate() {
    return Step(
      title: const Text('4 & 5. Homomorphic Evaluation & Arbitrary Computing', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      isActive: _currentStep >= 2,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select an operation to perform entirely on encrypted space.', style: TextStyle(color: AppColors.primaryDark)),
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: _operation,
            items: ["Addition (+)", "Multiplication (*)"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _operation = v!),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: (_currentStep == 2 && !_isProcessing) ? _evaluateHomomorphically : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
            child: const Text('Evaluate Computations', style: TextStyle(color: AppColors.white)),
          ),
          if (_cipherResult.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Ciphertext Result:', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            Text('ct_RES = Eval($_operation, $_cipherA, $_cipherB) = $_cipherResult', style: const TextStyle(fontFamily: 'monospace', color: Colors.deepPurple, fontSize: 12)),
            if (_noiseLevel > 0.8) const Text('⚠️ Warning: Noise Level Critical. Bootstrap required before decryption.', style: TextStyle(color: Colors.red, fontSize: 12)),
          ]
        ],
      ),
    );
  }

  Step _buildStep4_Decrypt() {
    return Step(
      title: const Text('8. Decryption Algorithm', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      isActive: _currentStep >= 3,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           ElevatedButton(
            onPressed: (_currentStep == 3 && !_isProcessing) ? _decrypt : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
            child: const Text('Decrypt Ciphertext Result', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Step _buildStep5_Correctness() {
    return Step(
      title: const Text('9. Correctness Guarantee', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
      state: StepState.indexed,
      isActive: _currentStep >= 4,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentStep == 4) ...[
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha:0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✅ Decryption Successful', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  Text('Decoded Result: $_decryptedResult', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Mathematical Proof:', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Dec(Eval($_operation, Enc($_plainA), Enc($_plainB))) \n== $_plainA ${_operation.contains("+") ? "+" : "*"} $_plainB \n== $_decryptedResult', style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.blueGrey)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentStep = 0;
                  _keysGenerated = false;
                  _cipherA = ""; _cipherB = ""; _cipherResult = "";
                  _noiseLevel = 0.0;
                });
              },
              child: const Text('Restart Sim', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
            )
          ] else const Text('Awaiting decryption completion...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
