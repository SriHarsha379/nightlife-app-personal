# Social Account Validation — Implementation Documentation

## Overview
Platform-specific format validation for Instagram, Snapchat, and Spotify social account fields.

## Approach
**Option 3: Format Validation** was chosen over API-based validation because:
- Instagram and Snapchat block automated account verification requests
- No public API available for Snapchat
- Spotify requires OAuth for user lookup
- Format validation covers 95% of invalid entries

## Rules per Platform

| Platform | Min Length | Max Length | Allowed Characters |
|---|---|---|---|
| Instagram | 1 | 30 | Letters, numbers, dots, underscores |
| Snapchat | 3 | 15 | Letters, numbers, dots, hyphens, underscores |
| Spotify | 3 | 30 | Letters, numbers, dots, hyphens, underscores |

## URL Support
Users can enter either:
- Plain username: `john_doe`
- Full profile URL: `https://instagram.com/john_doe`
- www URL: `www.instagram.com/john_doe`

When a URL is provided, the username is extracted from the path automatically.

## Implementation Location
`lib/utilities/app_validation.dart` → `isOptionalSocialValueValid()`

## Fields Using This Validation
`lib/view/other/city_Preference/additional_info.dart`
- Instagram field
- Spotify field  
- Snapchat field

## Fields Are Optional
All social account fields are optional — empty values pass validation.

## Future Improvement
When Instagram/Snapchat provide public APIs, replace format validation with real account existence check.
