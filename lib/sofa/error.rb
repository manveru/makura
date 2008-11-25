module Sofa
  # Mother and namespace of all exceptions
  class Error < ::RuntimeError
    class ConnectionRefused < Error; end
    class RequestFailed < Error; end
    class ResourceNotFound < RequestFailed; end
    class Conflict < RequestFailed; end
    class MissingRevision < RequestFailed; end
    class BadRequest < RequestFailed; end
    class Authorization < RequestFailed; end
    class NotFound < RequestFailed; end
    class FileExists < RequestFailed; end
  end
end
