<#
.SYNOPSIS
Add members to a channel under your account.
.DESCRIPTION
Add members to a channel under your account.
Prerequisite: Pro, Business, or Education account
Limited to adding 20 users to a channel with a single API Call.
.PARAMETER ChannelIds
List of channel IDs to add members to.
.PARAMETER Owner
Email or ID of channel owner
.PARAMETER MemberEmail
List of Member's Email to add to Channel.
.OUTPUTS
The Zoom response (an object). Example:
ids                    added_at
---                    --------
tKODqjp0S456QzjjcNQqVg 2019-08-28T22:39:51Z
.LINK
https://developers.zoom.us/docs/api-reference/chat/methods/#operation/inviteChannelMembers
.EXAMPLE
Add single user to single channel.

Add-ZoomChannelMember -ChannelIds '111111aaaaa333333cccc444444444ff' -Owner 'okenobi@lighside.com' -MemberEmails 'lskywalker@lightside.com'
                                  
.EXAMPLE
Add mulitple users to multiple channel.

$channels = @('111111aaaaa333333cccc444444444ff', '222222bbbbb555555dddd666666666ee')
$members = @('lskywalker@lightside.com', 'askywalker@theforce.com')
Add-ZoomChannelMember -ChannelIds $channels -Owner 'okenobi@lighside.com' -MemberEmails $members
#>

function Add-ZoomChannelMembers {
  [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
  param (
    # List of channel IDs to add members to.
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 0
    )]
    [Alias('channel_id', 'channel', 'channels', 'id', 'channelid')]
    [string[]]
    $ChannelIds,
    
    # Email or ID of channel owner
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 1
    )]
    [Alias('channelowner', 'owneremail')]
    [string]
    $Owner,
    
    # List of Member's Email to add to Channel
    [Parameter(
      Mandatory = $true,  
      ValueFromPipelineByPropertyName = $true,
      Position = 2
    )]
    [Alias('email', 'emails', 'emailaddress', 'emailaddresses', 'memberemail')]
    [string[]]
    $MemberEmails,

    [switch]$Passthru
  )
    
  process {
    $requestBody = @{}

    $members = New-Object System.Collections.Generic.List[System.Object]

    $MemberEmails.ForEach({$members.Add(@{email = $_})})

    if ($members.Count -gt 20) {
      throw 'Maximum amount of members that can be added at a time is 20.' #This limit is set by Zoom.
    }
    
    $requestBody.Add('members', $members)
    $requestBody = $requestBody | ConvertTo-Json

    foreach ($id in $ChannelIds){
      $request = [System.UriBuilder]"https://api.zoom.us/v2/chat/users/$Owner/channels/$id/members"
      if ($PSCmdlet.ShouldProcess($members, 'Add')) {
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST

        if (-not $Passthru) {
          Write-Output $response
        }
      }
    }
    
    if ($Passthru) {
      Write-Output $ChannelIds
    }
  }
}
