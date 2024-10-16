{ lib, fetchFromGitHub, perlPackages, autoreconfHook, perl, curl }:

let
  myPerl = perl.withPackages (ps: [ ps.JSONPP ]);
in
perlPackages.buildPerlPackage rec {
  pname = "ddclient";
  version = "3.11.3";

  outputs = [ "out" ];

  src = fetchFromGitHub {
    owner = "ddclient";
    repo = "ddclient";
    rev = "12e9a7c47bdbcb4322fd2ee9d3389a38e13b4d31";
    sha256 = "sha256-aFvjFajUdBh1NfGFyBvGHfKPD1h6uGE7awRYlsQPNIc=";
  };

  postPatch = ''
    touch Makefile.PL
  '';

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [ curl myPerl ];

  # Prevent ddclient from picking up build time perl which is implicitly added
  # by buildPerlPackage.
  configureFlags = [
    "--with-perl=${lib.getExe myPerl}"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ddclient $out/bin/ddclient
    install -Dm644 -t $out/share/doc/ddclient COP* README.* ChangeLog.md

    runHook postInstall
  '';

  # TODO: run upstream tests
  doCheck = false;

  meta = with lib; {
    description = "Client for updating dynamic DNS service entries";
    homepage = "https://ddclient.net/";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ bjornfor ];
    mainProgram = "ddclient";
  };
}
