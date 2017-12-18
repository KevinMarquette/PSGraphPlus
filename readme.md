# PSGraphPlus

Utility module that makes use of PSGraph

## GitPitch PitchMe presentation

* [gitpitch.com/KevinMarquette/PSGraphPlus](https://gitpitch.com/KevinMarquette/PSGraphPlus)

## Getting Started

    # Install GraphViz from the Chocolatey repo
    Register-PackageSource -Name Chocolatey -ProviderName Chocolatey -Location http://chocolatey.org/api/v2/
    Find-Package graphviz | Install-Package -ForceBootstrap

    # Install from the Powershell Gallery
    Find-Module PSGraph -Repository PSGallery | Install-Module
    Find-Module PSGraphPlus -Repository PSGallery | Install-Module

## More Information

For more information

* [PSGraphPlus.readthedocs.io](http://PSGraphPlus.readthedocs.io)
* [github.com/KevinMarquette/PSGraphPlus](https://github.com/KevinMarquette/PSGraphPlus)
* [KevinMarquette.github.io](https://KevinMarquette.github.io)

This project was generated using [Kevin Marquette](http://kevinmarquette.github.io)'s [Full Module Plaster Template](https://github.com/KevinMarquette/PlasterTemplates/tree/master/FullModuleTemplate).
