import '../domain/models/exam_model.dart';

class MockExamData {
  static const List<ExamSubject> subjects = [
    ExamSubject(
      id: 'waec-maths',
      name: 'WAEC Mathematics',
      hint: 'Algebra · Trigonometry · Geometry',
      emoji: '📐',
      iconBg: '#1E1240',
      group: ExamSubjectGroup.waec,
    ),
    ExamSubject(
      id: 'waec-english',
      name: 'WAEC English Language',
      hint: 'Comprehension · Essay · Grammar',
      emoji: '📝',
      iconBg: '#1A1A21',
      group: ExamSubjectGroup.waec,
    ),
    ExamSubject(
      id: 'waec-chemistry',
      name: 'WAEC Chemistry',
      hint: 'Organic · Inorganic · Physical',
      emoji: '⚗️',
      iconBg: '#2D0A1E',
      group: ExamSubjectGroup.waec,
    ),
    ExamSubject(
      id: 'waec-biology',
      name: 'WAEC Biology',
      hint: 'Ecology · Genetics · Physiology',
      emoji: '🔬',
      iconBg: '#052E1E',
      group: ExamSubjectGroup.waec,
    ),
    ExamSubject(
      id: 'waec-physics',
      name: 'WAEC Physics',
      hint: 'Mechanics · Waves · Electricity',
      emoji: '⚡',
      iconBg: '#0C1A3D',
      group: ExamSubjectGroup.waec,
    ),
    ExamSubject(
      id: 'waec-economics',
      name: 'WAEC Economics',
      hint: 'Micro · Macro · Trade',
      emoji: '💹',
      iconBg: '#2D1E00',
      group: ExamSubjectGroup.waec,
    ),
    ExamSubject(
      id: 'jamb-maths',
      name: 'JAMB Mathematics',
      hint: 'Sequences · Calculus · Statistics',
      emoji: '🧮',
      iconBg: '#1E1240',
      group: ExamSubjectGroup.jamb,
    ),
    ExamSubject(
      id: 'jamb-english',
      name: 'JAMB Use of English',
      hint: 'Lexis · Comprehension · Oral',
      emoji: '🌐',
      iconBg: '#1A1A21',
      group: ExamSubjectGroup.jamb,
    ),
    ExamSubject(
      id: 'jamb-government',
      name: 'JAMB Government',
      hint: 'Constitution · Politics · History',
      emoji: '🏛️',
      iconBg: '#2D1200',
      group: ExamSubjectGroup.jamb,
    ),
    ExamSubject(
      id: 'ielts',
      name: 'IELTS Academic',
      hint: 'Reading · Writing · Listening',
      emoji: '🌍',
      iconBg: '#052E1E',
      group: ExamSubjectGroup.international,
    ),
    ExamSubject(
      id: 'toefl',
      name: 'TOEFL iBT',
      hint: 'Reading · Listening · Speaking',
      emoji: '🇺🇸',
      iconBg: '#0C1A3D',
      group: ExamSubjectGroup.international,
    ),
    ExamSubject(
      id: 'gre-quant',
      name: 'GRE Quantitative',
      hint: 'Arithmetic · Algebra · Geometry',
      emoji: '🎓',
      iconBg: '#1E1240',
      group: ExamSubjectGroup.international,
    ),
  ];

  static List<ObjectiveQuestion> getObjectiveQuestions(String subjectId, {int count = 5}) {
    // TODO: Replace with Gemini API call
    return [
      const ObjectiveQuestion(
        question: 'If sin θ = 3/5 and θ is in Q1, what is cos θ?',
        options: ['4/5', '3/4', '5/3', '2/5'],
        correctIndex: 0,
        explanation: 'Using Pythagoras: cos²θ = 1 - sin²θ = 1 - 9/25 = 16/25, so cos θ = 4/5.',
      ),
      const ObjectiveQuestion(
        question: 'Simplify: (x² - 4) / (x - 2)',
        options: ['x - 2', 'x + 2', 'x² + 2', '2x'],
        correctIndex: 1,
        explanation: 'x² - 4 = (x+2)(x-2), dividing by (x-2) gives x + 2.',
      ),
      const ObjectiveQuestion(
        question: 'What is the derivative of f(x) = 3x² + 2x - 5?',
        options: ['6x + 2', '3x + 2', '6x - 5', '3x²'],
        correctIndex: 0,
        explanation: 'f\'(x) = 6x + 2 by the power rule.',
      ),
      const ObjectiveQuestion(
        question: 'A car travels 120km in 2 hours. What is its average speed?',
        options: ['60 km/h', '50 km/h', '70 km/h', '80 km/h'],
        correctIndex: 0,
        explanation: 'Speed = Distance/Time = 120/2 = 60 km/h.',
      ),
      const ObjectiveQuestion(
        question: 'Find the value of x: 2x + 3 = 11',
        options: ['3', '4', '5', '6'],
        correctIndex: 1,
        explanation: '2x = 11 - 3 = 8, so x = 4.',
      ),
    const ObjectiveQuestion(
        question: 'What is the area of a circle with radius 7cm? (π = 22/7)',
        options: ['154 cm²', '144 cm²', '164 cm²', '174 cm²'],
        correctIndex: 0,
        explanation: 'Area = πr² = 22/7 × 49 = 154 cm².',
      ),
      const ObjectiveQuestion(
        question: 'Solve: 3x - 7 = 14',
        options: ['5', '6', '7', '8'],
        correctIndex: 2,
        explanation: '3x = 21, x = 7.',
      ),
      const ObjectiveQuestion(
        question: 'What is the LCM of 4 and 6?',
        options: ['12', '24', '6', '8'],
        correctIndex: 0,
        explanation: 'LCM(4,6) = 12.',
      ),
      const ObjectiveQuestion(
        question: 'If a triangle has angles 40° and 70°, what is the third angle?',
        options: ['60°', '70°', '80°', '90°'],
        correctIndex: 1,
        explanation: '180° - 40° - 70° = 70°.',
      ),
      const ObjectiveQuestion(
        question: 'What is 15% of 200?',
        options: ['25', '30', '35', '40'],
        correctIndex: 1,
        explanation: '15/100 × 200 = 30.',
      ),
      const ObjectiveQuestion(
        question: 'Factorize: x² + 5x + 6',
        options: ['(x+2)(x+3)', '(x+1)(x+6)', '(x+2)(x+4)', '(x+3)(x+3)'],
        correctIndex: 0,
        explanation: 'Factors of 6 that add to 5 are 2 and 3.',
      ),
      const ObjectiveQuestion(
        question: 'What is the gradient of the line y = 3x + 5?',
        options: ['5', '3', '8', '1'],
        correctIndex: 1,
        explanation: 'In y = mx + c, m is the gradient. Here m = 3.',
      ),
      const ObjectiveQuestion(
        question: 'Convert 0.75 to a fraction in its lowest terms.',
        options: ['3/4', '7/10', '1/4', '4/5'],
        correctIndex: 0,
        explanation: '0.75 = 75/100 = 3/4.',
      ),
      const ObjectiveQuestion(
        question: 'What is the sum of interior angles of a pentagon?',
        options: ['360°', '450°', '540°', '720°'],
        correctIndex: 2,
        explanation: '(5-2) × 180° = 540°.',
      ),
      const ObjectiveQuestion(
        question: 'If 2^x = 32, find x.',
        options: ['4', '5', '6', '3'],
        correctIndex: 1,
        explanation: '2^5 = 32, so x = 5.',
      ),
      const ObjectiveQuestion(
        question: 'A rectangle has length 8cm and width 5cm. What is its perimeter?',
        options: ['26 cm', '40 cm', '13 cm', '24 cm'],
        correctIndex: 0,
        explanation: 'Perimeter = 2(l+w) = 2(8+5) = 26 cm.',
      ),
      const ObjectiveQuestion(
        question: 'Evaluate: 4! (4 factorial)',
        options: ['16', '24', '12', '8'],
        correctIndex: 1,
        explanation: '4! = 4×3×2×1 = 24.',
      ),
      const ObjectiveQuestion(
        question: 'What is the median of: 3, 7, 2, 9, 5?',
        options: ['5', '7', '3', '9'],
        correctIndex: 0,
        explanation: 'Sorted: 2,3,5,7,9. Middle value = 5.',
      ),
      const ObjectiveQuestion(
        question: 'If y varies directly as x and y=12 when x=4, find y when x=7.',
        options: ['18', '21', '24', '28'],
        correctIndex: 1,
        explanation: 'k = y/x = 3. y = 3×7 = 21.',
      ),
      const ObjectiveQuestion(
        question: 'What is the volume of a cube with side 3cm?',
        options: ['9 cm³', '18 cm³', '27 cm³', '36 cm³'],
        correctIndex: 2,
        explanation: 'V = s³ = 3³ = 27 cm³.',
      ),
    ].take(count).toList();
  }

  static List<TheoryQuestion> getTheoryQuestions(String subjectId, {int count = 2}) {
    // TODO: Replace with Gemini API call
    return [
      const TheoryQuestion(
        question: 'A circle has equation x² + y² − 6x + 4y − 12 = 0. Find the centre and radius, and determine whether the point (5, −1) lies inside, on, or outside the circle. Show all working clearly.',
        marks: 12,
        modelAnswer: 'Rewrite as (x−3)² + (y+2)² = 25.\nCentre = (3, −2), r = 5.\nd from (5,−1): √[(5−3)² + (−1+2)²] = √5.\nSince √5 < 5, point lies inside the circle.',
        markingPoints: [
          MarkingPoint(label: 'Centre found correctly', marks: 4, status: MarkingStatus.correct, feedback: 'Completed the square correctly. Centre (3,−2) stated clearly.'),
          MarkingPoint(label: 'Radius correct', marks: 3, status: MarkingStatus.correct, feedback: 'r = 5 derived with full working shown.'),
          MarkingPoint(label: 'Point location — partial', marks: 2, status: MarkingStatus.partial, feedback: 'Substitution correct but conclusion not formally stated.'),
          MarkingPoint(label: 'Formal proof missing', marks: 0, status: MarkingStatus.wrong, feedback: '"Since d < r, point lies INSIDE circle" not written.'),
        ],
      ),
      const TheoryQuestion(
        question: 'Prove that the sum of angles in a triangle is 180°. Use a diagram and show full working.',
        marks: 8,
        modelAnswer: 'Draw line parallel to base through apex. Using alternate angles and co-interior angles, the three angles at the apex sum to 180°, which equals the sum of angles in the triangle.',
        markingPoints: [
          MarkingPoint(label: 'Parallel line drawn', marks: 2, status: MarkingStatus.correct, feedback: 'Correctly extended line through apex.'),
          MarkingPoint(label: 'Alternate angles used', marks: 3, status: MarkingStatus.correct, feedback: 'All alternate angle pairs correctly identified.'),
          MarkingPoint(label: 'Conclusion stated', marks: 3, status: MarkingStatus.partial, feedback: 'Proof incomplete — final statement missing.'),
       ],
      ),
    ].take(count).toList();
  }
}
