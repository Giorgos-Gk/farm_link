abstract class FarmLinkException implements Exception {
  String errorMessage();
}

class UserNotFoundException extends FarmLinkException {
  @override
  String errorMessage() => 'No user found for provided uid/username';
}

class UsernameMappingUndefinedException extends FarmLinkException {
  @override
  String errorMessage() => 'User not found';
}

class ContactAlreadyExistsException extends FarmLinkException {
  @override
  String errorMessage() => 'Contact already exists!';
}
