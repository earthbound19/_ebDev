# UNTESTED. Makes all npm packages installed with the -g flag install into a local directory of your choosing withing your HOME path. re: https://johnpapa.net/how-to-use-npm-global-without-sudo-on-osx/

brew install node --without-npm  
mkdir "${HOME}/.npm-packages"  
echo NPM_PACKAGES="${HOME}/.npm-packages" >> ${HOME}/.bashrc  
echo prefix=${HOME}/.npm-packages >> ${HOME}/.npmrc  
curl -L https://www.npmjs.org/install.sh | sh  
echo NODE_PATH=\"\$NPM_PACKAGES/lib/node_modules:\$NODE_PATH\" >> ${HOME}/.bashrc  
echo PATH=\"\$NPM_PACKAGES/bin:\$PATH\" >> ${HOME}/.bashrc  
echo source "~/.bashrc" >> ${HOME}/.bash_profile  
source ~/.bashrc