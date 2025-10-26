import 'package:financy_control/router.dart';
import 'package:flutter/material.dart';
import 'package:financy_control/features/profile/profile_view_model.dart';
import 'package:go_router/go_router.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileViewModel _viewModel = ProfileViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.fetchUserProfile();
    _viewModel.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: _viewModel.photoUrl.isNotEmpty
                ? NetworkImage(_viewModel.photoUrl)
                : null,
            child: _viewModel.photoUrl.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            _viewModel.name.isNotEmpty ? _viewModel.name : 'Loading...',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            _viewModel.email.isNotEmpty ? _viewModel.email : 'Loading...',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Change Name'),
            onTap: () async {
              final newName = await _showInputDialog(context, 'Change Name');
              if (newName != null && newName.isNotEmpty) {
                final success = await _viewModel.updateUserName(newName);
                if (success) {
                  setState(() {});
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () async {
              final newPassword = await _showInputDialog(
                context,
                'Change Password',
              );
              if (newPassword != null && newPassword.isNotEmpty) {
                await _viewModel.updateUserPassword(newPassword);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final result = await _viewModel.logout();
              if (result && context.mounted) {
                context.go(Screen.root.location);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<String?> _showInputDialog(BuildContext context, String title) async {
    String input = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            onChanged: (value) {
              input = value;
            },
            decoration: const InputDecoration(hintText: 'Enter here'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(input),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
