import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';

const String excelFontFamily = 'Gilroy';

/// Number format that keeps negative values readable (shown in red).
const String excelNumberFormat = r'#,##0.00;[Red]-#,##0.00';

/// Custom `numFmtId`s must be >= 164; ids below that are reserved by Excel.
const int _customNumberFormatId = 164;

/// One plotted series of [ExcelChartSpec].
class ExcelChartSeries {
  const ExcelChartSeries({
    required this.column,
    required this.name,
    required this.colorHex,
    required this.values,
    this.asLine = false,
  });

  /// Worksheet column letter holding the values (e.g. `B`).
  final String column;

  /// Header text, also used as the series name.
  final String name;

  /// `RRGGBB` fill (columns) or stroke (line) colour.
  final String colorHex;

  /// Values in row order, used for the chart's cached numbers.
  final List<double> values;

  /// When true the series is drawn as a line on the secondary axis instead of
  /// a clustered column.
  final bool asLine;
}

/// Everything needed to inject a native, editable Excel chart into a sheet.
class ExcelChartSpec {
  const ExcelChartSpec({
    required this.sheetName,
    required this.title,
    required this.categoryColumn,
    required this.categories,
    required this.series,
    required this.firstDataRow,
    required this.totalRow,
  });

  /// Name of the worksheet the chart is anchored to. Only the workbook's first
  /// sheet (`xl/worksheets/sheet1.xml`) is supported.
  final String sheetName;

  final String title;

  /// Column holding the category labels (months).
  final String categoryColumn;

  /// Category labels, used for the chart's cached strings.
  final List<String> categories;

  final List<ExcelChartSeries> series;

  /// 1-based row of the first data row (the header sits on row 1).
  final int firstDataRow;

  /// 1-based row of the `Total` row, or `null` when there is none. It is styled
  /// like the other numbers but deliberately kept out of the chart range.
  final int? totalRow;

  int get lastDataRow => firstDataRow + categories.length - 1;

  /// Last row that should get the numeric cell format.
  int get lastNumberRow => totalRow ?? lastDataRow;

  List<String> get valueColumns =>
      series.map((item) => item.column).toList(growable: false);
}

/// Applies the app's typeface to every populated cell and makes first rows
/// visually distinct before the workbook is encoded.
void styleExcelWorkbook(Excel excel) {
  for (final sheet in excel.tables.values) {
    for (final row in sheet.rows) {
      // Cell values are SharedString/CellValue objects, so compare on text.
      final isEmphasizedRow = row.isNotEmpty &&
          (row.first?.rowIndex == 0 ||
              row.first?.value?.toString() == 'Total');
      for (final cell in row) {
        if (cell == null) continue;
        cell.cellStyle = CellStyle(
          fontFamily: excelFontFamily,
          fontSize: 11,
          bold: isEmphasizedRow,
        );
      }
    }
  }
}

/// Uses file_saver instead of Excel.save so downloads also work in Flutter
/// Web's Wasm build, where the older excel package only returns the bytes.
///
/// When [chart] is given, the encoded workbook is post-processed: the excel
/// package (2.1.0) supports neither number formats nor charts, so the required
/// OOXML parts are written straight into the XLSX zip.
Future<void> downloadExcel(
  Excel excel,
  String fileName, {
  ExcelChartSpec? chart,
}) async {
  final bytes = encodeExcel(excel, chart: chart);

  final name = fileName.toLowerCase().endsWith('.xlsx')
      ? fileName.substring(0, fileName.length - 5)
      : fileName;
  await FileSaver.instance.saveFile(
    name: name,
    bytes: Uint8List.fromList(bytes),
    fileExtension: 'xlsx',
    mimeType: MimeType.microsoftExcel,
  );
}

String excelTimestamp([DateTime? dateTime]) {
  final value = dateTime ?? DateTime.now();
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${value.year}${twoDigits(value.month)}${twoDigits(value.day)}_'
      '${twoDigits(value.hour)}${twoDigits(value.minute)}${twoDigits(value.second)}';
}

// ---------------------------------------------------------------------------
// XLSX post-processing
// ---------------------------------------------------------------------------

const String _sheetPath = 'xl/worksheets/sheet1.xml';
const String _sheetRelsPath = 'xl/worksheets/_rels/sheet1.xml.rels';
const String _stylesPath = 'xl/styles.xml';
const String _drawingPath = 'xl/drawings/drawing1.xml';
const String _drawingRelsPath = 'xl/drawings/_rels/drawing1.xml.rels';
const String _chartPath = 'xl/charts/chart1.xml';
const String _contentTypesPath = '[Content_Types].xml';

const String _chartContentType =
    'application/vnd.openxmlformats-officedocument.drawingml.chart+xml';
const String _drawingContentType =
    'application/vnd.openxmlformats-officedocument.drawing+xml';
const String _drawingRelType =
    'http://schemas.openxmlformats.org/officeDocument/2006/relationships/drawing';
const String _chartRelType =
    'http://schemas.openxmlformats.org/officeDocument/2006/relationships/chart';

/// Styles and encodes the workbook, optionally injecting the native chart.
/// Split out from [downloadExcel] so the bytes can be produced (and verified)
/// without touching the file system.
List<int> encodeExcel(Excel excel, {ExcelChartSpec? chart}) {
  styleExcelWorkbook(excel);
  final bytes = excel.encode();
  if (bytes == null || bytes.isEmpty) {
    throw StateError('Excel file could not be generated.');
  }
  return chart == null ? bytes : _injectChart(bytes, chart);
}

/// Rewrites the encoded workbook so the first sheet carries a native chart and
/// its numbers use [excelNumberFormat].
List<int> _injectChart(List<int> bytes, ExcelChartSpec spec) {
  final archive = ZipDecoder().decodeBytes(bytes);
  final files = <String, String>{};
  for (final file in archive.files) {
    if (!file.isFile) continue;
    files[file.name] = _asString(file);
  }

  final styles = files[_stylesPath];
  final sheet = files[_sheetPath];
  final contentTypes = files[_contentTypesPath];
  if (styles == null || sheet == null || contentTypes == null) {
    // Nothing to patch safely - hand back the untouched workbook.
    return bytes;
  }

  final numericStyles = _patchStyles(styles);
  files[_stylesPath] = numericStyles.xml;
  files[_sheetPath] = _patchSheet(sheet, spec, numericStyles);
  // The per-month sheets get the same numeric formatting.
  final monthSheet = RegExp(r'^xl/worksheets/sheet\d+\.xml$');
  for (final name in files.keys.toList()) {
    if (name == _sheetPath || !monthSheet.hasMatch(name)) continue;
    files[name] = _patchNumericCells(files[name]!, numericStyles);
  }
  files[_sheetRelsPath] = _sheetRelsXml(files[_sheetRelsPath]);
  files[_drawingPath] = _drawingXml();
  files[_drawingRelsPath] = _drawingRelsXml();
  files[_chartPath] = _chartXml(spec);
  files[_contentTypesPath] = _patchContentTypes(contentTypes);

  final output = Archive();
  for (final entry in files.entries) {
    final content = _utf8Bytes(entry.value);
    output.addFile(ArchiveFile(entry.key, content.length, content));
  }
  final encoded = ZipEncoder().encode(output);
  return encoded == null || encoded.isEmpty ? bytes : encoded;
}

String _asString(ArchiveFile file) {
  final content = file.content;
  final data = content is List<int> ? content : const <int>[];
  return utf8.decode(data, allowMalformed: true);
}

List<int> _utf8Bytes(String value) => utf8.encode(value);

String _escapeText(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

String _escapeAttribute(String value) =>
    _escapeText(value).replaceAll('"', '&quot;');

/// Result of adding number-formatted variants of every existing cell format.
class _NumericStyles {
  const _NumericStyles(this.xml, this.originalCount);

  final String xml;

  /// Number of `cellXfs` entries before the variants were appended; a cell
  /// using style `i` must switch to `originalCount + i`.
  final int originalCount;

  int variantFor(int styleIndex) =>
      styleIndex < originalCount ? originalCount + styleIndex : styleIndex;
}

/// Adds the custom number format and a formatted twin for every `cellXfs`
/// entry, so numeric cells keep their font/bold styling.
_NumericStyles _patchStyles(String xml) {
  var result = xml;

  if (!result.contains('numFmtId="$_customNumberFormatId"')) {
    final numFmts = '<numFmts count="1">'
        '<numFmt numFmtId="$_customNumberFormatId" '
        'formatCode="${_escapeAttribute(excelNumberFormat)}"/>'
        '</numFmts>';
    // `numFmts` must be the first child of `styleSheet`.
    result = result.replaceFirstMapped(
      RegExp(r'(<styleSheet\b[^>]*>)'),
      (match) => '${match[1]}$numFmts',
    );
  }

  final cellXfs = RegExp(r'<cellXfs\b[^>]*>([\s\S]*?)</cellXfs>');
  final match = cellXfs.firstMatch(result);
  if (match == null) return _NumericStyles(result, 0);

  final inner = match[1] ?? '';
  final entries = RegExp(r'<xf\b[^>]*/>|<xf\b[^>]*>[\s\S]*?</xf>')
      .allMatches(inner)
      .map((entry) => entry[0]!)
      .toList();
  if (entries.isEmpty) return _NumericStyles(result, 0);

  final variants = entries.map(_numberFormatVariant).join();
  final count = entries.length;
  result = result.replaceFirst(
    match[0]!,
    '<cellXfs count="${count * 2}">$inner$variants</cellXfs>',
  );
  return _NumericStyles(result, count);
}

String _numberFormatVariant(String xf) {
  var variant = xf.replaceFirst(
    RegExp(r'numFmtId="\d+"'),
    'numFmtId="$_customNumberFormatId"',
  );
  if (!variant.contains('numFmtId=')) {
    variant = variant.replaceFirst('<xf', '<xf numFmtId="$_customNumberFormatId"');
  }
  if (!variant.contains('applyNumberFormat=')) {
    variant = variant.replaceFirst('<xf', '<xf applyNumberFormat="1"');
  }
  return variant;
}

/// Points every numeric data cell of the chart's columns at the formatted
/// style variant, and makes sure the sheet references the drawing.
String _patchSheet(String xml, ExcelChartSpec spec, _NumericStyles styles) {
  final columns = spec.valueColumns.toSet();
  var result = xml.replaceAllMapped(
    RegExp(r'<c r="([A-Z]+)(\d+)"([^>]*?)(/?)>'),
    (match) {
      final column = match[1]!;
      final row = int.parse(match[2]!);
      final attributes = match[3] ?? '';
      final selfClosing = match[4] ?? '';
      final isNumeric = !attributes.contains('t="s"') &&
          !attributes.contains('t="str"') &&
          !attributes.contains('t="b"');
      if (!columns.contains(column) ||
          row < spec.firstDataRow ||
          row > spec.lastNumberRow ||
          !isNumeric) {
        return match[0]!;
      }
      return '<c r="$column$row"'
          '${_withNumericStyle(attributes, styles)}$selfClosing>';
    },
  );

  if (!result.contains('<drawing ')) {
    result = result.replaceFirst('</worksheet>', '<drawing r:id="rId1"/></worksheet>');
  }
  return result;
}

/// Applies the numeric style variant to every numeric cell of a sheet.
String _patchNumericCells(String xml, _NumericStyles styles) {
  return xml.replaceAllMapped(
    RegExp(r'<c r="([A-Z]+)(\d+)"([^>]*?)(/?)>'),
    (match) {
      final attributes = match[3] ?? '';
      final isNumeric = !attributes.contains('t="s"') &&
          !attributes.contains('t="str"') &&
          !attributes.contains('t="b"');
      if (!isNumeric) return match[0]!;
      return '<c r="${match[1]}${match[2]}"'
          '${_withNumericStyle(attributes, styles)}${match[4]}>';
    },
  );
}

/// Replaces (or adds) the `s` attribute so the cell uses the formatted twin of
/// its current style.
String _withNumericStyle(String attributes, _NumericStyles styles) {
  final current = RegExp(r's="(\d+)"').firstMatch(attributes);
  final index =
      styles.variantFor(current == null ? 0 : int.parse(current[1]!));
  return current == null
      ? '$attributes s="$index"'
      : attributes.replaceFirst(current[0]!, 's="$index"');
}

String _sheetRelsXml(String? existing) {
  if (existing != null && existing.contains(_drawingRelType)) return existing;
  return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="$_drawingRelType" Target="../drawings/drawing1.xml"/>'
      '</Relationships>';
}

/// Anchors the chart below the data on the first sheet.
String _drawingXml() {
  return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<xdr:wsDr xmlns:xdr="http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing" '
      'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
      '<xdr:twoCellAnchor>'
      '<xdr:from><xdr:col>0</xdr:col><xdr:colOff>0</xdr:colOff>'
      '<xdr:row>17</xdr:row><xdr:rowOff>0</xdr:rowOff></xdr:from>'
      '<xdr:to><xdr:col>8</xdr:col><xdr:colOff>0</xdr:colOff>'
      '<xdr:row>40</xdr:row><xdr:rowOff>0</xdr:rowOff></xdr:to>'
      '<xdr:graphicFrame macro="">'
      '<xdr:nvGraphicFramePr>'
      '<xdr:cNvPr id="2" name="Monthly Financial Summary"/>'
      '<xdr:cNvGraphicFramePr/>'
      '</xdr:nvGraphicFramePr>'
      '<xdr:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/></xdr:xfrm>'
      '<a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/chart">'
      '<c:chart xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" r:id="rId1"/>'
      '</a:graphicData></a:graphic>'
      '</xdr:graphicFrame>'
      '<xdr:clientData/>'
      '</xdr:twoCellAnchor>'
      '</xdr:wsDr>';
}

String _drawingRelsXml() {
  return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="$_chartRelType" Target="../charts/chart1.xml"/>'
      '</Relationships>';
}

String _patchContentTypes(String xml) {
  var result = xml;
  if (!result.contains('PartName="/xl/charts/chart1.xml"')) {
    result = result.replaceFirst('</Types>',
        '<Override PartName="/xl/charts/chart1.xml" ContentType="$_chartContentType"/></Types>');
  }
  if (!result.contains('PartName="/xl/drawings/drawing1.xml"')) {
    result = result.replaceFirst('</Types>',
        '<Override PartName="/xl/drawings/drawing1.xml" ContentType="$_drawingContentType"/></Types>');
  }
  return result;
}

// ---------------------------------------------------------------------------
// chart1.xml
// ---------------------------------------------------------------------------

const int _barCategoryAxisId = 111111111;
const int _barValueAxisId = 222222222;
const int _lineCategoryAxisId = 333333333;
const int _lineValueAxisId = 444444444;

String _sheetRef(String sheetName) =>
    RegExp(r"^[A-Za-z0-9_]+$").hasMatch(sheetName)
        ? sheetName
        : "'${sheetName.replaceAll("'", "''")}'";

/// A combo chart: clustered columns for the cost/revenue series and a line on
/// the secondary axis for net profit, which usually lives on a smaller scale.
String _chartXml(ExcelChartSpec spec) {
  final columnSeries =
      spec.series.where((series) => !series.asLine).toList(growable: false);
  final lineSeries =
      spec.series.where((series) => series.asLine).toList(growable: false);

  final buffer = StringBuffer()
    ..write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
    ..write('<c:chartSpace '
        'xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart" '
        'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">')
    ..write('<c:lang val="en-US"/>')
    ..write('<c:roundedCorners val="0"/>')
    ..write('<c:chart>')
    ..write(_chartTitle(spec.title))
    ..write('<c:autoTitleDeleted val="0"/>')
    ..write('<c:plotArea><c:layout/>');

  if (columnSeries.isNotEmpty) {
    buffer
      ..write('<c:barChart>')
      ..write('<c:barDir val="col"/>')
      ..write('<c:grouping val="clustered"/>')
      ..write('<c:varyColors val="0"/>');
    for (var index = 0; index < columnSeries.length; index++) {
      buffer.write(_series(spec, columnSeries[index], index, line: false));
    }
    buffer
      ..write('<c:gapWidth val="120"/>')
      ..write('<c:overlap val="-20"/>')
      ..write('<c:axId val="$_barCategoryAxisId"/>')
      ..write('<c:axId val="$_barValueAxisId"/>')
      ..write('</c:barChart>');
  }

  if (lineSeries.isNotEmpty) {
    buffer
      ..write('<c:lineChart>')
      ..write('<c:grouping val="standard"/>')
      ..write('<c:varyColors val="0"/>');
    for (var index = 0; index < lineSeries.length; index++) {
      buffer.write(_series(
          spec, lineSeries[index], columnSeries.length + index,
          line: true));
    }
    buffer
      ..write('<c:marker val="1"/>')
      ..write('<c:axId val="$_lineCategoryAxisId"/>')
      ..write('<c:axId val="$_lineValueAxisId"/>')
      ..write('</c:lineChart>');
  }

  // Primary pair (columns): months on the bottom, values on the left.
  buffer
    ..write(_categoryAxis(
        axisId: _barCategoryAxisId,
        crossAxisId: _barValueAxisId,
        deleted: false))
    ..write(_valueAxis(
        axisId: _barValueAxisId,
        crossAxisId: _barCategoryAxisId,
        position: 'l',
        crossesMax: false,
        majorGridlines: true));

  if (lineSeries.isNotEmpty) {
    // Secondary pair (net profit line): hidden category axis, right value axis.
    buffer
      ..write(_valueAxis(
          axisId: _lineValueAxisId,
          crossAxisId: _lineCategoryAxisId,
          position: 'r',
          crossesMax: true,
          majorGridlines: false))
      ..write(_categoryAxis(
          axisId: _lineCategoryAxisId,
          crossAxisId: _lineValueAxisId,
          deleted: true));
  }

  buffer
    ..write('</c:plotArea>')
    ..write('<c:legend><c:legendPos val="t"/><c:overlay val="0"/>'
        '${_textProperties()}</c:legend>')
    ..write('<c:plotVisOnly val="1"/>')
    ..write('<c:dispBlanksAs val="gap"/>')
    ..write('</c:chart>')
    ..write(_textProperties())
    ..write('</c:chartSpace>');
  return buffer.toString();
}

String _chartTitle(String title) {
  return '<c:title><c:tx><c:rich>'
      '<a:bodyPr rot="0" spcFirstLastPara="1" vertOverflow="ellipsis" vert="horz" wrap="square" anchor="ctr" anchorCtr="1"/>'
      '<a:lstStyle/>'
      '<a:p><a:pPr><a:defRPr sz="1400" b="1">'
      '<a:latin typeface="$excelFontFamily"/><a:cs typeface="$excelFontFamily"/>'
      '</a:defRPr></a:pPr>'
      '<a:r><a:rPr lang="en-US" sz="1400" b="1">'
      '<a:latin typeface="$excelFontFamily"/><a:cs typeface="$excelFontFamily"/>'
      '</a:rPr><a:t>${_escapeText(title)}</a:t></a:r>'
      '</a:p></c:rich></c:tx>'
      '<c:overlay val="0"/></c:title>';
}

/// Shared font settings so every label in the chart uses the app typeface.
String _textProperties() {
  return '<c:txPr><a:bodyPr/><a:lstStyle/>'
      '<a:p><a:pPr><a:defRPr sz="1000">'
      '<a:latin typeface="$excelFontFamily"/><a:cs typeface="$excelFontFamily"/>'
      '</a:defRPr></a:pPr><a:endParaRPr lang="en-US"/></a:p></c:txPr>';
}

String _series(ExcelChartSpec spec, ExcelChartSeries series, int index,
    {required bool line}) {
  final sheet = _sheetRef(spec.sheetName);
  final headerRef = '$sheet!\$${series.column}\$1';
  final categoryRef =
      '$sheet!\$${spec.categoryColumn}\$${spec.firstDataRow}:'
      '\$${spec.categoryColumn}\$${spec.lastDataRow}';
  final valueRef = '$sheet!\$${series.column}\$${spec.firstDataRow}:'
      '\$${series.column}\$${spec.lastDataRow}';

  final shape = line
      ? '<c:spPr><a:ln w="28575" cap="rnd">'
          '<a:solidFill><a:srgbClr val="${series.colorHex}"/></a:solidFill>'
          '<a:round/></a:ln><a:effectLst/></c:spPr>'
          '<c:marker><c:symbol val="circle"/><c:size val="6"/>'
          '<c:spPr><a:solidFill><a:srgbClr val="${series.colorHex}"/></a:solidFill>'
          '<a:ln w="9525"><a:solidFill><a:srgbClr val="FFFFFF"/></a:solidFill></a:ln>'
          '</c:spPr></c:marker>'
      : '<c:spPr><a:solidFill><a:srgbClr val="${series.colorHex}"/></a:solidFill>'
          '<a:ln><a:noFill/></a:ln></c:spPr>'
          '<c:invertIfNegative val="0"/>';

  return '<c:ser>'
      '<c:idx val="$index"/>'
      '<c:order val="$index"/>'
      '<c:tx><c:strRef><c:f>$headerRef</c:f>'
      '<c:strCache><c:ptCount val="1"/>'
      '<c:pt idx="0"><c:v>${_escapeText(series.name)}</c:v></c:pt>'
      '</c:strCache></c:strRef></c:tx>'
      '$shape'
      '<c:cat><c:strRef><c:f>$categoryRef</c:f>'
      '${_stringCache(spec.categories)}</c:strRef></c:cat>'
      '<c:val><c:numRef><c:f>$valueRef</c:f>'
      '${_numberCache(series.values)}</c:numRef></c:val>'
      '${line ? '<c:smooth val="0"/>' : ''}'
      '</c:ser>';
}

String _stringCache(List<String> values) {
  final buffer = StringBuffer('<c:strCache><c:ptCount val="${values.length}"/>');
  for (var index = 0; index < values.length; index++) {
    buffer.write(
        '<c:pt idx="$index"><c:v>${_escapeText(values[index])}</c:v></c:pt>');
  }
  return (buffer..write('</c:strCache>')).toString();
}

String _numberCache(List<double> values) {
  final buffer = StringBuffer('<c:numCache>'
      '<c:formatCode>${_escapeText(excelNumberFormat)}</c:formatCode>'
      '<c:ptCount val="${values.length}"/>');
  for (var index = 0; index < values.length; index++) {
    buffer.write('<c:pt idx="$index"><c:v>${values[index]}</c:v></c:pt>');
  }
  return (buffer..write('</c:numCache>')).toString();
}

String _categoryAxis({
  required int axisId,
  required int crossAxisId,
  required bool deleted,
}) {
  return '<c:catAx>'
      '<c:axId val="$axisId"/>'
      '<c:scaling><c:orientation val="minMax"/></c:scaling>'
      '<c:delete val="${deleted ? 1 : 0}"/>'
      '<c:axPos val="b"/>'
      '<c:majorTickMark val="none"/>'
      '<c:minorTickMark val="none"/>'
      '<c:tickLblPos val="${deleted ? 'none' : 'nextTo'}"/>'
      '${_textProperties()}'
      '<c:crossAx val="$crossAxisId"/>'
      '<c:crosses val="autoZero"/>'
      '<c:auto val="1"/>'
      '<c:lblAlgn val="ctr"/>'
      '<c:lblOffset val="100"/>'
      '<c:noMultiLvlLbl val="0"/>'
      '</c:catAx>';
}

String _valueAxis({
  required int axisId,
  required int crossAxisId,
  required String position,
  required bool crossesMax,
  required bool majorGridlines,
}) {
  return '<c:valAx>'
      '<c:axId val="$axisId"/>'
      '<c:scaling><c:orientation val="minMax"/></c:scaling>'
      '<c:delete val="0"/>'
      '<c:axPos val="$position"/>'
      '${majorGridlines ? '<c:majorGridlines/>' : ''}'
      '<c:numFmt formatCode="${_escapeAttribute(excelNumberFormat)}" sourceLinked="0"/>'
      '<c:majorTickMark val="none"/>'
      '<c:minorTickMark val="none"/>'
      '<c:tickLblPos val="nextTo"/>'
      '${_textProperties()}'
      '<c:crossAx val="$crossAxisId"/>'
      '<c:crosses val="${crossesMax ? 'max' : 'autoZero'}"/>'
      '<c:crossBetween val="between"/>'
      '</c:valAx>';
}
