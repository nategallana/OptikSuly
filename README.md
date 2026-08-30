# OptikSulyApp

OptikSulyApp is a Flutter-based mobile application designed to support comprehensive dry eye disease (DED) screening. It brings subjective symptom assessment and objective eye measurements into one guided workflow that can be used in clinical, community, and outreach settings.

The application is written in Dart and is intended to run primarily on Android and iOS devices. Its interface guides an examiner through patient registration, a dry-eye questionnaire, blink-rate analysis, tear break-up time measurement, tear meniscus height measurement, and a combined assessment summary.

> **Project status:** The application currently contains a complete interactive front-end prototype. Camera analysis and local database integration will be implemented in the next development phase. Current camera views and measurement results use simulated data for interface testing.

## Assessment workflow

1. **Patient profile** — Records the patient's name, age, gender, and optional clinical notes.
2. **OSDI questionnaire** — Presents 10 editable default questions divided into Sections A, B, and C. Questions are shown one at a time rather than in a scrolling survey.
3. **Blink-rate analysis** — Provides a 60-second test interface designed for automatic blink counting with the front camera, facial landmark detection, eye landmark tracking, and a blink-detection algorithm.
4. **Tear Break-Up Time (TBUT)** — Provides real-time measurement screens for three trials per eye. The planned implementation will use rear-camera frame processing, eye-region isolation, color thresholding, and pixel-area analysis.
5. **Tear Meniscus Height (TMH)** — Includes camera calibration and an on-screen digital caliper for measuring tear meniscus height. The planned backend will convert calibrated pixel distances into millimeters.
6. **Assessment results** — Combines the questionnaire score, blink rate, TBUT values, and TMH measurements into one patient summary.

## Planned local storage

Assessment information will be stored locally using SQLite. The application will automatically create and manage its database on the device. Planned stored data includes:

- Patient demographic information and clinical notes
- Questionnaire answers and calculated score
- Detected blink count and blink rate
- Three TBUT trials for the left and right eyes
- Left-eye and right-eye tear meniscus measurements
- Final assessment result and completion date

No cloud service is currently required. The planned local-first design keeps assessment data on the device unless an export or synchronization feature is added later.

## Technology

- Flutter
- Dart
- Material 3 interface components
- Phone camera APIs *(planned)*
- Facial landmark and eye landmark detection *(planned)*
- Real-time image and video-frame processing *(planned)*
- SQLite local database *(planned)*

## Running the project

Make sure Flutter is installed and a supported device, emulator, or browser is available. From the project directory, run:

```sh
flutter pub get
flutter run
```

Flutter will ask you to select a target device if more than one is available.

## Testing

Run the automated Flutter tests with:

```sh
flutter test
```

## Important notice

OptikSulyApp is being developed as a screening and clinical-support tool. Its results should not be treated as a final medical diagnosis and should not replace evaluation by a qualified eye-care professional.
