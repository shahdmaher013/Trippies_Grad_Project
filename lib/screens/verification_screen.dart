import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  XFile? _capturedImage;
  bool _isUploading = false;

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        _showError("No cameras available on this device.");
        return;
      }

      // Find front camera
      CameraDescription? frontCamera;
      for (var camera in _cameras!) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      // Fallback to first camera if no front camera is found
      final selectedCamera = frontCamera ?? _cameras!.first;

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      _showError("Failed to initialize camera: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    try {
      final image = await _controller!.takePicture();
      setState(() {
        _capturedImage = image;
      });
    } catch (e) {
      _showError("Failed to take picture: $e");
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
    });
  }

  Future<void> _submitPhoto() async {
    if (_capturedImage == null) return;

    final user = _authService.currentUser;
    if (user == null) {
      _showError("No user logged in.");
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final file = File(_capturedImage!.path);
      await _firestoreService.submitVerificationPhoto(user.uid, file);
      
      if (!mounted) return;
      _navigateToHome();
    } catch (e) {
      _showError("Failed to submit verification: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Identity Verification"),
        actions: [
          TextButton(
            onPressed: _navigateToHome,
            child: Text(
              "Skip",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Trippies is a Women-Only Community",
                style: AppTheme.headingSm,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "To ensure the safety of our community, please take a clear selfie to verify your identity. You won't be able to book trips until verified.",
                style: AppTheme.bodySm,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Camera / Preview Box
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    boxShadow: AppTheme.cardShadow,
                    border: Border.all(color: AppTheme.babyBlue, width: 3),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_capturedImage != null)
                        Image.file(
                          File(_capturedImage!.path),
                          fit: BoxFit.cover,
                        )
                      else if (_isCameraInitialized && _controller != null)
                        // This applies a scale transform to fix aspect ratio issues often seen in CameraPreview
                        ClipRect(
                          child: Transform.scale(
                            scale: _controller!.value.aspectRatio,
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: 1 / _controller!.value.aspectRatio,
                                child: CameraPreview(_controller!),
                              ),
                            ),
                          ),
                        )
                      else
                        const Center(
                          child: CircularProgressIndicator(color: AppTheme.babyBlue),
                        ),
                        
                      // Frame overlay for guidance
                      if (_capturedImage == null)
                        Center(
                          child: Container(
                            width: 250,
                            height: 320,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(150),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Actions
              if (_capturedImage == null)
                ElevatedButton.icon(
                  onPressed: _isCameraInitialized ? _capturePhoto : null,
                  style: AppTheme.primaryButton,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Take Selfie"),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: _isUploading ? null : _submitPhoto,
                      style: AppTheme.primaryButton,
                      child: _isUploading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppTheme.darkBlue,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Submit Verification"),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _isUploading ? null : _retakePhoto,
                      style: AppTheme.secondaryButton,
                      child: const Text("Retake Photo"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
