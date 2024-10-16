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
    rev = "1c0ba9a1260111f2eb75e76718d218ae2ee0b29f";
    sha256 = lib.fakeSha256;
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
