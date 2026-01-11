import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'security_cubit.dart';
import 'security_lock_screen.dart';

class SecurityGate extends StatefulWidget {
  const SecurityGate({super.key, required this.child});

  final Widget child;

  @override
  State<SecurityGate> createState() => _SecurityGateState();
}

class _SecurityGateState extends State<SecurityGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) {
      return;
    }
    if (state == AppLifecycleState.resumed) {
      context.read<SecurityCubit>().refreshSession();
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      context.read<SecurityCubit>().lockIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SecurityCubit, SecurityState>(
      builder: (context, state) {
        final showLock = state.requiresAuth && !state.isUnlocked;
        return Stack(
          children: [
            widget.child,
            if (showLock) const Positioned.fill(child: SecurityLockScreen()),
          ],
        );
      },
    );
  }
}
