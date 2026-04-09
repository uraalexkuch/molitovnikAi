
class Meal {
  final String id;
  final List<String> categories;
  final String title;
  final String imgPath;
  final List<String> titlestep;
  final List<String> steps;
  final int duration;

  const Meal({
    required this.id,
    required this.categories,
    required this.title,
    required this.imgPath,
    required this.steps,
    required this.titlestep,
    required this.duration,
  });
}
