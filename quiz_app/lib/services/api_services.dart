import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question_model.dart';


class ApiService {
static Future<List<Question>> fetchQuestions() async {
final url = Uri.parse('https://opentdb.com/api.php?amount=5&type=multiple');
final response = await http.get(url);
final data = json.decode(response.body);


return (data['results'] as List)
.map((q) => Question.fromJson(q))
.toList();
}
}