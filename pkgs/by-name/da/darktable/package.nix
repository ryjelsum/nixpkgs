{
  lib,
  stdenv,
  fetchurl,
  libsoup,
  graphicsmagick,
  json-glib,
  wrapGAppsHook3,
  cairo,
  cmake,
  ninja,
  curl,
  perl,
  desktop-file-utils,
  exiv2,
  glib,
  glib-networking,
  ilmbase,
  gtk3,
  intltool,
  lcms2,
  lensfun,
  libX11,
  libexif,
  libgphoto2,
  libjpeg,
  libpng,
  librsvg,
  libtiff,
  libjxl,
  openexr_3,
  osm-gps-map,
  pkg-config,
  sqlite,
  libxslt,
  openjpeg,
  pugixml,
  colord,
  colord-gtk,
  libwebp,
  libsecret,
  adwaita-icon-theme,
  SDL2,
  ocl-icd,
  pcre,
  gtk-mac-integration,
  isocodes,
  llvmPackages,
  gmic,
  libavif,
  icu,
  jasper,
  libheif,
  libaom,
  portmidi,
  lua,
}:

stdenv.mkDerivation rec {
  version = "4.8.1";
  pname = "darktable";

  src = fetchurl {
    url = "https://github.com/darktable-org/darktable/releases/download/release-${version}/darktable-${version}.tar.xz";
    hash = "sha256-kBsOLK7Tb7hhn99MYO37jTETS5R9MFS1xm/VXDivWZE=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    llvmPackages.llvm
    pkg-config
    intltool
    perl
    desktop-file-utils
    wrapGAppsHook3
  ];

  buildInputs =
    [
      cairo
      curl
      exiv2
      glib
      glib-networking
      gtk3
      ilmbase
      lcms2
      lensfun
      libexif
      libgphoto2
      libjpeg
      libpng
      librsvg
      libtiff
      libjxl
      openexr_3
      sqlite
      libxslt
      libsoup
      graphicsmagick
      json-glib
      openjpeg
      pugixml
      libwebp
      libsecret
      SDL2
      adwaita-icon-theme
      osm-gps-map
      pcre
      isocodes
      gmic
      libavif
      icu
      jasper
      libheif
      libaom
      portmidi
      lua
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      colord
      colord-gtk
      libX11
      ocl-icd
    ]
    ++ lib.optional stdenv.hostPlatform.isDarwin gtk-mac-integration
    ++ lib.optional stdenv.cc.isClang llvmPackages.openmp;

  cmakeFlags =
    [
      "-DBUILD_USERMANUAL=False"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      "-DUSE_COLORD=OFF"
      "-DUSE_KWALLET=OFF"
    ];

  # darktable changed its rpath handling in commit
  # 83c70b876af6484506901e6b381304ae0d073d3c and as a result the
  # binaries can't find libdarktable.so, so change LD_LIBRARY_PATH in
  # the wrappers:
  preFixup =
    let
      libPathEnvVar = if stdenv.hostPlatform.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH";
      libPathPrefix =
        "$out/lib/darktable" + lib.optionalString stdenv.hostPlatform.isLinux ":${ocl-icd}/lib";
    in
    ''
      for f in $out/share/darktable/kernels/*.cl; do
        sed -r "s|#include \"(.*)\"|#include \"$out/share/darktable/kernels/\1\"|g" -i "$f"
      done

      gappsWrapperArgs+=(
        --prefix ${libPathEnvVar} ":" "${libPathPrefix}"
      )
    '';

  meta = with lib; {
    description = "Virtual lighttable and darkroom for photographers";
    homepage = "https://www.darktable.org";
    license = licenses.gpl3Plus;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [
      flosse
      mrVanDalo
      paperdigits
      freyacodes
    ];
  };
}
