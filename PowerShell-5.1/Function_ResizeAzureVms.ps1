function Resize-AzVMRoH {
    <#
    .Synopsis
        Resize given azure vm to specified size.

    .DESCRIPTION
        Resizes the specified azure vm to the given size.

    .EXAMPLE
        Resize the specified vm to the given size. 

        Resize-AzVMRoH -ResourceGroupName ExampleGroup -VMName ExampleVM -TargetSKU ExampleSKU

    .EXAMPLE
        Resize the specified vm to the given size. 

        Get-AzVM -ResourceGroupName ExampleGroup -VMName ExampleVM | Resize-AzVMRoH -TargetSKU ExampleSKU

    .NOTES
        Written and tested in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    
    [CmdletBinding(DefaultParameterSetName='ResizeAzureVm', 
                   SupportsShouldProcess=$true)]

    param(
        [Parameter(
        ParameterSetName='ResizeAzureVm',
        Position=0,
        ValueFromPipelineByPropertyName,
        HelpMessage='Resource group name.')]
        [String]$ResourceGroupName,

        [Parameter(
        ParameterSetName='ResizeAzureVm',
        Position=0,
        ValueFromPipelineByPropertyName,
        HelpMessage='VM name.')]
        [Alias('Name')]
        [String]$VMName,

        [Parameter(
        ParameterSetName='ResizeAzureVm',
        Position=0,
        HelpMessage='Target SKU.')]
        [String]$TargetSKU
    )
    
    begin {
        
    }
    
    process {
        # Get vm infos.
        $VM = Get-AzVM -ResourceGroupName $ResourceGroupName -VMName $VMName
        # Set to new sku.
        $VM.HardwareProfile.VmSize = $TargetSKU
        # Update new sku.
        $VM | Update-AzVM -Verbose
    }
    
    end {
        
    }
}

function Get-AzVMSizeRoH {
    <#
    .Synopsis
        Get sku size of specified azure vm.

    .DESCRIPTION
        Get the sku size of the specified azure vm.

        This function can use pipeline input.

    .EXAMPLE
        Get the sku size of the specified machine.

        (Get-AzVM)[0] | Get-AzVMSizeRoH

        Output:

        VmSize          VmSizeProperties
        ------          ----------------
        Standard_D2s_v3

    .NOTES
        Written and tested in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    
    [CmdletBinding(DefaultParameterSetName='GetAZVMSize')]

    param(
        [Parameter(
        ParameterSetName='GetAZVMSize',
        Position=0,
        ValueFromPipelineByPropertyName,
        HelpMessage='Resource group name.')]
        [String]$ResourceGroupName,

        [Parameter(
        ParameterSetName='GetAZVMSize',
        Position=0,
        ValueFromPipelineByPropertyName,
        HelpMessage='VM name.')]
        [Alias('Name')]
        [String]$VMName
    )

    begin {
        
    }
    
    process {
        $VM = Get-AzVM -ResourceGroupName $ResourceGroupName -VMName $VMName
        $VM.HardwareProfile
    }
    
    end {
        
    }
}