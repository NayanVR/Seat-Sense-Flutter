import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:seat_sense_flutter/services/attendance_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final String eventId;

  const MarkAttendanceScreen({super.key, required this.eventId});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  File? _imageFile;
  bool _isLoading = false;
  final AttendanceService _attendanceService = AttendanceService();

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

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ShadToaster.of(context).show(
        const ShadToast(
          title: Text('Location services are disabled. Please enable them.'),
        ),
      );
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ShadToaster.of(context).show(
          const ShadToast(
            title: Text('Location permission denied. Please allow access.'),
          ),
        );
        return Future.error('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ShadToaster.of(context).show(
        const ShadToast(
          title: Text('Location permissions are permanently denied.'),
        ),
      );
      return Future.error('Location permissions are permanently denied');
    }

    try {
      // Get the current location
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          timeLimit: Duration(seconds: 5),
        ),
      );

      return position;
    } catch (e) {
      ShadToaster.of(
        context,
      ).show(ShadToast(title: Text('Error fetching location: $e')));
      return Future.error('Error fetching location: $e');
    }
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

  Future<void> _markAttendance() async {
    if (_imageFile == null) {
      ShadToaster.of(
        context,
      ).show(const ShadToast(title: Text('Please take a picture')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Try to get current location if not already available
    Position currentPosition = await _getCurrentLocation().catchError((error) {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to get location: $error');
    });

    try {
      final success = await _attendanceService.markAttendance(
        context: context,
        eventId: widget.eventId,
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        imagePath: _imageFile!.path,
      );

      if (success) {
        ShadToaster.of(
          context,
        ).show(const ShadToast(title: Text('Attendance marked successfully!')));
        Navigator.pop(context);
      } else {
        ShadToaster.of(
          context,
        ).show(const ShadToast(title: Text('Failed to mark attendance')));
      }
    } catch (e) {
      ShadToaster.of(context).show(ShadToast(title: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
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
                        _imageFile = null;
                      });
                    },
                    child: const Text('Retake'),
                  ),
                  ShadButton(
                    onPressed: _isLoading ? null : _markAttendance,
                    width: 150,
                    child:
                        _isLoading
                            ? SizedBox(
                              height: 20.0,
                              width: 20.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    ShadTheme.of(
                                      context,
                                    ).colorScheme.primaryForeground,
                              ),
                            )
                            : const Text('Mark Attendance'),
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
