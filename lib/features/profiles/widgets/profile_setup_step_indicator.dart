import 'package:flutter/material.dart';

class ProfileSetupStepIndicator extends StatelessWidget {
  final int step;

  const ProfileSetupStepIndicator({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step $step of 2',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 1; index <= 2; index++)
            Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                index == step ? Icons.circle : Icons.circle_outlined,
                size: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
