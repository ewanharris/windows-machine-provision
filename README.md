# Automated Windows 10 setup

I install Windows a lot, and always forget what I need. So this automates that using [Boxstarter](http://boxstarter.org/), and [Chocolatey](https://chocolatey.org/).

It consists of 2 scripts.

- run-boxstarter.ps1
    - Install Boxstarter, then install the required software I want.
- install-vs.ps1
    - Download the Visual Studio Community installer. Then run it and install the required things required to get started on Titanium Windows development.