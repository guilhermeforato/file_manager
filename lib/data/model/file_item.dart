class FileItem {
  final String name;
  final String path;
  final int size;

  const FileItem({
    required this.name,
    required this.path,
    required this.size,
  });

  factory FileItem.fromMap(Map<String, dynamic> map) {
    return FileItem(
      name: map['name'].toString(),
      path: map['path'].toString(),
      size: map['size'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'path': path,
      'size': size,
    };
  }

  FileItem copyWith({
    String? name,
    String? path,
    int? size,
  }) {
    return FileItem(
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
    );
  }
}