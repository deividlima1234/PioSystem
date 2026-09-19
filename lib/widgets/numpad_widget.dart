import 'package:flutter/material.dart';

class NumPadWidget extends StatelessWidget {
  final Function(String) onNumberTap;
  final VoidCallback onDeleteTap;
  final VoidCallback onClearTap;

  const NumPadWidget({
    super.key,
    required this.onNumberTap,
    required this.onDeleteTap,
    required this.onClearTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('1', context),
              _buildNumberButton('2', context),
              _buildNumberButton('3', context),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('4', context),
              _buildNumberButton('5', context),
              _buildNumberButton('6', context),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('7', context),
              _buildNumberButton('8', context),
              _buildNumberButton('9', context),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(Icons.clear, onClearTap, context, color: Colors.redAccent),
              _buildNumberButton('0', context),
              _buildActionButton(Icons.backspace, onDeleteTap, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number, BuildContext context) {
    return InkWell(
      onTap: () => onNumberTap(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 2),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap, BuildContext context, {Color color = Colors.white54}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 32,
            color: color,
          ),
        ),
      ),
    );
  }
}
