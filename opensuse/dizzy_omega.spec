Name: Dizzy Omega
Version: 0.17
Release: 1%{?dist}
Summary: Dizzy Omega is the sequel of the game Dizzy Y.

License: GPL3+
URL: https://dizzy-omega.sourceforge.io
Source0: dizzy_omega

Requires: libSDL2-2_0-0 >= 2.0.3
Requires: libSDL2_image-2_0-0 >= 2.0.0

%description
Dizzy Omega is the sequel of the game Dizzy Y.
Dizzy is a puzzle game, Purpose of which is
the collection and use of items.

%install
mkdir -p %{buildroot}/%{_bindir}
install -p -m 755 %{SOURCE0}/unde %{buildroot}/%{_bindir}
mkdir -p %{buildroot}/%{_datadir}/dizzy_omega/models
mkdir -p %{buildroot}/%{_datadir}/dizzy_omega/music
mkdir -p %{buildroot}/%{_datadir}/dizzy_omega/sounds
cp -a %{SOURCE0}/models/* %{buildroot}/%{_datadir}/dizzy_omega/models
cp -a %{SOURCE0}/music/* %{buildroot}/%{_datadir}/dizzy_omega/music
cp -a %{SOURCE0}/sounds/* %{buildroot}/%{_datadir}/dizzy_omega/sounds

%files
%{_bindir}/dizzy_omega
%{_datadir}/dizzy_omega/models
%{_datadir}/dizzy_omega/music
%{_datadir}/dizzy_omega/sounds

%changelog

