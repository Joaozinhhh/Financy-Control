import 'package:financy_control/core/components/buttons.dart';
import 'package:financy_control/core/components/constants.dart';
import 'package:financy_control/core/components/textfields.dart';
import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/features/profile/profile_view_model.dart';
import 'package:financy_control/locator.dart';
import 'package:financy_control/router.dart';
import 'package:financy_control/services/storage/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
        flexibleSpace: kFlexibleSpace,
        title: Text(context.translations.profileTitle),
        actions: [launchUrl('https://example.com')], // TODO: replace with actual URL
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                bottom: 24 + 8 + 24 + 8 + 128 / 4,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xff38b6ff),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                ),
              ),
              Align(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints.tight(
                          const Size.square(128),
                        ),
                        child: const FittedBox(
                          child: CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.person),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints.tightFor(height: 24),
                        child: Text(
                          _viewModel.name.isNotEmpty ? _viewModel.name : 'Loading...',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints.tightFor(height: 24),
                        child: Text(
                          _viewModel.email.isNotEmpty ? _viewModel.email : 'Loading...',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(context.translations.changeName),
            onTap: () async {
              final newName = await _showInputBottomSheet(
                context,
                title: context.translations.changeName,
                hint: context.translations.enterNewName,
              );
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
            title: Text(context.translations.changePassword),
            onTap: () async {
              final newPassword = await _showInputBottomSheet(
                context,
                title: context.translations.changePassword,
                hint: context.translations.enterNewPassword,
                obscureText: true,
              );
              if (newPassword != null && newPassword.isNotEmpty) {
                await _viewModel.updateUserPassword(newPassword);
              }
            },
          ),
          // access reports
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: Text(context.translations.accessReports),
            onTap: () async {
              context.go(Screen.reports.location);
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(context.translations.logout),
            onTap: () async {
              final result = await _viewModel.logout();
              if (result != null && context.mounted) {
                context.go(result.location);
              }
            },
          ),
          if (kDebugMode)
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FCButton.danger(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(context.translations.confirmDeletion),
                          content: Text(
                            context.translations.confirmDeletionBody,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(false),
                              child: Text(context.translations.cancel),
                            ),
                            TextButton(
                              onPressed: () => context.pop(true),
                              child: Text(context.translations.delete),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirmed == true) {
                      if (await locator<StorageService>().clearAll() && context.mounted) {
                        context.go(Screen.signIn.location);
                      }
                    }
                  },
                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                    minimumSize: WidgetStateProperty.all<Size>(
                      const Size(128, 32),
                    ),
                  ),
                  child: Text(context.translations.deleteData),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<String?> _showInputBottomSheet(
    BuildContext context, {
    required String title,
    required String hint,
    bool obscureText = false,
  }) async {
    String input = '';
    bool isObscured = obscureText;
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return FCTextField(
                    onChanged: (value) => input = value,
                    decoration: const InputDecoration().copyWith(
                      hintText: hint,
                      suffixIcon: switch (obscureText) {
                        true => IconButton(
                          icon: Icon(
                            isObscured ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => isObscured = !isObscured),
                        ),
                        false => null,
                      },
                    ),
                    obscureText: isObscured,
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FCButton.terciary(
                    style: Theme.of(context).textButtonTheme.style?.copyWith(
                      minimumSize: WidgetStateProperty.all<Size>(
                        const Size(110, 50),
                      ),
                    ),
                    onPressed: () => context.pop(),
                    child: Text(context.translations.cancel),
                  ),
                  const SizedBox(width: 8),
                  FCButton.primary(
                    style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                      minimumSize: WidgetStateProperty.all<Size>(
                        const Size(110, 50),
                      ),
                    ),
                    onPressed: () => context.pop(input),
                    child: Text(context.translations.save),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
