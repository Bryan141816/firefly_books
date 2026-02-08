import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DirectoryEdit extends StatefulWidget {
  final VoidCallback onPressed;
  final String selectedFolder;

  const DirectoryEdit({
    super.key,
    required this.onPressed,
    required this.selectedFolder,
  });

  @override
  State<StatefulWidget> createState() => _DirectoryEdit();
}

class _DirectoryEdit extends State<DirectoryEdit> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Disabled input look
          Expanded(
            child: Container(
              height: 50,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Text(
                widget.selectedFolder,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),

          SizedBox(width: 5),

          // Edit icon button
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary, // background color
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: widget.onPressed,
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              tooltip: 'Change folder',
            ),
          ),
        ],
      ),
    );
  }
}
