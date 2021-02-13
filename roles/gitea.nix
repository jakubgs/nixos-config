{ ... }:

{
  services.gitea = {
    enable = true;
    useWizard = false;
    disableRegistration = true;

    user = "sochan";
    httpPort = 9080;
    httpAddress = "127.0.0.1";
    repositoryRoot = "/git";
    log.level = "Info";

    settings = {
      repository = {
        DISABLE_MIGRATIONS = false;
        ALLOW_ADOPTION_OF_UNADOPTED_REPOSITORIES = true;
      };
    };

    database = {
      type = "sqlite3";
      user = "sochan";
      #host
      #name
      #port
      #socket
      #password
      #createDatabase
      #passwordFile
    };
  };
}
