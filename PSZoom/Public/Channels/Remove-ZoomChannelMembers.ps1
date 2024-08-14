<#
.SYNOPSIS
Removes members from a channel under your account.
.DESCRIPTION
Removes members from a channel under your account.
Prerequisite: Pro, Business, or Education account
.PARAMETER ChannelIds
List of channel IDs to remove members from.
.PARAMETER Owner
Email or ID of channel owner
.PARAMETER MemberIds
List of Member's Emails or Ids to remove from Channel.
.OUTPUTS
The Zoom response (an object).
.LINK
https://developers.zoom.us/docs/api-reference/chat/methods/#operation/removeAChannelMember
.EXAMPLE
Remove single user from single channel.

Remove-ZoomChannelMember -ChannelIds '111111aaaaa333333cccc444444444ff' -Owner 'okenobi@lighside.com' -MemberIds 'lskywalker@lightside.com'
                                  
.EXAMPLE
Remove mulitple users from multiple channels.

$channels = @('111111aaaaa333333cccc444444444ff', '222222bbbbb555555dddd666666666ee')
$members = @('lskywalker@lightside.com', 'askywalker@theforce.com')
Remove-ZoomChannelMember -ChannelIds $channels -Owner 'okenobi@lighside.com' -MemberIds $members
#>

function Remove-ZoomChannelMembers {
  [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
  param (
    # List of channel IDs to remove members from.
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 0
    )]
    [Alias('channel_id', 'channel', 'channels', 'id', 'channelid')]
    [string[]]
    $ChannelIds,
    
    # Email of channel owner
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 1
    )]
    [Alias('channelowner', 'owneremail')]
    [string]
    $Owner,
    
    # List of Member's Ids or Emails to remove from Channel
    [Parameter(
      Mandatory = $true,  
      ValueFromPipelineByPropertyName = $true,
      Position = 2
    )]
    [Alias('memberid', 'memberemail')]
    [string[]]
    $MemberIds
  )
  process {
    foreach ($channelId in $ChannelIds){
      foreach ($memberId in $MemberIds){
        $request = [System.UriBuilder]"https://api.zoom.us/v2/chat/users/$owner/channels/$channelId/members/$memberId"

        if ($PSCmdlet.ShouldProcess($member, 'Remove')){
          Write-Verbose "Removing $member from $channel."
          $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method DELETE

          Write-Output $response
        }
      }
    }
  }
}
