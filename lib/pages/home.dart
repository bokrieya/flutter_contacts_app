import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../db/database_helper.dart';
import '../models/contact.dart';
import 'login_page.dart'; // Import your LoginPage here

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dbHelper = DatabaseHelper.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _isAddingContact = false;
  String? _loggedInUserEmail;
  int? _loggedInUserId;

  @override
  void initState() {
    super.initState();
    _getLoggedInUser();
    _loadContacts();
  }

  Future<void> _getLoggedInUser() async {
    _loggedInUserEmail = await _dbHelper.getLoggedInUser();
    if (_loggedInUserEmail != null) {
      // Fetch the user ID associated with the logged-in user
      final user = _loggedInUserEmail;
      if (user != null) {
        
        _loadContacts(); // Load contacts after getting userId
      }
    } else {
      // If no user is logged in, redirect to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Future<void> _loadContacts() async {
    List<Contact> contacts = await _dbHelper.getContacts();

    // Sort contacts alphabetically by name
    contacts
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    setState(() {
      _contacts = contacts;
      _filteredContacts =
          contacts; // Initialize filtered list with sorted contacts
    });
  }

  Future<void> _addContact() async {
    final contact = Contact(
      id: null,
      name: _nameController.text,
      pseudoName: _pseudoController.text,
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
    _pseudoController.text = contact.pseudoName;
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

  // Method to initiate a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    // Direct phone call (requires permission on Android)
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Contact List'),
        leading: IconButton(
          // Back button to navigate to the login page
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      LoginPage()), // Navigate to the login page
            );
          },
        ),
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
                          _makePhoneCall(_filteredContacts[index].phoneNumber);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editContact(_filteredContacts[index]),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () =>
                            _confirmDeleteContact(_filteredContacts[index].id!),
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
            keyboardType: TextInputType.number,
            controller: _phoneController,
            decoration: InputDecoration(labelText: 'Phone Number'),
          ),
          ElevatedButton(
            onPressed: () {
              _addContact();
            },
            child: Text('Save Contact'),
          ),
        ],
      ),
    );
  }
}
