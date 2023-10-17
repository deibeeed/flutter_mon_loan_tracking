abstract class BaseCacheService<T> {

  Future<T> add({ required T data });
  Future<T> update({ required T data});
  Future<T> delete({ required T data });
  Future<T> get({ required String id });
  Future<List<T>> all();
}