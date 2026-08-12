class SauceNaoResult {
  final int illustId;
  final String? thumbnail;
  final String? similarity;
  final String? title;
  final String? author;

  const SauceNaoResult({
    required this.illustId,
    this.thumbnail,
    this.similarity,
    this.title,
    this.author,
  });
}
