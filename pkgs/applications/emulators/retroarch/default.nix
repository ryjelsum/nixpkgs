{
  lib,
  stdenv,
  nixosTests,
  enableNvidiaCgToolkit ? false,
  withGamemode ? stdenv.hostPlatform.isLinux,
  withVulkan ? stdenv.hostPlatform.isLinux,
  withWayland ? stdenv.hostPlatform.isLinux,
  alsa-lib,
  dbus,
  fetchFromGitHub,
  ffmpeg,
  flac,
  freetype,
  gamemode,
  gitUpdater,
  libdrm,
  libGL,
  libGLU,
  libpulseaudio,
  libv4l,
  libX11,
  libXdmcp,
  libXext,
  libxkbcommon,
  libxml2,
  libXxf86vm,
  makeWrapper,
  mbedtls_2,
  mesa,
  nvidia_cg_toolkit,
  pkg-config,
  python3,
  qtbase,
  SDL2,
  spirv-tools,
  udev,
  vulkan-loader,
  wayland,
  wayland-scanner,
  wrapQtAppsHook,
  zlib,
}:

let
  runtimeLibs =
    lib.optional withVulkan vulkan-loader
    ++ lib.optional withGamemode (lib.getLib gamemode);
in
stdenv.mkDerivation rec {
  pname = "retroarch-bare";
  version = "1.19.1";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "RetroArch";
    hash = "sha256-NVe5dhH3w7RL1C7Z736L5fdi/+aO+Ah9Dpa4u4kn0JY=";
    rev = "v${version}";
  };

  nativeBuildInputs =
    [
      pkg-config
      wrapQtAppsHook
    ]
    ++ lib.optional withWayland wayland
    ++ lib.optional (runtimeLibs != [ ]) makeWrapper;

  buildInputs =
    [
      ffmpeg
      flac
      freetype
      libGL
      libGLU
      libxml2
      mbedtls_2
      python3
      qtbase
      SDL2
      spirv-tools
      zlib
    ]
    ++ lib.optional enableNvidiaCgToolkit nvidia_cg_toolkit
    ++ lib.optional withVulkan vulkan-loader
    ++ lib.optionals withWayland [
      wayland
      wayland-scanner
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      alsa-lib
      dbus
      libX11
      libXdmcp
      libXext
      libXxf86vm
      libdrm
      libpulseaudio
      libv4l
      libxkbcommon
      mesa
      udev
    ];

  enableParallelBuilding = true;

  configureFlags =
    [
      "--disable-update_cores"
      "--disable-builtinmbedtls"
      "--enable-systemmbedtls"
      "--disable-builtinzlib"
      "--disable-builtinflac"
      "--disable-update_assets"
      "--disable-update_core_info"
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      "--enable-dbus"
      "--enable-egl"
      "--enable-kms"
    ];

  postInstall =
    lib.optionalString (runtimeLibs != [ ]) ''
      wrapProgram $out/bin/retroarch \
        --prefix LD_LIBRARY_PATH ':' ${lib.makeLibraryPath runtimeLibs}
    ''
    + lib.optionalString enableNvidiaCgToolkit ''
      wrapProgram $out/bin/retroarch-cg2glsl \
        --prefix PATH ':' ${lib.makeBinPath [ nvidia_cg_toolkit ]}
    '';

  preFixup = lib.optionalString (!enableNvidiaCgToolkit) ''
    rm $out/bin/retroarch-cg2glsl
    rm $out/share/man/man6/retroarch-cg2glsl.6*
  '';

  passthru = {
    tests = nixosTests.retroarch;
    updateScript = gitUpdater {
      rev-prefix = "v";
    };
  };

  meta = with lib; {
    homepage = "https://libretro.com";
    description = "Multi-platform emulator frontend for libretro cores";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    changelog = "https://github.com/libretro/RetroArch/blob/v${version}/CHANGES.md";
    maintainers =
      with maintainers;
      teams.libretro.members
      ++ [
        matthewbauer
        kolbycrouch
      ];
    mainProgram = "retroarch";
    # If you want to (re)-add support for macOS, see:
    # https://docs.libretro.com/development/retroarch/compilation/osx/
    # and
    # https://github.com/libretro/RetroArch/blob/71eb74d256cb4dc5b8b43991aec74980547c5069/.gitlab-ci.yml#L330
    broken = stdenv.hostPlatform.isDarwin;
  };
}
