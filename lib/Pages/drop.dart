import 'package:flutter/material.dart';

class DropDownSearch extends StatefulWidget {
  const DropDownSearch(
      {super.key,
      required this.title,
      required this.textController,
      required this.items,
      required this.onItemSelected});
  final String title;
  final TextEditingController? textController;
  final List<String>? items;
  final Function? onItemSelected;
  @override
  State<DropDownSearch> createState() => _DropDownSearchState();
}

class _DropDownSearchState extends State<DropDownSearch> {
  bool _isTapped = false;
  List<String> _filteredList = [];
  List<String> _subFilteredList = [];

  @override
  initState() {
    _filteredList = widget.items!;
    _subFilteredList = _filteredList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 16, color: Color(0xFF858597)),
          ),
          const SizedBox(height: 5),
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: widget.textController,
                    onChanged: (val) {
                      setState(() {
                        _filteredList = _subFilteredList
                            .where((element) => element.toLowerCase().contains(
                                widget.textController!.text.toLowerCase()))
                            .toList();
                      });
                    },
                    validator: (val) =>
                        val!.isEmpty ? 'Field can\'t empty' : null,
                    style: const TextStyle(color: Colors.black, fontSize: 16.0),
                    onTap: () {
                      setState(() => _isTapped = true);
                      if (widget.onItemSelected != null) {
                        widget.onItemSelected!();
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      errorStyle: const TextStyle(fontSize: 0.01),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          style: BorderStyle.solid,
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.only(bottom: 10, left: 10),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.black.withOpacity(0.7),
                              width: 0.8)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.black.withOpacity(0.7),
                              width: 0.8)),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.black.withOpacity(0.7), width: 0.8),
                      ),
                      suffixIcon: const Icon(Icons.arrow_drop_down, size: 25),
                      isDense: true,
                    ),
                  ),
                  _isTapped && _filteredList.isNotEmpty
                      ? Container(
                          height: 150.0,
                          color: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ListView.builder(
                            itemCount: _filteredList.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  setState(() => _isTapped = !_isTapped);
                                  widget.textController!.text =
                                      _filteredList[index];
                                  setState(() {});
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(_filteredList[index],
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 16.0)),
                                ),
                              );
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ))
        ]);
  }
}
