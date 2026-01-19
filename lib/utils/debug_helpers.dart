/// Debug Helpers for Testing Scribe v2 Implementation
/// Add these functions to test each stage visually

import '../config/environment.dart';

/// STEP 1 TEST: Environment Configuration
void testStep1Environment() {
  print('\n╔════════════════════════════════════════╗');
  print('║  STEP 1: Environment Configuration    ║');
  print('╚════════════════════════════════════════╝\n');
  
  print('🔑 API Key Status:');
  final hasApiKey = Environment.elevenLabsApiKey.isNotEmpty;
  print(hasApiKey ? '   ✅ API Key loaded' : '   ❌ API Key missing');
  
  if (hasApiKey) {
    final keyPreview = Environment.elevenLabsApiKey.substring(0, 10);
    print('   📋 Preview: $keyPreview...');
    print('   📏 Length: ${Environment.elevenLabsApiKey.length} chars');
  }
  
  print('\n🌐 Endpoint Configuration:');
  final hasEndpoint = Environment.scribeEndpoint.isNotEmpty;
  print(hasEndpoint ? '   ✅ Endpoint configured' : '   ❌ Endpoint missing');
  print('   📋 URL: ${Environment.scribeEndpoint}');
  
  print('\n🎯 Overall Status:');
  if (hasApiKey && hasEndpoint) {
    print('   ✅ STEP 1 PASSED - Environment ready!');
  } else {
    print('   ❌ STEP 1 FAILED - Check .env file');
  }
  print('\n');
}

/// Print a visual separator for console logs
void printSeparator([String title = '']) {
  if (title.isNotEmpty) {
    print('\n┌─────────────────────────────────────────┐');
    print('│  $title');
    print('└─────────────────────────────────────────┘');
  } else {
    print('─' * 50);
  }
}

/// Print a success message
void printSuccess(String message) {
  print('✅ SUCCESS: $message');
}

/// Print an error message
void printError(String message) {
  print('❌ ERROR: $message');
}

/// Print an info message
void printInfo(String message) {
  print('ℹ️  INFO: $message');
}

/// Print a warning message
void printWarning(String message) {
  print('⚠️  WARNING: $message');
}

/// Test audio chunk simulation
void testAudioChunkLogging(int chunkSize) {
  print('🔊 Audio Chunk Test:');
  print('   Size: $chunkSize bytes');
  print('   Expected: 1600-6400 bytes');
  
  if (chunkSize >= 1600 && chunkSize <= 6400) {
    printSuccess('Chunk size is optimal');
  } else if (chunkSize < 1600) {
    printWarning('Chunk size too small - may cause latency');
  } else {
    printWarning('Chunk size too large - may cause delays');
  }
}

/// Print transcript update visualization
void visualizeTranscriptUpdate(String speaker, String text, int totalLength) {
  print('\n╭─────────────────────────────────────╮');
  print('│  TRANSCRIPT UPDATE                  │');
  print('├─────────────────────────────────────┤');
  print('│  Speaker: $speaker');
  print('│  Text: "$text"');
  print('│  Total Length: $totalLength chars');
  print('╰─────────────────────────────────────╯\n');
}

/// Print connection status
void visualizeConnectionStatus(bool isConnected, String? endpoint) {
  print('\n┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓');
  print('┃  WebSocket Connection Status      ┃');
  print('┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫');
  print(isConnected 
      ? '┃  ✅ Connected                     ┃'
      : '┃  ❌ Disconnected                  ┃');
  if (endpoint != null) {
    print('┃  📍 $endpoint');
  }
  print('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\n');
}

/// Create a visual test report
class TestReport {
  final List<String> passedTests = [];
  final List<String> failedTests = [];
  
  void addPass(String testName) {
    passedTests.add(testName);
  }
  
  void addFail(String testName, String reason) {
    failedTests.add('$testName: $reason');
  }
  
  void printReport() {
    print('\n╔════════════════════════════════════════╗');
    print('║        TEST REPORT SUMMARY             ║');
    print('╚════════════════════════════════════════╝\n');
    
    print('✅ PASSED: ${passedTests.length}');
    for (var test in passedTests) {
      print('   • $test');
    }
    
    print('\n❌ FAILED: ${failedTests.length}');
    for (var test in failedTests) {
      print('   • $test');
    }
    
    print('\n📊 TOTAL: ${passedTests.length + failedTests.length} tests');
    
    final successRate = passedTests.length / (passedTests.length + failedTests.length) * 100;
    print('📈 Success Rate: ${successRate.toStringAsFixed(1)}%\n');
    
    if (failedTests.isEmpty) {
      print('🎉 ALL TESTS PASSED! 🎉\n');
    } else {
      print('⚠️  Some tests failed. Check details above.\n');
    }
  }
}
