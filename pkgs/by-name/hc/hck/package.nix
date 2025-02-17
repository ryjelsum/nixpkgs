{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
}:

rustPlatform.buildRustPackage rec {
  pname = "hck";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "sstadick";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-7a+gNnxr/OiM5MynOxOQ3hAprog7eAAZnMvi+5/gMzg=";
  };

  cargoHash = "sha256-rGKD09YV+QqzZ1n6gYerjbpTr+4KJ5UzynDDRw5rnP0=";

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Close to drop in replacement for cut that can use a regex delimiter instead of a fixed string";
    homepage = "https://github.com/sstadick/hck";
    changelog = "https://github.com/sstadick/hck/blob/v${version}/CHANGELOG.md";
    license = with licenses; [
      mit # or
      unlicense
    ];
    maintainers = with maintainers; [
      figsoda
      gepbird
    ];
    mainProgram = "hck";
  };
}
