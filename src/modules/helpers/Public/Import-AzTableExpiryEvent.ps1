function Import-AzTableExpiryEvent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object]$CloudTable,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PartitionKey,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object]$Data
    )
    process {
        $ErrorActionPreference = 'Stop'
        Import-Module 'AzTable' -Force
        $tableInsertSplat = @{
            Table = $CloudTable
            PartitionKey = $PartitionKey
            RowKey = '{0}-{1}-{2}-{3}' -f $Data.topic.split('/')[2], $Data.data.VaultName, $Data.data.ObjectType, $Data.data.ObjectName
            Property = @{
                'id' = '{0}' -f $Data.id
                'topic' = $Data.topic
                'subject' = $Data.subject
                'eventType' = $Data.eventType
                'eventTime' = $Data.eventTime
                'VaultName' = $Data.data.VaultName
                'ObjectType' = $Data.data.ObjectType
                'ObjectName' = $Data.data.ObjectName
                'Version' = $Data.data.Version
                'EXP' = $Data.data.EXP
            }
            UpdateExisting = $true
        }
        [void](Add-AzTableRow @tableInsertSplat)
        Write-Verbose ('Successfully imported expiry event into the Azure Table.') -Verbose
    }
}