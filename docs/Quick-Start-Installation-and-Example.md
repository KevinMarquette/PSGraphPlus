# Installing PSGraphPlus

    # Install GraphViz from the Chocolatey repo
    Register-PackageSource -Name Chocolatey -ProviderName Chocolatey -Location http://chocolatey.org/api/v2/
    Find-Package graphviz | Install-Package -ForceBootstrap

    # Install from the Powershell Gallery
    Find-Module PSGraph -Repository PSGallery | Install-Module
    Find-Module PSGraphPlus -Repository PSGallery | Install-Module
