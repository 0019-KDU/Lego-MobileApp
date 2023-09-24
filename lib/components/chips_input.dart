import 'package:flutter/material.dart';

class ChipsInput<T> extends StatefulWidget {
  final List<T> initialValue;
  final InputDecoration decoration;
  final int? maxChips;
  final ValueChanged<List<T>> onChanged;
  final Future<List<T>> Function(String) findSuggestions;
  final Widget Function(BuildContext, ChipsInputState<T>, T) chipBuilder;
  final Widget Function(BuildContext, ChipsInputState<T>, T) suggestionBuilder;

  const ChipsInput({
    Key? key,
    required this.initialValue,
    required this.decoration,
    this.maxChips,
    required this.onChanged,
    required this.findSuggestions,
    required this.chipBuilder,
    required this.suggestionBuilder,
  }) : super(key: key);

  @override
  ChipsInputState<T> createState() => ChipsInputState<T>();
}

class ChipsInputState<T> extends State<ChipsInput<T>> {
  final List<T> _chips = [];

  @override
  void initState() {
    super.initState();
    _chips.addAll(widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputDecorator(
          decoration: widget.decoration,
          child: Wrap(
            spacing: 8.0,
            children: _chips.map((chip) {
              return widget.chipBuilder(context, this, chip);
            }).toList(),
          ),
        ),
        TextField(
          onChanged: (query) {
            widget.findSuggestions(query).then((suggestions) {
              // Update the UI with suggestions
            });
          },
        ),
      ],
    );
  }

  void deleteChip(T chip) {
    setState(() {
      _chips.remove(chip);
      widget.onChanged(_chips);
    });
  }

  void selectSuggestion(T suggestion) {
    setState(() {
      _chips.add(suggestion);
      widget.onChanged(_chips);
    });
  }
}
