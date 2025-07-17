import 'dart:html' as html;

void saveExcelWeb(List<int> fileBytes, String fileName) {
  final blob = html.Blob([
    fileBytes,
  ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
