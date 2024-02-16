import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TeacherFormEdit extends StatefulWidget {
  final int teacherId;
  const TeacherFormEdit({Key? key, required this.teacherId}) : super(key: key);
  @override
  _TeacherFormState createState() => _TeacherFormState();
}

class _TeacherFormState extends State<TeacherFormEdit> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cellphoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _condicionController = TextEditingController();
  final TextEditingController _tiempoLaboralController =
      TextEditingController();

  bool _isFormValid = true;
  String? _nameError;
  String? _lastNameError;
  String? _cellphoneError;
  String? _emailError;
  DateTime? _selectedBirthdate;
  String? _selectedCargo;
  String? _selectedCondicion;
  String? _tiempoLaboralError;

  List<String> _cargoList = [
    'Director',
    'Doc. por horas',
    'Jeie de taller',
    'Auxiliar',
    'Docente',
  ];
  List<String> _condicionList = [
    'Nombrado',
    'Contratado',
    'Encargado',
  ];

  @override
  void initState() {
    super.initState();
    _loadTeacherData(widget.teacherId);
    _loadDocumentTypes();
    _loadUbigeo();
  }

  Future<void> _loadTeacherData(int teacherId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.47:8085/scavontime/teacher/$teacherId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        _selectedDocumentType = data['documentType']['id'].toString();
        _documentNumberController.text = data['documentNumber'];
        _nameController.text = data['name'];
        _lastNameController.text = data['lastname'];
        _cellphoneController.text = data['cellphone'] ?? '';
        _emailController.text = data['email'] ?? '';
        _selectedBirthdate = data['birthdate'] != null
            ? DateTime.parse(data['birthdate'])
            : null;
        _selectedUbigeo = data['ubigeo'];
        _selectedCargo = data['typeCharge'];
        _selectedCondicion = data['typeCondition'];
        _tiempoLaboralController.text = data['workday'];
        if (_selectedBirthdate != null) {
          _birthdateController.text =
              DateFormat('dd-MMM-yyyy').format(_selectedBirthdate!);
        }
      });
    } else {
      print('Error al cargar datos del docente para editar');
    }
  }

  final TextEditingController _documentNumberController =
      TextEditingController();
  String? _selectedDocumentType;
  String? _documentNumberError;
  bool _isDocumentNumberValid = false;
  Map<String, dynamic>? _selectedUbigeo;
  List<Map<String, dynamic>> _documentTypes = [];
  List<Map<String, dynamic>> _ubigeoList = [];

  Future<void> _loadDocumentTypes() async {
    final response = await http
        .get(Uri.parse('http://192.168.1.47:8085/scavontime/document'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _documentTypes =
            data.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    } else {
      print('Error al cargar tipos de documento');
    }
  }

  Future<void> _loadUbigeo() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.47:8085/scavontime/ubigeo'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _ubigeoList = data.map((item) {
          return {
            'id': item['id'],
            'formattedUbigeo':
                '${item['department']}, ${item['province']}, ${item['district']}',
          };
        }).toList();
      });
    } else {
      print('Error al cargar la lista de Ubigeo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actualizar un registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField2(
                      labelText: 'Tipo Doc',
                      items: _documentTypes,
                      value: _selectedDocumentType,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedDocumentType = value;
                          _documentNumberController.clear();
                          _documentNumberError = null;
                          _isDocumentNumberValid = false;
                          _validateForm();
                        });
                      },
                      displayKey: 'nameDocument',
                      valueKey: 'id',
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    flex: 2,
                    child: _buildTextField2(
                      controller: _documentNumberController,
                      labelText: 'Número de Documento',
                      errorText: _documentNumberError,
                      isValid: _isDocumentNumberValid,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        setState(() {
                          if (value.contains(
                              RegExp(r'[a-zA-Z@!#$%^&*(),.?":{}|<>]'))) {
                            _documentNumberError = 'Solo se ingresan números';
                            _isDocumentNumberValid = false;
                          } else if (_selectedDocumentType != null &&
                              _documentNumberController.text.isNotEmpty) {
                            int expectedLength =
                                _selectedDocumentType == '1' ? 8 : 12;
                            if (value.length == expectedLength) {
                              _documentNumberError = null;
                              _isDocumentNumberValid = true;
                            } else {
                              _documentNumberError =
                                  'Debe contener exactamente $expectedLength dígitos';
                              _isDocumentNumberValid = false;
                            }
                          } else {
                            _documentNumberError =
                                'Ingrese un número de documento válido';
                            _isDocumentNumberValid = false;
                          }

                          _validateForm();
                        });
                      },
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: _nameController,
                labelText: 'Nombres',
                errorText: _nameError,
                isValid: _nameError == null,
                onChanged: (value) {
                  setState(() {
                    if (value
                        .contains(RegExp(r'[a-z0-9@!#$%^&*(),.?":{}|<>]'))) {
                      _nameError = 'Solo se ingresan letras mayúsculas';
                    } else {
                      _nameError = null;
                    }

                    _validateForm();
                  });
                },
              ),
              _buildTextField(
                controller: _lastNameController,
                labelText: 'Apellidos',
                errorText: _lastNameError,
                isValid: _lastNameError == null,
                onChanged: (value) {
                  setState(() {
                    if (value
                        .contains(RegExp(r'[a-z0-9@!#$%^&*(),.?":{}|<>]'))) {
                      _lastNameError = 'Solo se ingresan letras mayúsculas';
                    } else {
                      _lastNameError = null;
                    }

                    _validateForm();
                  });
                },
              ),
              _buildTextField(
                controller: _cellphoneController,
                labelText: 'Celular',
                errorText: _cellphoneError,
                isValid: _cellphoneError == null,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  setState(() {
                    if (value
                        .contains(RegExp(r'[a-zA-Z@!#$%^&*(),.?":{}|<>]'))) {
                      _cellphoneError = 'Solo se ingresan números';
                    } else if (value.isNotEmpty &&
                        (value.length != 9 || !value.startsWith('9'))) {
                      _cellphoneError =
                          'Se inicializa con el número 9 y debe contener exactamente 9 dígitos';
                    } else {
                      _cellphoneError = null;
                    }

                    _validateForm();
                  });
                },
              ),
              _buildTextField(
                controller: _emailController,
                labelText: 'Correo',
                errorText: _emailError,
                isValid: _emailError == null || _emailController.text.isEmpty,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    if (!value.contains('@') || !value.contains('.')) {
                      _emailError = 'Correo electrónico no válido';
                    } else {
                      _emailError = null;
                    }

                    _validateForm();
                  });
                },
              ),
              _buildTextField(
                controller: _birthdateController,
                labelText: 'Fec. Nacimiento',
                errorText: null,
                isValid: true,
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: () {
                  _selectDate(context);
                },
              ),
              _buildDropdownField2(
                labelText: 'Ubigeo',
                items: _ubigeoList,
                value: _selectedUbigeo != null
                    ? _selectedUbigeo!['id'].toString()
                    : null,
                onChanged: (String? value) {
                  setState(() {
                    _selectedUbigeo = _ubigeoList.firstWhere(
                        (ubigeo) => ubigeo['id'].toString() == value);
                    _validateForm();
                  });
                },
                displayKey: 'formattedUbigeo',
                valueKey: 'id',
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      labelText: 'Tipo de cargo',
                      items: _cargoList,
                      value: _selectedCargo,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCargo = value;
                          _validateForm();
                        });
                      },
                      fontSize: 14.0,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: _buildDropdownField(
                      labelText: 'Tipo de condición',
                      items: _condicionList,
                      value: _selectedCondicion,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCondicion = value;
                          _validateForm();
                        });
                      },
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: _tiempoLaboralController,
                labelText: 'Tiempo laboral',
                errorText: _tiempoLaboralError,
                isValid: _tiempoLaboralError == null,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  setState(() {
                    if (value
                        .contains(RegExp(r'[a-zA-Z@!#$%^&*(),.?":{}|<>]'))) {
                      _tiempoLaboralError = 'Solo se ingresan números';
                    } else if (value.isNotEmpty &&
                        (int.parse(value) <= 0 || int.parse(value) > 40)) {
                      _tiempoLaboralError =
                          'Solo se permiten números entre 1 y 40';
                    } else {
                      _tiempoLaboralError = null;
                    }

                    _validateForm();
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isFormValid ? () => _updateTeacher() : null,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String? errorText,
    required bool isValid,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
    bool readOnly = false,
    void Function()? onTap,
    double fontSize = 16.0,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: isValid ? Colors.green : Colors.grey,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required List<String> items,
    String? value,
    void Function(String?)? onChanged,
    double fontSize = 16.0,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: value != null && value.isNotEmpty
                  ? Colors.green
                  : Colors.grey,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(fontSize: fontSize),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField2({
    required TextEditingController controller,
    required String labelText,
    required String? errorText,
    required bool isValid,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
    bool readOnly = false,
    void Function()? onTap,
    double fontSize = 16.0,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: isValid ? Colors.green : Colors.grey,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }

  Widget _buildDropdownField2({
    required String labelText,
    required List<Map<String, dynamic>> items,
    String? value,
    void Function(String?)? onChanged,
    String displayKey = 'name',
    String valueKey = 'id',
    double fontSize = 16.0,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: value != null && value.isNotEmpty
                  ? Colors.green
                  : Colors.grey,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        items: items.map((Map<String, dynamic> item) {
          return DropdownMenuItem<String>(
            value: item[valueKey].toString(),
            child: Text(
              item[displayKey].toString(),
              style: TextStyle(fontSize: fontSize),
            ),
          );
        }).toList(),
        onChanged: (value) {
          print('Selected $labelText ID: $value');
          onChanged?.call(value);
        },
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthdate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedBirthdate) {
      setState(() {
        _selectedBirthdate = picked;
        _birthdateController.text = DateFormat('dd-MMM-yyyy').format(picked);
        _validateForm();
      });
    }
  }

  void _validateForm() {
    setState(() {
      _isFormValid = true;

      if (_nameError != null ||
          _lastNameError != null ||
          _cellphoneError != null ||
          _emailError != null ||
          (_emailController.text.isNotEmpty && _emailError != null) ||
          _selectedBirthdate == null ||
          !(_isDocumentNumberValid && _selectedUbigeo != null) ||
          _selectedCargo == null ||
          _selectedCondicion == null ||
          _tiempoLaboralError != null) {
        _isFormValid = false;
      }
    });
  }

  void _showAlert(String message, Color color) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _updateTeacher() async {
    final int teacherId = widget.teacherId;
    final String apiUrl =
        'http://192.168.1.47:8085/scavontime/teacher/edit/$teacherId';

    // Prepara los datos actualizados
    Map<String, dynamic> updatedData = {
      'documentType': {'id': int.parse(_selectedDocumentType!)},
      'documentNumber': _documentNumberController.text,
      'name': _nameController.text,
      'lastname': _lastNameController.text,
      'cellphone': _cellphoneController.text,
      'email': _emailController.text,
      'birthdate': _selectedBirthdate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedBirthdate!)
          : null,
      'ubigeo': _selectedUbigeo!['id'],
      'typeCharge': _selectedCargo,
      'typeCondition': _selectedCondicion,
      'workday': _tiempoLaboralController.text,
      'active': 'A',
    };

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );

      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _showAlert('Docente actualizado exitosamente', Colors.green);

        _documentNumberController.clear();
        _nameController.clear();
        _lastNameController.clear();
        _cellphoneController.clear();
        _emailController.clear();
        _birthdateController.clear();
        _tiempoLaboralController.clear();

        setState(() {
          _selectedDocumentType = null;
          _selectedUbigeo = null;
          _selectedCargo = null;
          _selectedCondicion = null;
          _selectedBirthdate = null;
        });
      } else {
        _showAlert('Error al actualizar el docente', Colors.red);
      }
    } catch (e) {
      print('Error: $e');
      _showAlert('Error al actualizar el docente', Colors.red);
    }
  }
}
