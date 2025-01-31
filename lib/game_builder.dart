import 'package:flutter/material.dart';
import 'package:deckopia/models/game_rule.dart';
import 'package:deckopia/service/action_json_reader.dart';
import 'dart:convert';

class GameBuilderScreen extends StatefulWidget {
  const GameBuilderScreen({super.key});

  @override
  _GameBuilderScreenState createState() => _GameBuilderScreenState();
}

class _GameBuilderScreenState extends State<GameBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  String gameName = '';
  List<Phase> phases = [];
  List<Section> availableSections = [];
  String? selectedSection;
  List<CardAction> availableActions = [];
  String? selectedAction;
  int draggedIndex = -1;
  CardAction? currentAction;

  @override
  void initState() {
    super.initState();
    loadAvailableSections();
  }

  Future<void> loadAvailableSections() async {
    try {
      List<Section> sections = await loadSections();
      setState(() {
        availableSections = sections;
        if (sections.isNotEmpty) {
          selectedSection = sections.first.name;
          availableActions = sections.first.actions;
          if (availableActions.isNotEmpty) {
            selectedAction = availableActions.first.action;
            currentAction = availableActions.first;
          }
        }
      });
    } catch (e) {
      print('Error loading sections: $e');
    }
  }

  void addPhase() {
    setState(() {
      phases.add(Phase(name: '', actions: []));
    });
  }

  void addAction(int phaseIndex) {
    if (selectedAction != null && selectedAction!.isNotEmpty) {
      CardAction selectedCardAction = availableActions.firstWhere((element) => element.action == selectedAction);
      setState(() {
        phases[phaseIndex].actions.add(CardAction(
          action: selectedCardAction.action,
          description: selectedCardAction.description,
          id: selectedCardAction.id,
          amount: selectedCardAction.amount,
          condition: selectedCardAction.condition,
        ));
      });
    } else {
      // Handle case where no action is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an action before adding.')),
      );
    }
  }

  void saveGameTemplate() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Set the sequence for each action based on their order in the phase
      for (var phase in phases) {
        for (var i = 0; i < phase.actions.length; i++) {
          phase.actions[i] = CardAction(
            action: phase.actions[i].action,
            description: phase.actions[i].description,
            id: phase.actions[i].id,
            amount: phase.actions[i].amount,
            condition: phase.actions[i].condition,
          );
        }
      }
      GameRule gameRule = GameRule(name: gameName, phases: phases);
      String json = jsonEncode(gameRule.toJson());
      print(json); // This will print the generated JSON to the console
      // Here you can add functionality to save the JSON to a file or send it to a backend
    }
  }

  void onReorder(int phaseIndex, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = phases[phaseIndex].actions.removeAt(oldIndex);
      phases[phaseIndex].actions.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Builder'),
      ),
      body: availableSections.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Game Name'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a game name';
                }
                return null;
              },
              onSaved: (value) {
                gameName = value!;
              },
            ),
            ...phases.asMap().entries.map((entry) {
              int phaseIndex = entry.key;
              Phase phase = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Phase Name'),
                    initialValue: phase.name,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a phase name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      phase.name = value!;
                    },
                  ),
                  Column(
                    children: phase.actions.asMap().entries.map((entry) {
                      int actionIndex = entry.key;
                      CardAction action = entry.value;
                      return LongPressDraggable(
                        data: actionIndex,
                        axis: Axis.vertical,
                        feedback: Material(
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            color: Colors.blueAccent,
                            child: Text(action.action.isNotEmpty ? action.action : 'Action'),
                          ),
                        ),
                        childWhenDragging: Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          color: Colors.grey,
                          child: Text(action.action.isNotEmpty ? action.action : 'Action'),
                        ),
                        onDragStarted: () {
                          setState(() {
                            draggedIndex = actionIndex;
                          });
                        },
                        onDragCompleted: () {
                          setState(() {
                            draggedIndex = -1;
                          });
                        },
                        onDraggableCanceled: (_, __) {
                          setState(() {
                            draggedIndex = -1;
                          });
                        },
                        child: DragTarget<int>(
                          builder: (
                              BuildContext context,
                              List<int?> candidateData,
                              List<dynamic> rejectedData,
                              ) {
                            return Container(
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              color: Colors.blueAccent,
                              child: Text(action.action.isNotEmpty ? action.action : 'Action'),
                            );
                          },
                          onAccept: (oldIndex) {
                            onReorder(phaseIndex, oldIndex, actionIndex);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Section'),
                    value: selectedSection,
                    items: availableSections.map((Section section) {
                      return DropdownMenuItem<String>(
                        value: section.name,
                        child: Text(section.name),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSection = newValue;
                        availableActions = availableSections.firstWhere((section) => section.name == newValue!).actions;
                        selectedAction = availableActions.isNotEmpty ? availableActions.first.action : null;
                        currentAction = availableActions.isNotEmpty ? availableActions.firstWhere((element) => element.action == selectedAction) : null;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a section';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Action Type'),
                    value: selectedAction,
                    items: availableActions.map((CardAction availableAction) {
                      return DropdownMenuItem<String>(
                        value: availableAction.action,
                        child: Text(availableAction.action),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedAction = newValue;
                        currentAction = availableActions.firstWhere((element) => element.action == newValue);
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an action';
                      }
                      return null;
                    },
                  ),
                  if (currentAction != null && currentAction!.amount != null)
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Action Amount'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) {
                        int? amount = int.tryParse(value!);
                        if (amount != null) {
                          setState(() {
                            phases[phaseIndex].actions.last.amount = amount;
                          });
                        }
                      },
                    ),
                  ElevatedButton(
                    onPressed: () => addAction(phaseIndex),
                    child: const Text('Add Action'),
                  ),
                  const Divider(),
                ],
              );
            }).toList(),
            ElevatedButton(
              onPressed: addPhase,
              child: const Text('Add Phase'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveGameTemplate,
              child: const Text('Save Game Template'),
            ),
          ],
        ),
      ),
    );
  }
}
