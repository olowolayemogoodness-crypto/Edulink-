import '../domain/models/flashcard_model.dart';

class MockFlashcards {
  static const List<FlashcardDeck> decks = [
    FlashcardDeck(
      id: 'data-structures',
      name: 'Data Structures',
      subtitle: 'Binary Trees · Graphs · Sorting',
      emoji: '💻',
      totalCards: 48,
      dueCount: 24,
      progress: 0.34,
      color: DeckColor.violet,
    ),
    FlashcardDeck(
      id: 'ielts-vocab',
      name: 'IELTS Vocabulary',
      subtitle: 'Academic words · Collocations',
      emoji: '🌍',
      totalCards: 60,
      dueCount: 12,
      progress: 0.60,
      color: DeckColor.teal,
    ),
    FlashcardDeck(
      id: 'mathematics',
      name: 'Mathematics',
      subtitle: 'Trigonometry · Calculus',
      emoji: '📐',
      totalCards: 40,
      dueCount: 5,
      progress: 0.78,
      color: DeckColor.amber,
    ),
    FlashcardDeck(
      id: 'chemistry',
      name: 'Chemistry',
      subtitle: 'Organic · Periodic table',
      emoji: '⚗️',
      totalCards: 55,
      dueCount: 0,
      progress: 0.92,
      color: DeckColor.pink,
    ),
  ];

  static List<FlashcardModel> getCards(String deckId) {
    return [
      FlashcardModel(
        id: '1',
        front: 'What is the time complexity of inserting a node into a BST?',
        back: 'O(h) where h is the tree height. For a balanced BST this is O(log n). For a skewed tree it degrades to O(n).',
        topic: 'Data Structures',
      ),
      FlashcardModel(
        id: '2',
        front: 'What does DFS stand for and what data structure does it use?',
        back: 'Depth-First Search. It uses a Stack (or recursion) to explore as far as possible before backtracking.',
        topic: 'Data Structures',
      ),
      FlashcardModel(
        id: '3',
        front: 'Define a Min-Heap in one sentence.',
        back: 'A complete binary tree where every parent node is smaller than or equal to its children — the minimum element is always at the root.',
        topic: 'Data Structures',
      ),
      FlashcardModel(
        id: '4',
        front: 'What is the difference between a Tree and a Graph?',
        back: 'A Tree is a connected, acyclic graph with N nodes and N-1 edges with a root. A Graph can have cycles, multiple edges, and no root.',
        topic: 'Data Structures',
      ),
      FlashcardModel(
        id: '5',
        front: 'What is the time complexity of Merge Sort?',
        back: 'O(n log n) in all cases — best, average, and worst. It divides the array in half and merges, requiring O(n) extra space.',
        topic: 'Data Structures',
      ),
      FlashcardModel(
        id: '6',
        front: 'What is a Hash Table collision?',
        back: 'When two different keys produce the same hash index. Resolved via chaining or open addressing.',
        topic: 'Data Structures',
      ),
      FlashcardModel(
        id: '7',
        front: 'What is the difference between BFS and DFS?',
        back: 'BFS uses a Queue and explores level by level. DFS uses a Stack and explores depth-first. BFS finds shortest path; DFS uses less memory on wide graphs.',
        topic: 'Data Structures',
      ),
      FlashcardModel(
        id: '8',
        front: 'What is a Queue and what ordering does it follow?',
        back: 'A Queue is a linear data structure that follows FIFO (First In, First Out) — the first element added is the first to be removed.',
        topic: 'Data Structures',
      ),
      FlashcardModel(
        id: '9',
        front: 'What is Dynamic Programming?',
        back: 'An optimization technique that solves problems by breaking them into overlapping subproblems and storing results to avoid redundant computation.',
        topic: 'Data Structures',
      ),
      FlashcardModel(
        id: '10',
        front: 'What is Big O notation?',
        back: 'A mathematical notation describing the upper bound of an algorithm\'s time or space complexity as input size grows.',
        topic: 'Data Structures',
      ),
    ];
  }
}