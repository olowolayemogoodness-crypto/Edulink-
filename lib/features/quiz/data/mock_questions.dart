
import '../domain/models/quiz_question.dart';

class MockQuestions {
  static const List<QuizQuestion> dataStructures = [
    QuizQuestion(
      question: "In a Binary Search Tree (BST), where is the smallest element always located?",
      options: ["At the root node", "At the rightmost node", "At the leftmost node", "At the leaf node closest to root"],
      correctIndex: 2,
      explanation: "In a BST, all left child values are smaller than their parent. So the smallest element is always at the leftmost node.",
    ),
    QuizQuestion(
      question: "What is the time complexity of searching in a balanced BST?",
      options: ["O(n)", "O(log n)", "O(1)", "O(n^2)"],
      correctIndex: 1,
      explanation: "A balanced BST halves the search space at each step, giving O(log n).",
    ),
    QuizQuestion(
      question: "Which traversal visits nodes in ascending order in a BST?",
      options: ["Pre-order", "Post-order", "In-order", "Level-order"],
      correctIndex: 2,
      explanation: "In-order traversal (Left, Root, Right) visits BST nodes in ascending sorted order.",
    ),
    QuizQuestion(
      question: "What data structure uses LIFO order?",
      options: ["Queue", "Stack", "Linked list", "Heap"],
      correctIndex: 1,
      explanation: "A Stack uses LIFO — the last element pushed is the first to be popped.",
    ),
    QuizQuestion(
      question: "What is the height of a complete binary tree with 7 nodes?",
      options: ["2", "3", "4", "1"],
      correctIndex: 0,
      explanation: "A complete binary tree with 7 nodes has height 2 (0-indexed).",
    ),
    QuizQuestion(
      question: "Which data structure is best for implementing a priority queue?",
      options: ["Array", "Linked list", "Heap", "Stack"],
      correctIndex: 2,
      explanation: "A Heap supports O(log n) insert and O(1) peek at the highest-priority element.",
    ),
    QuizQuestion(
      question: "What is the space complexity of DFS on a graph with V vertices?",
      options: ["O(V)", "O(E)", "O(V + E)", "O(1)"],
      correctIndex: 0,
      explanation: "DFS uses a stack proportional to the depth, which is at most O(V).",
    ),
    QuizQuestion(
      question: "In a hash table, what is a collision?",
      options: ["When two keys map to the same index", "When the table is full", "When a key is deleted", "When search returns null"],
      correctIndex: 0,
      explanation: "A collision occurs when two different keys produce the same hash index.",
    ),
    QuizQuestion(
      question: "Which sorting algorithm has the best average-case time complexity?",
      options: ["Bubble sort", "Insertion sort", "Merge sort", "Selection sort"],
      correctIndex: 2,
      explanation: "Merge sort runs in O(n log n) in all cases using divide and conquer.",
    ),
    QuizQuestion(
      question: "What does BFS use internally to track nodes to visit?",
      options: ["Stack", "Queue", "Heap", "Array"],
      correctIndex: 1,
      explanation: "BFS uses a Queue (FIFO) to explore nodes level by level.",
    ),
  ];

  static List<QuizQuestion> getQuestions({
    required String topic,
    required QuizDifficulty difficulty,
    int count = 10,
  }) {
    // TODO: Replace with Gemini API call
    final questions = List<QuizQuestion>.from(dataStructures);
    questions.shuffle();
    return questions.take(count).toList();
  }
}
