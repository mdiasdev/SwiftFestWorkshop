echo "Starting Workshop Setup"
echo
echo "*****************************"

command -v brew >/dev/null 2>&1 || {
  echo >&2 "Installing Homebrew Now"; \
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
}
echo "Homebrew installed"


echo
echo "*****************************"
if brew ls --versions libxml2 > /dev/null; then
  echo "libxml2 already installed"
else
  # The package is not installed
  echo "installing libxml2"
  command brew install libxml2
fi


echo
echo "*****************************"
if brew ls --versions postgres > /dev/null; then
  echo "Postgres already installed"
else
  # The package is not installed
  echo "Installing postgres"
  command brew install postgres
fi


echo
echo "*****************************"
echo "Starting Postgres"
command brew services start postgresql


echo
echo "*****************************"
echo "Generating SwiftFestServer"
command cd Server
command swift package generate-xcodeproj
