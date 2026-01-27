import 'package:flutter/material.dart';
import '../models/hobby.dart';
import '../services/hobby_service.dart';

class AddHobbyScreen extends StatefulWidget {
  final Hobby? hobby;
  
  const AddHobbyScreen({Key? key, this.hobby}) : super(key: key);

  @override
  State<AddHobbyScreen> createState() => _AddHobbyScreenState();
}

class _AddHobbyScreenState extends State<AddHobbyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final HobbyService _service = HobbyService();
  
  String _repeatMode = 'Daily';
  String _priority = 'Medium';
  
  @override
  void initState() {
    super.initState();
    if (widget.hobby != null) {
      _nameController.text = widget.hobby!.name;
      _notesController.text = widget.hobby!.notes;
      _repeatMode = widget.hobby!.repeatMode[0].toUpperCase() + widget.hobby!.repeatMode.substring(1);
      _priority = widget.hobby!.priority[0].toUpperCase() + widget.hobby!.priority.substring(1);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveHobby() async {
    if (_formKey.currentState!.validate()) {
      if (widget.hobby != null) {
        // Update existing hobby
        final updatedHobby = widget.hobby!.copyWith(
          name: _nameController.text,
          notes: _notesController.text,
          repeatMode: _repeatMode.toLowerCase(),
          priority: _priority.toLowerCase(),
        );
        await _service.updateHobby(updatedHobby);
      } else {
        // Create new hobby
        final hobby = Hobby(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          notes: _notesController.text,
          repeatMode: _repeatMode.toLowerCase(),
          priority: _priority.toLowerCase(),
          color: const Color(0xFF6C3FFF).value,
        );
        await _service.addHobby(hobby);
      }
      
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1625),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C3FFF),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      widget.hobby != null ? 'EDIT HOBBY TASK' : 'NEW HOBBY TASK',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                        hintText: 'Hobby Name (e.g., Exercise)',
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                          fontSize: 18,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2A2238),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a hobby name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Add details or notes',
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2A2238),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            value: _repeatMode,
                            items: ['Daily', 'Weekly', 'Monthly'],
                            onChanged: (value) => setState(() => _repeatMode = value!),
                            label: 'Repeat Mode',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            value: _priority,
                            items: ['Low', 'Medium', 'High'],
                            onChanged: (value) => setState(() => _priority = value!),
                            label: 'Priority',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveHobby,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C3FFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.hobby != null ? 'Update' : 'Create',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2238),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF2A2238),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
