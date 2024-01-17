# This workflow uses actions that are not certified by GitHub.
# They are provided by a third-party and are governed by
# separate terms of service, privacy policy, and support
# documentation.

name: Lint and test for dev-new-battle-input branch

on:
  push:
    branches: [ "dev-new-battle-input" ]
  pull_request:
    branches: [ "dev-new-battle-input" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.5'
          channel: 'stable'
      - run: flutter --version
      - name: Install packages
        run: |
          cd poke_reco
          flutter pub get
      - name: Prepare AdHelper
        run: |
          
      - name: Linter
        run: echo -e "::add-mask::${{ secrets.AD_HELPER }}" >> poke_reco/lib/ad_helper.dart
          flutter analyze
      - name: Test
        run: |
          cd poke_reco
          flutter test

      # Note: This workflow uses the latest stable version of the Dart SDK.
      # You can specify other versions if desired, see documentation here:
      # https://github.com/dart-lang/setup-dart/blob/main/README.md
      # - uses: dart-lang/setup-dart@v1
#      - uses: dart-lang/setup-dart@9a04e6d73cca37bd455e0608d7e5092f881fd603
#
#      - name: Install dependencies
#        run: dart pub get
#
      # Uncomment this step to verify the use of 'dart format' on each commit.
      # - name: Verify formatting
      #   run: dart format --output=none --set-exit-if-changed .
#
      # Consider passing '--fatal-infos' for slightly stricter analysis.
#      - name: Analyze project source
#        run: dart analyze
#
      # Your project will need to have tests in test/ and a dependency on
      # package:test for this step to succeed. Note that Flutter projects will
      # want to change this to 'flutter test'.
#      - name: Run tests
#        run: dart test
