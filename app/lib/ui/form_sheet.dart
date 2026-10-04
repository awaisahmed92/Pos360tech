import 'dart:math' as math;

import 'package:flutter/material.dart';

const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF64748B);
const _line = Color(0xFFD7DEE3);

Future<bool?> showFormSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<Widget> fields,
  required String saveLabel,
  required String cancelLabel,
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: const Color(0x73101A1F),
    builder: (context) {
      final size = MediaQuery.sizeOf(context);
      final width = math.min(980.0, size.width - 28);
      final height = math.min(760.0, size.height - 28);
      return Dialog(
        insetPadding: const EdgeInsets.all(14),
        backgroundColor: Colors.white,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 12, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _ink)),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(subtitle, style: const TextStyle(color: _muted, height: 1.35)),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: _line),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: fieldGrid(fields),
                ),
              ),
              const Divider(height: 1, color: _line),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(cancelLabel),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(saveLabel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget fieldGrid(List<Widget> fields) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 680 ? 2 : 1;
      if (columns == 1) {
        return Column(
          children: [
            for (final field in fields) Padding(padding: const EdgeInsets.only(bottom: 16), child: field),
          ],
        );
      }
      final rows = <Widget>[];
      for (var i = 0; i < fields.length; i += 2) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: fields[i]),
                const SizedBox(width: 16),
                Expanded(child: i + 1 < fields.length ? fields[i + 1] : const SizedBox.shrink()),
              ],
            ),
          ),
        );
      }
      return Column(children: rows);
    },
  );
}

Widget labeledField(
  String label,
  TextEditingController controller, {
  String? hint,
  String? prefix,
  TextInputType? keyboard,
  bool obscure = false,
  bool enabled = true,
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onSubmitted,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _ink)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboard,
        obscureText: obscure,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(hintText: hint, prefixText: prefix == null || prefix.isEmpty ? null : '$prefix '),
      ),
    ],
  );
}

Widget labeledSelect<T>({
  required String label,
  required T? value,
  required List<DropdownMenuItem<T>> items,
  ValueChanged<T?>? onChanged,
}) {
  final current = items.any((item) => item.value == value) ? value : null;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _ink)),
      const SizedBox(height: 6),
      DropdownButtonFormField<T>(
        key: ValueKey(current),
        initialValue: current,
        isExpanded: true,
        items: items,
        onChanged: onChanged,
      ),
    ],
  );
}
