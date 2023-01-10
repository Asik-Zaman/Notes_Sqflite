class Note {
  late final int? id;
  final String? title;
  final String? desc;

  Note({required this.id, required this.title, required this.desc});

  Note.fromMap(Map<dynamic, dynamic> res)
      : id = res['id'],
        title = res['title'],
        desc = res['desc'];

  Map<String, Object?> toMap() {
    return {'id': id, 'title': title, 'desc': desc};
  }
}
