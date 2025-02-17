{ callPackage, fetchpatch2, openssl, python3, enableNpm ? true }:

let
  buildNodejs = callPackage ./nodejs.nix {
    inherit openssl;
    python = python3;
  };
in
buildNodejs {
  inherit enableNpm;
  version = "22.12.0";
  sha256 = "fe1bc4be004dc12721ea2cb671b08a21de01c6976960ef8a1248798589679e16";
  patches = [
    ./configure-emulator.patch
    ./configure-armv6-vfpv2.patch
    ./disable-darwin-v8-system-instrumentation-node19.patch
    ./bypass-darwin-xcrun-node16.patch
    ./node-npm-build-npm-package-logic.patch
    ./use-correct-env-in-tests.patch
    ./bin-sh-node-run-v22.patch

    # Those reverts are due to a mismatch with the libuv version used upstream
    (fetchpatch2 {
      url = "https://github.com/nodejs/node/commit/84fe809535b0954bbfed8658d3ede8a2f0e030db.patch?full_index=1";
      hash = "sha256-C1xG2K9Ejofqkl/vKWLBz3vE0mIPBjCdfA5GX2wlS0I=";
      revert = true;
    })
    (fetchpatch2 {
      url = "https://github.com/nodejs/node/commit/dcbc5fbe65b068a90c3d0970155d3a68774caa38.patch?full_index=1";
      hash = "sha256-Q7YrooolMjsGflTQEj5ra6hRVGhMP6APaydf1MGH54Q=";
      revert = true;
      excludes = [ "doc/*" ];
    })
    (fetchpatch2 {
      url = "https://github.com/nodejs/node/commit/ec867ac7ce4e4913a8415eda48a7af9fc226097d.patch?full_index=1";
      hash = "sha256-zfnHxC7ZMZAiu0/6PsX7RFasTevHMETv+azhTZnKI64=";
      revert = true;
      excludes = [ "doc/*" ];
    })
    (fetchpatch2 {
      url = "https://github.com/nodejs/node/commit/f97865fab436fba24b46dad14435ec4b482243a2.patch?full_index=1";
      hash = "sha256-o5aPQqUXubtJKMX28jn8LdjZHw37/BqENkYt6RAR3kY=";
      revert = true;
    })
    (fetchpatch2 {
      url = "https://github.com/nodejs/node/commit/54d55f2337ebe04451da770935ad453accb147f9.patch?full_index=1";
      hash = "sha256-gmIyiSyNzC3pClL1SM2YicckWM+/2tsbV1xv2S3d5G0=";
      revert = true;
    })
    # Fix for https://github.com/NixOS/nixpkgs/issues/355919
    # FIXME: remove after a minor point release
    (fetchpatch2 {
      url = "https://github.com/nodejs/node/commit/f270462c09ddfd770291a7c8a2cd204b2c63d730.patch?full_index=1";
      hash = "sha256-Err0i5g7WtXcnhykKgrS3ocX7/3oV9UrT0SNeRtMZNU=";
    })
    # fixes test failure, remove when included in release
    (fetchpatch2 {
      url = "https://github.com/nodejs/node/commit/b6fe731c55eb4cb9d14042a23e5002ed39b7c8b7.patch?full_index=1";
      hash = "sha256-KoKsQBFKUji0GeEPTR8ixBflCiHBhPqd2cPVPuKyua8=";
    })
  ];
}
