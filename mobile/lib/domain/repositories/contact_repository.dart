import '../entities/contact.dart';

abstract class ContactRepository {
  Future<List<Contact>> getAll();

  Future<List<Contact>> getFavorites();

  Future<Contact?> findById(String id);

  Future<Contact?> findByPhone(String phone);

  Future<Contact> save(Contact contact);

  Future<void> delete(String id);

  Stream<List<Contact>> watchAll();
}
