
#https://developers.zoom.us/docs/api-reference/chat/methods/#operation/listChannelMembers

function Get-ZoomChannelMembers {
  [CmdletBinding()]
  param (
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 0,
      ParameterSetName = 'FullApiResponse'
    )]
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 0,
      ParameterSetName = 'All'
    )]
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 0,
      ParameterSetName = 'Default'
    )]
    [Alias('channel_id', 'channel', 'id')]
    [string[]]
    $ChannelId,
    
    # Email or ID of channel owner
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 1,
      ParameterSetName = 'FullApiResponse'
    )]
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 1,
      ParameterSetName = 'All'
    )]
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 1,
      ParameterSetName = 'Default'
    )]
    [Alias('channel_owner', 'owneremail')]
    [string]
    $Owner, 

    # Number of records returned with a single API Call. Default is 30. Maximum value is 100.
    [Parameter(
      ParameterSetName = 'FullApiResponse'
    )]
    [Parameter(
      ParameterSetName = 'All'
    )]
    [Parameter(
      ParameterSetName = 'Default'
    )]
    [ValidateRange(1, 100)]
    [int]
    $PageSize = 30,

    # TToken to return next page of results when greater than PageSize as returned from this function..
    [Parameter(
      ParameterSetName = 'FullApiResponse'
    )]
    [Parameter(
      ParameterSetName = 'All'
    )]
    [Parameter(
      ParameterSetName = 'Default'
    )]
    [string]
    $NextPageToken = "",

    # This will return the default Zoom API response.
    [Parameter(
      ParameterSetName = 'FullApiResponse',
      Mandatory = $true
    )]
    [switch]
    $FullApiResponse,

    # This will return All Channel Members.
    [Parameter(
      ParameterSetName = 'All',
      Mandatory = $true
    )]
    [switch]
    $All
  )
  
  process {
    if ($All) { $PageSize = 100 }
    $request = [System.UriBuilder]"https://api.zoom.us/v2/chat/users/$Owner/channels/$ChannelId/members"
    $query = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
    $query.Add('page_size', $PageSize)
    $query.Add('next_page_token', $NextPageToken)

    $request.Query = $query.ToString()
    $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

    if ($FullApiResponse) {
      Write-Output $response
    }
    elseif ($All) {
      $allMembers = $response.members

      While ($response.next_page_token -ne "") {
        $response = Get-ZoomChannelMembers -ChannelId $ChannelId -Owner $Owner -NextPageToken $response.next_page_token -PageSize 100 -FullApiResponse
        $allMembers += $response.members
      }
      
      Write-Output $allMembers
    }
    else {
      Write-Output $response.members
    }
  }
}
