{ stdenv, fetchurl, hamlib, fltk14, libjpeg, libpng, portaudio, libsndfile,
  libsamplerate, libpulseaudio, libXinerama, gettext, pkgconfig, alsaLib }:

stdenv.mkDerivation rec {
  version = "4.1.11";
  pname = "fldigi";

  src = fetchurl {
    url = "mirror://sourceforge/${pname}/${pname}-${version}.tar.gz";
    sha256 = "1y62xn1pim38ibaf2mbl8b7aq20jdaac6lgggb9r402w9bj5b196";
  };

  buildInputs = [ libXinerama gettext hamlib fltk14 libjpeg libpng portaudio
                  libsndfile libsamplerate libpulseaudio pkgconfig alsaLib ];

  meta = {
    description = "Digital modem program";
    homepage = "https://sourceforge.net/projects/fldigi/";
    license = stdenv.lib.licenses.gpl3Plus;
    maintainers = with stdenv.lib.maintainers; [ relrod ftrvxmtrx ];
    platforms = stdenv.lib.platforms.linux;
  };
}
