import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';


class AudioPage extends StatefulWidget {
   final String ip,lang;
  const AudioPage({Key? key,required this.ip,required this.lang}) : super(key: key);

  @override
  _AudioPageState createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _filePath;
  double _currentPosition = 0;
  double _totalDuration = 0;

  @override
  void dispose() {
    _audioPlayer.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
  final PermissionStatus status = await Permission.microphone.request();
  
  if (status != PermissionStatus.granted) {
    // Permission not granted
    return;
  }

  final directory = await getApplicationDocumentsDirectory();
  String fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
  _filePath = '${directory.path}/$fileName';

  const config = RecordConfig(
    encoder: AudioEncoder.aacLc,
    sampleRate: 44100,
    bitRate: 128000,
  );

  await _recorder.start(config, path: _filePath!);
  setState(() {
    _isRecording = true;
  });
}

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    print("Recorded path");
    print(path);
    setState(() {
      _isRecording = false;
    });
    if (path != null) {
      
      await _sendAudioToBackend(path);
    }
  }

  Future<void> _sendAudioToBackend(String filePath) async {
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(filePath, filename: 'recording.m4a'),
  });

  try {
    final response = await Dio().post(
      'http://${widget.ip}:5000/upload',
      data: formData,
      options: Options(
        responseType: ResponseType.stream,
      ),
    );

    if (response.statusCode == 200) {
      // Convert the response stream to bytes
      final bytes = await _streamToBytes(response.data.stream);

      // Save the received audio file
      final receivedAudioPath = await _saveReceivedAudio(bytes);
      
      // Save the received audio file
      // Play the received audio
      print("received_path");
      print(receivedAudioPath);
      await _playAudio(receivedAudioPath);
    } else {
      print('Failed to post data');
    }
  } catch (e) {
    print("audio error");
    print(e);
  }
}

Future<Uint8List> _streamToBytes(Stream<List<int>> stream) async {
  final bytes = <int>[];
  await for (final chunk in stream) {
    bytes.addAll(chunk);
  }
  return Uint8List.fromList(bytes);
}

Future<String> _saveReceivedAudio(List<int> audioData) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/received_audio.m4a';
  final file = File(filePath);
  await file.writeAsBytes(audioData);
  return filePath;
}

      

  Future<void> _playAudio(String filePath) async {
    await _audioPlayer.setFilePath(filePath);
    _totalDuration = _audioPlayer.duration?.inSeconds.toDouble() ?? 0;
    _audioPlayer.play();
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPosition = position.inSeconds.toDouble();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friday'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 100,
              color: _isRecording ? Colors.red : Colors.blue,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRecording ? null : _startRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Record'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isRecording ? _stopRecording : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Stop'),
                ),
              ],
            ),
           
            Slider(
              value: _currentPosition,
              max: _totalDuration,
              onChanged: (value) {
                setState(() {
                  _currentPosition = value;
                });
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
