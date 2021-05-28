Name:    bash-args
Version: 0.5.0
Release: 1%{?dist}
Summary: A cute little Bash library for blazing fast argument parsing
Group:
License: Public Domain
Source0: bash-args-0.5.0
# Source0: https://github.com/eankeen/bash-args/download/%{name}/%{name}-${version}.tar.gz
URL:     https://github.com/eankeen/bash-args
# Requires: bash

%description
A cute little Bash library for blazing fast argument parsing

%install
mkdir -p %{buildroot}%{_bindir}
install -p -m 755 %{SOURCE0} %{buildroot}%{_bindir}

%files

%changelog
