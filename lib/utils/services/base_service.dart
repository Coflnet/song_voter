class BaseService {
  bool isResponseSuccessfull(int code) => code >= 200 || code < 299;
}
