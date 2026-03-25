class IptvChannel {
  const IptvChannel({
    required this.id,
    required this.name,
    required this.url,
    this.logo,
    this.groupTitle,
  });

  final String id;
  final String name;
  final String url;
  final String? logo;
  final String? groupTitle;
}
