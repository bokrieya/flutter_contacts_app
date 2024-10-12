import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/contact.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController(); 

  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = []; 
  bool _isAddingContact = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    List<Contact> contacts = await _dbHelper.getContacts();

    // Sort contacts alphabetically by name
    contacts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    setState(() {
      _contacts = contacts;
      _filteredContacts = contacts; // Initialize filtered list with sorted contacts
    });
  }

  Future<void> _addContact() async {
    final contact = Contact(
      name: _nameController.text,
      pseudo: _pseudoController.text,
      phoneNumber: _phoneController.text,
    );

    if (contact.name.isNotEmpty && contact.phoneNumber.isNotEmpty) {
      await _dbHelper.insertContact(contact);
      _nameController.clear();
      _pseudoController.clear();
      _phoneController.clear();
      _loadContacts(); 
      setState(() {
        _isAddingContact = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  Future<void> _confirmDeleteContact(int id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Contact'),
          content: Text('Are you sure you want to delete this contact?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); 
                await _deleteContact(id);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteContact(int id) async {
    await _dbHelper.deleteContact(id);
    _loadContacts();
  }

  Future<void> _editContact(Contact contact) async {
    _nameController.text = contact.name;
    _pseudoController.text = contact.pseudo;
    _phoneController.text = contact.phoneNumber;
    setState(() {
      _isAddingContact = true;
    });
  }

  void _filterContacts(String query) {
    List<Contact> filteredList = _contacts.where((contact) {
      return contact.name.toLowerCase().contains(query.toLowerCase()) ||
             contact.phoneNumber.contains(query);
    }).toList();

    setState(() {
      _filteredContacts = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                _isAddingContact = !_isAddingContact;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isAddingContact) // Only show the search bar when not adding a contact
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Contacts',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _filterContacts,
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredContacts[index].name),
                  subtitle: Text(_filteredContacts[index].phoneNumber),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.call),
                        onPressed: () {
                          // Add call logic
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editContact(_filteredContacts[index]),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _confirmDeleteContact(_filteredContacts[index].id!),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isAddingContact) _buildAddContactForm(), 
        ],
      ),
    );
  }

  Widget _buildAddContactForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _pseudoController,
            decoration: InputDecoration(labelText: 'Pseudo'),
          ),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(labelText: 'Phone Number'),
          ),
          ElevatedButton(
            onPressed: _addContact,
            child: Text('Save Contact'),
          ),
        ],
      ),
    );
  }
}
