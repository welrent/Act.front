/// Legal page / agreement model — matches pages and agreements tables.
class PageItem {
  final int id;
  final String title;
  final String slug;
  final String? content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PageItem({
    required this.id,
    required this.title,
    required this.slug,
    this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory PageItem.fromMap(Map<String, dynamic> map) {
    return PageItem(
      id: map['id'] is int ? map['id'] : int.tryParse('${map['id'] ?? 0}') ?? 0,
      title: map['title'] ?? '',
      slug: map['slug'] ?? '',
      content: map['content'],
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'content': content,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}

/// Site setting — matches site_settings table.
class SiteSetting {
  final String key;
  final String value;
  final String? label;

  SiteSetting({
    required this.key,
    required this.value,
    this.label,
  });

  factory SiteSetting.fromMap(Map<String, dynamic> map) {
    return SiteSetting(
      key: map['key'] ?? '',
      value: map['value'] ?? '',
      label: map['label'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
      if (label != null) 'label': label,
    };
  }
}

/// Agreement model — matches agreements table.
class Agreement {
  final int id;
  final String title;
  final String? description;
  final String? content;

  Agreement({
    required this.id,
    required this.title,
    this.description,
    this.content,
  });

  factory Agreement.fromMap(Map<String, dynamic> map) {
    return Agreement(
      id: map['id'] is int ? map['id'] : int.tryParse('${map['id'] ?? 0}') ?? 0,
      title: map['title'] ?? '',
      description: map['description'],
      content: map['content'],
    );
  }
}
