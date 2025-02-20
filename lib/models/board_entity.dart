class BoardEntity {
  final String boardId;
  final int numberOfPlayers;
  final String type;

  const BoardEntity({
    required this.boardId,
    required this.numberOfPlayers,
    required this.type,
  });
}