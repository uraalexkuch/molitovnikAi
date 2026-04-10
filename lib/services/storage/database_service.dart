import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../security/encryption_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  final _encryptionService = EncryptionService();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> initialize() async {
    await database;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'chaplain_v2.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Таблиця повідомлень чату
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        is_encrypted INTEGER DEFAULT 1
      )
    ''');

    // Таблиця налаштувань (зашифрована)
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // --- Методи для повідомлень ---

  Future<void> insertMessage(String role, String content) async {
    final db = await database;
    
    // Шифруємо контент перед записом
    final encryptedContent = _encryptionService.encryptText(content);
    
    await db.insert(
      'messages',
      {
        'role': role,
        'content': encryptedContent,
        'is_encrypted': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('messages', orderBy: 'timestamp ASC');

    // Дешифруємо контент при читанні
    return maps.map((map) {
      final content = map['content'] as String;
      final isEncrypted = map['is_encrypted'] == 1;
      
      return {
        ...map,
        'content': isEncrypted ? _encryptionService.decryptText(content) : content,
      };
    }).toList();
  }

  Future<void> clearMessages() async {
    final db = await database;
    await db.delete('messages');
  }

  // --- Методи для Panic Wipe ---

  Future<void> clearAllData() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'chaplain_v2.db');
    
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    await deleteDatabase(path);
  }
}
