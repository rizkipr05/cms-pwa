import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_service.dart';
import '../../core/theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  bool _isCheckingSession = true;
  bool _isLoadingUsers = true;
  List<dynamic> _users = [];
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _validateSession();
    _searchController.addListener(() {
      setState(() => _searchTerm = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _validateSession() async {
    try {
      final profile = await _apiService.getProfile();
      if (profile['role'] != 'admin') {
        await _apiService.logout();
        if (mounted) context.go('/admin-login');
        return;
      }
      await _loadUsers();
    } on SessionExpiredException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.danger),
      );
      context.go('/admin-login');
      return;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingSession = false);
      }
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      final users = await _apiService.getUsers();
      if (mounted) {
        setState(() => _users = users);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingUsers = false);
      }
    }
  }

  Future<void> _logout() async {
    await _apiService.logout();
    if (mounted) context.go('/admin-login');
  }

  Future<void> _openUserForm({Map<String, dynamic>? user}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: user?['name']?.toString() ?? '',
    );
    final emailController = TextEditingController(
      text: user?['email']?.toString() ?? '',
    );
    final passwordController = TextEditingController();
    final departmentController = TextEditingController(
      text: user?['department']?.toString() ?? '',
    );
    final positionController = TextEditingController(
      text: user?['position']?.toString() ?? '',
    );
    final addressController = TextEditingController(
      text: user?['address']?.toString() ?? '',
    );
    String selectedRole = user?['role']?.toString() ?? 'user';
    bool isSubmitting = false;
    final isEditing = user != null;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              if (!formKey.currentState!.validate()) return;

              setDialogState(() => isSubmitting = true);
              final payload = <String, dynamic>{
                'name': nameController.text.trim(),
                'email': emailController.text.trim(),
                'role': selectedRole,
                'department': departmentController.text.trim(),
                'position': positionController.text.trim(),
                'address': addressController.text.trim(),
              };

              if (passwordController.text.isNotEmpty) {
                payload['password'] = passwordController.text;
              }

              try {
                final userId = int.tryParse(user?['id']?.toString() ?? '');
                if (isEditing) {
                  if (userId == null) {
                    throw Exception('ID user tidak valid');
                  }
                  await _apiService.updateUser(userId, payload);
                } else {
                  payload['password'] = passwordController.text;
                  await _apiService.createUser(payload);
                }

                if (!mounted || !dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? 'User berhasil diperbarui'
                          : 'User berhasil ditambahkan',
                    ),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
                await _loadUsers();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppTheme.danger,
                    ),
                  );
                }
              } finally {
                if (dialogContext.mounted) {
                  setDialogState(() => isSubmitting = false);
                }
              }
            }

            return AlertDialog(
              backgroundColor: AppTheme.surfaceStrong,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(isEditing ? 'Edit User' : 'Tambah User'),
              content: SizedBox(
                width: 520,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Nama'),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Nama wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Email wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: isEditing
                                ? 'Password Baru (opsional)'
                                : 'Password',
                          ),
                          validator: (value) {
                            if (!isEditing &&
                                (value == null || value.isEmpty)) {
                              return 'Password wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: selectedRole,
                          decoration: const InputDecoration(labelText: 'Role'),
                          items: const [
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text('admin'),
                            ),
                            DropdownMenuItem(
                              value: 'user',
                              child: Text('user'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => selectedRole = value);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: departmentController,
                          decoration: const InputDecoration(
                            labelText: 'Departemen',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: positionController,
                          decoration: const InputDecoration(
                            labelText: 'Jabatan',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: addressController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Alamat',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : submit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEditing ? 'Simpan' : 'Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceStrong,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Hapus User'),
          content: Text(
            'Hapus user ${user['name']}? Tindakan ini tidak bisa dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final userId = int.tryParse(user['id']?.toString() ?? '');
      if (userId == null) {
        throw Exception('ID user tidak valid');
      }
      await _apiService.deleteUser(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User berhasil dihapus'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      await _loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  List<dynamic> get _filteredUsers {
    if (_searchTerm.isEmpty) return _users;
    return _users.where((user) {
      final name = (user['name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      final position = (user['position'] ?? '').toString().toLowerCase();
      return name.contains(_searchTerm) ||
          email.contains(_searchTerm) ||
          position.contains(_searchTerm);
    }).toList();
  }

  Color _roleColor(String role) =>
      role == 'admin' ? AppTheme.primaryPurple : AppTheme.primaryGreen;

  String _initialFor(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }

  Widget _buildRoleChip(String role) {
    final color = _roleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildUserTable() {
    if (_isLoadingUsers) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final users = _filteredUsers;
    if (users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            'Tidak ada user yang cocok.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 980),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'KARYAWAN',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'EMAIL',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'JABATAN',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'ROLE',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'AKSI',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...users.map((user) {
              final name = (user['name'] ?? '-').toString();
              final email = (user['email'] ?? '-').toString();
              final role = (user['role'] ?? 'user').toString();
              final position = (user['position'] ?? '').toString();

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppTheme.primaryPurple.withValues(
                              alpha: 0.16,
                            ),
                            child: Text(
                              _initialFor(name),
                              style: const TextStyle(
                                color: AppTheme.lightPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        email,
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        position.isEmpty ? '—' : position,
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                    ),
                    Expanded(flex: 2, child: _buildRoleChip(role)),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 8,
                          children: [
                            TextButton(
                              onPressed: () => _openUserForm(
                                user: Map<String, dynamic>.from(user),
                              ),
                              child: const Text('Edit'),
                            ),
                            TextButton(
                              onPressed: () => _confirmDelete(
                                Map<String, dynamic>.from(user),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.danger,
                              ),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return Scaffold(
        body: Container(
          decoration: AppTheme.pageBackground,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final filteredUsers = _filteredUsers;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: AppTheme.pageBackground,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manajemen User',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Kelola data karyawan dan hak akses sistem.',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isLoadingUsers ? null : _loadUsers,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Refresh'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _openUserForm(),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Tambah User'),
                        ),
                        IconButton(
                          onPressed: _logout,
                          tooltip: 'Logout',
                          icon: const Icon(Icons.logout_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.panelDecoration(radius: 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Daftar Karyawan',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${filteredUsers.length} karyawan terdaftar',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 280,
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Cari nama atau email...',
                                  prefixIcon: Icon(Icons.search_rounded),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Expanded(child: _buildUserTable()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
