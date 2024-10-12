class Api {
  String? id;
  String? assignerId;
  String? assigneeId;
  String? projectId;
  String? sectionId;
  String? parentId;
  int? order;
  String? content;
  String? description;
  bool? isCompleted;
  List<String>? labels;
  int? priority;
  int? commentCount;
  String? creatorId;
  String? createdAt;
  String? due;
  String? url;
  String? duration;
  String? deadline;

  Api({
    this.id,
    this.assignerId,
    this.assigneeId,
    this.projectId,
    this.sectionId,
    this.parentId,
    this.order,
    required this.content,
    this.description,
    this.isCompleted = false,
    this.labels = const [],
    this.priority = 1,
    this.commentCount,
    this.creatorId,
    this.createdAt,
    this.due,
    this.url,
    this.duration,
    this.deadline, String? dueDate,
  });

  Api.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    assignerId = json['assigner_id'];
    assigneeId = json['assignee_id'];
    projectId = json['project_id'];
    sectionId = json['section_id'];
    parentId = json['parent_id'];
    order = json['order'];
    content = json['content'] ?? '';
    description = json['description'] ?? '';
    isCompleted = json['is_completed'] ?? false;
    labels = List<String>.from(json['labels'] ?? []);
    priority = json['priority'] ?? 1;
    commentCount = json['comment_count'];
    creatorId = json['creator_id'];
    createdAt = json['created_at'];
    due = json['due'];
    url = json['url'];
    duration = json['duration'];
    deadline = json['deadline'];
  }

  get dueDate => null;

  Map<String, dynamic> toJson() {
    return {
      'assigner_id': assignerId,
      'assignee_id': assigneeId,
      'project_id': projectId,
      'section_id': sectionId,
      'parent_id': parentId,
      'order': order,
      'content': content,
      'description': description ?? '',
      'is_completed': isCompleted ?? false,
      'labels': labels ?? [],
      'priority': priority ?? 1,
      'comment_count': commentCount,
      'creator_id': creatorId,
      'created_at': createdAt,
      'due': due,
      'url': url,
      'duration': duration,
      'deadline': deadline,
    };
  }
}
