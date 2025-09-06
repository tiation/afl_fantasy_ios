# TradesAPI

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**calculateTradeScore**](TradesAPI.md#calculatetradescore) | **POST** /api/trade_score | Calculate trade score


# **calculateTradeScore**
```swift
    open class func calculateTradeScore(tradeScoreRequest: TradeScoreRequest, completion: @escaping (_ data: TradeScoreResponse?, _ error: Error?) -> Void)
```

Calculate trade score

Calculate a trade score and recommendation for swapping one player for another. Uses advanced algorithms considering form, price, fixtures, and ownership. 

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let tradeScoreRequest = TradeScoreRequest(playerInId: 123, playerOutId: 123, budget: 123, currentTeam: [123]) // TradeScoreRequest | Trade analysis parameters

// Calculate trade score
TradesAPI.calculateTradeScore(tradeScoreRequest: tradeScoreRequest) { (response, error) in
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
 **tradeScoreRequest** | [**TradeScoreRequest**](TradeScoreRequest.md) | Trade analysis parameters | 

### Return type

[**TradeScoreResponse**](TradeScoreResponse.md)

### Authorization

[ApiKeyAuth](../README.md#ApiKeyAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

