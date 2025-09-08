# PlayersAPI

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getPlayerById**](PlayersAPI.md#getplayerbyid) | **GET** /v1/players/{playerId} | Get single player
[**getPlayers**](PlayersAPI.md#getplayers) | **GET** /v1/players | List all players


# **getPlayerById**
```swift
    open class func getPlayerById(playerId: Int, completion: @escaping (_ data: SinglePlayerResponse?, _ error: Error?) -> Void)
```

Get single player

Get detailed information for a specific player including statistics, fixtures, injury status, and form data. 

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let playerId = 987 // Int | Unique identifier for the player

// Get single player
PlayersAPI.getPlayerById(playerId: playerId) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **playerId** | **Int** | Unique identifier for the player | 

### Return type

[**SinglePlayerResponse**](SinglePlayerResponse.md)

### Authorization

[ApiKeyAuth](../README.md#ApiKeyAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlayers**
```swift
    open class func getPlayers(position: Position_getPlayers? = nil, season: Int? = nil, limit: Int? = nil, offset: Int? = nil, completion: @escaping (_ data: PlayersResponse?, _ error: Error?) -> Void)
```

List all players

Get a list of all AFL Fantasy players with optional filtering by position and season. Returns player statistics including price, average score, ownership percentage. 

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let position = "position_example" // String | Filter players by position (DEF, MID, RUC, FWD) (optional)
let season = 987 // Int | Season year to filter by (optional)
let limit = 987 // Int | Maximum number of players to return (optional) (default to 100)
let offset = 987 // Int | Number of players to skip for pagination (optional) (default to 0)

// List all players
PlayersAPI.getPlayers(position: position, season: season, limit: limit, offset: offset) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **position** | **String** | Filter players by position (DEF, MID, RUC, FWD) | [optional] 
 **season** | **Int** | Season year to filter by | [optional] 
 **limit** | **Int** | Maximum number of players to return | [optional] [default to 100]
 **offset** | **Int** | Number of players to skip for pagination | [optional] [default to 0]

### Return type

[**PlayersResponse**](PlayersResponse.md)

### Authorization

[ApiKeyAuth](../README.md#ApiKeyAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

