import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _country = '';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().register(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          country: _country,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
        if (state.firebaseUser != null && !state.loading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created, please login.')),
          );
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Create Account')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (v) => Validators.requiredField(v, label: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Country'),
                      items: const [
                        DropdownMenuItem(value: 'USA', child: Text('USA')),
                        DropdownMenuItem(value: 'UK', child: Text('UK')),
                        DropdownMenuItem(value: 'Canada', child: Text('Canada')),
                        DropdownMenuItem(value: 'Saudi Arabia', child: Text('Saudi Arabia')),
                        DropdownMenuItem(value: 'UAE', child: Text('UAE')),
                        DropdownMenuItem(value: 'Jordan', child: Text('Jordan')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => _country = v ?? ''),
                      validator: (v) => (v == null || v.isEmpty) ? 'Select a country' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: state.loading ? null : _submit,
                      child: state.loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Register'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}



