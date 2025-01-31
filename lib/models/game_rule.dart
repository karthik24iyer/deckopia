
class GameRule {
  String name;
  List<Phase> phases;

  GameRule({required this.name, required this.phases});

  factory GameRule.fromJson(Map<String, dynamic> json) {
    return GameRule(
      name: json['game']['name'],
      phases: (json['game']['phases'] as List).map((i) => Phase.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game': {
        'name': name,
        'phases': phases.map((phase) => phase.toJson()).toList(),
      },
    };
  }
}

class Phase {
  String name;
  List<CardAction> actions;

  Phase({required this.name, required this.actions});

  factory Phase.fromJson(Map<String, dynamic> json) {
    return Phase(
      name: json['name'],
      actions: (json['actions'] as List).map((i) => CardAction.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'actions': actions.map((action) => action.toJson()).toList(),
    };
  }
}

class CardAction {
  String action;
  String description;
  String id;
  int? amount;
  String? condition;

  CardAction({
    required this.action,
    required this.description,
    required this.id,
    this.amount,
    this.condition,
  });

  factory CardAction.fromJson(Map<String, dynamic> json) {
    return CardAction(
      action: json['action'],
      description: json['description'],
      id: json['id'],
      amount: json['amount'],
      condition: json['condition'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'description': description,
      'id': id,
      'amount': amount,
      'condition': condition,
    };
  }
}

class Section {
  String name;
  List<CardAction> actions;

  Section({required this.name, required this.actions});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      name: json['name'],
      actions: (json['actions'] as List).map((i) => CardAction.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'actions': actions.map((action) => action.toJson()).toList(),
    };
  }
}
