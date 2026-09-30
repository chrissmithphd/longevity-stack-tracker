import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/forest_night_theme.dart';
import '../services/database_service.dart';
import '../services/sun_timing_service.dart';
import '../services/task_service.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  final DatabaseService _db = DatabaseService.instance;
  final SunTimingService _sunTiming = SunTimingService();

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  final TextEditingController _tzController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  SunTimes? _sunTimes;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    _tzController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      final settings = await _db.getAppSettings();
      final lat = settings['latitude'] as double?;
      final lon = settings['longitude'] as double?;
      final tz = settings['timezone_offset'] as double?;

      if (lat != null) _latController.text = lat.toString();
      if (lon != null) _lonController.text = lon.toString();
      if (tz != null) _tzController.text = tz.toString();

      if (lat != null && lon != null) {
        await _updateSunTimes();
      }
    } catch (e) {
      _errorMessage = 'Error loading location: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _detectLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them.';
          _isLoading = false;
        });
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permission permanently denied. Please enable in settings.';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();

      // Calculate timezone offset (hours from UTC)
      final now = DateTime.now();
      final offset = now.timeZoneOffset.inHours.toDouble();

      setState(() {
        _latController.text = position.latitude.toStringAsFixed(6);
        _lonController.text = position.longitude.toStringAsFixed(6);
        _tzController.text = offset.toStringAsFixed(1);
      });

      await _updateSunTimes();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error detecting location: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSunTimes() async {
    final lat = double.tryParse(_latController.text);
    final lon = double.tryParse(_lonController.text);
    final tz = double.tryParse(_tzController.text);

    if (lat == null || lon == null || tz == null) {
      setState(() => _sunTimes = null);
      return;
    }

    // Temporarily set location to calculate sun times
    await _db.setLocation(lat, lon, tz);
    final sunTimes = await _sunTiming.getSunTimes(DateTime.now());
    setState(() => _sunTimes = sunTimes);
  }

  Future<void> _saveLocation() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final lat = double.tryParse(_latController.text);
      final lon = double.tryParse(_lonController.text);
      final tz = double.tryParse(_tzController.text);

      if (lat == null || lon == null || tz == null) {
        setState(() {
          _errorMessage = 'Please enter valid numbers for all fields';
          _isSaving = false;
        });
        return;
      }

      // Validate ranges
      if (lat < -90 || lat > 90) {
        setState(() {
          _errorMessage = 'Latitude must be between -90 and 90';
          _isSaving = false;
        });
        return;
      }

      if (lon < -180 || lon > 180) {
        setState(() {
          _errorMessage = 'Longitude must be between -180 and 180';
          _isSaving = false;
        });
        return;
      }

      if (tz < -12 || tz > 14) {
        setState(() {
          _errorMessage = 'Timezone offset must be between -12 and +14';
          _isSaving = false;
        });
        return;
      }

      await _db.setLocation(lat, lon, tz);

      // Regenerate today's tasks with new sunrise/sunset times
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      await _db.deleteTasksForDate(todayDate);
      await TaskService().generateDailyTasks(todayDate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Location saved! Today\'s tasks regenerated with sunrise/sunset times.'),
            backgroundColor: ForestNightTheme.completed,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving location: $e';
      });
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Settings'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(ForestNightTheme.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info box
                  Container(
                    padding: const EdgeInsets.all(ForestNightTheme.space3),
                    decoration: BoxDecoration(
                      color: ForestNightTheme.active.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ForestNightTheme.radiusMedium),
                      border: Border.all(
                        color: ForestNightTheme.active.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20, color: ForestNightTheme.active),
                        const SizedBox(width: ForestNightTheme.space2),
                        Expanded(
                          child: Text(
                            'Location is used to adjust outdoor activity timing based on sunrise/sunset',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ForestNightTheme.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: ForestNightTheme.space4),

                  // Auto-detect button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _detectLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Auto-Detect Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ForestNightTheme.active,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(ForestNightTheme.space3),
                      ),
                    ),
                  ),

                  const SizedBox(height: ForestNightTheme.space4),

                  Text(
                    'Or enter manually:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: ForestNightTheme.secondaryText,
                    ),
                  ),

                  const SizedBox(height: ForestNightTheme.space3),

                  // Latitude field
                  TextField(
                    controller: _latController,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      hintText: 'e.g., 40.7128',
                      helperText: 'Range: -90 to +90',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _updateSunTimes(),
                  ),

                  const SizedBox(height: ForestNightTheme.space3),

                  // Longitude field
                  TextField(
                    controller: _lonController,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      hintText: 'e.g., -74.0060',
                      helperText: 'Range: -180 to +180',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _updateSunTimes(),
                  ),

                  const SizedBox(height: ForestNightTheme.space3),

                  // Timezone offset field
                  TextField(
                    controller: _tzController,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Timezone Offset (hours from UTC)',
                      hintText: 'e.g., -5.0',
                      helperText: 'Range: -12 to +14 (EST = -5, PST = -8)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _updateSunTimes(),
                  ),

                  const SizedBox(height: ForestNightTheme.space4),

                  // Sun times preview
                  if (_sunTimes != null) ...[
                    Container(
                      padding: const EdgeInsets.all(ForestNightTheme.space3),
                      decoration: BoxDecoration(
                        color: ForestNightTheme.secondaryBackground,
                        borderRadius: BorderRadius.circular(ForestNightTheme.radiusMedium),
                        border: Border.all(
                          color: ForestNightTheme.tertiaryBackground,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Sun Times:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: ForestNightTheme.space2),
                          Row(
                            children: [
                              const Text('🌅 Sunrise: ', style: TextStyle(fontSize: 16)),
                              Text(
                                _formatTime(_sunTimes!.sunrise),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: ForestNightTheme.space1),
                          Row(
                            children: [
                              const Text('🌇 Sunset: ', style: TextStyle(fontSize: 16)),
                              Text(
                                _formatTime(_sunTimes!.sunset),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: ForestNightTheme.space4),
                  ],

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(ForestNightTheme.space3),
                      decoration: BoxDecoration(
                        color: ForestNightTheme.skipped.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(ForestNightTheme.radiusMedium),
                        border: Border.all(
                          color: ForestNightTheme.skipped.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 20, color: ForestNightTheme.skipped),
                          const SizedBox(width: ForestNightTheme.space2),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: ForestNightTheme.skipped,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: ForestNightTheme.space4),
                  ],

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ForestNightTheme.completed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(ForestNightTheme.space3),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Save Location'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
