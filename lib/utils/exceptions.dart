abstract class FarmLinkException implements Exception {
  String errorMessage();
}

class UserNotFoundException extends FarmLinkException {
  @override
  String errorMessage() => 'Δεν βρέθηκε χρήστης';
}

class UsernameMappingUndefinedException extends FarmLinkException {
  @override
  String errorMessage() => 'Ο χρήστης δεν βρέθηκε';
}

class ContactAlreadyExistsException extends FarmLinkException {
  @override
  String errorMessage() => 'Η επικοινωνία υπάρχει ήδη';
}
