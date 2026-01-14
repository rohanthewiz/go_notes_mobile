class Note {
  // Core identifiers
  final String id;
  final String guid;

  // Content fields
  final String title;
  final String? description;
  final String body;  // Renamed from 'content' to match gonotes
  final String? tags;

  // Security & privacy
  final bool isPrivate;
  final String? encryptionIv;

  // User tracking
  final String? createdBy;
  final String? updatedBy;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? authoredAt;
  final DateTime? syncedAt;
  final DateTime? deletedAt;

  // Mobile-specific features
  final String language;
  final bool isPinned;

  Note({
    required this.id,
    required this.guid,
    required this.title,
    this.description,
    required this.body,
    this.tags,
    this.isPrivate = false,
    this.encryptionIv,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.authoredAt,
    this.syncedAt,
    this.deletedAt,
    this.language = '',
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guid': guid,
      'title': title,
      'description': description,
      'body': body,
      'tags': tags,
      'isPrivate': isPrivate ? 1 : 0,
      'encryptionIv': encryptionIv,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'authoredAt': authoredAt?.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'language': language,
      'isPinned': isPinned ? 1 : 0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guid': guid,
      'title': title,
      'description': description,
      'body': body,
      'tags': tags,
      'is_private': isPrivate,
      'encryption_iv': encryptionIv,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'authored_at': authoredAt?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      guid: map['guid'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      body: map['body'] as String? ?? map['content'] as String? ?? '',
      tags: map['tags'] as String?,
      isPrivate: (map['isPrivate'] as int?) == 1,
      encryptionIv: map['encryptionIv'] as String?,
      createdBy: map['createdBy'] as String?,
      updatedBy: map['updatedBy'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      authoredAt: map['authoredAt'] != null ? DateTime.parse(map['authoredAt'] as String) : null,
      syncedAt: map['syncedAt'] != null ? DateTime.parse(map['syncedAt'] as String) : null,
      deletedAt: map['deletedAt'] != null ? DateTime.parse(map['deletedAt'] as String) : null,
      language: map['language'] as String? ?? '',
      isPinned: (map['isPinned'] as int?) == 1,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id']?.toString() ?? '',
      guid: json['guid'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      body: json['body'] as String? ?? '',
      tags: json['tags'] as String?,
      isPrivate: json['is_private'] as bool? ?? false,
      encryptionIv: json['encryption_iv'] as String?,
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
      authoredAt: json['authored_at'] != null ? DateTime.parse(json['authored_at'] as String) : null,
      syncedAt: json['synced_at'] != null ? DateTime.parse(json['synced_at'] as String) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      language: '',
      isPinned: false,
    );
  }

  Note copyWith({
    String? id,
    String? guid,
    String? title,
    String? description,
    String? body,
    String? tags,
    bool? isPrivate,
    String? encryptionIv,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? authoredAt,
    DateTime? syncedAt,
    DateTime? deletedAt,
    String? language,
    bool? isPinned,
  }) {
    return Note(
      id: id ?? this.id,
      guid: guid ?? this.guid,
      title: title ?? this.title,
      description: description ?? this.description,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      isPrivate: isPrivate ?? this.isPrivate,
      encryptionIv: encryptionIv ?? this.encryptionIv,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authoredAt: authoredAt ?? this.authoredAt,
      syncedAt: syncedAt ?? this.syncedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      language: language ?? this.language,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  String toString() {
    return 'Note{id: $id, guid: $guid, title: $title, language: $language, isPinned: $isPinned, isPrivate: $isPrivate}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note && other.guid == guid;
  }

  @override
  int get hashCode => guid.hashCode;
}
