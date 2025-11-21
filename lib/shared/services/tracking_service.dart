import 'dart:developer';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';

/// Service to handle App Tracking Transparency (ATT) for iOS
/// and advertising ID permissions
class TrackingService {
  static TrackingService? _instance;
  static TrackingService get instance => _instance ??= TrackingService._();

  TrackingService._();

  /// Request tracking authorization (iOS only)
  /// Returns the authorization status
  Future<TrackingStatus> requestTrackingAuthorization() async {
    try {
      // Only request on iOS
      if (!Platform.isIOS) {
        log(
          'Tracking authorization is iOS-only, skipping on ${Platform.operatingSystem}',
        );
        return TrackingStatus.notSupported;
      }

      // Get current status
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      log('Current tracking status: $status');

      // If not determined, request authorization
      if (status == TrackingStatus.notDetermined) {
        log('Requesting tracking authorization...');
        final newStatus =
            await AppTrackingTransparency.requestTrackingAuthorization();
        log('New tracking status: $newStatus');
        return newStatus;
      }

      return status;
    } catch (e) {
      log('Error requesting tracking authorization: $e');
      return TrackingStatus.notSupported;
    }
  }

  /// Get the current tracking authorization status
  Future<TrackingStatus> getTrackingStatus() async {
    try {
      if (!Platform.isIOS) {
        return TrackingStatus.notSupported;
      }

      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      return status;
    } catch (e) {
      log('Error getting tracking status: $e');
      return TrackingStatus.notSupported;
    }
  }

  /// Get the advertising identifier (IDFA on iOS, AAID on Android)
  Future<String?> getAdvertisingIdentifier() async {
    try {
      final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
      log('Advertising Identifier: $uuid');
      return uuid;
    } catch (e) {
      log('Error getting advertising identifier: $e');
      return null;
    }
  }

  /// Check if user has authorized tracking
  Future<bool> isTrackingAuthorized() async {
    try {
      if (!Platform.isIOS) {
        // On Android, tracking is generally allowed
        return true;
      }

      final status = await getTrackingStatus();
      return status == TrackingStatus.authorized;
    } catch (e) {
      log('Error checking tracking authorization: $e');
      return false;
    }
  }

  /// Initialize tracking service
  /// Should be called after app launch
  Future<void> initialize() async {
    try {
      log('Initializing Tracking Service...');

      // Wait a bit for the app to fully load
      await Future.delayed(const Duration(seconds: 1));

      // Request authorization
      final status = await requestTrackingAuthorization();

      // Log the result
      switch (status) {
        case TrackingStatus.authorized:
          log('✅ Tracking authorized - personalized ads enabled');
          break;
        case TrackingStatus.denied:
          log('❌ Tracking denied - only contextual ads will be shown');
          break;
        case TrackingStatus.restricted:
          log('⚠️ Tracking restricted - device settings prevent tracking');
          break;
        case TrackingStatus.notDetermined:
          log('❓ Tracking not determined - user hasn\'t responded yet');
          break;
        case TrackingStatus.notSupported:
          log('ℹ️ Tracking not supported on this platform');
          break;
      }

      // Get advertising ID if authorized
      if (status == TrackingStatus.authorized || !Platform.isIOS) {
        await getAdvertisingIdentifier();
      }
    } catch (e) {
      log('Error initializing tracking service: $e');
    }
  }
}
