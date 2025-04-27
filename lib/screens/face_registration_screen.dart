import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img; // Add this import
import 'package:seat_sense_flutter/screens/home_screen.dart'; // Import HomeScreen
import 'package:seat_sense_flutter/services/auth_service.dart';
import 'package:seat_sense_flutter/widgets/circular_button_loading.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FaceRegistrationScreen extends StatefulWidget {
  const FaceRegistrationScreen({super.key});

  @override
  State<FaceRegistrationScreen> createState() => _FaceRegistrationState();
}

class _FaceRegistrationState extends State<FaceRegistrationScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  File? _imageFile;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    CameraDescription? frontCamera;

    for (var camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        frontCamera = camera;
        break;
      }
    }

    if (frontCamera == null) {
      // Handle the case where no front camera is available
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(const ShadToast(title: Text('No front camera available')));
      }
      return; // Or choose a default camera if you prefer
    }

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium, // Adjust resolution as needed
    );

    _initializeControllerFuture = _cameraController!.initialize();

    setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      final image = await _cameraController!.takePicture();

      if (!mounted) return;

      // Load the captured image
      final originalImage = img.decodeImage(
        await File(image.path).readAsBytes(),
      );

      if (originalImage != null) {
        // Flip the image horizontally (mirror it)
        final mirroredImage = img.flipHorizontal(originalImage);

        // Save the mirrored image back to a file
        final mirroredImageFile = File(image.path)
          ..writeAsBytesSync(img.encodeJpg(mirroredImage));

        setState(() {
          _imageFile = mirroredImageFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast(title: Text('Error taking picture: $e')));
      }
    }
  }

  Future<void> _uploadImage(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    if (_imageFile == null) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(const ShadToast(title: Text('No image selected')));
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final success = await _authService.registerFace(
        context,
        _imageFile!.path,
      );
      if (success) {
        // Fetch user profile after successful login
        final user = await _authService.getStoredProfile();
        setState(() {
          _isLoading = false;
        });
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
          );
        } else {
          // Handle the case where the profile fetch fails
          if (mounted) {
            ShadToaster.of(context).show(
              const ShadToast(title: Text('Failed to fetch user profile')),
            );
          }
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast(title: Text('Error uploading image: $e')));
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Registration')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias, // Important for proper clipping
              child:
                  _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : _cameraController != null
                      ? FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(
                                pi,
                              ), // Mirror the front camera
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: ClipRect(
                                  child: OverflowBox(
                                    alignment: Alignment.center,
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: SizedBox(
                                        width: 280,
                                        height:
                                            _cameraController!
                                                .value
                                                .aspectRatio *
                                            280,
                                        child: Center(
                                          child: CameraPreview(
                                            _cameraController!,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Otherwise, display a loading indicator.
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      )
                      : const Icon(
                        Icons.camera_alt,
                        size: 80,
                        color: Colors.grey,
                      ),
            ),
            const SizedBox(height: 20),
            if (_imageFile == null) ...[
              ShadButton.outline(
                onPressed: _takePicture,
                child: const Text('Take Picture'),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShadButton.outline(
                    onPressed: () {
                      setState(() {
                        _imageFile =
                            null; // Reset the image file to retake the picture
                      });
                    },
                    child: const Text('Retake'),
                  ),
                  ShadButton(
                    onPressed: _isLoading ? null : () => _uploadImage(context),
                    width: 140,
                    child:
                        _isLoading
                            ? CircularButtonLoading()
                            : const Text('Register Face'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
