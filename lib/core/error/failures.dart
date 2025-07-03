// Custom failures for the app
abstract class Failure {}

class ServerFailure extends Failure {}

class CacheFailure extends Failure {}
