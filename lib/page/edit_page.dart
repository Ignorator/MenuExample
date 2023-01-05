// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import '../main.dart';
import '../model/model.dart';
import '../page/progress_dialog.dart';
import '../page/listview_elements.dart';
import 'dart:typed_data';
import 'package:translator/translator.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';


class Utility {
  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.scaleDown,
    );
  }
  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }
  static String base64String(Uint8List data) {
    return base64Encode(data);
  }
}

class EditNotePage extends StatefulWidget {
  /// null when adding a note
  final DbNote? initialNote;

  final String selected_lang;

  const EditNotePage({Key? key, required this.initialNote, required this.selected_lang}) : super(key: key);
  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {

  GoogleTranslator translator = new GoogleTranslator();

  Future<String> trans(String input, String langCode) async
  {
    String retVal = ' ';
    await translator.translate(input, to: langCode)   //translating to hi = hindi
        .then((output)
    {
      retVal = output.toString();
    });
    return retVal;
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController? _titleTextController;
  TextEditingController? _contentTextController;
  TextEditingController? _priceTextController;
  var _selectedValue;
  var _selectedLangValue;
  var _imgString = 'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE7mlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNi4wLWMwMDYgNzkuZGFiYWNiYiwgMjAyMS8wNC8xNC0wMDozOTo0NCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpwaG90b3Nob3A9Imh0dHA6Ly9ucy5hZG9iZS5jb20vcGhvdG9zaG9wLzEuMC8iIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIyLjQgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMS0xMC0wNFQxMjo1NzoxMSswMjowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMS0xMC0wNFQxMjo1NzoxMSswMjowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjEtMTAtMDRUMTI6NTc6MTErMDI6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOmQ3NjlkYzk4LTQ3Y2YtMGM0OC1iMDdiLTU3NTMwZGRlZWQ2MyIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpkNzY5ZGM5OC00N2NmLTBjNDgtYjA3Yi01NzUzMGRkZWVkNjMiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkNzY5ZGM5OC00N2NmLTBjNDgtYjA3Yi01NzUzMGRkZWVkNjMiIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmQ3NjlkYzk4LTQ3Y2YtMGM0OC1iMDdiLTU3NTMwZGRlZWQ2MyIgc3RFdnQ6d2hlbj0iMjAyMS0xMC0wNFQxMjo1NzoxMSswMjowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIyLjQgKFdpbmRvd3MpIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PnsiyycAAAglSURBVGiB7VrZcuO4DgVIidRmOY7TM///e9OdeNEukcB9oC1Tku046a5Jza0gVUkkgdABiI2wsa5r+C+T+GoAv0vfCnw1fSvw1fStwFfTtwJfTd8KfDVdV4A9+pcBXSVEJKKrj4LZNTM3TQOAgEBEQgitVBAEj2uCiACAAP4CdMIBPmERRKzqer8/ZGm6zlez9QsFACyRQIGATMzwgU1w0I0xwzAMxhhjrbXMLBBlIMPA/QRSSviIJsxclhURlVWVJHEYhv7aiQKISNYSEUpEAAYGgEdeJBAtUVVVddNaaxExDAIZBEEQIAAzE1HTtrY0DBAEQZYmURQh4rtqIKKzhBDCyZkxzHeAiE5CEQEA8B1TORDHoiyrChGTONZaSyndbiyFG2Partvtj1IUeb6K4xje241hMETkBC45Fy5E5JyX6cTKfD16AEAgtl233x8YIF+ttNbja65iQkSllFYqS9OmaXaHQ1XXT+v1nRhDAGvtBd6Ca56FaJR0DsNbogViUZa/Xt+01i/bbRRFd6B7CJiYETHLspfnLTP88/NX13VC3EjoCJZolMgwt+Z82cnw5+DFGzEgBB6OxeFYPK3XeZ7P9ETE2Vagd9MREUkpnzebJEl+vb41TXNdBwYii97lzDWnQQxAzmHwlPNgvDNBL45FUVbV82ajtfYDyyXstuuMMedXniIKAcIwVEqNset+56uVEOL1bfeyFZFWNDUYA4zymWFZDK7UAZc3mE5ZyFrrJ3VErJvmeCw2U/QOet00xhh5rh7+PgzGdH3ftq1SKo4iOKtBRFmSMNHr29vff/2QUs6ccIxGQJhWF4ArLnS2DZ/wo7V23DZEJEu73X6VZdEUfT8Mx6JwFs2yzFl6fCqEiLR2jwZjDkXhsq1jIOYsy8IwfNvtl3j8PeFHFCBmIrLGWGuNNXyJa0CA/fEYBEGapj76ruuqqsrSNEtTuBHK7qYQwuWroiiMMX5UrNf5MAxVXc9S8CQNvptGEbBuGnEW0XadSy9wNnPTNNvn5ws/Ytd1Tds+rdd3OpaZJpHWUoiiLF0AuJtSyFWWFcciieOp2nfwT3eAAZQKYbKAAynHy6IotdZ+MbdEddOssuyRsuqLDcMwjuOyLEd7M7Ora23bXhoqHtPhGeI9BZjjOM7zbIyEKNKrfOWeElHX92mSjPyIWFVVHMfLyHtEh0hrKWXdNH60xElSltX4AseLF/wPxMA6z52LK6VetlspBDMjYt/3iDiaHxGHYQDmSOvPdd3MnCTJMAz+8khrY605hzgReXUMeOFE1+uf1oqZwzAQnmO4DOhHWNt1SqlPQL+8XggpRNd1Y8J1fdQwDI5hUmQe2YETH43J9EJ9P6gwHC+ZmYmUUr956AmV6s9wAQARpZR93+NZwwn3u73QhNHLKEREzPIc0K7HQiFu9jCPETOHQQDTTiQMgr4f3OknCAK/1Xu/mfP5CC6ZnpmBGUe4iH6T+DvkeqTJGSUI+Fx+BWKaJne2+I79cJqA/WR2uiOuNf0fJTxL824hXzoxztI0TZITw2ILbh7qxyQ8Cl2C/SMH/nP3PhE/K8XrfBXcyNQ3FAD2Q56ZBQAg+G3JJ3L/TZpuJlkL094bzno+lIU8sZf/UQh3Yj4/YinlvNB/nBDRWOvqzHhzMCYIpM90R8JtFzr9HXcYpQyMF7julD1ryD5BwzBIr1sBAGOM1nqC5/QLH8pCPK6YmjeKdNd1PmcYhl3ffxb56V1mGEa4LjsTURiEU76bO30zBsC5EPNoXq21tXY0OTNHUWSN+fQmIGLXtoB4yfSIwzAgYhjOj/nMjNcOuPfL0GW+4iqOlKL1NgERoyiqPvtBLRG1bet3hwBQN00Sx7ME7bdDM7oXA24ud4ELkKVpXdf+lEZrLYQoq+oTJbkoiiiKxmzmzhvDMCwr151U8Z4C3k1iTpJYCFFVNXqcWZoSkevsH/Ekx3UsijAMoyjywRVFEUfRMuVfEvoiGm4oQC6vLUd5uM7zqq76qd+vsoyYj8ejZcZFCvehCyH6YdgfDioMk7G+Aggh6ro2xuR5vrT2nXHT/Eg58oMLmKkCzBxHOk2T/X6/fX52mXTUoW3bsiyllFrrYDFdZOa+77uuc92Bf6xzh41jUWw2T4EUtMB6x4WuKMA8Vly2i5XE/JTnP/vX/eGw2Wz8IU8URVrrtm3ruhZ4IkB0BnSjbq21S5o+emvtbrfLsjSN4yV6gHtNy9UduEi/rjridvv889frbrfbPD3NBlVxHMdxbM/EACiElDKQcjy/j5IE4mDM226no2id59fRT4A9oMDE4a5JdNORl+3z69vu9e1tvV6rMPTmZwzuqDWtrzM/dg7WtO3heIzjaPP0dMdPli3QSNcqMbPXxs1nkSOPlPLHy1ap8PX1tShLABALp/fJh+7cZn847A+HfLW6j/4+LeZCiM5hEZGYLdn5p0UePgB43jxFUXQ4HJu6TtLUDRpmPOA348zGmLppmqYJw/CvHz9UGLzrOXg249KaV1wIUZxGVNMm8SoRcRxFkdZN0xRlVVWVlFIrpZQSQoynLWIma7uu64eBLIUq2D5vXDS/i36myjsKMLOUIk3ToiiUUmkc3/5847IEAJIkieN4GIau65q2a9rWPRhD3H3ulKWpUioM5+fg++TmxNaSlMHs/Im3vnJGRIhCiA/M2+Dk324O7iY6DAyIgEIIJw7nHcqDgvuht8ZqrWY9y00FPjQqvCXBv/wj0pZCrteB33/fH5HwiLT/068a/IfoW4Gvpm8Fvpq+Ffhq+lbgq+l/uKLfsLSnQGUAAAAASUVORK5CYII=';
  final picker = ImagePicker();

  int? get _noteId => widget.initialNote?.id.v;
  @override
  void initState() {
    super.initState();
    _titleTextController =
        TextEditingController(text: widget.initialNote?.title.v);
    _contentTextController =
        TextEditingController(text: widget.initialNote?.content.v);
    _priceTextController =
        TextEditingController(text: widget.initialNote?.price.v);
    _selectedValue = widget.initialNote?.type.v;
    _selectedLangValue = widget.initialNote?.langName.v;
    _imgString = widget.initialNote?.picture.v ?? 'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE7mlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNi4wLWMwMDYgNzkuZGFiYWNiYiwgMjAyMS8wNC8xNC0wMDozOTo0NCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpwaG90b3Nob3A9Imh0dHA6Ly9ucy5hZG9iZS5jb20vcGhvdG9zaG9wLzEuMC8iIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIyLjQgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMS0xMC0wNFQxMjo1NzoxMSswMjowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMS0xMC0wNFQxMjo1NzoxMSswMjowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjEtMTAtMDRUMTI6NTc6MTErMDI6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOmQ3NjlkYzk4LTQ3Y2YtMGM0OC1iMDdiLTU3NTMwZGRlZWQ2MyIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpkNzY5ZGM5OC00N2NmLTBj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';
  }

  Future<bool> IsInternetConnected() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return Future<bool>.value(true);
      }
      else {
        return Future<bool>.value(false);
      }
    } on SocketException catch (_) {
      return Future<bool>.value(false);
    }
  }

  /// Get from gallery
  _getFromGallery() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
    );
    if (pickedFile != null) {
      var imageFile = File(pickedFile.path);
      setState(() {
        _imgString = Utility.base64String(imageFile.readAsBytesSync());
      });
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
      maxHeight: 600,
    );
    if (pickedFile != null) {
      var imageFile = File(pickedFile.path);
      setState(() {
        _imgString = Utility.base64String(imageFile.readAsBytesSync());
      });
    }
  }

  _deletePicture() async {
      setState(() {
        _imgString = 'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE7mlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNi4wLWMwMDYgNzkuZGFiYWNiYiwgMjAyMS8wNC8xNC0wMDozOTo0NCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpwaG90b3Nob3A9Imh0dHA6Ly9ucy5hZG9iZS5jb20vcGhvdG9zaG9wLzEuMC8iIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIyLjQgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMS0xMC0wNFQxMjo1NzoxMSswMjowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMS0xMC0wNFQxMjo1NzoxMSswMjowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjEtMTAtMDRUMTI6NTc6MTErMDI6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOmQ3NjlkYzk4LTQ3Y2YtMGM0OC1iMDdiLTU3NTMwZGRlZWQ2MyIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpkNzY5ZGM5OC00N2NmLTBj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';
      });
  }

  Future save(bool isConnected) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if(_noteId == null && isConnected) {
        for (var i = 0; i < language_Codes.length; i++) {
          await menuItemProvider.saveNote(DbNote()
            ..id.v = _noteId
            ..title.v = await trans(
                _titleTextController!.text, language_Codes[i])
            ..content.v = await trans(
                _contentTextController!.text, language_Codes[i])
            ..type.v = _selectedValue!.toString()
            ..langName.v = language_Names[i]
            ..picture.v = _imgString.toString()
            ..price.v = _priceTextController!.text
            ..date.v = DateTime
                .now()
                .millisecondsSinceEpoch);
        }
      } else if(_noteId == null && !isConnected){
          await menuItemProvider.saveNote(DbNote()
            ..id.v = _noteId
            ..title.v = _titleTextController!.text
            ..content.v = _contentTextController!.text
            ..type.v = _selectedValue!.toString()
            ..langName.v = widget.selected_lang.toString()
            ..picture.v = _imgString.toString()
            ..price.v = _priceTextController!.text
            ..date.v = DateTime
                .now()
                .millisecondsSinceEpoch);
      } else {
        await menuItemProvider.saveNote(DbNote()
          ..id.v = _noteId
          ..title.v = _titleTextController!.text
          ..content.v = _contentTextController!.text
          ..type.v = _selectedValue!.toString()
          ..langName.v = _selectedLangValue!.toString()
          ..picture.v = _imgString.toString()
          ..price.v = _priceTextController!.text
          ..date.v = DateTime
              .now()
              .millisecondsSinceEpoch);
      }
        Navigator.pop(context);
        Navigator.pop(context);
        // Pop twice when editing
        if (_noteId != null) {
          Navigator.pop(context);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    var language = widget.selected_lang;
    return WillPopScope(
      onWillPop: () async {
        var dirty = false;
        if (_titleTextController!.text != widget.initialNote?.title.v) {
          dirty = true;
        } else if (_contentTextController!.text !=
            widget.initialNote?.content.v) {
          dirty = true;
        } else if (_priceTextController!.text !=
            widget.initialNote?.price.v) {
          dirty = true;
        }
        else if (_selectedValue?.toString() !=
            widget.initialNote?.type.v) {
          dirty = true;
        }
        else if (_selectedLangValue?.toString() !=
            widget.initialNote?.langName.v) {
          dirty = true;
        }
        else if (_imgString !=
            widget.initialNote?.picture.v) {
          dirty = true;
        }
        if (dirty) {
          return await (showDialog<bool>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Scartare il cambio?'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('Il contenuto è cambiato.'),
                            SizedBox(
                              height: 12,
                            ),
                            Text('Rubinetto \'CONTINUA\' per annullare le modifiche.'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            Navigator.of(context).pop(true);
                          },
                          child: Text('CONTINUA'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: Text('ANNULLA'),
                        ),
                      ],
                    );
                  }) as FutureOr<bool>?) ??
              false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Modifica piatto',
          ),
          actions: <Widget>[
            if (_noteId != null)
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  if (await showDialog<bool>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Eliminare il piatto dalla lingua $language?'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text(
                                        'Tocca OK per confermare l\'eliminazione.'),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text('OK'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text('NO'),
                                ),
                              ],
                            );
                          }) ??
                      false) {
                    await menuItemProvider.deleteNote(widget.initialNote!.id.v);
                    // Pop twice to go back to the list
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                },
              ),
            // action button
            IconButton(
              icon: Icon(Icons.save_alt),
              onPressed: () async {
                if(!await IsInternetConnected() && _noteId == null){
                if (await showDialog<bool>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Nessuna connessione Internet trovata. Il piatto verrà salvato in lingua $language.'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text(
                                  'Tocca OK per salvare.'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text('OK'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text('NO'),
                          ),
                        ],
                      );
                    }) ??
                    false) {
                  if (_formKey.currentState!.validate()){
                   unawaited (showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context)
                        {
                          return ProgressDialog(message: "Salvataggio..");
                        }
                    ));
                  }
                  await save(false);
                }
              }
                else{                                 //Internet connection and a new Note
                  if (_formKey.currentState!.validate()) {
                    unawaited (showDialog (
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context)
                        {
                          return ProgressDialog(message: "Salvataggio..");
                        }
                    ));}
                  await save(true);
                }
            },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(children: <Widget>[
            Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Titolo',
                          border: OutlineInputBorder(),
                        ),
                        controller: _titleTextController,
                        validator: (val) =>
                            val!.isNotEmpty ? null : 'Il titolo non deve essere vuoto.',
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      DropdownButtonFormField(
                        value: _selectedValue,
                        validator: (value) {
                          if (value == null) {
                            return 'È necessario selezionare il tipo di piatto.';
                          }
                        },
                        items: listview_Groups_it
                          .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                      ))
                        .toList(),
                        decoration: InputDecoration(
                          labelText: 'Tipo di piatto',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState((){
                            _selectedValue = value;
                          });
                        },
                      ),
                      SizedBox(
                        height: 16,
                      ),
                     /* DropdownButtonFormField(
                        value: _selectedLangValue,
                        items: language_Names
                            .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                            .toList(),
                        decoration: InputDecoration(
                          labelText: 'Language',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: null
                      ),*/
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Descrizione',
                          border: OutlineInputBorder(),
                        ),
                        controller: _contentTextController,
                        validator: (val) => val!.isNotEmpty
                            ? null
                            : 'La descrizione non deve essere vuota.',
                        keyboardType: TextInputType.multiline,
                        maxLines: 2,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Prezzo',
                          border: OutlineInputBorder(),
                        ),
                        controller: _priceTextController,
                        validator: (val) => val!.isNotEmpty
                            ? null
                            : 'Il prezzo non deve essere vuoto.',
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Column (
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                              color: Colors.brown,
                              onPressed: () {
                                _getFromGallery();
                              },
                              child: Text("IMMAGINE DALLA GALLERIA", style: TextStyle( color:Colors.white)),
                            ),
                            Container(
                              width: 30.0,
                            ),
                            RaisedButton(
                              color: Colors.brown,
                              onPressed: () {
                                _getFromCamera();
                              },
                              child: Text("IMMAGINE DALLA FOTOCAMERA", style: TextStyle( color:Colors.white)),
                            ),
                            Container(
                              width: 30.0,
                            ),
                            RaisedButton(
                              color: Colors.brown,
                              onPressed: () {
                                _deletePicture();
                              },
                              child: Text("CANCELLA IMMAGINE", style: TextStyle( color:Colors.white)),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth: 200,
                                    minHeight: 200,
                                    maxWidth: 440,
                                    maxHeight: 440
                                ),
                                child: FadeInImage (
                                    placeholder: AssetImage('assets/images/placeholder.png'),
                                    image: Utility.imageFromBase64String(_imgString).image,
                                    fit: BoxFit.scaleDown
                                )
                            ),
                          ],
                        ),
                      )
                    ]))
          ]),
        ),
      ),
    );
  }
}
