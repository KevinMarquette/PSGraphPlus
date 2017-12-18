# PSGraphPlus

This is a utility module that contains a lot of the graphs used when I demo PSGraph.

---

### Commands

* Show-GitGraph
* Show-NetworkConnectionGraph
* Show-ProcessConnectionGraph
* Show-ServiceDependencyGraph

---

### Examples

Comming soon

---

### Getting Started

    # Install GraphViz from the Chocolatey repo
    Register-PackageSource -Name Chocolatey -ProviderName Chocolatey -Location http://chocolatey.org/api/v2/
    Find-Package graphviz | Install-Package -ForceBootstrap

    # Install from the Powershell Gallery
    Find-Module PSGraph -Repository PSGallery | Install-Module
    Find-Module PSGraphPlus -Repository PSGallery | Install-Module

---

### What's next?

For more information

* [PSGraphPlus.readthedocs.io](http://PSGraphPlus.readthedocs.io)
* [github.com/KevinMarquette/PSGraphPlus](https://github.com/KevinMarquette/PSGraphPlus)
* [KevinMarquette.github.io](https://KevinMarquette.github.io)
