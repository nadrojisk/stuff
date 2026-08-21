# File Reorganization Script - Dewey Decimal Classification
# This script will reorganize your Obsidian vault according to the Dewey Decimal system

param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath,
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf = $false
)

# Validate source path
if (-not (Test-Path $SourcePath)) {
    Write-Error "Source path does not exist: $SourcePath"
    exit 1
}

Write-Host "Starting file reorganization..." -ForegroundColor Green
Write-Host "Source: $SourcePath" -ForegroundColor Yellow
if ($WhatIf) {
    Write-Host "WHAT-IF MODE: No files will be moved" -ForegroundColor Cyan
}

# Create the new directory structure
$newStructure = @{
    # 000-099 Computer Science, Information & General Works
    "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.6 Interfacing & Communications" = @()
    "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/AppleScript" = @()
    "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/C" = @()
    "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/C Sharp" = @()
    "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/C++" = @()
    "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/Excel 4.0" = @()
    "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/go" = @()
    "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/PowerShell" = @()
    "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/Visual Basic" = @()
    "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/x86 Assembly" = @()
    "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Malware Development/02.ThreadContext" = @()
    "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Malware Development/Classic" = @()
    
    # 005 Programming section
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/Computer Architecture" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/File Formats/PDF" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/Offensive Security" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/Protocols" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/Security Implementations" = @()
    
    # 005.8 Data Security
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Cryptography" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Environment" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Malware Functionality/Anti-Analysis" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Malware Functionality/Malware Techniques" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Malware Functionality/Persistence" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Malware Functionality/Process Injection" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Meta/Malware Classification/Rootkits" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Training/SANS/FOR710" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Training/Sektor7/API Hooking" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Training/Sektor7/Code Injection" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Training/Sektor7/PE Format" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Types of Analysis/Host Analysis/Dynamic Analysis" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Types of Analysis/Host Analysis/Static Analysis" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Types of Analysis/Network Analysis" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Windows Internals/Forensic Artifacts/Registry/attachments" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Windows Internals/GPO" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Windows Internals/Kernel Concepts" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Windows Internals/WinAPI" = @()
    "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Vulnerabilities/ProxyX/Articles/A New Attack Surface on MSExchange" = @()
    
    # 025 Library Operations
    "000-099 Computer Science, Information & General Works/025 Library Operations/025.04 Information Storage & Retrieval/Cheat Sheets" = @()
    
    # 300s Social Sciences
    "300-399 Social Sciences/330 Economics/332 Financial Economics/Cryptocurrency" = @()
    
    # 600s Technology
    "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Azure AD" = @()
    "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Cybersec Tools/Splunk/Training" = @()
    "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Kusto Query Language" = @()
    "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Utility Tools" = @()
    
    # 658 Management - CSOC content
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Administration/2025/03" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Administration/2025/04" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Administration/2025/05" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Administration/2025/06" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Administration/2025/07" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Administration/2025/08" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Conferences/Auburn 2024" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Conferences/BatCloak Deobfuscator" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Conferences/CyberExpo 2023" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Conferences/Malware Analysis Presentations/1. Introduction to Malware Analysis/labs" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Conferences/Malware Analysis Presentations/101" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Conferences/Malware Analysis Presentations/2. Introduction to Malicious Documents and Fileless Malware/documentation" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Conferences/Malware Analysis Presentations/2. Introduction to Malicious Documents and Fileless Malware/extra" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Conferences/Malware Analysis Presentations/2. Introduction to Malicious Documents and Fileless Malware/labs" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Conferences/Malware Analysis Presentations/3. Introduction to Compiled Binaries" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Conferences/Malware Analysis Presentations/4. Introduction to Manual Code Reversing" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Conferences/Malware Analysis Presentations/Threat" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Conferences/MTEM/2025" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Conferences/Old Presentations/Labs/2. Static Analysis" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Conferences/Old Presentations/Labs/3. Dynamic Analysis" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Conferences/Old Presentations/Labs/4. x64 and ELF" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Excalidraw" = @()
    
    # IR section with complex structure
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/IR/iJC3" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/IR/IMperial/Dodo (2025)/Part 2/Blue Team/Analysis" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/IR/IMperial/Dodo (2025)/Part 2/Blue Team/Exports/D/Shares/file-share/Public Share" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/IR/IMperial/Dodo (2025)/Part 2/Blue Team/Exports/f/PowershellHistory/Users/admin/AppData/Roaming/Microsoft/Windows/PowerShell/PSReadline" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/IR/IMperial/Dodo (2025)/Part 2/Blue Team/Exports/f/PowershellHistory/Users/administrator/AppData/Roaming/Microsoft/Windows/PowerShell/PSReadline" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/IR/IMperial/Dodo (2025)/Part 2/Blue Team/Exports/f/PowershellHistory/Users/dadmin/AppData/Roaming/Microsoft/Windows/PowerShell/PSReadline" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/IR/IMperial/Dodo (2025)/Part 2/Blue Team/Exports/f/PowershellHistory/Users/wruger/AppData/Roaming/Microsoft/Windows/PowerShell/PSReadline" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/IR/IMperial/Dodo (2025)/Part 2/Blue Team/Incident/attachments" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/IR/IMperial/Dodo (2025)/Part 2/Blue Team/Incident/logs/To Be Filtered" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/IR/IMperial/Dodo (2025)/Part 2/Documents" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/IR/Microsoft Support/URL Count" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/IR/Projects/2023" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/IR/Projects/2024" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/IR/Projects/2025/csoc_llm" = @()
    
    # Resources section
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Resources/Books" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Resources/Queries/Kusto" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Resources/Queries/Splunk" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Resources/Readings/Threat Reports" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Resources/Training/Microsoft/Kusto" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Resources/Training/SANS" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Resources/wls" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Shadow/Emma/debug" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Templates" = @()
    "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/TheHive" = @()
    
    # General/Temporary
    "000 General/025 Library Operations/To Organize/Tips and Tricks/Linux" = @()
    "000 General/025 Library Operations/To Organize/Tips and Tricks/Windows" = @()
    "000 General/025 Library Operations/To Organize/Unicode" = @()
    "000 General/070 News Media & Journalism/OUI Lookups" = @()
}

# File mapping - maps current paths to new paths
$fileMapping = @{
    # DNS, IPFS, IPv6 to Communications
    "Low Level\Protocols\DNS.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.6 Interfacing & Communications/DNS.md"
    "Low Level\Protocols\IPFS.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.6 Interfacing & Communications/IPFS.md"
    "To Organize\IPv6.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.6 Interfacing & Communications/IPv6.md"
    
    # Programming Languages
    "Malware\Languages\AppleScript\AppleScript.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/AppleScript/AppleScript.md"
    "Malware\Languages\C\C Runtime.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/C/C Runtime.md"
    "Malware\Languages\C\C.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/C/C.md"
    "Malware\Languages\C\Optimizations.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/C/Optimizations.md"
    "Malware\Languages\C\Pointers.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/C/Pointers.md"
    "Malware\Languages\C\Recipes.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/C/Recipes.md"
    
    "Malware\Languages\C Sharp\C Sharp.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/C Sharp/C Sharp.md"
    
    "Malware\Languages\C++\C++.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/C++/C++.md"
    "Malware\Languages\C++\std__vector.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/C++/std__vector.md"
    
    "Malware\Languages\Excel 4.0\Excel 4.0 Macros.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/Excel 4.0/Excel 4.0 Macros.md"
    "Malware\Languages\Excel 4.0\Excel(lent) Malicious Malware Analysis.pdf.pdf" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/Excel 4.0/Excel(lent) Malicious Malware Analysis.pdf.pdf"
    "Malware\Languages\Excel 4.0\Excel-4.0-Macros-Function-Reference.pdf" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/Excel 4.0/Excel-4.0-Macros-Function-Reference.pdf"
    
    "Malware\Languages\go\go internals.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/go/go internals.md"
    "Malware\Languages\go\go.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/go/go.md"
    
    "Malware\Languages\PowerShell\Powershell inside a certificate.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/PowerShell/Powershell inside a certificate.md"
    
    "Malware\Languages\Visual Basic\Compiled VB.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/Visual Basic/Compiled VB.md"
    "Malware\Languages\Visual Basic\VBScript.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/Visual Basic/VBScript.md"
    "Malware\Languages\Visual Basic\Visual Basic Image Internal Structure Format.pdf" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/Visual Basic/Visual Basic Image Internal Structure Format.pdf"
    
    "Malware\Languages\x86 Assembly\Important Instructions.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/x86 Assembly/Important Instructions.md"
    "Malware\Languages\x86 Assembly\x86 Assembly.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/x86 Assembly/x86 Assembly.md"
    
    "Malware\Languages\PHP.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/PHP.md"
    "Malware\Languages\Python.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Languages/Python.md"
    
    # Malware Development
    "Malware\Malware Development\Custom Function Importer.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Malware Development/Custom Function Importer.md"
    "Malware\Malware Development\Custom Shellcode Loader.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Malware Development/Custom Shellcode Loader.md"
    "Malware\Malware Development\Get Module Handle.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Malware Development/Get Module Handle.md"
    "Malware\Malware Development\Malware Development.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Malware Development/Malware Development.md"
    "Malware\Malware Development\PE Format.md" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Malware Development/PE Format.md"
    "Malware\Malware Development\02.ThreadContext\compile.bat" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Malware Development/02.ThreadContext/compile.bat"
    "Malware\Malware Development\02.ThreadContext\implant.cpp" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Malware Development/02.ThreadContext/implant.cpp"
    "Malware\Malware Development\Classic\compile.bat" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Malware Development/Classic/compile.bat"
    "Malware\Malware Development\Classic\implant.cpp" = "000-099 Computer Science, Information & General Works/004 Data Processing & Computer Science/004.9 Computer Programming/Malware Development/Classic/implant.cpp"
    
    # Low Level Programming
    "Low Level\Low Level.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/Low Level.md"
    "Low Level\Optimization.ppt" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/Optimization.ppt"
    
    # Computer Architecture
    "Low Level\Computer Architecture\Computer Anatomy.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/Computer Architecture/Computer Anatomy.md"
    "Low Level\Computer Architecture\CPU.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/Computer Architecture/CPU.md"
    "Low Level\Computer Architecture\Input and Output.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/Computer Architecture/Input and Output.md"
    "Low Level\Computer Architecture\Instruction Set.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/Computer Architecture/Instruction Set.md"
    "Low Level\Computer Architecture\Memory Address.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/Computer Architecture/Memory Address.md"
    "Low Level\Computer Architecture\Memory.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/Computer Architecture/Memory.md"
    
    # File Formats
    "Low Level\File Formats\Portable Executable (PE).md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/File Formats/Portable Executable (PE).md"
    "Low Level\File Formats\PDF\PDFReference.pdf" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/File Formats/PDF/PDFReference.pdf"
    "Low Level\File Formats\PDF\PDFReference1.7.pdf" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/File Formats/PDF/PDFReference1.7.pdf"
    
    # Offensive Security
    "Low Level\Offensive Security\Binary Exploitation.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/Offensive Security/Binary Exploitation.md"
    "Low Level\Offensive Security\Stack Exploitation.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/Offensive Security/Stack Exploitation.md"
    
    # Security Implementations
    "Low Level\Security Implementations\ASLR.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/Security Implementations/ASLR.md"
    "Low Level\Security Implementations\PIE.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.1 Programming/Low Level/Security Implementations/PIE.md"
    
    # Data Security - Main
    "Malware\Malware Analysis.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Malware Analysis.md"
    
    # Cryptography
    "Malware\Cryptography\AES.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Cryptography/AES.md"
    "Malware\Cryptography\Cryptography.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Cryptography/Cryptography.md"
    "Malware\Cryptography\Elliptic Curve.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Cryptography/Elliptic Curve.md"
    "Malware\Cryptography\RC4.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Cryptography/RC4.md"
    "Malware\Cryptography\RSA.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Cryptography/RSA.md"
    "Malware\Cryptography\Salsa and ChaCha.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Cryptography/Salsa and ChaCha.md"
    
    # Environment
    "Malware\Environment\KVM Malware Lab Guide.md" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Environment/KVM Malware Lab Guide.md"
    
    # Cheat Sheets
    "Cheat Sheets\335.pdf" = "000-099 Computer Science, Information & General Works/025 Library Operations/025.04 Information Storage & Retrieval/Cheat Sheets/335.pdf"
    
    # Cryptocurrency
    "To Organize\Cryptocurrency\Binance.md" = "300-399 Social Sciences/330 Economics/332 Financial Economics/Cryptocurrency/Binance.md"
    "To Organize\Cryptocurrency\Blockchain.md" = "300-399 Social Sciences/330 Economics/332 Financial Economics/Cryptocurrency/Blockchain.md"
    "To Organize\Cryptocurrency\Cryptocurrency.md" = "300-399 Social Sciences/330 Economics/332 Financial Economics/Cryptocurrency/Cryptocurrency.md"
    "To Organize\Cryptocurrency\Decentralized Application.md" = "300-399 Social Sciences/330 Economics/332 Financial Economics/Cryptocurrency/Decentralized Application.md"
    "To Organize\Cryptocurrency\Ethereum.md" = "300-399 Social Sciences/330 Economics/332 Financial Economics/Cryptocurrency/Ethereum.md"
    "To Organize\Cryptocurrency\Smart Contract.md" = "300-399 Social Sciences/330 Economics/332 Financial Economics/Cryptocurrency/Smart Contract.md"
    "To Organize\Cryptocurrency\Solidity.md" = "300-399 Social Sciences/330 Economics/332 Financial Economics/Cryptocurrency/Solidity.md"
    
    # Tools
    "Tools\Useful Regex.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Useful Regex.md"
    "Tools\Useful Scripts.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Useful Scripts.md"
    
    # Azure AD
    "Tools\Azure AD\Sign-In Logs.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Azure AD/Sign-In Logs.md"
    
    # Cybersec Tools
    "Tools\Cybersec Tools\LaikaBOSS.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Cybersec Tools/LaikaBOSS.md"
    "Tools\Cybersec Tools\SCOT.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Cybersec Tools/SCOT.md"
    "Tools\Cybersec Tools\Sliver.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Cybersec Tools/Sliver.md"
    "Tools\Cybersec Tools\Zeek.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Cybersec Tools/Zeek.md"
    
    # Splunk
    "Tools\Cybersec Tools\Splunk\Custom Splunk Commands.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Cybersec Tools/Splunk/Custom Splunk Commands.md"
    "Tools\Cybersec Tools\Splunk\Splunk Custom Commands.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Cybersec Tools/Splunk/Splunk Custom Commands.md"
    "Tools\Cybersec Tools\Splunk\Splunk Dashboards.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Cybersec Tools/Splunk/Splunk Dashboards.md"
    "Tools\Cybersec Tools\Splunk\Splunk.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Cybersec Tools/Splunk/Splunk.md"
    "Tools\Cybersec Tools\Splunk\Training\1. Introduction to Splunk.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Cybersec Tools/Splunk/Training/1. Introduction to Splunk.md"
    "Tools\Cybersec Tools\Splunk\Training\2. Using Fields.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Cybersec Tools/Splunk/Training/2. Using Fields.md"
    "Tools\Cybersec Tools\Splunk\Training\3. Scheduling Reports & Alerts.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Cybersec Tools/Splunk/Training/3. Scheduling Reports & Alerts.md"
    "Tools\Cybersec Tools\Splunk\Training\4. Statistical Processing.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Cybersec Tools/Splunk/Training/4. Statistical Processing.md"
    "Tools\Cybersec Tools\Splunk\Training\5. Working with Time.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Cybersec Tools/Splunk/Training/5. Working with Time.md"
    
    # Kusto Query Language
    "Tools\Kusto Query Language\Aggregate Functions.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Kusto Query Language/Aggregate Functions.md"
    
    # Utility Tools
    "Tools\Utility Tools\TMUX.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Utility Tools/TMUX.md"
    "Tools\Utility Tools\VIM.md" = "600-699 Technology & Applied Sciences/621 Applied Physics/621.39 Computer Engineering/Tools/Utility Tools/VIM.md"
    
    # Vulnerabilities
    "Vulnerabilities\ProxyX\Articles\A New Attack Surface on Microsoft Exchange - ProxyShell.pdf" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Vulnerabilities/ProxyX/Articles/A New Attack Surface on Microsoft Exchange - ProxyShell.pdf"
    "Vulnerabilities\ProxyX\Articles\ProxyShell Exploiting Microsoft Exchange Servers.pdf" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Vulnerabilities/ProxyX/Articles/ProxyShell Exploiting Microsoft Exchange Servers.pdf"
    "Vulnerabilities\ProxyX\Articles\A New Attack Surface on MSExchange\Part 1 - ProxyLogon.pdf" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Vulnerabilities/ProxyX/Articles/A New Attack Surface on MSExchange/Part 1 - ProxyLogon.pdf"
    "Vulnerabilities\ProxyX\Articles\A New Attack Surface on MSExchange\Part 2 - ProxyOracle.pdf" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Vulnerabilities/ProxyX/Articles/A New Attack Surface on MSExchange/Part 2 - ProxyOracle.pdf"
    "Vulnerabilities\ProxyX\Articles\A New Attack Surface on MSExchange\Part 3 - ProxyShell.pdf" = "000-099 Computer Science, Information & General Works/005 Computer Programming, Programs & Data/005.8 Data Security/Vulnerabilities/ProxyX/Articles/A New Attack Surface on MSExchange/Part 3 - ProxyShell.pdf"
    
    # To Organize items
    "To Organize\Tips and Tricks\Linux\Shell.md" = "000 General/025 Library Operations/To Organize/Tips and Tricks/Linux/Shell.md"
    "To Organize\Tips and Tricks\Windows\Custom Start Bar Layout.md" = "000 General/025 Library Operations/To Organize/Tips and Tricks/Windows/Custom Start Bar Layout.md"
    "To Organize\Tips and Tricks\Windows\Werfault.md" = "000 General/025 Library Operations/To Organize/Tips and Tricks/Windows/Werfault.md"
    "To Organize\Unicode\Emojis.md" = "000 General/025 Library Operations/To Organize/Unicode/Emojis.md"
    
    # OUI Lookups
    "To Organize\OUI Lookups\full.csv" = "000 General/070 News Media & Journalism/OUI Lookups/full.csv"
    "To Organize\OUI Lookups\mam.csv" = "000 General/070 News Media & Journalism/OUI Lookups/mam.csv"
    "To Organize\OUI Lookups\oui.csv" = "000 General/070 News Media & Journalism/OUI Lookups/oui.csv"
    "To Organize\OUI Lookups\oui36.csv" = "000 General/070 News Media & Journalism/OUI Lookups/oui36.csv"
}

# Add all cheat sheet files
$cheatSheetFiles = @(
    "335.pdf", "Analyzing Malicious Documents.pdf", "Android Third-Party Apps Forensics.pdf",
    "Command Line Helper.pdf", "Eric Zimmerman Tools Cheat Sheet.pdf", "Google Hacking and Defense Cheat Sheet.pdf",
    "Hex File Headers and Regex for Forensics Cheat Sheet.pdf", "Hunt Evil Poster.pdf", "iOS Third-Party Apps Forensics.pdf",
    "JSON and jq Quick Start Guide.pdf", "Linux Intrusion Discovery Cheat Sheet.pdf", "Linux Shell Survival Guide.pdf",
    "Log Lifecycle.pdf", "Malware Analysis Cheat Sheet.pdf", "Memory Forensics Analysis Poster.pdf",
    "Memory Forensics Cheat Sheet.pdf", "Netcat Cheat Sheet.pdf", "Network Forensics and Analysis Poster.pdf",
    "oledump.py Quick Reference.pdf", "Rekall Cheat Sheet.pdf", "REMNUX Usage Tips.pdf",
    "Results in Seconds at the Command Line.pdf", "SIFT and REMnux Poster.pdf", "SIFT Workstation.pdf",
    "Smartphone Forensic Analysis.pdf", "SOC Digital Poster_210915.pdf", "SQLite Pocket Reference Guide.pdf",
    "Threat Intelligence Consumption.pdf", "Tips for Reverse-Engineering Malicious Code.pdf",
    "Windows Command Line Cheat Sheet.pdf", "Windows Forensics Analysis Poster.pdf",
    "Windows Intrusion Discovery Cheat Sheet.pdf", "Windows Third Party Forensics Poster.pdf",
    "x86 Assembly Cheat Sheet.pdf"
)

foreach ($file in $cheatSheetFiles) {
    $fileMapping["Cheat Sheets\$file"] = "000-099 Computer Science, Information & General Works/025 Library Operations/025.04 Information Storage & Retrieval/Cheat Sheets/$file"
}

# Add CSOC files (keeping relative structure but moving to new location)
$csocMapping = @{
    "CSOC\csoc_splunk_app-feature-ucs_2434@64f4492f469.zip" = "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/csoc_splunk_app-feature-ucs_2434@64f4492f469.zip"
    "CSOC\PNNL Logo Guidelines.pdf" = "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/PNNL Logo Guidelines.pdf"
    "CSOC\PNNL_Brand_Colors.pdf" = "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/PNNL_Brand_Colors.pdf"
    "CSOC\POST Email Archival Processing and Flagging.pdf" = "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/POST Email Archival Processing and Flagging.pdf"
    "CSOC\Schedule.md" = "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Schedule.md"
    "CSOC\Welcome.md" = "600-699 Technology & Applied Sciences/658 General Management/658.4 Executive Management/CSOC/Welcome.md"
}

$fileMapping += $csocMapping

# Function to create directory if it doesn't exist
function New-DirectoryIfNotExists {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        if (-not $WhatIf) {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
        }
        Write-Host "Would create directory: $Path" -ForegroundColor Green
    }
}

# Function to move file
function Move-FileToNewLocation {
    param(
        [string]$SourceFile,
        [string]$DestinationFile
    )
    
    $sourceFullPath = Join-Path $SourcePath $SourceFile
    $destinationFullPath = Join-Path $SourcePath $DestinationFile
    
    if (Test-Path $sourceFullPath) {
        # Create destination directory
        $destinationDir = Split-Path $destinationFullPath -Parent
        New-DirectoryIfNotExists $destinationDir
        
        if ($WhatIf) {
            Write-Host "WOULD MOVE: $SourceFile -> $DestinationFile" -ForegroundColor Yellow
        } else {
            try {
                Move-Item -Path $sourceFullPath -Destination $destinationFullPath -Force
                Write-Host "MOVED: $SourceFile -> $DestinationFile" -ForegroundColor Green
            } catch {
                Write-Error "Failed to move $SourceFile : $($_.Exception.Message)"
            }
        }
    } else {
        Write-Warning "Source file not found: $SourceFile"
    }
}

# Create all directory structures first
Write-Host "Creating directory structure..." -ForegroundColor Cyan
foreach ($dir in $newStructure.Keys) {
    $fullPath = Join-Path $SourcePath $dir
    New-DirectoryIfNotExists $fullPath
}

# Move files according to mapping
Write-Host "Moving files..." -ForegroundColor Cyan
foreach ($mapping in $fileMapping.GetEnumerator()) {
    Move-FileToNewLocation $mapping.Key $mapping.Value
}

# Handle remaining files that need manual attention
Write-Host "Files requiring manual review:" -ForegroundColor Magenta

# Complex CSOC structures that need individual attention
$complexCSocPaths = @(
    "CSOC\Administration\2025\03\*",
    "CSOC\Administration\2025\04\*",
    "CSOC\Administration\2025\05\*",
    "CSOC\Administration\2025\06\*",
    "CSOC\Administration\2025\07\*",
    "CSOC\Administration\2025\08\*",
    "CSOC\Conferences\*",
    "CSOC\IR\*",
    "CSOC\Resources\*"
)

foreach ($path in $complexCSocPaths) {
    $fullPath = Join-Path $SourcePath $path
    if (Test-Path $fullPath) {
        Write-Host "Manual review needed: $path" -ForegroundColor Yellow
    }
}

Write-Host "Reorganization complete!" -ForegroundColor Green
Write-Host "Please review the 'To Organize' folder for any remaining items." -ForegroundColor Yellow

# Summary
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "✓ Created Dewey Decimal directory structure" -ForegroundColor Green
Write-Host "✓ Moved core files to appropriate categories" -ForegroundColor Green
Write-Host "⚠ Complex CSOC structure preserved (manual review needed)" -ForegroundColor Yellow
Write-Host "⚠ Some files may require manual categorization" -ForegroundColor Yellow
Write-Host "`nNext steps:" -ForegroundColor White
Write-Host "1. Review moved files in new locations" -ForegroundColor White
Write-Host "2. Handle complex CSOC folder structure manually" -ForegroundColor White
Write-Host "3. Update any internal note links" -ForegroundColor White
Write-Host "4. Test dataview scripts with new paths" -ForegroundColor White