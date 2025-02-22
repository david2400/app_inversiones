abstract class TableAbstract {
  String createTableQuery();

  String dropTableQuery();

  Future<int> update(dynamic object);

  Future<int> insert(dynamic object);

  Future<int> insertAll(List<dynamic> object);

  Future<List<dynamic>> getAll();

  Future<dynamic> getById(int id);

  Future<int> deleteById(int id);

  Future<int> deleteAll();
}
