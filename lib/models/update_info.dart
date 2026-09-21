class UpdateInfo {
  final String latestVersion;
  final String releaseNotes;
  final String downloadUrl;
  final bool isMandatory;
  final bool hasUpdate;

  UpdateInfo({
    required this.latestVersion,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.isMandatory,
    required this.hasUpdate,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json, bool hasUpdate) {
    return UpdateInfo(
      latestVersion: json['latestVersion'] ?? '',
      releaseNotes: json['releaseNotes'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
      isMandatory: json['isMandatory'] ?? false,
      hasUpdate: hasUpdate,
    );
  }
}
