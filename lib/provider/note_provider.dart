import 'package:tekartik_common_utils/common_utils_import.dart';
import '../model/model.dart';
import '../model/model_constant.dart';
import 'package:sqflite/sqflite.dart';

DbNote snapshotToNote(Map<String, Object?> snapshot) {
  return DbNote()..fromMap(snapshot);
}

class DbNotes extends ListBase<DbNote> {
  final List<Map<String, Object?>> list;
  late List<DbNote?> _cacheNotes;

  DbNotes(this.list) {
    _cacheNotes = List.generate(list.length, (index) => null);
  }

  @override
  DbNote operator [](int index) {
    return _cacheNotes[index] ??= snapshotToNote(list[index]);
  }

  @override
  int get length => list.length;

  @override
  void operator []=(int index, DbNote? value) => throw 'read-only';

  @override
  set length(int newLength) => throw 'read-only';
}

class DbMenuProvider {
  final lock = Lock(reentrant: true);
  final DatabaseFactory dbFactory;
  final _updateTriggerController = StreamController<bool>.broadcast();
  Database? db;

  DbMenuProvider(this.dbFactory);

  Future openPath(String path) async {
    db = await dbFactory.openDatabase(path,
        options: OpenDatabaseOptions(
            version: kVersion1,
            onCreate: (db, version) async {
              await _createDb(db);
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              if (oldVersion < kVersion1) {
                await _createDb(db);
              }
            }));
  }

  void _triggerUpdate() {
    _updateTriggerController.sink.add(true);
  }

  Future<Database?> get ready async => db ??= await lock.synchronized(() async {
        if (db == null) {
          await open();
        }
        return db;
      });

  Future<DbNote?> getNote(int? id) async {
    var list = (await db!.query(tableNotes,
        columns: [columnId, columnTitle, contentType, columnContent, contentPrice, contentPicture, languageName, columnUpdated],
        where: '$columnId = ?',
        whereArgs: <Object?>[id]));
    if (list.isNotEmpty) {
      return DbNote()..fromMap(list.first);
    }
    return null;
  }

  Future _createDb(Database db) async {
    await db.execute('DROP TABLE If EXISTS $tableNotes');
    await db.execute(
        'CREATE TABLE $tableNotes($columnId INTEGER PRIMARY KEY, $columnTitle TEXT, $columnContent TEXT, $contentType TEXT, $languageName TEXT, $contentPrice TEXT, $contentPicture TEXT, $columnUpdated INTEGER)');
    await db
        .execute('CREATE INDEX NotesUpdated ON $tableNotes ($columnUpdated)');
    await _saveNote(
        db,
        DbNote()
          ..title.v = 'Water'
          ..content.v = ' '
          ..type.v = 'Drinks'
          ..langName.v = 'English'
          ..price.v = '2 Euro'
          ..picture.v = 'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE7mlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNi4wLWMwMDYgNzkuZGFiYWNiYiwgMjAyMS8wNC8xNC0wMDozOTo0NCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpwaG90b3Nob3A9Imh0dHA6Ly9ucy5hZG9iZS5jb20vcGhvdG9zaG9wLzEuMC8iIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIyLjQgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMS0xMC0wNFQxMjo1NzoxMSswMjowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMS0xMC0wNFQxMjo1NzoxMSswMjowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjEtMTAtMDRUMTI6NTc6MTErMDI6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOmQ3NjlkYzk4LTQ3Y2YtMGM0OC1iMDdiLTU3NTMwZGRlZWQ2MyIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpkNzY5ZGM5OC00N2NmLTBj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'
          ..date.v = 1);
    await _saveNote(
        db,
        DbNote()
          ..title.v =
              'Acqua'
          ..content.v =
              ' '
          ..type.v =
              'Drinks'
          ..price.v =
              '2 Euro'
          ..langName.v =
              'Italian'
          ..picture.v =
              'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE7mlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNi4wLWMwMDYgNzkuZGFiYWNiYiwgMjAyMS8wNC8xNC0wMDozOTo0NCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpwaG90b3Nob3A9Imh0dHA6Ly9ucy5hZG9iZS5jb20vcGhvdG9zaG9wLzEuMC8iIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIyLjQgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMS0xMC0wNFQxMjo1NzoxMSswMjowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMS0xMC0wNFQxMjo1NzoxMSswMjowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjEtMTAtMDRUMTI6NTc6MTErMDI6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOmQ3NjlkYzk4LTQ3Y2YtMGM0OC1iMDdiLTU3NTMwZGRlZWQ2MyIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpkNzY5ZGM5OC00N2NmLTBjNDgtYjA3Yi01NzUzMGRkZWVkNjMiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkNzY5ZGM5OC00N2NmLTBjNDgtYjA3Yi01NzUzMGRkZWVkNjMiIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmQ3NjlkYzk4LTQ3Y2YtMGM0OC1iMDdiLTU3NTMwZGRlZWQ2MyIgc3RFdnQ6d2hlbj0iMjAyMS0xMC0wNFQxMjo1NzoxMSswMjowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIyLjQgKFdpbmRvd3MpIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PnsiyycAAAglSURBVGiB7VrZcuO4DgVIidRmOY7TM///e9OdeNEukcB9oC1Tku046a5Jza0gVUkkgdABiI2wsa5r+C+T+GoAv0vfCnw1fSvw1fStwFfTtwJfTd8KfDVdV4A9+pcBXSVEJKKrj4LZNTM3TQOAgEBEQgitVBAEj2uCiACAAP4CdMIBPmERRKzqer8/ZGm6zlez9QsFACyRQIGATMzwgU1w0I0xwzAMxhhjrbXMLBBlIMPA/QRSSviIJsxclhURlVWVJHEYhv7aiQKISNYSEUpEAAYGgEdeJBAtUVVVddNaaxExDAIZBEEQIAAzE1HTtrY0DBAEQZYmURQh4rtqIKKzhBDCyZkxzHeAiE5CEQEA8B1TORDHoiyrChGTONZaSyndbiyFG2Partvtj1IUeb6K4xje241hMETkBC45Fy5E5JyX6cTKfD16AEAgtl233x8YIF+ttNbja65iQkSllFYqS9OmaXaHQ1XXT+v1nRhDAGvtBd6Ca56FaJR0DsNbogViUZa/Xt+01i/bbRRFd6B7CJiYETHLspfnLTP88/NX13VC3EjoCJZolMgwt+Z82cnw5+DFGzEgBB6OxeFYPK3XeZ7P9ETE2Vagd9MREUkpnzebJEl+vb41TXNdBwYii97lzDWnQQxAzmHwlPNgvDNBL45FUVbV82ajtfYDyyXstuuMMedXniIKAcIwVEqNset+56uVEOL1bfeyFZFWNDUYA4zymWFZDK7UAZc3mE5ZyFrrJ3VErJvmeCw2U/QOet00xhh5rh7+PgzGdH3ftq1SKo4iOKtBRFmSMNHr29vff/2QUs6ccIxGQJhWF4ArLnS2DZ/wo7V23DZEJEu73X6VZdEUfT8Mx6JwFs2yzFl6fCqEiLR2jwZjDkXhsq1jIOYsy8IwfNvtl3j8PeFHFCBmIrLGWGuNNXyJa0CA/fEYBEGapj76ruuqqsrSNEtTuBHK7qYQwuWroiiMMX5UrNf5MAxVXc9S8CQNvptGEbBuGnEW0XadSy9wNnPTNNvn5ws/Ytd1Tds+rdd3OpaZJpHWUoiiLF0AuJtSyFWWFcciieOp2nfwT3eAAZQKYbKAAynHy6IotdZ+MbdEddOssuyRsuqLDcMwjuOyLEd7M7Ora23bXhoqHtPhGeI9BZjjOM7zbIyEKNKrfOWeElHX92mSjPyIWFVVHMfLyHtEh0hrKWXdNH60xElSltX4AseLF/wPxMA6z52LK6VetlspBDMjYt/3iDiaHxGHYQDmSOvPdd3MnCTJMAz+8khrY605hzgReXUMeOFE1+uf1oqZwzAQnmO4DOhHWNt1SqlPQL+8XggpRNd1Y8J1fdQwDI5hUmQe2YETH43J9EJ9P6gwHC+ZmYmUUr956AmV6s9wAQARpZR93+NZwwn3u73QhNHLKEREzPIc0K7HQiFu9jCPETOHQQDTTiQMgr4f3OknCAK/1Xu/mfP5CC6ZnpmBGUe4iH6T+DvkeqTJGSUI+Fx+BWKaJne2+I79cJqA/WR2uiOuNf0fJTxL824hXzoxztI0TZITw2ILbh7qxyQ8Cl2C/SMH/nP3PhE/K8XrfBXcyNQ3FAD2Q56ZBQAg+G3JJ3L/TZpuJlkL094bzno+lIU8sZf/UQh3Yj4/YinlvNB/nBDRWOvqzHhzMCYIpM90R8JtFzr9HXcYpQyMF7julD1ryD5BwzBIr1sBAGOM1nqC5/QLH8pCPK6YmjeKdNd1PmcYhl3ffxb56V1mGEa4LjsTURiEU76bO30zBsC5EPNoXq21tXY0OTNHUWSN+fQmIGLXtoB4yfSIwzAgYhjOj/nMjNcOuPfL0GW+4iqOlKL1NgERoyiqPvtBLRG1bet3hwBQN00Sx7ME7bdDM7oXA24ud4ELkKVpXdf+lEZrLYQoq+oTJbkoiiiKxmzmzhvDMCwr151U8Z4C3k1iTpJYCFFVNXqcWZoSkevsH/Ekx3UsijAMoyjywRVFEUfRMuVfEvoiGm4oQC6vLUd5uM7zqq76qd+vsoyYj8ejZcZFCvehCyH6YdgfDioMk7G+Aggh6ro2xuR5vrT2nXHT/Eg58oMLmKkCzBxHOk2T/X6/fX52mXTUoW3bsiyllFrrYDFdZOa+77uuc92Bf6xzh41jUWw2T4EUtMB6x4WuKMA8Vly2i5XE/JTnP/vX/eGw2Wz8IU8URVrrtm3ruhZ4IkB0BnSjbq21S5o+emvtbrfLsjSN4yV6gHtNy9UduEi/rjridvv889frbrfbPD3NBlVxHMdxbM/EACiElDKQcjy/j5IE4mDM226no2id59fRT4A9oMDE4a5JdNORl+3z69vu9e1tvV6rMPTmZwzuqDWtrzM/dg7WtO3heIzjaPP0dMdPli3QSNcqMbPXxs1nkSOPlPLHy1ap8PX1tShLABALp/fJh+7cZn847A+HfLW6j/4+LeZCiM5hEZGYLdn5p0UePgB43jxFUXQ4HJu6TtLUDRpmPOA348zGmLppmqYJw/CvHz9UGLzrOXg249KaV1wIUZxGVNMm8SoRcRxFkdZN0xRlVVWVlFIrpZQSQoynLWIma7uu64eBLIUq2D5vXDS/i36myjsKMLOUIk3ToiiUUmkc3/5847IEAJIkieN4GIau65q2a9rWPRhD3H3ulKWpUioM5+fg++TmxNaSlMHs/Im3vnJGRIhCiA/M2+Dk324O7iY6DAyIgEIIJw7nHcqDgvuht8ZqrWY9y00FPjQqvCXBv/wj0pZCrteB33/fH5HwiLT/068a/IfoW4Gvpm8Fvpq+Ffhq+lbgq+l/uKLfsLSnQGUAAAAASUVORK5CYII='
          ..date.v = 2);
    _triggerUpdate();
  }

  Future open() async {
    await openPath(await fixPath(dbName));
  }

  Future<String> fixPath(String path) async => path;

  /// Add or update a note
  Future _saveNote(DatabaseExecutor? db, DbNote updatedNote) async {
    if (updatedNote.id.v != null) {
      await db!.update(tableNotes, updatedNote.toMap(),
          where: '$columnId = ?', whereArgs: <Object?>[updatedNote.id.v]);
    } else {
      updatedNote.id.v = await db!.insert(tableNotes, updatedNote.toMap());
    }
  }

  Future saveNote(DbNote updatedNote) async {
    await _saveNote(db, updatedNote);
    _triggerUpdate();
  }

  Future<void> deleteNote(int? id) async {
    await db!
        .delete(tableNotes, where: '$columnId = ?', whereArgs: <Object?>[id]);
    _triggerUpdate();
  }

  var notesTransformer =
      StreamTransformer<List<Map<String, Object?>>, List<DbNote>>.fromHandlers(
          handleData: (snapshotList, sink) {
    sink.add(DbNotes(snapshotList));
  });

  var noteTransformer =
      StreamTransformer<Map<String, Object?>, DbNote?>.fromHandlers(
          handleData: (snapshot, sink) {
    sink.add(snapshotToNote(snapshot));
  });

  /// Listen for changes on any note
  Stream<List<DbNote?>> onNotes() {
    late StreamController<DbNotes> ctlr;
    StreamSubscription? _triggerSubscription;

    Future<void> sendUpdate() async {
      var notes = await getListNotes();
      if (!ctlr.isClosed) {
        ctlr.add(notes);
      }
    }

    ctlr = StreamController<DbNotes>(onListen: () {
      sendUpdate();

      /// Listen for trigger
      _triggerSubscription = _updateTriggerController.stream.listen((_) {
        sendUpdate();
      });
    }, onCancel: () {
      _triggerSubscription?.cancel();
    });
    return ctlr.stream;
  }

  /// Listed for changes on a given note
  Stream<DbNote?> onNote(int? id) {
    late StreamController<DbNote?> ctlr;
    StreamSubscription? _triggerSubscription;

    Future<void> sendUpdate() async {
      var note = await getNote(id);
      if (!ctlr.isClosed) {
        ctlr.add(note);
      }
    }

    ctlr = StreamController<DbNote?>(onListen: () {
      sendUpdate();

      /// Listen for trigger
      _triggerSubscription = _updateTriggerController.stream.listen((_) {
        sendUpdate();
      });
    }, onCancel: () {
      _triggerSubscription?.cancel();
    });
    return ctlr.stream;
  }

  /// Don't read all fields
  Future<DbNotes> getListNotes(
      {int? offset, int? limit, bool? descending}) async {
    // devPrint('fetching $offset $limit');
    var list = (await db!.query(tableNotes,
        columns: [columnId, columnTitle, contentType, languageName, columnContent, contentPrice, contentPicture],
        orderBy: '$columnUpdated ${(descending ?? false) ? 'ASC' : 'DESC'}',
        limit: limit,
        offset: offset));
    return DbNotes(list);
  }


  Future clearAllNotes() async {
    await db!.delete(tableNotes);
    _triggerUpdate();
  }

  Future close() async {
    await db!.close();
  }

  Future deleteDb() async {
    await dbFactory.deleteDatabase(await fixPath(dbName));
  }
}
