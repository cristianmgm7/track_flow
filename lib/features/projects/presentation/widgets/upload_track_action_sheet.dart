import 'package:flutter/material.dart';

class UploadTrackOptionsSheet extends StatelessWidget {
  const UploadTrackOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select upload method',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.mic),
          title: const Text('Record Audio'),
          subtitle: const Text('Use voice recorder to add track'),
          onTap: () {
            Navigator.pop(context);
            // context.read<TrackBloc>().add(RecordNewTrack());
          },
        ),
        ListTile(
          leading: const Icon(Icons.file_upload),
          title: const Text('Select File'),
          subtitle: const Text('Choose audio file from your device'),
          onTap: () {
            Navigator.pop(context);
            // context.read<TrackBloc>().add(UploadTrackFromFile());
          },
        ),
      ],
    );
  }
}
